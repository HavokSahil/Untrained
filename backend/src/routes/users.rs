use actix_web::web;
use crate::handlers::user_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/users")
        .route("", web::post().to(create_user))
        .route("", web::get().to(get_users))
        .route("/{email}", web::get().to(get_user_by_email))
        .route("/{email}", web::put().to(update_user))
        .route("/{email}", web::delete().to(delete_user))
    );
}