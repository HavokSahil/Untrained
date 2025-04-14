// models/cancellation.rs

use serde::{Deserialize, Serialize};
use sqlx::prelude::Type;


#[derive(Debug, Serialize, Deserialize, Type, Clone, Copy, PartialEq, Eq)]
#[sqlx(type_name = "CHAR(3)")]
#[serde(rename_all = "UPPERCASE")]
pub enum CancellationStatus {
    CNC, // Cancelled
    PND, // Pending
}

impl CancellationStatus {
    pub fn to_string(&self) -> String {
        match self {
            CancellationStatus::CNC => "Cancelled".to_string(),
            CancellationStatus::PND => "Pending".to_string(),
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCancellation {
    pub status: CancellationStatus,
    pub refund_amount: f64,
    pub txn_id: i64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Cancellation {
    pub cid: i64,
    pub status: CancellationStatus,
    pub refund_amount: f64,
    pub txn_id: i64,
}