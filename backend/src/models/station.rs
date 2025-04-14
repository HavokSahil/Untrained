use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct StationResponse {
    pub station_id: i64,
    pub station_name: Option<String>,
    pub station_type: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CreateStation {
    pub station_name: String,
    pub station_type: String, // Should be "JN", "TM", "HT", "ST"
}