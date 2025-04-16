use actix_web::web;
use crate::handlers::station_handler::{
    create_station, get_all_stations, get_station_by_name,
};

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/station")
            .route("/add", web::post().to(create_station))
            .route("/all", web::get().to(get_all_stations))
            .route("", web::get().to(get_station_by_name))
    );
}
