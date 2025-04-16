use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct Schedule {
    pub sched_id: i64,
    pub station_id: Option<i64>,
    pub station_name: Option<String>,
    pub sched_toa: Option<DateTime<Utc>>,
    pub sched_tod: Option<DateTime<Utc>>,
    pub journey_id: Option<i64>,
    pub stop_number: Option<i32>,
    pub route_id: Option<i64>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct ScheduleJourney {
    pub sched_id: i64,
    pub station_id: Option<i64>,
    pub station_name: Option<String>,
    pub sched_toa: Option<DateTime<Utc>>,
    pub sched_tod: Option<DateTime<Utc>>,
    pub journey_id: Option<i64>,
    pub stop_number: Option<i32>,
    pub route_id: Option<i64>,
    pub distance: Option<f64>,
}

#[derive(Debug, Deserialize)]
pub struct CreateSchedule {
    pub station_id: i64,
    pub sched_toa: DateTime<Utc>,
    pub sched_tod: DateTime<Utc>,
    pub journey_id: i64,
    pub stop_number: i32,
    pub route_id: Option<i64>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateSchedule {
    pub sched_toa: Option<DateTime<Utc>>,
    pub sched_tod: Option<DateTime<Utc>>,
    pub stop_number: Option<i32>,
    pub route_id: Option<i64>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct RoutesBetweenStations {
    pub route_id: Option<i64>,
    pub route_name: Option<String>,
    pub source_station_id: Option<i64>,
    pub destination_station_id: Option<i64>,
    pub distance: Option<f64>,
}
