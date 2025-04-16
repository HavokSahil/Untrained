use actix_web::{web, Error, HttpResponse, Responder, Result};
use sqlx::MySqlPool;

use crate::models::seat::SeatCount;

pub async fn get_cnf_seat_count_by_coach_category(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let results = sqlx::query_as!(
        SeatCount,
        r#"
        SELECT
            c.coach_type AS reservation_category,
            COUNT(rs.reservation_status) AS seat_count
        FROM (
            SELECT 'SL' AS coach_type
            UNION ALL SELECT 'AC3'
            UNION ALL SELECT 'AC2'
            UNION ALL SELECT 'AC1'
            UNION ALL SELECT 'CC'
            UNION ALL SELECT 'FC'
            UNION ALL SELECT '2S'
        ) c
        LEFT JOIN coach ch ON ch.coach_type = c.coach_type
        LEFT JOIN seat s ON s.coach_id = ch.coach_id
        LEFT JOIN booking b ON b.seat_id = s.seat_id AND b.journey_id = ?
        LEFT JOIN reservation_status rs ON rs.pnr = b.pnr AND rs.reservation_status = 'CNF'
        GROUP BY c.coach_type
        ORDER BY c.coach_type
        "#,
        *journey_id
    )
    .fetch_all(pool.get_ref())
    .await;

    match results {
        Ok(counts) => Ok(HttpResponse::Ok().json(counts)),
        Err(e) => {
            eprintln!("Error fetching CNF seat count: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch CNF seat count",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn get_rac_seat_count_by_coach_category(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let results = sqlx::query_as!(
        SeatCount,
        r#"
        SELECT
            c.coach_type AS reservation_category,
            COUNT(rs.reservation_status) AS seat_count
        FROM (
            SELECT 'SL' AS coach_type
            UNION ALL SELECT 'AC3'
            UNION ALL SELECT 'AC2'
            UNION ALL SELECT 'AC1'
            UNION ALL SELECT 'CC'
            UNION ALL SELECT 'FC'
            UNION ALL SELECT '2S'
        ) c
        LEFT JOIN coach ch ON ch.coach_type = c.coach_type
        LEFT JOIN seat s ON s.coach_id = ch.coach_id
        LEFT JOIN booking b ON b.seat_id = s.seat_id AND b.journey_id = ?
        LEFT JOIN reservation_status rs ON rs.pnr = b.pnr AND rs.reservation_status = 'RAC'
        GROUP BY c.coach_type
        ORDER BY c.coach_type
        "#,
        *journey_id
    )
    .fetch_all(pool.get_ref())
    .await;

    match results {
        Ok(counts) => Ok(HttpResponse::Ok().json(counts)),
        Err(e) => {
            eprintln!("Error fetching RAC seat count: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch RAC seat count",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn get_wl_seat_count_by_coach_category(
    pool: web::Data<MySqlPool>,
    journey_id: web::Path<i64>,
) -> Result<impl Responder, Error> {
    let results = sqlx::query_as!(
        SeatCount,
        r#"
        SELECT
            c.coach_type AS reservation_category,
            COUNT(rs.reservation_status) AS seat_count
        FROM (
            SELECT 'SL' AS coach_type
            UNION ALL SELECT 'AC3'
            UNION ALL SELECT 'AC2'
            UNION ALL SELECT 'AC1'
            UNION ALL SELECT 'CC'
            UNION ALL SELECT 'FC'
            UNION ALL SELECT '2S'
        ) c
        LEFT JOIN coach ch ON ch.coach_type = c.coach_type
        LEFT JOIN seat s ON s.coach_id = ch.coach_id
        LEFT JOIN booking b ON b.seat_id = s.seat_id AND b.journey_id = ?
        LEFT JOIN reservation_status rs ON rs.pnr = b.pnr AND rs.reservation_status = 'WL'
        GROUP BY c.coach_type
        ORDER BY c.coach_type
        "#,
        *journey_id
    )
    .fetch_all(pool.get_ref())
    .await;

    match results {
        Ok(counts) => Ok(HttpResponse::Ok().json(counts)),
        Err(e) => {
            eprintln!("Error fetching WL seat count: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch WL seat count",
                "details": e.to_string()
            })))
        }
    }
}
