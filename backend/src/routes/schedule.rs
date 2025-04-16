use actix_web::web;
use crate::handlers::schedule_handler::*;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/schedules")
            .route("", web::get().to(get_all_schedules))                              // GET /api/schedules
            .route("/add", web::post().to(create_schedule))                           // POST /api/schedules/add
            .route("/id/{id}", web::get().to(get_schedule_by_id))                        // GET /api/schedules/{id}
            .route("/update/id/{id}", web::put().to(update_schedule))                    // PUT /api/schedules/{id}/update
            .route("/delete/id/{id}", web::delete().to(delete_schedule))                 // DELETE /api/schedules/{id}/delete
            .route("/journey/{journey_id}", web::get().to(get_schedule_by_journey))   // GET /api/schedules/journey/{journey_id}
    );
}