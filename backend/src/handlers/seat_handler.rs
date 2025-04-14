use actix_web::{
    web::{self, Json, Path},
    HttpResponse, Responder, Error
};
use sqlx::MySqlPool;

use crate::models::seat::{CreateSeat, Seat, SeatCategory, SeatType};

use super::utils::QueryParams;

pub async fn create_seat(
    pool: web::Data<MySqlPool>,
    payload: Json<CreateSeat>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        INSERT INTO seat (seat_no, seat_type, coach_id, seat_category)
        VALUES (?, ?, ?, ?)
        "#,
        payload.seat_no,
        &payload.seat_type as &SeatType,
        payload.coach_id,
        &payload.seat_category as &SeatCategory,
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => Ok(HttpResponse::Created().finish()),
        Err(err) => {
            eprintln!("Error creating seat: {:?}", err);
            Ok(HttpResponse::InternalServerError().finish())
        }
    }
}

pub async fn get_seats_by_coach(
    pool: web::Data<MySqlPool>,
    coach_id: Path<i64>,
    query: web::Query<QueryParams>
) -> Result<impl Responder, Error> {

    let coach_id = coach_id.into_inner();

    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    let seats = sqlx::query_as!(
        Seat,
        r#"
        SELECT seat_id, seat_no, seat_type, coach_id, seat_category
        FROM seat
        WHERE coach_id = ?
        LIMIT ? OFFSET ?
        "#,
        coach_id,
        limit,
        offset
    )
    .fetch_all(pool.get_ref())
    .await;

    let total_seats_res: Result<i64, sqlx::Error> = sqlx::query_scalar(
        r#"
        SELECT COUNT(*) 
        FROM seat
        WHERE coach_id = ?
        "#,
    )
    .bind(coach_id)
    .fetch_one(pool.get_ref())
    .await;

    match (seats, total_seats_res) {
        (Ok(seats), Ok(total_seats)) => {
            Ok(HttpResponse::Ok().json(serde_json::json!({
                "data": seats,
                "page": page,
                "limit": limit,
                "offset": offset,
                "total": total_seats,  // Total seats count
            })))
        },
        (Err(e), _) | (_, Err(e)) => {
            eprintln!("Error fetching seats: {:?}", e);
            Ok(HttpResponse::InternalServerError().finish())
        }
    }
}
