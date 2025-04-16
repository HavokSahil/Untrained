use actix_web::{web, HttpResponse, Responder, Error};
use sqlx::mysql::MySqlPool;

use crate::models::passenger::PnrStatusResponse;

pub async fn get_pnr_status(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let pnr = path.into_inner();

    let result = sqlx::query_as!(
        PnrStatusResponse,
        r#"
        SELECT 
            t.train_name AS train_name,
            ss.station_name AS start_station,
            es.station_name AS end_station,
            c.coach_name AS coach_name,
            s.seat_no AS seat_no,
            s.seat_type AS seat_type,
            b.booking_status AS booking_status,
            DATE_FORMAT(j.start_time, '%Y-%m-%d %H:%i') AS start_time,
            DATE_FORMAT(j.end_time, '%Y-%m-%d %H:%i') AS end_time
        FROM booking b
        JOIN journey j ON b.journey_id = j.journey_id
        JOIN station ss ON j.start_station_id = ss.station_id
        JOIN station es ON j.end_station_id = es.station_id
        JOIN train t ON j.train_id = t.train_id
        JOIN seat s ON b.seat_id = s.seat_id
        JOIN coach c ON s.coach_id = c.coach_id
        WHERE b.pnr = ?
        "#,
        pnr
    )
    .fetch_optional(pool.get_ref())
    .await;

    match result {
        Ok(Some(status)) => Ok(HttpResponse::Ok().json(status)),
        Ok(None) => Ok(HttpResponse::NotFound().json(serde_json::json!({
            "error": "PNR not found"
        }))),
        Err(e) => {
            eprintln!("Database error fetching PNR: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch PNR status",
                "details": e.to_string()
            })))
        }
    }
}