mod config;
mod db;
mod errors;
mod models;
mod handlers;
mod routes;
mod demo;

use actix_web::{App, HttpServer};
use actix_cors::Cors;
use config::Config;
use db::init_pool;
use tracing_subscriber;
use tracing;

#[actix_web::main]
async fn main() -> std::io::Result<()> {

    // Initialize tracing subscriber
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .with_target(false)
        .without_time()
        .init();

    dotenv::dotenv().ok();
    let config = Config::from_env().expect("Failed to load config");
    println!("Server starting on {}:{}", config.host, config.port);
    let db_pool = init_pool(&config.database_url)
        .await
        .expect("Failed to create pool");

    HttpServer::new(move || {
        App::new()
        .wrap(Cors::permissive())
        .app_data(actix_web::web::Data::new(db_pool.clone()))
        .configure(routes::init_routes)
    })
    .bind((config.host.as_str(), config.port))?
    .run()
    .await
}

