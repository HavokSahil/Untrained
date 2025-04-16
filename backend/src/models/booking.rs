// models/booking.rs

use serde::{Deserialize, Serialize};
use sqlx::prelude::{FromRow, Type};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize, Type, Clone, Copy, PartialEq, Eq)]
#[sqlx(type_name = "CHAR(3)")]
#[serde(rename_all = "UPPERCASE")]
pub enum BookingStatus {
    WAT,    // Waiting
    RAC,    // Reservation Against Cancellation
    PND,    // Pending
    CNF,    // Confirmed
    CNC,    // Cancelled
}

#[derive(Serialize, Deserialize)]
pub struct CreateBooking {
    pub pnr: i64,
    pub journey_id: i64,
    pub start_station_id: i64,
    pub end_station_id: i64,
    pub price: f32,
    pub txn_id: String,
    pub sid: i64
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Booking {
    pub booking_id: i64,
    pub booking_time: DateTime<Utc>,
    pub booking_status: BookingStatus,
    pub pnr: i64,
    pub journey_id: i64,
    pub start_station_id: i64,
    pub end_station_id: i64,
    pub price: f32,
    pub txn_id: i64,
    pub sid: i64,
}

#[derive(Deserialize)]
pub struct GroupBookingRequest {
    pub group_size: i32,
    pub passenger_data: serde_json::Value, // raw JSON array of passengers
    pub journey_id: i64,
    pub train_id: i64,
    pub start_station_id: i64,
    pub end_station_id: i64,
    pub mode: String,
    pub txn_id: i64,
    pub email: String,
    pub reservation_category: String, // e.g. "SL", "AC3", etc.
}

#[derive(Debug, Serialize)]
pub struct BookingDetail {
    pub pnr: i64,
    pub pass_name: Option<String>,
    pub age: Option<i32>,
    pub sex: Option<String>,
    pub disability: Option<i8>,
    pub booking_id: Option<i64>,
    pub booking_time: Option<chrono::DateTime<Utc>>,
    pub booking_status: Option<String>,
    pub amount: Option<f32>,
    pub txn_id: Option<i64>,
    pub payment_mode: Option<String>,
    pub txn_status: Option<String>,
    pub reservation_status: Option<String>,
    pub reservation_category: Option<String>,
    pub seat_no: Option<i64>,
    pub seat_type: Option<String>,
    pub seat_category: Option<String>,
    pub coach_name: Option<String>,
    pub coach_type: Option<String>,
    pub train_name: Option<String>,
    pub train_type: Option<String>,
    pub journey_id: Option<i64>,
    pub start_time: Option<chrono::DateTime<Utc>>,
    pub end_time: Option<chrono::DateTime<Utc>>,
    pub start_station: Option<String>,
    pub end_station: Option<String>,
}
