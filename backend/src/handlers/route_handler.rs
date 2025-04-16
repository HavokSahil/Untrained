use actix_web::{web, Error, HttpResponse, Responder};
use sqlx::MySqlPool;
use serde_json::json;
use crate::models::{route::{AddIntermediateStation, CreateRoute, RelativeStation, RouteDetailResponse, RouteResponse, RouteStation}, schedule::RoutesBetweenStations};
use crate::handlers::utils::QueryParams;

pub async fn get_routes(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl actix_web::Responder, Error> {
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    // ----------------------------------
    // DYNAMICALLY BUILD RAW SQL FILTERS
    // ----------------------------------
    let mut where_clauses = vec![];

    if let Some(route_name) = &query.route_name {
        where_clauses.push(format!("r.route_name LIKE '%{}%'", route_name));
    }

    if let Some(route_id) = query.route_id {
        where_clauses.push(format!("r.route_id = {}", route_id));
    }

    if let Some(route_station) = &query.route_station {
        where_clauses.push(format!("r.source_station_id LIKE '%{}%'", route_station));
    }

    let where_sql = if !where_clauses.is_empty() {
        format!("WHERE {}", where_clauses.join(" AND "))
    } else {
        String::new()
    };

    // ------------------
    // COUNT TOTAL RECORDS
    // ------------------
    let count_sql = format!("SELECT COUNT(*) as total FROM route r {}", where_sql);

    let total: i64 = sqlx::query_scalar(&count_sql)
        .fetch_one(pool.get_ref())
        .await
        .map_err(|err| {
            eprintln!("Count query failed: {}", err);
            actix_web::error::ErrorInternalServerError("Failed to count routes")
        })?;

    // ---------------------
    // FETCH ROUTES DATA WITH JOIN + AGGREGATE
    // ---------------------
    let data_sql = format!(
        "
        SELECT
            r.route_id,
            r.route_name,
            r.source_station_id,
            (SELECT station_name FROM station s WHERE s.station_id = r.source_station_id) AS source_station_name,
            COUNT(dm.station_id) AS num_stations,
            COALESCE(MAX(dm.distance), 0) AS total_distance
        FROM route r
        LEFT JOIN distance_map dm ON r.route_id = dm.route_id
        {}
        GROUP BY r.route_id
        ORDER BY r.route_id
        LIMIT {} OFFSET {}
        ",
        where_sql, limit, offset
    );

    println!("Data SQL: {}", data_sql);

    let routes: Vec<RouteResponse> = sqlx::query_as::<_, RouteResponse>(&data_sql)
        .fetch_all(pool.get_ref())
        .await
        .map_err(|err| {
            eprintln!("Select query failed: {}", err);
            actix_web::error::ErrorInternalServerError("Failed to fetch routes")
        })?;

    // ---------------------
    // FINAL RESPONSE
    // ---------------------
    Ok(HttpResponse::Ok().json(json!({
        "data": routes,
        "page": page,
        "limit": limit,
        "offset": offset,
        "total": total
    })))
}

pub async fn create_route(
    pool: web::Data<MySqlPool>,
    route: web::Json<CreateRoute>,
) -> Result<impl Responder, Error> {
    let mut tx = pool.begin().await.map_err(|err| {
        eprintln!("Failed to start transaction: {}", err);
        actix_web::error::ErrorInternalServerError("Transaction start failed")
    })?;

    // Step 1: Insert into route table
    let insert_route_result = sqlx::query!(
        "INSERT INTO route (route_name, source_station_id)
         VALUES (?, ?)",
        route.route_name,
        route.source_station_id,
    )
    .execute(&mut *tx)
    .await;

    let route_id = match insert_route_result {
        Ok(res) => res.last_insert_id() as i64,
        Err(err) => {
            eprintln!("Failed to insert route: {}", err);
            return Ok(HttpResponse::InternalServerError().json(json!({
                "error": "Failed to insert route"
            })));
        }
    };

    // Step 2: Insert source station into distance_map
    let insert_source = sqlx::query!(
        "INSERT INTO distance_map (route_id, station_id, distance)
         VALUES (?, ?, ?)",
        route_id,
        route.source_station_id,
        0
    )
    .execute(&mut *tx)
    .await;

    if let Err(err) = insert_source {
        eprintln!("Failed to insert source into distance_map: {}", err);
        tx.rollback().await.ok();
        return Ok(HttpResponse::InternalServerError().json(json!({
            "error": "Failed to insert source station distance"
        })));
    }

    // Commit transaction
    if let Err(err) = tx.commit().await {
        eprintln!("Transaction commit failed: {}", err);
        return Ok(HttpResponse::InternalServerError().json(json!({
            "error": "Failed to commit transaction"
        })));
    }

    Ok(HttpResponse::Created().json(json!({
        "message": "Route created successfully",
        "route_id": route_id
    })))
}

pub async fn add_intermediate_station(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>, // route_id
    station: web::Json<AddIntermediateStation>,
) -> Result<impl Responder, Error> {
    let route_id = path.into_inner();

    let result = sqlx::query!(
        "INSERT INTO distance_map (route_id, station_id, distance)
         VALUES (?, ?, ?)",
        route_id,
        station.station_id,
        station.distance
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => Ok(HttpResponse::Created().json(json!({
            "message": "Intermediate station added successfully"
        }))),
        Err(err) => {
            eprintln!("Database error while inserting intermediate station: {}", err);
            Ok(HttpResponse::InternalServerError().json(json!({
                "error": "Failed to add intermediate station"
            })))
        }
    }
}


pub async fn get_route_stations(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let route_id = path.into_inner();

    // 1. Get route metadata
    let route = sqlx::query!(
        r#"SELECT r.route_id, r.route_name, r.source_station_id,
        (SELECT station_name FROM station s WHERE s.station_id = r.source_station_id) AS source_station_name
        FROM route r WHERE route_id = ?"#,
        route_id
    )
    .fetch_one(pool.get_ref())
    .await
    .map_err(|err| {
        eprintln!("Failed to fetch route: {}", err);
        actix_web::error::ErrorInternalServerError("Failed to fetch route")
    })?;

    // 2. Get station details for this route
    let stations: Vec<RouteStation> = sqlx::query_as!(
        RouteStation,
        r#"SELECT route_id, station_id, (SELECT station_name FROM station s WHERE s.station_id = dm.station_id) AS source_station_name,
        distance FROM distance_map dm
        WHERE route_id = ?
        ORDER BY distance"#,
        route_id
    )
    .fetch_all(pool.get_ref())
    .await
    .map_err(|err| {
        eprintln!("Failed to fetch stations: {}", err);
        actix_web::error::ErrorInternalServerError("Failed to fetch stations")
    })?;

    // 3. Calculate total distance (max of all distances)
    let total_distance = stations
    .iter()
    .map(|s| s.distance.unwrap_or(0.0))
    .fold(0.0, f32::max);

    let response = RouteDetailResponse {
        route_id: route.route_id,
        route_name: route.route_name,
        source_station_id: route.source_station_id,
        source_station_name: route.source_station_name,
        total_stations: stations.len(),
        total_distance,
        stations,
    };

    Ok(HttpResponse::Ok().json(response))
}


pub async fn get_routes_between_stations(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    let Some(source_station_id) = query.source_station_id else {
        return Ok(HttpResponse::BadRequest().body("Missing source_station_id"));
    };

    let Some(destination_station_id) = query.destination_station_id else {
        return Ok(HttpResponse::BadRequest().body("Missing destination_station_id"));
    };

    let routes: Vec<RoutesBetweenStations> = sqlx::query_as!(
        RoutesBetweenStations,
        r#"SELECT 
            r.route_id,
            r.route_name,
            s1.station_id AS source_station_id,
            s2.station_id AS destination_station_id,
            ABS(s2.distance - s1.distance) AS distance
        FROM 
            route r
        JOIN 
            distance_map s1 ON r.route_id = s1.route_id
        JOIN 
            distance_map s2 ON r.route_id = s2.route_id
        WHERE 
            s1.station_id = ? AND 
            s2.station_id = ?"#,
        source_station_id,
        destination_station_id
    )
    .fetch_all(pool.get_ref())
    .await
    .map_err(|err| {
        eprintln!("Failed to fetch routes: {}", err);
        actix_web::error::ErrorInternalServerError("Failed to fetch routes")
    })?;

    // Always return valid JSON (even if empty)
    Ok(HttpResponse::Ok().json(routes))
}


pub async fn get_relative_stations(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    let route_id = query.route_id;
    let reference_station_id = query.station_id;
    
    let stations: Vec<RelativeStation> = sqlx::query_as!(
        RelativeStation,
        r#"
        SELECT
            dm2.station_id AS station_id,
            (SELECT station_name FROM station s WHERE s.station_id = dm2.station_id) AS station_name,
            (dm2.distance - dm1.distance) AS distance_from_given_station
        FROM 
            distance_map dm1
        JOIN 
            distance_map dm2 ON dm1.route_id = dm2.route_id
        WHERE 
            dm1.route_id = ? AND dm1.station_id = ?
            AND dm2.station_id != dm1.station_id
        ORDER BY 
            distance_from_given_station
        "#,
        route_id,
        reference_station_id
    )
    .fetch_all(pool.get_ref())
    .await
    .map_err(|err| {
        eprintln!("Database query error: {}", err);
        actix_web::error::ErrorInternalServerError("Failed to fetch station distances")
    })?;

    Ok(HttpResponse::Ok().json(stations))
}
