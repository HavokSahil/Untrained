use actix_web::{web, Error, HttpResponse, Responder, Result};
use chrono::Utc;
use sqlx::MySqlPool;

use crate::models::{booking::{BookingDetail, GroupBookingRequest}, seat::SeatCount, transaction::CancelBookingRequest};

use super::utils::QueryParams;

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
        ) AS c
        LEFT JOIN (
            SELECT rs.reservation_category, rs.reservation_status
            FROM reservation_status rs
            JOIN booking b ON rs.pnr = b.pnr
            WHERE b.journey_id = ? AND rs.reservation_status = 'CNF'
            AND b.booking_status IN ('CONFIRMED', 'PENDING')
        ) AS rs ON rs.reservation_category = c.coach_type
        GROUP BY c.coach_type
        ORDER BY c.coach_type;
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
        ) AS c
        LEFT JOIN (
            SELECT rs.reservation_category, rs.reservation_status
            FROM reservation_status rs
            JOIN booking b ON rs.pnr = b.pnr
            WHERE b.journey_id = ? AND rs.reservation_status = 'RAC'
            AND b.booking_status IN ('CONFIRMED', 'PENDING')
        ) AS rs ON rs.reservation_category = c.coach_type
        GROUP BY c.coach_type
        ORDER BY c.coach_type;
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
        ) AS c
        LEFT JOIN (
            SELECT rs.reservation_category, rs.reservation_status
            FROM reservation_status rs
            JOIN booking b ON rs.pnr = b.pnr
            WHERE b.journey_id = ? AND rs.reservation_status = 'WL'
            AND b.booking_status IN ('CONFIRMED', 'PENDING')
        ) AS rs ON rs.reservation_category = c.coach_type
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

pub async fn create_group_booking_handler(
    pool: web::Data<MySqlPool>,
    booking: web::Json<GroupBookingRequest>,
) -> Result<impl Responder, actix_web::Error> {
    let result = sqlx::query!(
        r#"
        CALL create_group_booking(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        "#,
        booking.group_size,
        booking.passenger_data.to_string(), // serialize JSON
        booking.journey_id,
        booking.train_id,
        booking.start_station_id,
        booking.end_station_id,
        booking.mode,
        booking.txn_id,
        booking.email,
        booking.reservation_category,
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => {
            // You could also query back for bookings based on txn_id if needed
            Ok(HttpResponse::Created().json(serde_json::json!({
                "message": "Group booking created successfully",
                "txn_id": booking.txn_id
            })))
        },
        Err(e) => {
            eprintln!("Error in group booking: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Group booking failed",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn get_booking_details_by_email(
    pool: web::Data<MySqlPool>,
    query: web::Query<QueryParams>,
) -> Result<impl Responder, Error> {

    let email = &query.email;

    let bookings = sqlx::query_as!(
        BookingDetail,
        r#"
        SELECT
            p.pnr,
            p.pass_name,
            p.age,
            p.sex,
            p.disability,
            b.booking_id,
            b.booking_time,
            b.booking_status,
            b.amount,
            pt.txn_id,
            pt.payment_mode,
            pt.txn_status,
            rs.reservation_status,
            rs.reservation_category,
            s.seat_no,
            s.seat_type,
            s.seat_category,
            c.coach_name,
            c.coach_type,
            t.train_name,
            t.train_type,
            j.journey_id,
            -- Get the start time based on start station from the schedule table
            ss.sched_toa AS start_time,
            -- Get the end time based on end station from the schedule table
            es.sched_tod AS end_time,
            st1.station_name AS start_station,
            st2.station_name AS end_station
        FROM passenger p
        JOIN booking b ON p.pnr = b.pnr
        LEFT JOIN payment_transaction pt ON b.txn_id = pt.txn_id
        LEFT JOIN reservation_status rs ON p.pnr = rs.pnr
        LEFT JOIN seat s ON b.seat_id = s.seat_id
        LEFT JOIN coach c ON s.coach_id = c.coach_id
        -- Correctly joining train table via the journey table
        LEFT JOIN journey j ON b.journey_id = j.journey_id
        LEFT JOIN train t ON j.train_id = t.train_id
        LEFT JOIN station st1 ON b.start_station_id = st1.station_id
        LEFT JOIN station st2 ON b.end_station_id = st2.station_id
        -- Join schedule table to fetch start and end time based on station and journey
        LEFT JOIN schedule ss ON ss.journey_id = j.journey_id AND ss.station_id = b.start_station_id
        LEFT JOIN schedule es ON es.journey_id = j.journey_id AND es.station_id = b.end_station_id
        WHERE p.email = ?
        ORDER BY b.booking_time DESC;
        "#,
        email
    )
    .fetch_all(pool.get_ref())
    .await
    .map_err(|e| {
        eprintln!("Error fetching booking details: {}", e);
        actix_web::error::ErrorInternalServerError("Could not retrieve booking details")
    })?;

    Ok(HttpResponse::Ok().json(bookings))
}

pub async fn cancel_booking_handler(
    pool: web::Data<MySqlPool>,
    request: web::Json<CancelBookingRequest>,
) -> Result<impl Responder, Error> {
    let booking_id = request.booking_id;
    let refund_amount = request.refund_amount;
    let txn_id = request.txn_id;

    // Cancel time
    let cancel_time = Utc::now().naive_utc();

    let mut tx = pool.begin().await.map_err(|e| {
        eprintln!("Transaction begin failed: {:?}", e);
        actix_web::error::ErrorInternalServerError("Transaction begin failed")
    })?;

    // Step 1: Update booking status
    let update_result = sqlx::query!(
        r#"
        UPDATE booking
        SET booking_status = 'CANCELLED'
        WHERE booking_id = ?
        "#,
        booking_id
    )
    .execute(&mut *tx)
    .await;

    if let Err(e) = update_result {
        eprintln!("Failed to update booking: {:?}", e);
        return Ok(HttpResponse::InternalServerError().json(serde_json::json!({
            "error": "Failed to update booking status",
            "details": e.to_string()
        })));
    }

    // Step 2: Insert into cancellation_record
    let insert_result = sqlx::query!(
        r#"
        INSERT INTO cancellation_record (booking_id, cancel_time, refund_amount, cancel_status, txn_id)
        VALUES (?, ?, ?, 'COMPLETED', ?)
        "#,
        booking_id,
        cancel_time,
        refund_amount,
        txn_id
    )
    .execute(&mut *tx)
    .await;

    if let Err(e) = insert_result {
        eprintln!("Failed to insert cancellation record: {:?}", e);
        return Ok(HttpResponse::InternalServerError().json(serde_json::json!({
            "error": "Failed to insert cancellation record",
            "details": e.to_string()
        })));
    }

    // Commit transaction
    if let Err(e) = tx.commit().await {
        eprintln!("Transaction commit failed: {:?}", e);
        return Ok(HttpResponse::InternalServerError().json(serde_json::json!({
            "error": "Transaction commit failed",
            "details": e.to_string()
        })));
    }

    Ok(HttpResponse::Ok().json(serde_json::json!({
        "message": "Booking cancelled successfully",
        "booking_id": booking_id
    })))
}