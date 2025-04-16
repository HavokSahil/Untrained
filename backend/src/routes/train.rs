use actix_web::web;
use crate::handlers::{
    coach_handler::*,
    seat_handler::*,
    train_handler::*,
};

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/trains")
            .route("", web::get().to(get_trains)) // GET /api/trains
            .route("/id/{train_id}", web::get().to(get_train_by_id)) // GET /api/trains/{train_id}
            .route("/add", web::post().to(create_train)) // POST /api/trains/create
            .route("/detailed", web::get().to(get_trains_detailed)) // GET /api/trains/detailed
            .route("/coaches/id/{train_id}", web::get().to(get_coaches_for_train)) // GET /api/trains/{train_id}/coaches
    );

    cfg.service(
        web::scope("/api/coaches")
            .route("/add", web::post().to(create_coach)) // POST /api/coaches/add
            .route("/seats/id/{coach_id}", web::get().to(get_seats_by_coach)) // GET /api/coaches/{coach_id}/seats
    );

    cfg.service(
        web::scope("/api/seats")
            .route("/add", web::post().to(create_seat)) // POST /api/seats/add
            .route("/total/cnf/{train_id}", web::get().to(get_cnf_seat_count_by_coach_category))
            .route("/total/rac/{train_id}", web::get().to(get_rac_seat_count_by_coach_category))
    );
}
