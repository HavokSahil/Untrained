use actix_web::web;
use crate::handlers::transaction_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/transaction")
            .route("/add", web::post().to(create_payment_transaction))
            .route("/update", web::post().to(update_payment_transaction_status))
            .route("/all", web::get().to(get_all_transactions))
    );
}
