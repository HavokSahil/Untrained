use actix_web::web;
use crate::handlers::route_handler;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/route")
            .route("", web::get().to(route_handler::get_routes))
            .route("/add", web::post().to(route_handler::create_route))
            .route("/{route_id}/add", web::post().to(route_handler::add_intermediate_station))
            .route("/{route_id}", web::get().to(route_handler::get_route_stations))
    );
}