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
    pub txn_id: String,
    pub amount: f64,
    pub ac_no: String,
    pub payment_mode: PaymentMode,
}