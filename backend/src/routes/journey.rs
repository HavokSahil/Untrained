use actix_web::web;
use crate::handlers::journey_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/journeys")
            .route("", web::get().to(get_all_journeys))
            .route("/add", web::post().to(create_journey)) // POST /api/journeys/add
            .route("/{journey_id}", web::get().to(get_journey_by_id)) // GET /api/journeys/{journey_id}
            .route("/{journey_id}/update", web::put().to(update_journey)) // PUT /api/journeys/{journey_id}/update
            .route("/{journey_id}/delete", web::delete().to(delete_journey)) // DELETE /api/journeys/{journey_id}/delete
            .route("/train/{train_id}", web::get().to(get_journeys_by_train)) // GET /api/journeys/train/{train_id}
    );
}