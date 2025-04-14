DROP TABLE IF EXISTS train_log;
DROP TABLE IF EXISTS coach_log;
DROP TABLE IF EXISTS seat_log;
DROP TABLE IF EXISTS station_log;
DROP TABLE IF EXISTS passenger_log;
DROP TABLE IF EXISTS route_log;
DROP TABLE IF EXISTS distance_map_log;
DROP TABLE IF EXISTS journey_log;
DROP TABLE IF EXISTS schedule_log;
DROP TABLE IF EXISTS running_log;
DROP TABLE IF EXISTS booking_log;
DROP TABLE IF EXISTS reservation_status_log;
DROP TABLE IF EXISTS payment_transaction_log;
DROP TABLE IF EXISTS cancellation_record_log;

CREATE TABLE train_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    train_id BIGINT,
    train_name VARCHAR(100),
    train_type ENUM('EX', 'ML', 'SF', 'VB', 'MM', 'IN')
);

CREATE TRIGGER trg_train_insert
AFTER INSERT ON train
FOR EACH ROW
BEGIN
    INSERT INTO train_log (operation_type, train_id, train_name, train_type)
    VALUES ('INSERT', NEW.train_id, NEW.train_name, NEW.train_type);
END;

CREATE TRIGGER trg_train_update
AFTER UPDATE ON train
FOR EACH ROW
BEGIN
    INSERT INTO train_log (operation_type, train_id, train_name, train_type)
    VALUES ('UPDATE', NEW.train_id, NEW.train_name, NEW.train_type);
END;

CREATE TRIGGER trg_train_delete
AFTER DELETE ON train
FOR EACH ROW
BEGIN
    INSERT INTO train_log (operation_type, train_id, train_name, train_type)
    VALUES ('DELETE', OLD.train_id, OLD.train_name, OLD.train_type);
END;

CREATE TABLE coach_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    coach_id BIGINT,
    coach_name VARCHAR(10),
    coach_type ENUM('SL', 'AC3', 'AC2', 'AC1', 'CC', 'FC', '2S'),
    fare FLOAT,
    train_id BIGINT
);

CREATE TRIGGER trg_coach_insert
AFTER INSERT ON coach
FOR EACH ROW
BEGIN
    INSERT INTO coach_log (operation_type, coach_id, coach_name, coach_type, fare, train_id)
    VALUES ('INSERT', NEW.coach_id, NEW.coach_name, NEW.coach_type, NEW.fare, NEW.train_id);
END;

CREATE TRIGGER trg_coach_update
AFTER UPDATE ON coach
FOR EACH ROW
BEGIN
    INSERT INTO coach_log (operation_type, coach_id, coach_name, coach_type, fare, train_id)
    VALUES ('UPDATE', NEW.coach_id, NEW.coach_name, NEW.coach_type, NEW.fare, NEW.train_id);
END;

CREATE TRIGGER trg_coach_delete
AFTER DELETE ON coach
FOR EACH ROW
BEGIN
    INSERT INTO coach_log (operation_type, coach_id, coach_name, coach_type, fare, train_id)
    VALUES ('DELETE', OLD.coach_id, OLD.coach_name, OLD.coach_type, OLD.fare, OLD.train_id);
END;

CREATE TABLE seat_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    seat_id BIGINT,
    seat_no BIGINT,
    seat_type ENUM('SL', 'SU', 'LL', 'MD', 'UP', 'ST', 'FC'),
    coach_id BIGINT,
    seat_category ENUM('CNF', 'RAC')
);

CREATE TRIGGER trg_seat_insert
AFTER INSERT ON seat
FOR EACH ROW
BEGIN
    INSERT INTO seat_log (operation_type, seat_id, seat_no, seat_type, coach_id, seat_category)
    VALUES ('INSERT', NEW.seat_id, NEW.seat_no, NEW.seat_type, NEW.coach_id, NEW.seat_category);
END;

