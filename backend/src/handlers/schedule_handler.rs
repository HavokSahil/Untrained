use actix_web::{web, Error, HttpResponse, Responder};
use sqlx::MySqlPool;
use crate::models::schedule::{CreateSchedule, Schedule, ScheduleJourney, UpdateSchedule};

// POST /schedule
pub async fn create_schedule(
    pool: web::Data<MySqlPool>,
    payload: web::Json<CreateSchedule>
) -> Result<impl Responder, Error> {
    let res = sqlx::query!(
        r#"
        CALL insert_schedule_and_shift(
            ?, ?, ?, ?, ?, ?
        );
        "#,
        payload.journey_id,
        payload.station_id,
        payload.sched_toa,
        payload.sched_tod,
        payload.stop_number,
        payload.route_id
    )
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(result) => Ok(HttpResponse::Created().json({
            serde_json::json!({
                "message": "Schedule created successfully",
                "rows_affected": result.rows_affected()
            })
        })),
        Err(e) => {
            eprintln!("Error creating schedule: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to create schedule",
                    "details": e.to_string()
                })
            }))
        }
    }
}

// GET /schedules/journey/{journey_id}
pub async fn get_schedule_by_journey(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>
) -> Result<impl Responder, Error> {
    let journey_id = path.into_inner();

    let result = sqlx::query_as!(
        ScheduleJourney,
        r#"
        SELECT 
            s.sched_id, 
            s.station_id, 
            s.sched_toa, 
            s.sched_tod,
            s.journey_id, 
            s.stop_number, 
            s.route_id,
            st.station_name,
            CASE 
                WHEN s.stop_number = 0 THEN 0
                ELSE (
                    SELECT 
                        dm_next.distance - dm_curr.distance
                    FROM 
                        schedule s_next
                    JOIN distance_map dm_next 
                        ON dm_next.station_id = s_next.station_id 
                        AND dm_next.route_id = s.route_id
                    JOIN distance_map dm_curr 
                        ON dm_curr.station_id = s.station_id 
                        AND dm_curr.route_id = s.route_id
                    WHERE 
                        s_next.journey_id = s.journey_id 
                        AND s_next.stop_number = s.stop_number + 1
                        AND dm_next.distance IS NOT NULL
                        AND dm_curr.distance IS NOT NULL
                    LIMIT 1
                )
            END AS distance
        FROM 
            schedule s
        JOIN 
            station st ON st.station_id = s.station_id
        WHERE 
            s.journey_id = ?
        ORDER BY 
            s.stop_number ASC
        "#,

        journey_id
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(data) => Ok(HttpResponse::Ok().json(data)),
        Err(e) => {
            eprintln!("Error fetching schedule for journey {}: {:?}", journey_id, e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch schedule for journey",
                    "details": e.to_string()
                })
            }))
        }
    }
}



// GET /schedules
pub async fn get_all_schedules(
    pool: web::Data<MySqlPool>
) -> Result<impl Responder, Error> {
    let result = sqlx::query_as!(
        Schedule,
        r#"SELECT sched_id, station_id, sched_toa, sched_tod,
        journey_id, stop_number, route_id,
        (SELECT station_name FROM station WHERE station_id = schedule.station_id) AS station_name
        FROM schedule"#,
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(data) => Ok(HttpResponse::Ok().json(data)),
        Err(e) => {
            eprintln!("Error fetching schedules: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch schedules",
                    "details": e.to_string()
                })
            }))
        }
    }
}

// GET /schedules/{id}
pub async fn get_schedule_by_id(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>
) -> Result<impl Responder, Error> {
    let id = path.into_inner();

    let result = sqlx::query_as!(
        Schedule,
        r#"SELECT sched_id, station_id, sched_toa, sched_tod,
        journey_id, stop_number, route_id,
        (SELECT station_name FROM station WHERE station_id = schedule.station_id) AS station_name
        FROM schedule WHERE sched_id = ?"#,
        id
    )
    .fetch_optional(pool.get_ref())
    .await;

    match result {
        Ok(Some(data)) => Ok(HttpResponse::Ok().json(data)),
        Ok(None) => Ok(HttpResponse::NotFound().finish()),
        Err(e) => {
            eprintln!("Error fetching schedule: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to fetch schedule",
                    "details": e.to_string()
                })
            }))
        }
    }
}

// PUT /schedules/{id}
pub async fn update_schedule(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>,
    payload: web::Json<UpdateSchedule>
) -> Result<impl Responder, Error> {
    let id = path.into_inner();

    let result = sqlx::query!(
        r#"
        UPDATE schedule
        SET sched_toa = COALESCE(?, sched_toa),
            sched_tod = COALESCE(?, sched_tod),
            stop_number = COALESCE(?, stop_number),
            route_id = COALESCE(?, route_id)
        WHERE sched_id = ?
        "#,
        payload.sched_toa,
        payload.sched_tod,
        payload.stop_number,
        payload.route_id,
        id
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(data) => Ok(HttpResponse::Ok().json({
            serde_json::json!({
                "message": "Schedule updated successfully",
                "rows_affected": data.rows_affected()
            })
        })),
        Err(e) => {
            eprintln!("Error updating schedule: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to update schedule",
                    "details": e.to_string()
                })
            }))
        }
    }
}

// DELETE /schedules/{id}
pub async fn delete_schedule(
    pool: web::Data<MySqlPool>,
    path: web::Path<i64>
) -> Result<impl Responder, Error> {
    let id = path.into_inner();

    let result = sqlx::query!(
        "DELETE FROM schedule WHERE sched_id = ?",
        id
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(r) => {
            if r.rows_affected() > 0 {
                Ok(HttpResponse::Ok().json({
                    serde_json::json!({
                        "message": "Schedule deleted",
                        "rows_affected": r.rows_affected()
                    })
                }))
            } else {
                Ok(HttpResponse::NotFound().finish())
            }
        }
        Err(e) => {
            eprintln!("Error deleting schedule: {:?}", e);
            Ok(HttpResponse::InternalServerError().json({
                serde_json::json!({
                    "error": "Failed to delete schedule",
                    "details": e.to_string()
                })
            }))
        }
    }
}