// models/route.rs

use serde::{Serialize, Deserialize};
use sqlx::prelude::FromRow;

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct RouteResponse {
    pub route_id: i64,
    pub route_name: String,
    pub source_station_id: i64,
    pub num_stations: i64,
    pub total_distance: f32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateRoute {
    pub route_name: String,
    pub source_station_id: i64,
}

#[derive(Debug, Deserialize)]
pub struct AddIntermediateStation {
    pub station_id: i64,
    pub distance: f32, // Distance from source station
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct RouteStation {
    pub route_id: i64,
    pub station_id: Option<i64>,
    pub distance: Option<f32>, // Distance from source station
}

#[derive(Serialize)]
pub struct RouteDetailResponse {
    pub route_id: i64,
    pub route_name: Option<String>,
    pub source_station_id: Option<i64>,
    pub total_stations: usize,
    pub total_distance: f32,
    pub stations: Vec<RouteStation>,
}