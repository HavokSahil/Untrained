use serde::{Serialize, Deserialize};
use chrono::{DateTime, NaiveDateTime, Utc};

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct JourneyDetailedResponse {
    pub journey_id: i64,
    pub start_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    pub train_id: Option<i64>,
    pub start_station_id: Option<i64>,
    pub end_station_id: Option<i64>,
    pub start_station_name: Option<String>,
    pub end_station_name: Option<String>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct JourneyResponse {
    pub journey_id: i64,
    pub start_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    pub train_id: Option<i64>,
    pub start_station_id: Option<i64>,
    pub end_station_id: Option<i64>,
}

#[derive(Debug, Deserialize)]
pub struct CreateJourney {
    pub start_time: String,
    pub end_time: String,
    pub train_id: i64,
    pub start_station_id: i64,
    pub end_station_id: i64,
}

#[derive(Deserialize)]
pub struct UpdateJourney {
    pub start_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
    pub start_station_id: Option<i64>,
    pub end_station_id: Option<i64>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct JourneyBetweenStations {
    pub journey_id: i64,
    pub train_id: Option<i64>,
    pub train_name: Option<String>,
    pub start_station_id: Option<i64>,
    pub start_schedule_id: Option<i64>,
    pub start_station: Option<String>,
    pub end_station_id: Option<i64>,
    pub end_schedule_id: Option<i64>,
    pub end_station: Option<String>,
    pub start_time: Option<chrono::DateTime<Utc>>,
    pub end_time: Option<chrono::DateTime<Utc>>,
    pub start_stop_number: Option<i32>,
    pub end_stop_number: Option<i32>,
    pub travel_time: Option<i64>,
}