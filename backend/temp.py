# Generate SQL scripts for log tables and triggers for all given table names and their schemas.

# Base schema for each table from the user's input
tables = {
    "train": ["train_id BIGINT", "train_name VARCHAR(100)", "train_type ENUM('EX', 'ML', 'SF', 'VB', 'MM', 'IN')"],
    "coach": ["coach_id BIGINT", "coach_name VARCHAR(10)", "coach_type ENUM('SL', 'AC3', 'AC2', 'AC1', 'CC', 'FC', '2S')", "fare FLOAT", "train_id BIGINT"],
    "seat": ["seat_id BIGINT", "seat_no BIGINT", "seat_type ENUM('SL', 'SU', 'LL', 'MD', 'UP', 'ST', 'FC')", "coach_id BIGINT", "seat_category ENUM('CNF', 'RAC')"],
    "station": ["station_id BIGINT", "station_name VARCHAR(100)", "station_type ENUM('JN', 'TM', 'HT', 'ST')"],
    "passenger": ["pnr BIGINT", "pass_name VARCHAR(100)", "age INT", "sex CHAR(1)", "disability BOOLEAN"],
    "route": ["route_id BIGINT", "route_name VARCHAR(100)", "source_station_id BIGINT", "final_station_id BIGINT"],
    "distance_map": ["route_id BIGINT", "station_id BIGINT", "distance INT", "order_from_start INT"],
    "journey": ["journey_id BIGINT", "start_time TIMESTAMP", "train_id BIGINT", "start_station_id BIGINT", "end_station_id BIGINT"],
    "schedule": ["sched_id BIGINT", "station_id BIGINT", "sched_toa TIMESTAMP", "sched_tod TIMESTAMP", "journey_id BIGINT", "stop_number INT", "route_id BIGINT"],
    "running": ["running_id BIGINT", "station_id BIGINT", "toa TIMESTAMP", "tod TIMESTAMP", "journey_id BIGINT", "stop_number INT", "route_id BIGINT"],
    "booking": ["booking_id BIGINT", "booking_time TIMESTAMP", "booking_status ENUM('CONFIRMED', 'CANCELLED', 'PENDING')", "pnr BIGINT", "journey_id BIGINT", "txn_id BIGINT", "amount FLOAT", "start_station_id BIGINT", "end_station_id BIGINT", "seat_id BIGINT"],
    "reservation_status": ["reservation_id BIGINT", "pnr BIGINT", "seat_id BIGINT", "reservation_status ENUM('CNF', 'RAC', 'WL')", "booking_time TIMESTAMP"],
    "payment_transaction": ["txn_id BIGINT", "total_amount FLOAT", "txn_status ENUM('PENDING', 'COMPLETE', 'FAILED')", "payment_mode ENUM('UPI', 'CARD', 'CASH', 'NETBANKING')"],
    "cancellation_record": ["booking_id BIGINT", "cancel_time TIMESTAMP", "refund_amount FLOAT", "cancel_status ENUM('PENDING', 'COMPLETED', 'FAILED')", "txn_id BIGINT"]
}

def create_log_and_triggers(table_name, columns):
    # Log table creation
    log_columns = [
        "log_id BIGINT PRIMARY KEY AUTO_INCREMENT",
        "operation_type ENUM('INSERT', 'UPDATE', 'DELETE')",
        "operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    ] + columns

    log_table = f"CREATE TABLE {table_name}_log (\n    " + ",\n    ".join(log_columns) + "\n);\n"

    # Triggers for INSERT, UPDATE, DELETE
    triggers = ""
    for op in ['INSERT', 'UPDATE', 'DELETE']:
        action = 'NEW' if op != 'DELETE' else 'OLD'
        column_names = ", ".join(col.split()[0] for col in columns)
        values = ", ".join(f"{action}.{col.split()[0]}" for col in columns)
        triggers += f"""
DELIMITER //

CREATE TRIGGER trg_{table_name.lower()}_{op.lower()}
AFTER {op} ON {table_name}
FOR EACH ROW
BEGIN
    INSERT INTO {table_name}_log (operation_type, {column_names})
    VALUES ('{op}', {values});
END;
//

DELIMITER ;
"""
    return log_table + triggers

# Generate full SQL
full_sql_script = ""
for table, cols in tables.items():
    full_sql_script += create_log_and_triggers(table, cols) + "\n\n"

print(full_sql_script)
