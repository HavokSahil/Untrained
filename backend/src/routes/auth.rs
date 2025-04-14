use actix_web::web;
use crate::handlers::user_handler::{create_user, get_user_by_email_and_password, get_user_by_email};

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/auth")
            .route("/login", web::get().to(get_user_by_email))
            .route("/login", web::post().to(get_user_by_email_and_password))
            .route("/signup", web::post().to(create_user))
    );
}