CREATE TRIGGER trg_seat_update
AFTER UPDATE ON seat
FOR EACH ROW
BEGIN
    INSERT INTO seat_log (operation_type, seat_id, seat_no, seat_type, coach_id, seat_category)
    VALUES ('UPDATE', NEW.seat_id, NEW.seat_no, NEW.seat_type, NEW.coach_id, NEW.seat_category);
END;

CREATE TRIGGER trg_seat_delete
AFTER DELETE ON seat
FOR EACH ROW
BEGIN
    INSERT INTO seat_log (operation_type, seat_id, seat_no, seat_type, coach_id, seat_category)
    VALUES ('DELETE', OLD.seat_id, OLD.seat_no, OLD.seat_type, OLD.coach_id, OLD.seat_category);
END;

CREATE TABLE station_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    station_id BIGINT,
    station_name VARCHAR(100),
    station_type ENUM('JN', 'TM', 'HT', 'ST')
);

CREATE TRIGGER trg_station_insert
AFTER INSERT ON station
FOR EACH ROW
BEGIN
    INSERT INTO station_log (operation_type, station_id, station_name, station_type)
    VALUES ('INSERT', NEW.station_id, NEW.station_name, NEW.station_type);
END;

CREATE TRIGGER trg_station_update
AFTER UPDATE ON station
FOR EACH ROW
BEGIN
    INSERT INTO station_log (operation_type, station_id, station_name, station_type)
    VALUES ('UPDATE', NEW.station_id, NEW.station_name, NEW.station_type);
END;

CREATE TRIGGER trg_station_delete
AFTER DELETE ON station
FOR EACH ROW
BEGIN
    INSERT INTO station_log (operation_type, station_id, station_name, station_type)
    VALUES ('DELETE', OLD.station_id, OLD.station_name, OLD.station_type);
END;

CREATE TABLE passenger_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pnr BIGINT,
    pass_name VARCHAR(100),
    age INT,
    sex CHAR(1),
    disability BOOLEAN
);

CREATE TRIGGER trg_passenger_insert
AFTER INSERT ON passenger
FOR EACH ROW
BEGIN
    INSERT INTO passenger_log (operation_type, pnr, pass_name, age, sex, disability)
    VALUES ('INSERT', NEW.pnr, NEW.pass_name, NEW.age, NEW.sex, NEW.disability);
END;

CREATE TRIGGER trg_passenger_update
AFTER UPDATE ON passenger
FOR EACH ROW
BEGIN
    INSERT INTO passenger_log (operation_type, pnr, pass_name, age, sex, disability)
    VALUES ('UPDATE', NEW.pnr, NEW.pass_name, NEW.age, NEW.sex, NEW.disability);
END;

CREATE TRIGGER trg_passenger_delete
AFTER DELETE ON passenger
FOR EACH ROW
BEGIN
    INSERT INTO passenger_log (operation_type, pnr, pass_name, age, sex, disability)
    VALUES ('DELETE', OLD.pnr, OLD.pass_name, OLD.age, OLD.sex, OLD.disability);
END;

CREATE TABLE route_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    route_id BIGINT,
    route_name VARCHAR(100),
    source_station_id BIGINT
);

CREATE TRIGGER trg_route_insert
AFTER INSERT ON route
FOR EACH ROW
BEGIN
    INSERT INTO route_log (operation_type, route_id, route_name, source_station_id)
    VALUES ('INSERT', NEW.route_id, NEW.route_name, NEW.source_station_id);
END;

CREATE TRIGGER trg_route_update
AFTER UPDATE ON route
FOR EACH ROW
BEGIN
    INSERT INTO route_log (operation_type, route_id, route_name, source_station_id)
    VALUES ('UPDATE', NEW.route_id, NEW.route_name, NEW.source_station_id);
END;

CREATE TRIGGER trg_route_delete
AFTER DELETE ON route
FOR EACH ROW
BEGIN
    INSERT INTO route_log (operation_type, route_id, route_name, source_station_id)
    VALUES ('DELETE', OLD.route_id, OLD.route_name, OLD.source_station_id);
END;

