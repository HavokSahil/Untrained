use actix_web::web;
use crate::handlers::{
    coach_handler::{create_coach, get_coaches_for_train},
    seat_handler::{create_seat, get_seats_by_coach},
    train_handler::{create_train, get_trains, get_trains_detailed},
};

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/trains")
            .route("", web::get().to(get_trains)) // GET /api/trains
            .route("/add", web::post().to(create_train)) // POST /api/trains/create
            .route("/detailed", web::get().to(get_trains_detailed)) // GET /api/trains/detailed
            .route("/{train_id}/coaches", web::get().to(get_coaches_for_train)) // GET /api/trains/{train_id}/coaches
    );

    cfg.service(
        web::scope("/api/coaches")
            .route("/add", web::post().to(create_coach)) // POST /api/coaches/add
            .route("/{coach_id}/seats", web::get().to(get_seats_by_coach)) // GET /api/coaches/{coach_id}/seats
    );

    cfg.service(
        web::scope("/api/seats")
            .route("/add", web::post().to(create_seat)) // POST /api/seats/add
    );
}
