// models/transaction.rs

use serde::{self, Serialize, Deserialize};
use sqlx::prelude::Type;

#[derive(Debug, Serialize, Deserialize, Type, Clone, Copy, PartialEq, Eq)]
#[sqlx(type_name = "CHAR(3)")]
#[serde(rename_all = "UPPERCASE")]
pub enum PaymentMode {
    CSH,    // Cash
    CCD,    // Credit Card
    DCD,    // Debit Card
    NBK,    // Net Banking
    UPI,    // Unified Payments Interface
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Transaction {
    pub txn_id: i64,
    pub total_amount: Option<f32>,
    pub txn_status: Option<String>,  // 'PENDING', 'COMPLETE', 'FAILED'
    pub payment_mode: Option<String>, // 'UPI', 'CARD', 'CASH', 'NETBANKING'
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateTransaction {
    pub total_amount: f32,
    pub txn_status: String,  // 'PENDING', 'COMPLETE', 'FAILED'
    pub payment_mode: PaymentMode,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateTransactionStatus {
    pub txn_id: i64,
    pub txn_status: Option<String>,  // 'PENDING', 'COMPLETE', 'FAILED'
}

#[derive(Debug, Deserialize)]
pub struct CancelBookingRequest {
    pub booking_id: i64,
    pub refund_amount: f64,
    pub txn_id: i64,
}