CREATE TABLE distance_map_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    route_id BIGINT,
    station_id BIGINT,
    distance INT
);

CREATE TRIGGER trg_distance_map_insert
AFTER INSERT ON distance_map
FOR EACH ROW
BEGIN
    INSERT INTO distance_map_log (operation_type, route_id, station_id, distance)
    VALUES ('INSERT', NEW.route_id, NEW.station_id, NEW.distance);
END;

CREATE TRIGGER trg_distance_map_update
AFTER UPDATE ON distance_map
FOR EACH ROW
BEGIN
    INSERT INTO distance_map_log (operation_type, route_id, station_id, distance)
    VALUES ('UPDATE', NEW.route_id, NEW.station_id, NEW.distance);
END;

CREATE TRIGGER trg_distance_map_delete
AFTER DELETE ON distance_map
FOR EACH ROW
BEGIN
    INSERT INTO distance_map_log (operation_type, route_id, station_id, distance)
    VALUES ('DELETE', OLD.route_id, OLD.station_id, OLD.distance);
END;

CREATE TABLE journey_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    journey_id BIGINT,
    start_time TIMESTAMP,
    train_id BIGINT,
    start_station_id BIGINT,
    end_station_id BIGINT
);

CREATE TRIGGER trg_journey_insert
AFTER INSERT ON journey
FOR EACH ROW
BEGIN
    INSERT INTO journey_log (operation_type, journey_id, start_time, train_id, start_station_id, end_station_id)
    VALUES ('INSERT', NEW.journey_id, NEW.start_time, NEW.train_id, NEW.start_station_id, NEW.end_station_id);
END;

CREATE TRIGGER trg_journey_update
AFTER UPDATE ON journey
FOR EACH ROW
BEGIN
    INSERT INTO journey_log (operation_type, journey_id, start_time, train_id, start_station_id, end_station_id)
    VALUES ('UPDATE', NEW.journey_id, NEW.start_time, NEW.train_id, NEW.start_station_id, NEW.end_station_id);
END;

CREATE TRIGGER trg_journey_delete
AFTER DELETE ON journey
FOR EACH ROW
BEGIN
    INSERT INTO journey_log (operation_type, journey_id, start_time, train_id, start_station_id, end_station_id)
    VALUES ('DELETE', OLD.journey_id, OLD.start_time, OLD.train_id, OLD.start_station_id, OLD.end_station_id);
END;

CREATE TABLE schedule_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sched_id BIGINT,
    station_id BIGINT,
    sched_toa TIMESTAMP,
    sched_tod TIMESTAMP,
    journey_id BIGINT,
    stop_number INT,
    route_id BIGINT
);

CREATE TRIGGER trg_schedule_insert
AFTER INSERT ON schedule
FOR EACH ROW
BEGIN
    INSERT INTO schedule_log (operation_type, sched_id, station_id, sched_toa, sched_tod, journey_id, stop_number, route_id)
    VALUES ('INSERT', NEW.sched_id, NEW.station_id, NEW.sched_toa, NEW.sched_tod, NEW.journey_id, NEW.stop_number, NEW.route_id);
END;

CREATE TRIGGER trg_schedule_update
AFTER UPDATE ON schedule
FOR EACH ROW
BEGIN
    INSERT INTO schedule_log (operation_type, sched_id, station_id, sched_toa, sched_tod, journey_id, stop_number, route_id)
    VALUES ('UPDATE', NEW.sched_id, NEW.station_id, NEW.sched_toa, NEW.sched_tod, NEW.journey_id, NEW.stop_number, NEW.route_id);
END;

CREATE TRIGGER trg_schedule_delete
AFTER DELETE ON schedule
FOR EACH ROW
BEGIN
    INSERT INTO schedule_log (operation_type, sched_id, station_id, sched_toa, sched_tod, journey_id, stop_number, route_id)
    VALUES ('DELETE', OLD.sched_id, OLD.station_id, OLD.sched_toa, OLD.sched_tod, OLD.journey_id, OLD.stop_number, OLD.route_id);
