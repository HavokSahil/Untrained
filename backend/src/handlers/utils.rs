use chrono::NaiveDate;

#[derive(serde::Deserialize, Debug)]
pub struct QueryParams {
    pub search: Option<String>,
    pub sort: Option<String>,

    // Train Specific
    pub train_no: Option<i64>,
    pub train_name: Option<String>,
    pub train_type: Option<String>,

    pub station_id: Option<i64>,
    pub station_name: Option<String>,
    pub station_type: Option<String>,
    
    // Coach Specific
    pub coach_type: Option<String>,
    pub coach_name: Option<String>,

    pub route_id: Option<i64>,
    pub route_name: Option<String>,
    pub route_station: Option<i64>,

    pub journey_id: Option<i64>,
    pub start_station_name: Option<String>,
    pub end_station_name: Option<String>,

    pub source_station_id: Option<i64>,
    pub destination_station_id: Option<i64>,

    pub journey_date: Option<NaiveDate>,

    pub page: Option<u32>,
    pub limit: Option<u32>
}