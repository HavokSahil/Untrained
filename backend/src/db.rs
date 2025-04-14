use sqlx::{mysql::MySqlPoolOptions, MySqlPool};

pub async fn init_pool(database_url: &str) -> Result<MySqlPool, sqlx::Error> {
    MySqlPoolOptions::new()
        .max_connections(5)
        .connect(database_url)
        .await
}