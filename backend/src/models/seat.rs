use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "ENUM", rename_all = "UPPERCASE")]
pub enum SeatType {
    SL,
    SU,
    LL,
    MD,
    UP,
    ST,
    FC,
}

#[derive(Debug, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "ENUM", rename_all = "UPPERCASE")]
pub enum SeatCategory {
    CNF,
    RAC,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Seat {
    pub seat_id: i64,
    pub seat_no: Option<i64>,
    pub seat_type: Option<String>,
    pub coach_id: Option<i64>,
    pub seat_category: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateSeat {
    pub seat_no: i64,
    pub seat_type: SeatType,
    pub coach_id: i64,
    pub seat_category: SeatCategory,
}
