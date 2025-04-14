// models/schedule.rs

use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScheduleInstance {
    pub station_abb: String,
    pub toa: String,
    pub tod: String,
    pub index: i32,
    pub dist_begin: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PassedInstance {
    pub station_abb: String,
    pub toa: Option<String>,
    pub tod: Option<String>,
    pub index: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Schedule {
    pub id: i32,
    pub train_no: String,
    pub instances: Vec<ScheduleInstance>
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScheduleWithPassed {
    pub id: i32,
    pub train_no: String,
    pub instances: Vec<PassedInstance>
}