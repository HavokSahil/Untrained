use actix_web::web;

pub mod auth;
pub mod users;
pub mod train;
pub mod station;
pub mod route;
pub mod journey;

pub fn init_routes(cfg: &mut web::ServiceConfig) {
    auth::config(cfg);
    journey::config(cfg);
    train::config(cfg);
    station::config(cfg);
    users::config(cfg);
    route::config(cfg);
}