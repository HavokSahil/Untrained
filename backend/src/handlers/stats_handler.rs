use actix_web::{web, Error, HttpResponse, Responder};
use sqlx::MySqlPool;

pub async fn total_number_of_journeys(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query_scalar!(
        r#"
        SELECT COUNT(*) 
        FROM journey
        "#
    )
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(total_journeys) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "total_journeys": total_journeys
        }))),
        Err(e) => {
            eprintln!("Error fetching total number of journeys: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch total number of journeys",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn busiest_route(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT r.route_name, COUNT(b.booking_id) AS total_bookings
        FROM booking b
        JOIN journey j ON b.journey_id = j.journey_id
        JOIN route r ON j.start_station_id = r.source_station_id
        GROUP BY r.route_name
        ORDER BY total_bookings DESC
        LIMIT 1
        "#
    )
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(row) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "route_name": row.route_name,
            "total_bookings": row.total_bookings
        }))),
        Err(e) => {
            eprintln!("Error fetching busiest route: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch busiest route",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn total_passengers_traveling(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT j.journey_id, COUNT(b.booking_id) AS total_passengers
        FROM booking b
        JOIN journey j ON b.journey_id = j.journey_id
        GROUP BY j.journey_id
        ORDER BY total_passengers DESC
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(passengers) => Ok(HttpResponse::Ok().json(passengers.into_iter().map(|row| {
            serde_json::json!({
                "journey_id": row.journey_id,
                "total_passengers": row.total_passengers
            })
        }).collect::<Vec<_>>())),
        Err(e) => {
            eprintln!("Error fetching total passengers traveling: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch total passengers traveling",
                "details": e.to_string()
            })))
        }
    }
}
pub async fn gender_distribution(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT sex, COUNT(*) AS total_passengers
        FROM passenger
        GROUP BY sex
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(gender_stats) => {
            let response: Vec<_> = gender_stats
                .into_iter()
                .map(|row| {
                    serde_json::json!({
                        "sex": row.sex,
                        "total_passengers": row.total_passengers
                    })
                })
                .collect();

            Ok(HttpResponse::Ok().json(response))
        }
        Err(e) => {
            eprintln!("Error fetching gender distribution: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch gender distribution",
                "details": e.to_string()
            })))
        }
    }
}


pub async fn busiest_station(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT s.station_name, COUNT(b.booking_id) AS total_bookings
        FROM booking b
        JOIN station s ON b.start_station_id = s.station_id
        GROUP BY s.station_name
        ORDER BY total_bookings DESC
        LIMIT 1
        "#
    )
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(row) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "station_name": row.station_name,
            "total_bookings": row.total_bookings
        }))),
        Err(e) => {
            eprintln!("Error fetching busiest station: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch busiest station",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn rank_running_trains_by_bookings(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT t.train_name, COUNT(b.booking_id) AS total_bookings
        FROM running r
        JOIN journey j ON r.journey_id = j.journey_id
        JOIN train t ON j.train_id = t.train_id
        JOIN booking b ON b.journey_id = j.journey_id
        GROUP BY t.train_name
        ORDER BY total_bookings DESC
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(trains) => Ok(HttpResponse::Ok().json(trains.into_iter().map(|row| {
            serde_json::json!({
                "train_name": row.train_name,
                "total_bookings": row.total_bookings
            })
        }).collect::<Vec<_>>())),
        Err(e) => {
            eprintln!("Error ranking running trains: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to rank running trains",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn busiest_time_period(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT EXTRACT(HOUR FROM booking_time) AS hour_of_day, COUNT(booking_id) AS total_bookings
        FROM booking
        GROUP BY hour_of_day
        ORDER BY total_bookings DESC
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(time_periods) => Ok(HttpResponse::Ok().json(time_periods.into_iter().map(|row| {
            serde_json::json!({
                "hour_of_day": row.hour_of_day,
                "total_bookings": row.total_bookings
            })
        }).collect::<Vec<_>>())),
        Err(e) => {
            eprintln!("Error fetching busiest time period: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch busiest time period",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn reservation_status_distribution(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let result = sqlx::query!(
        r#"
        SELECT reservation_status, COUNT(reservation_id) AS total_reservations
        FROM reservation_status
        GROUP BY reservation_status
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(status_distribution) => Ok(HttpResponse::Ok().json(status_distribution.into_iter().map(|row| {
            serde_json::json!({
                "reservation_status": row.reservation_status,
                "total_reservations": row.total_reservations
            })
        }).collect::<Vec<_>>())),
        Err(e) => {
            eprintln!("Error fetching reservation status distribution: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch reservation status distribution",
                "details": e.to_string()
            })))
        }
    }
}
