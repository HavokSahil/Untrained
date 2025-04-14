// models/train.rs

use serde::{Serialize, Deserialize};
use sqlx::prelude::{FromRow, Type};

#[derive(Debug, Serialize, Deserialize, Type, Clone, Copy, PartialEq, Eq)]
#[sqlx(type_name = "CHAR(2)")]
#[serde(rename_all = "UPPERCASE")]
pub enum TrainType {
    EX, // Express
    ML, // Mail
    SF, // Superfast
    VB, // Vande Bharat
    MM, // MEMU
    IN // Intercity
}

#[derive(Debug, Serialize, Deserialize)]
pub  struct Train {
    pub train_no: i64,
    pub train_name: String,
    pub train_type: TrainType,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct TrainResponse {
    pub train_no: i64,
    pub train_name: Option<String>,
    pub train_type: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct TrainDetailedResponse {
    pub train_no: i64,
    pub train_name: String,
    pub train_type: String,
    pub coaches: i64,
    pub seats: i64,
    pub journeys: i64,
    pub upcoming_journeys: i64,
}