use actix_web::{web, HttpResponse, Responder, Error};
use chrono::Utc;
use sqlx::mysql::MySqlPool;

use crate::models::transaction::{CancelBookingRequest, CreateTransaction, Transaction, UpdateTransactionStatus};

pub async fn create_payment_transaction(
    pool: web::Data<MySqlPool>,
    payment: web::Json<CreateTransaction>,
) -> Result<impl Responder, actix_web::Error> {
    // Step 1: Call the stored procedure to insert the payment transaction
    let _ = sqlx::query!(
        r#"
        CALL create_payment_transaction_proc(?, ?, ?);
        "#,
        payment.total_amount,
        payment.txn_status,
        payment.payment_mode,
    )
    .execute(pool.get_ref())
    .await;

    // Step 2: Fetch the transaction ID using the @txn_id output parameter
    let txn_id_result = sqlx::query_scalar!(
        r#"SELECT CAST(var_value AS UNSIGNED) FROM global_variables WHERE var_name = 'last_txn_id';"#
    )
    .fetch_one(pool.get_ref())
    .await;

    match txn_id_result {
        Ok(txn_id) => {
            // Send back the payment information with the transaction ID
            let response = serde_json::json!({
                "txn_id": txn_id,
                "total_amount": payment.total_amount,
                "txn_status": payment.txn_status,
                "payment_mode": payment.payment_mode,
            });
            Ok(HttpResponse::Created().json(response))
        },
        Err(e) => {
            eprintln!("Error retrieving transaction ID: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to retrieve transaction ID",
                "details": e.to_string()
            })))
        },
    }
}


pub async fn update_payment_transaction_status(
    pool: web::Data<MySqlPool>,
    transaction: web::Json<UpdateTransactionStatus>,
) -> Result<impl Responder, Error> {

    // Step 1: Validate the input
    let transaction_id = transaction.txn_id;
    let transaction_status = transaction.txn_status.clone();

    println!("Transaction ID: {:?}", transaction_id);
    println!("Transaction Status: {:?}", transaction_status);

    let result = sqlx::query!(
        r#"
        UPDATE payment_transaction
        SET txn_status = ?
        WHERE txn_id = ?
        "#,
        transaction.txn_status,
        transaction.txn_id
    )
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(_) => Ok(HttpResponse::Ok().json(serde_json::json!({
            "message": "Transaction status updated"
        }))),
        Err(e) => {
            eprintln!("Error updating payment transaction: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to update payment transaction",
                "details": e.to_string()
            })))
        }
    }
}

pub async fn get_all_transactions(
    pool: web::Data<MySqlPool>,
) -> Result<impl Responder, Error> {
    let transactions = sqlx::query_as!(
        Transaction,
        r#"
        SELECT txn_id, total_amount, txn_status, payment_mode
        FROM payment_transaction
        "#
    )
    .fetch_all(pool.get_ref())
    .await;

    match transactions {
        Ok(transactions) => {
            // Check if there are any transactions, if yes return them, else return an empty array
            let response_data = if transactions.len() > 0 {
                transactions
            } else {
                Vec::new()  // Return an empty vector if no transactions are found
            };
    
            Ok(HttpResponse::Ok().json(response_data))
        },
        Err(e) => {
            eprintln!("Error fetching transactions: {:?}", e);
            Ok(HttpResponse::InternalServerError().json(serde_json::json!({
                "error": "Failed to fetch transactions",
                "details": e.to_string()
            })))
        }
    }
    
}