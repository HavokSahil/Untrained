// models/passenger.rs

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct CreatePassenger {
    pub name: String,
    pub age: i32,
    pub sex: String,
    pub disability: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Passenger {
    pub pnr: i64,
    pub name: String,
    pub age: i32,
    pub sex: String,
    pub disability: bool,
}

#[derive(Serialize)]
pub struct PnrStatusResponse {
    pub train_name: Option<String>,
    pub start_station: Option<String>,
    pub end_station: Option<String>,
    pub coach_name: Option<String>,
    pub seat_no: Option<i64>,
    pub seat_type: Option<String>,
    pub booking_status: Option<String>,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
}