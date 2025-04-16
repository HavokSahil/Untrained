use actix_web::web;
use crate::handlers::stats_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/stat")
            .route("/total-journeys", web::get().to(total_number_of_journeys))
            .route("/busiest-route", web::get().to(busiest_route))
            .route("/total-passengers", web::get().to(total_passengers_traveling))
            .route("/gender-distribution", web::get().to(gender_distribution))
            .route("/busiest-station", web::get().to(busiest_station))
            .route("/rank-running-trains", web::get().to(rank_running_trains_by_bookings))
            .route("/busiest-time-period", web::get().to(busiest_time_period))
            .route("/reservation-status-distribution", web::get().to(reservation_status_distribution)),
    );
}
