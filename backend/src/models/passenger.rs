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