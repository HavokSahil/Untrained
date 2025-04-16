use actix_web::web;
use crate::handlers::route_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/route")
            .route("", web::get().to(get_routes))
            .route("/add", web::post().to(create_route))
            .route("/id/{route_id}/add", web::post().to(add_intermediate_station))
            .route("/id/{route_id}", web::get().to(get_route_stations))
            .route("/between", web::get().to(get_routes_between_stations))
            .route("/relative", web::get().to(get_relative_stations))
    );
}