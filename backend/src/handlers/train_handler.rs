// handlers/train_handlers.rs
use actix_web::{web, HttpResponse, Responder};
use serde::de::value::Error;
use sqlx::{MySqlPool, Row};
use crate::models::train::{Train, TrainDetailedResponse, TrainResponse, TrainType};

use super::utils::QueryParams;

pub async fn get_train_by_id(
    pool: web::Data<MySqlPool>,
    train_no: web::Path<i64>
) -> Result<impl Responder, Error> {

    let train_no = train_no.into_inner();

    let result = sqlx::query_as!(
        TrainResponse,
        "SELECT train_id as train_no, train_name, train_type
        FROM train
        WHERE train_id = ?",
        train_no
    )
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(train) => Ok(HttpResponse::Ok().json(train)),
        Err(e) => {
            eprintln!("Error fetching train: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch train",
                    "details": e.to_string(),
                })
            }))
        }
    }
}

// POST /create_train
pub async fn create_train(
    pool: web::Data<MySqlPool>,
    payload: web::Json<Train>
) -> impl Responder {
    let res = sqlx::query!(
        r#"
        INSERT INTO train(train_id, train_name, train_type)
        VALUES(?, ?, ?);
        "#,
        payload.train_no,
        payload.train_name,
        payload.train_type as TrainType
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(res) => {
            HttpResponse::Created().json({
                serde_json::json!({
                    "message": "Train created successfully",
                    "train_no": payload.train_no,
                    "train_name": payload.train_name,
                    "train_type": payload.train_type,
                    "rows_affected": res.rows_affected(),
                })
            })
        },
        Err(e) => {
            eprintln!("Error inserting train: {:?}", e);
            HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to create train",
                    "details": e.to_string(),
                })
            })
        }
    }
}

// GET /get_trains

pub async fn get_trains(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    let train_no = query.train_no.unwrap_or(0);
    let train_name = query.train_name.clone().unwrap_or_default();
    let train_type = query.train_type.clone().unwrap_or_default();

    let sort = match query.sort.as_deref() {
        Some("train_id") => "train_id",
        Some("train_name") => "train_name",
        Some("train_type") => "train_type",
        _ => "train_id",
    };

    // ---- Build base filter SQL ----
    let mut filter_sql = String::from(" WHERE 1=1 ");
    if train_no > 0 {
        filter_sql.push_str(" AND train_id LIKE ?");
    }
    if !train_name.is_empty() {
        filter_sql.push_str(" AND train_name LIKE ?");
    }
    if !train_type.is_empty() {
        filter_sql.push_str(" AND train_type = ?");
    }

    // ---- Total count query ----
    let total_sql = format!("SELECT COUNT(*) as count FROM train {}", filter_sql);
    let mut total_query = sqlx::query_scalar::<_, i64>(&total_sql); // i64 is safest for COUNT(*)

    if train_no > 0 {
        total_query = total_query.bind(format!("%{}%", train_no));
    }
    if !train_name.is_empty() {
        total_query = total_query.bind(format!("%{}%", train_name));
    }
    if !train_type.is_empty() {
        total_query = total_query.bind(train_type.clone());
    }

    let total: i64 = match total_query.fetch_one(pool.get_ref()).await {
        Ok(count) => count,
        Err(e) => {
            eprintln!("Error fetching count: {:?}", e);
            return Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch total count",
                "details": e.to_string()
            })));
        }
    };

    // ---- Final data query with pagination ----
    let data_sql = format!(
        "SELECT train_id as train_no, train_name, train_type FROM train {} ORDER BY {} LIMIT ? OFFSET ?",
        filter_sql, sort
    );
    let mut data_query = sqlx::query_as::<_, TrainResponse>(&data_sql);

    if train_no > 0 {
        data_query = data_query.bind(format!("%{}%", train_no));
    }
    if !train_name.is_empty() {
        data_query = data_query.bind(format!("%{}%", train_name));
    }
    if !train_type.is_empty() {
        data_query = data_query.bind(train_type);
    }

    data_query = data_query.bind(limit).bind(offset);

    // ---- Fetch paginated result ----
    match data_query.fetch_all(pool.get_ref()).await {
        Ok(trains) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "data": trains,
            "page": page,
            "limit": limit,
            "offset": offset,
            "total": total
        }))),
        Err(e) => {
            eprintln!("Error fetching trains: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Something went wrong",
                "details": e.to_string()
            })))
        }
    }
}


// GET /get_trains_detailed
pub async fn get_trains_detailed(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {
    
    let page = query.page.unwrap_or(1);
    let limit = query.limit.unwrap_or(10);
    let offset = (page - 1) * limit;

    let train_no = query.train_no.unwrap_or(0);

    let train_name = query.train_name.clone()
        .filter(|s| !s.trim().is_empty());

    let train_type = query.train_type.clone()
        .filter(|s| !s.trim().is_empty() && s.to_uppercase() != "ALL");

    let train_name_sql = match &train_name {
        Some(name) => format!("'{}'", name.replace("'", "''")),
        None => "null".to_string(),
    };

    let train_type_sql = match &train_type {
        Some(t) => format!("'{}'", t.replace("'", "''")),
        None => "null".to_string(),
    };

    let sql_data = format!(
        "CALL get_all_trains_detailed({}, {}, {}, {}, {}, {})",
        train_no, train_name_sql, train_type_sql, page, limit, offset
    );

    let sql_count = format!(
        "CALL get_trains_count({}, {}, {})",
        train_no, train_name_sql, train_type_sql
    );

    // Manual mapping from rows
    let trains_res = sqlx::query(&sql_data)
        .fetch_all(pool.get_ref())
        .await
        .map(|rows| {
            rows.into_iter()
                .map(|row| TrainDetailedResponse {
                    train_no: row.get::<i64, _>(0),
                    train_name: row.get::<String, _>(1),
                    train_type: row.get::<String, _>(2),
                    coaches: row.get::<i64, _>(3),
                    seats: row.get::<i64, _>(4),
                    journeys: row.get::<i64, _>(5),
                    upcoming_journeys: row.get::<i64, _>(6),
                })
                .collect::<Vec<_>>()
        });

    let total_res = sqlx::query(&sql_count)
        .fetch_one(pool.get_ref())
        .await
        .map(|row| row.get::<i64, _>(0));

    match (trains_res, total_res) {
        (Ok(trains), Ok(total)) => Ok(HttpResponse::Ok().json({
            serde_json::json!({
                "data": trains,
                "page": page,
                "limit": limit,
                "offset": offset,
                "total": total
            })
        })),
        (Err(e), _) | (_, Err(e)) => {
            eprintln!("Error executing raw SQL: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch train data",
                "details": e.to_string()
            })))
        }
    }
}
