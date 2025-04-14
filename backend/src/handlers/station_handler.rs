use actix_web::{web, HttpResponse, Responder, Error};
use sqlx::{mysql::MySqlArguments, Arguments, MySqlPool};

use crate::models::station::{CreateStation, StationResponse};

use super::utils::QueryParams;

// POST /api/station/add
pub async fn create_station(
    pool: web::Data<MySqlPool>,
    station: web::Json<CreateStation>,
) -> Result<impl Responder, Error> {

    let res = sqlx::query!(
        "INSERT INTO station (station_name, station_type) VALUES (?, ?)",
        &station.station_name,
        &station.station_type
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(_) => Ok(HttpResponse::Created().finish()),
        Err(e) => {
            eprintln!("Error creating station: {:?}", e);
            Ok(HttpResponse::InternalServerError().body("Failed to create station"))
        }
    }
}

pub async fn get_all_stations(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> impl Responder {
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    let mut conditions = Vec::new();
    let mut args = MySqlArguments::default();

    if let Some(station_id) = query.station_id {
        conditions.push("station_id = ?");
        args.add(station_id);
    }

    if let Some(name) = &query.station_name {
        conditions.push("station_name LIKE ?");
        args.add(format!("%{}%", name));
    }

    if let Some(station_type) = &query.station_type {
        conditions.push("station_type = ?");
        args.add(station_type);
    }

    let mut base_query = String::from("SELECT station_id, station_name, station_type FROM station");

    if !conditions.is_empty() {
        base_query.push_str(" WHERE ");
        base_query.push_str(&conditions.join(" AND "));
    }

    // Count query
    let mut count_query = String::from("SELECT COUNT(*) FROM station");
    if !conditions.is_empty() {
        count_query.push_str(" WHERE ");
        count_query.push_str(&conditions.join(" AND "));
    }

    // Add pagination
    base_query.push_str(" LIMIT ? OFFSET ?");
    args.add(limit);
    args.add(offset);

    // Execute both queries
    let stations = sqlx::query_as_with::<_, StationResponse, _>(&base_query, args.clone())
        .fetch_all(pool.get_ref())
        .await;

    let total = sqlx::query_scalar_with::<_, i64, _>(&count_query, args)
        .fetch_one(pool.get_ref())
        .await;

    match (stations, total) {
        (Ok(stations), Ok(total)) => {
            let response = serde_json::json!({
                "total": total,
                "offset": offset,
                "page": page,
                "limit": limit,
                "data": stations
            });
            HttpResponse::Ok().json(response)
        }
        (Err(e), _) | (_, Err(e)) => {
            eprintln!("Error fetching stations: {:?}", e);
            HttpResponse::InternalServerError().body("Failed to fetch stations")
        }
    }
}