END;

CREATE TABLE running_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    running_id BIGINT,
    station_id BIGINT,
    toa TIMESTAMP,
    tod TIMESTAMP,
    journey_id BIGINT,
    stop_number INT,
    route_id BIGINT
);


CREATE TRIGGER trg_running_insert
AFTER INSERT ON running
FOR EACH ROW
BEGIN
    INSERT INTO running_log (operation_type, running_id, station_id, toa, tod, journey_id, stop_number, route_id)
    VALUES ('INSERT', NEW.running_id, NEW.station_id, NEW.toa, NEW.tod, NEW.journey_id, NEW.stop_number, NEW.route_id);
END;

CREATE TRIGGER trg_running_update
AFTER UPDATE ON running
FOR EACH ROW
BEGIN
    INSERT INTO running_log (operation_type, running_id, station_id, toa, tod, journey_id, stop_number, route_id)
    VALUES ('UPDATE', NEW.running_id, NEW.station_id, NEW.toa, NEW.tod, NEW.journey_id, NEW.stop_number, NEW.route_id);
END;

CREATE TRIGGER trg_running_delete
AFTER DELETE ON running
FOR EACH ROW
BEGIN
    INSERT INTO running_log (operation_type, running_id, station_id, toa, tod, journey_id, stop_number, route_id)
    VALUES ('DELETE', OLD.running_id, OLD.station_id, OLD.toa, OLD.tod, OLD.journey_id, OLD.stop_number, OLD.route_id);
END;

CREATE TABLE booking_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_id BIGINT,
    booking_time TIMESTAMP,
    booking_status ENUM('CONFIRMED', 'CANCELLED', 'PENDING'),
    pnr BIGINT,
    journey_id BIGINT,
    txn_id BIGINT,
    amount FLOAT,
    start_station_id BIGINT,
    end_station_id BIGINT,
    seat_id BIGINT
);

CREATE TRIGGER trg_booking_insert
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
    INSERT INTO booking_log (operation_type, booking_id, booking_time, booking_status, pnr, journey_id, txn_id, amount, start_station_id, end_station_id, seat_id)
    VALUES ('INSERT', NEW.booking_id, NEW.booking_time, NEW.booking_status, NEW.pnr, NEW.journey_id, NEW.txn_id, NEW.amount, NEW.start_station_id, NEW.end_station_id, NEW.seat_id);
END;

CREATE TRIGGER trg_booking_update
AFTER UPDATE ON booking
FOR EACH ROW
BEGIN
    INSERT INTO booking_log (operation_type, booking_id, booking_time, booking_status, pnr, journey_id, txn_id, amount, start_station_id, end_station_id, seat_id)
    VALUES ('UPDATE', NEW.booking_id, NEW.booking_time, NEW.booking_status, NEW.pnr, NEW.journey_id, NEW.txn_id, NEW.amount, NEW.start_station_id, NEW.end_station_id, NEW.seat_id);
END;

CREATE TRIGGER trg_booking_delete
AFTER DELETE ON booking
FOR EACH ROW
BEGIN
    INSERT INTO booking_log (operation_type, booking_id, booking_time, booking_status, pnr, journey_id, txn_id, amount, start_station_id, end_station_id, seat_id)
    VALUES ('DELETE', OLD.booking_id, OLD.booking_time, OLD.booking_status, OLD.pnr, OLD.journey_id, OLD.txn_id, OLD.amount, OLD.start_station_id, OLD.end_station_id, OLD.seat_id);
END;

CREATE TABLE reservation_status_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reservation_id BIGINT,
    pnr BIGINT,
    seat_id BIGINT,
    reservation_status ENUM('CNF', 'RAC', 'WL'),
    booking_time TIMESTAMP
);

CREATE TRIGGER trg_reservation_status_insert
AFTER INSERT ON reservation_status
FOR EACH ROW
BEGIN
    INSERT INTO reservation_status_log (operation_type, reservation_id, pnr, seat_id, reservation_status, booking_time)
    VALUES ('INSERT', NEW.reservation_id, NEW.pnr, NEW.seat_id, NEW.reservation_status, NEW.booking_time);
