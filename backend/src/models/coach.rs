use serde::{Serialize, Deserialize};
use sqlx::prelude::FromRow;

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCoach {
    pub coach_name: String,
    pub coach_type: String,
    pub fare: f32,
    pub train_id: i64,
}

#[derive(Serialize, Deserialize, FromRow, Debug)]
pub struct CoachResponse {
    pub coach_id: Option<i64>,
    pub coach_name: Option<String>,
    pub coach_type: Option<String>,
    pub fare: Option<f32>,
    pub train_id: Option<i64>,
    pub total_seats: Option<i64>
}

#[derive(Serialize, Deserialize, FromRow, Debug)]
pub struct CoachPricesByType {
    pub coach_type: Option<String>,
    pub fare: Option<f32>,
}
