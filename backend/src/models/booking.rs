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