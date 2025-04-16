use actix_web::{web, Error, HttpResponse, Responder, Result};
use chrono::NaiveDate;
use sqlx::MySqlPool;

use crate::models::journey::{CreateJourney, JourneyBetweenStations, JourneyDetailedResponse, JourneyResponse, UpdateJourney};

use super::utils::QueryParams;

pub async fn create_journey(
    pool: web::Data<MySqlPool>,
    new_journey: web::Json<CreateJourney>,
) -> Result<impl Responder, Error> {
    
    let journey = new_journey.into_inner();

    let res = sqlx::query!(
        r#"
        INSERT INTO journey (start_time, end_time, train_id, start_station_id, end_station_id)
        VALUES (?, ?, ?, ?, ?)
        "#,
        journey.start_time,
        journey.end_time,
        journey.train_id,
        journey.start_station_id,
        journey.end_station_id
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(_) => Ok(HttpResponse::Created().finish()),
        Err(e) => {
            eprintln!("Error creating journey: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to create journey",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn get_all_journeys(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    let journey_id = query.journey_id.unwrap_or(0);
    let train_no = query.train_no.unwrap_or(0);
    let start_station_name = query.start_station_name.clone().unwrap_or_default();
    let end_station_name = query.end_station_name.clone().unwrap_or_default();

    let mut query_str = r#"
    SELECT J.journey_id AS journey_id, J.start_time AS start_time, J.end_time AS end_time, J.train_id AS train_id,
    J.start_station_id AS start_station_id, J.end_station_id AS end_station_id,
    S1.station_name AS start_station_name, S2.station_name AS end_station_name
    FROM journey J
    JOIN station S1 ON S1.station_id = J.start_station_id
    JOIN station S2 ON S2.station_id = J.end_station_id
    "#.to_string();

    // Add WHERE clause for filtering based on parameters
    let mut where_clauses = Vec::new();
    
    if journey_id != 0 {
        where_clauses.push("J.journey_id = ?");
    }
    if train_no != 0 {
        where_clauses.push("J.train_id = ?");
    }
    if !start_station_name.is_empty() {
        where_clauses.push("S1.station_name LIKE ?");
    }
    if !end_station_name.is_empty() {
        where_clauses.push("S2.station_name LIKE ?");
    }

    // Add WHERE clauses if any filter is applied
    if !where_clauses.is_empty() {
        query_str.push_str(" WHERE ");
        query_str.push_str(&where_clauses.join(" AND "));
    }

    // Add LIMIT and OFFSET for pagination
    query_str.push_str(" LIMIT ? OFFSET ?");

    // Execute the query to fetch journeys
    let mut query = sqlx::query_as(&query_str);

    // Bind parameters
    if journey_id != 0 {
        query = query.bind(journey_id);
    }
    if train_no != 0 {
        query = query.bind(train_no);
        println!("Train No: {}", train_no);
    }
    if !start_station_name.is_empty() {
        let like_start = format!("%{}%", start_station_name); // Add wildcards for LIKE
        query = query.bind(like_start);
    }
    if !end_station_name.is_empty() {
        let like_end = format!("%{}%", end_station_name); // Add wildcards for LIKE
        query = query.bind(like_end);
    }

    query = query.bind(limit as i64).bind(offset as i64);

    let journeys: Result<Vec<JourneyDetailedResponse>, sqlx::Error> = query.fetch_all(pool.get_ref()).await;

    // Base query for total count
    let mut total_count_query = r#"
    SELECT COUNT(*) as count
    FROM journey J
    JOIN station S1 ON S1.station_id = J.start_station_id
    JOIN station S2 ON S2.station_id = J.end_station_id
    "#.to_string();

    // Add WHERE clause for filtering based on parameters
    if !where_clauses.is_empty() {
        total_count_query.push_str(" WHERE ");
        total_count_query.push_str(&where_clauses.join(" AND "));
    }

    // Execute the query to fetch the total count
    let mut total_count_query = sqlx::query_scalar(&total_count_query);
    if journey_id != 0 {
        total_count_query = total_count_query.bind(journey_id);
    }
    if train_no != 0 {
        total_count_query = total_count_query.bind(train_no);
    }
    if !start_station_name.is_empty() {
        total_count_query = total_count_query.bind(format!("%{}%", start_station_name));
    }
    if !end_station_name.is_empty() {
        total_count_query = total_count_query.bind(format!("%{}%", end_station_name));
    }

    let total_count: Result<i64, sqlx::Error> = total_count_query.fetch_one(pool.get_ref()).await;

    match (journeys, total_count) {
        (Ok(journeys), Ok(total)) => Ok(HttpResponse::Ok().json({
            serde_json::json!({
                "data": journeys,
                "offset": offset,
                "page": page,
                "limit": limit,
                "total": total,
            })
        })),
        (Err(e), _) | (_, Err(e)) => {
            eprintln!("Error fetching journeys: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch journeys",
                "details": e.to_string()
            })))
        }
    }
}




pub async fn get_journeys_by_train(
    pool: web::Data<MySqlPool>,
    train_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let res = sqlx::query_as!(
        JourneyResponse,
        r#"
        SELECT journey_id, start_time, end_time, train_id, start_station_id, end_station_id
        FROM journey
        WHERE train_id = ?
        "#,
        *train_id
    )
    .fetch_all(pool.get_ref())
    .await;

    match res {
        Ok(journeys) => Ok(HttpResponse::Ok().json(journeys)),
        Err(e) => {
            eprintln!("Error fetching journeys for train: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch journeys for train",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn update_journey(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
    update: web::Json<UpdateJourney>,
) -> Result<impl Responder, Error> {
    let update = update.into_inner();

    let res = sqlx::query!(
        r#"
        UPDATE journey
        SET
            start_time = COALESCE(?, start_time),
            end_time = COALESCE(?, end_time),
            start_station_id = COALESCE(?, start_station_id),
            end_station_id = COALESCE(?, end_station_id)
        WHERE journey_id = ?
        "#,
        update.start_time,
        update.end_time,
        update.start_station_id,
        update.end_station_id,
        *journey_id
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(_) => Ok(HttpResponse::Ok().finish()),
        Err(e) => {
            eprintln!("Error updating journey: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to update journey",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn delete_journey(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let res = sqlx::query!(
        r#"DELETE FROM journey WHERE journey_id = ?"#,
        *journey_id
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(_) => Ok(HttpResponse::Ok().finish()),
        Err(e) => {
            eprintln!("Error deleting journey: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to delete journey",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn get_journey_by_id(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let res = sqlx::query_as!(
        JourneyResponse,
        r#"
        SELECT journey_id, start_time, end_time, train_id, start_station_id, end_station_id
        FROM journey
        WHERE journey_id = ?
        "#,
        *journey_id
    )
    .fetch_optional(pool.get_ref())
    .await;

    match res {
        Ok(Some(journey)) => Ok(HttpResponse::Ok().json(journey)),
        Ok(None) => Ok(HttpResponse::NotFound().json(serde_json::json!({ "error": "Journey not found" }))),
        Err(e) => {
            eprintln!("Error fetching journey: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch journey",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn get_journey_by_stations(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    let start_station_id = query.source_station_id.unwrap_or(0);
    let end_station_id = query.destination_station_id.unwrap_or(0);
    let date_of_journey = query.journey_date.unwrap_or_else(|| NaiveDate::from_ymd_opt(1970, 1, 1).unwrap());

    // Early return if invalid station IDs or date
    if start_station_id == 0 || end_station_id == 0 {
        return Ok(HttpResponse::BadRequest().body("Missing or invalid station IDs"));
    }

    let result = sqlx::query_as!(
        JourneyBetweenStations,
        r#"
        SELECT
            j.journey_id,
            t.train_id,
            t.train_name,
            s1.station_id AS start_station_id,
            sched_start.sched_id AS start_schedule_id,
            s1.station_name AS start_station,
            s2.station_id AS end_station_id,
            sched_end.sched_id AS end_schedule_id,
            s2.station_name AS end_station,
            sched_start.sched_toa AS start_time,
            sched_end.sched_toa AS end_time,
            sched_start.stop_number AS start_stop_number,
            sched_end.stop_number AS end_stop_number,
            TIME_TO_SEC(TIMEDIFF(sched_end.sched_toa, sched_start.sched_toa)) AS travel_time
        FROM
            journey j
        JOIN
            train t ON j.train_id = t.train_id
        JOIN
            (
                SELECT
                    sched_id,
                    journey_id,
                    station_id,
                    sched_toa,
                    sched_tod,
                    stop_number
                FROM
                    schedule
                WHERE
                    station_id = ?
                    AND DATE(sched_toa) = ?
            ) sched_start ON j.journey_id = sched_start.journey_id
        JOIN
            (
                SELECT
                    sched_id,
                    journey_id,
                    station_id,
                    sched_toa,
                    sched_tod,
                    stop_number
                FROM
                    schedule
                WHERE
                    station_id = ?
            ) sched_end ON j.journey_id = sched_end.journey_id
        JOIN
            station s1 ON sched_start.station_id = s1.station_id
        JOIN
            station s2 ON sched_end.station_id = s2.station_id
        WHERE
            sched_start.stop_number < sched_end.stop_number
        "#,
        &start_station_id,
        date_of_journey,
        &end_station_id,
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(journeys) => Ok(HttpResponse::Ok().json({
            serde_json::json!({
                "page": 1,
                "data": journeys,
                "offset": 0,
                "total": journeys.len(),
                "limit": journeys.len(),
            })
        })),
        Err(e) => {
            eprintln!("Database query error: {:?}", e);
            Ok(HttpResponse::InternalServerError().body("Error fetching journeys"))
        }
    }
}
