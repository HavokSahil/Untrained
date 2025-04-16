use actix_web::web;
use crate::handlers::passenger_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/pnr")
            .route("/{pnr}", web::get().to(get_pnr_status))
    );
}