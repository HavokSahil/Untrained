use actix_web::web;
use crate::handlers::booking_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/booking")
            .route("seat/cnf/{journey_id}", web::get().to(get_cnf_seat_count_by_coach_category))
            .route("seat/rac/{journey_id}", web::get().to(get_rac_seat_count_by_coach_category))
            .route("seat/wl/{journey_id}", web::get().to(get_wl_seat_count_by_coach_category))
            .route("/book", web::post().to(create_group_booking_handler))
            .route("/details", web::get().to(get_booking_details_by_email))
            .route("/cancel", web::post().to(cancel_booking_handler))
    );
}