use actix_web::{web, Error, HttpResponse, Responder, Result};
use sqlx::MySqlPool;
use crate::models::coach::{CoachResponse, CreateCoach};

use super::utils::QueryParams;

pub async fn get_coaches_for_train(
    pool: web::Data<MySqlPool>,
    train_id: web::Path<i64>,  // Path parameter for train_id
    query: web::Query<QueryParams>, // Query parameters for pagination
) -> Result<impl Responder, Error> {

    let train_id = train_id.into_inner();

    // Extract page and limit from the query parameters or use defaults
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    // Fetch coaches for the specified train_id with pagination
    let coaches = sqlx::query_as!(
        CoachResponse,
        r#"
        SELECT coach_id, coach_name, coach_type, fare, train_id, (SELECT COUNT(*) FROM seat WHERE seat.coach_id = coach.coach_id) AS total_seats
        FROM coach
        WHERE train_id = ?
        LIMIT ? OFFSET ?
        "#,
        train_id,
        limit,
        offset
    )
    .fetch_all(pool.get_ref())
    .await;

    // Fetch total count of coaches for the given train_id
    let total_coaches_res: Result<i64, sqlx::Error> = sqlx::query_scalar(
        r#"
        SELECT COUNT(*) 
        FROM coach
        WHERE train_id = ?
        "#,
    )
    .bind(train_id)
    .fetch_one(pool.get_ref())
    .await;

    match (coaches, total_coaches_res) {
        (Ok(coaches) ,Ok(total_coaches)) => {
            // Return the paginated list of coaches and total count
            Ok(HttpResponse::Ok().json(serde_json::json!({
                "data": coaches,
                "page": page,
                "limit": limit,
                "offset": offset,
                "total": total_coaches,  // Total coaches count
            })))
        },
        (Err(e), _) | (_, Err(e)) => {
            eprintln!("Error fetching coaches: {:?}", e);
            // Return an internal server error response
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch coaches",
                    "details": e.to_string(),
                })
            }))
        }
    }
}


pub async fn create_coach(
    pool: web::Data<MySqlPool>,
    new_coach: web::Json<CreateCoach>,
) -> Result<impl Responder, Error> {

    let new_coach = new_coach.into_inner();

    // Insert the new coach into the database
    let result = sqlx::query!(
        r#"
        INSERT INTO coach (coach_name, coach_type, fare, train_id)
        VALUES (?, ?, ?, ?)
        "#,
        new_coach.coach_name,
        new_coach.coach_type,
        new_coach.fare,
        new_coach.train_id
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => Ok(HttpResponse::Created().finish()),
        Err(e) => {
            eprintln!("Error creating coach: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to create coach",
                "details": e.to_string()
            })))
        }
    }
}

// Fetch the fare for a specific coach
pub async fn get_coach_price(
    pool: web::Data<MySqlPool>,
    coach_id: web::Path<i64>,
) -> Result<impl Responder, Error> {

    let coach_id = coach_id.into_inner();

    // Fetch the fare for the specified coach_id
    let fare = sqlx::query_scalar!(
        r#"
        SELECT fare 
        FROM coach
        WHERE coach_id = ?
        "#,
        coach_id
    )
    .fetch_one(pool.get_ref())
    .await;

    match fare {
        Ok(fare) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "fare": fare,
        }))),
        Err(e) => {
            eprintln!("Error fetching fare: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch fare",
                "details": e.to_string()
            })))
        }
    }
}