END;

CREATE TRIGGER trg_reservation_status_update
AFTER UPDATE ON reservation_status
FOR EACH ROW
BEGIN
    INSERT INTO reservation_status_log (operation_type, reservation_id, pnr, seat_id, reservation_status, booking_time)
    VALUES ('UPDATE', NEW.reservation_id, NEW.pnr, NEW.seat_id, NEW.reservation_status, NEW.booking_time);
END;

CREATE TRIGGER trg_reservation_status_delete
AFTER DELETE ON reservation_status
FOR EACH ROW
BEGIN
    INSERT INTO reservation_status_log (operation_type, reservation_id, pnr, seat_id, reservation_status, booking_time)
    VALUES ('DELETE', OLD.reservation_id, OLD.pnr, OLD.seat_id, OLD.reservation_status, OLD.booking_time);
END;

CREATE TABLE payment_transaction_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    txn_id BIGINT,
    total_amount FLOAT,
    txn_status ENUM('PENDING', 'COMPLETE', 'FAILED'),
    payment_mode ENUM('UPI', 'CARD', 'CASH', 'NETBANKING')
);

CREATE TRIGGER trg_payment_transaction_insert
AFTER INSERT ON payment_transaction
FOR EACH ROW
BEGIN
    INSERT INTO payment_transaction_log (operation_type, txn_id, total_amount, txn_status, payment_mode)
    VALUES ('INSERT', NEW.txn_id, NEW.total_amount, NEW.txn_status, NEW.payment_mode);
END;

CREATE TRIGGER trg_payment_transaction_update
AFTER UPDATE ON payment_transaction
FOR EACH ROW
BEGIN
    INSERT INTO payment_transaction_log (operation_type, txn_id, total_amount, txn_status, payment_mode)
    VALUES ('UPDATE', NEW.txn_id, NEW.total_amount, NEW.txn_status, NEW.payment_mode);
END;

CREATE TRIGGER trg_payment_transaction_delete
AFTER DELETE ON payment_transaction
FOR EACH ROW
BEGIN
    INSERT INTO payment_transaction_log (operation_type, txn_id, total_amount, txn_status, payment_mode)
    VALUES ('DELETE', OLD.txn_id, OLD.total_amount, OLD.txn_status, OLD.payment_mode);
END;



CREATE TABLE cancellation_record_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_id BIGINT,
    cancel_time TIMESTAMP,
    refund_amount FLOAT,
    cancel_status ENUM('PENDING', 'COMPLETED', 'FAILED'),
    txn_id BIGINT
);


CREATE TRIGGER trg_cancellation_record_insert
AFTER INSERT ON cancellation_record
FOR EACH ROW
BEGIN
    INSERT INTO cancellation_record_log (operation_type, booking_id, cancel_time, refund_amount, cancel_status, txn_id)
    VALUES ('INSERT', NEW.booking_id, NEW.cancel_time, NEW.refund_amount, NEW.cancel_status, NEW.txn_id);
END;



CREATE TRIGGER trg_cancellation_record_update
AFTER UPDATE ON cancellation_record
FOR EACH ROW
BEGIN
    INSERT INTO cancellation_record_log (operation_type, booking_id, cancel_time, refund_amount, cancel_status, txn_id)
    VALUES ('UPDATE', NEW.booking_id, NEW.cancel_time, NEW.refund_amount, NEW.cancel_status, NEW.txn_id);
END;

CREATE TRIGGER trg_cancellation_record_delete
AFTER DELETE ON cancellation_record
FOR EACH ROW
BEGIN
    INSERT INTO cancellation_record_log (operation_type, booking_id, cancel_time, refund_amount, cancel_status, txn_id)
    VALUES ('DELETE', OLD.booking_id, OLD.cancel_time, OLD.refund_amount, OLD.cancel_status, OLD.txn_id);
END;




