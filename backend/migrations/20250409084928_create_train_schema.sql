DROP TABLE IF EXISTS cancellation_record;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS reservation_status;
DROP TABLE IF EXISTS running;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS journey;
DROP TABLE IF EXISTS distance_map;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS coach;
DROP TABLE IF EXISTS payment_transaction;
DROP TABLE IF EXISTS passenger;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS station;
DROP TABLE IF EXISTS train;

-- User Table
CREATE TABLE users (
    email VARCHAR(255) PRIMARY KEY CHECK (email LIKE '%@%'),
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'USER') DEFAULT 'USER'
);

-- Train Table
CREATE TABLE train (
    train_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    train_name VARCHAR(100),
    train_type ENUM('EX', 'ML', 'SF', 'VB', 'MM', 'IN') -- Express, Mail, Superfast, Vande Bharat, MEMU, Intercity
);

-- Coach Table
CREATE TABLE coach (
    coach_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    coach_name VARCHAR(10),
    coach_type ENUM('SL', 'AC3', 'AC2', 'AC1', 'CC', 'FC', '2S'), -- Sleeper, AC 3 Tier, AC 2 Tier, AC 1 Tier, Chair Car, First Class, Second Sitting
    fare FLOAT,
    train_id BIGINT
);

-- Seat Table
CREATE TABLE seat (
    seat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    seat_no BIGINT,
    seat_type ENUM('SL', 'SU', 'LL', 'MD', 'UP', 'ST', 'FC'), -- Sleeper, Side Upper, Lower Berth, Middle Berth, Upper Berth, Side Lower, First Class
    coach_id BIGINT,
    seat_category ENUM("CNF", "RAC") -- Confirmed, RAC
);

-- Station Table
CREATE TABLE station (
    station_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_name VARCHAR(100) UNIQUE NOT NULL,
    station_type ENUM('JN', 'TM', 'HT', 'ST') -- Junction, Terminal, Halt, Station
);

-- Passenger Table
CREATE TABLE passenger (
    pnr BIGINT PRIMARY KEY AUTO_INCREMENT,
    pass_name VARCHAR(100),
    age INT CHECK (age > 0),
    sex CHAR(1),
    disability BOOLEAN,
    email VARCHAR(255) CHECK (email LIKE '%@%')
);

-- Route Table
CREATE TABLE route (
    route_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    route_name VARCHAR(100),
    source_station_id BIGINT
);

-- Distance Map
CREATE TABLE distance_map (
    route_id BIGINT,
    station_id BIGINT,
    distance FLOAT,  -- Distance from source station
    PRIMARY KEY (route_id, station_id)
);

-- Journey Table
CREATE TABLE journey (
    journey_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    start_time TIMESTAMP,
    end_time TIMESTAMP, -- end time > start time 
    train_id BIGINT,
    start_station_id BIGINT,
    end_station_id BIGINT
);

-- Schedule Table
CREATE TABLE schedule (
    sched_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_id BIGINT,
    sched_toa TIMESTAMP,
    sched_tod TIMESTAMP,
    journey_id BIGINT,
    stop_number INT,
    route_id BIGINT
);

-- Running Table
CREATE TABLE running (
    running_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_id BIGINT,
    toa TIMESTAMP,
    tod TIMESTAMP,
    journey_id BIGINT,
    stop_number INT,
    route_id BIGINT
);

-- Booking Table
CREATE TABLE booking (
    booking_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_time TIMESTAMP,
    booking_status ENUM('CONFIRMED', 'CANCELLED', 'PENDING'), -- Confirmed, Cancelled, Pending
    pnr BIGINT,
    journey_id BIGINT,
    txn_id BIGINT,
    amount FLOAT,
    start_station_id BIGINT,
    end_station_id BIGINT,
    seat_id BIGINT
);

CREATE TABLE reservation_status (
    reservation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pnr BIGINT,  -- Passenger's PNR
    seat_id BIGINT,  -- Seat ID if assigned
    reservation_status ENUM('CNF', 'RAC', 'WL') DEFAULT 'WL',  -- Confirmed, RAC, Waiting List
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Transaction Table
CREATE TABLE payment_transaction (
    txn_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    total_amount FLOAT,
    txn_status ENUM('PENDING', 'COMPLETE', 'FAILED'), -- Pending, Complete, Failed
    payment_mode ENUM('UPI', 'CARD', 'CASH', 'NETBANKING') -- UPI, Card, Cash, Netbanking
);

-- Cancellation Record Table
CREATE TABLE cancellation_record (
    booking_id BIGINT PRIMARY KEY,
    cancel_time TIMESTAMP,
    refund_amount FLOAT,
    cancel_status ENUM('PENDING', 'COMPLETED', 'FAILED'), -- Pending, Completed, Failed
    txn_id BIGINT
);


ALTER TABLE coach
ADD CONSTRAINT fk_coach_train
FOREIGN KEY (train_id) REFERENCES train(train_id);

ALTER TABLE seat
ADD CONSTRAINT fk_seat_coach
FOREIGN KEY (coach_id) REFERENCES coach(coach_id);

ALTER TABLE route
ADD CONSTRAINT fk_route_source_station
FOREIGN KEY (source_station_id) REFERENCES station(station_id);

ALTER TABLE distance_map
ADD CONSTRAINT fk_distance_map_route
FOREIGN KEY (route_id) REFERENCES route(route_id),
ADD CONSTRAINT fk_distance_map_station
FOREIGN KEY (station_id) REFERENCES station(station_id);

ALTER TABLE journey
ADD CONSTRAINT fk_journey_train
FOREIGN KEY (train_id) REFERENCES train(train_id),
ADD CONSTRAINT fk_journey_start_station
FOREIGN KEY (start_station_id) REFERENCES station(station_id),
ADD CONSTRAINT fk_journey_end_station
FOREIGN KEY (end_station_id) REFERENCES station(station_id);

ALTER TABLE schedule
ADD CONSTRAINT fk_schedule_station
FOREIGN KEY (station_id) REFERENCES station(station_id),
ADD CONSTRAINT fk_schedule_journey
FOREIGN KEY (journey_id) REFERENCES journey(journey_id),
ADD CONSTRAINT fk_schedule_route
FOREIGN KEY (route_id) REFERENCES route(route_id);

ALTER TABLE running
ADD CONSTRAINT fk_running_station
FOREIGN KEY (station_id) REFERENCES station(station_id),
ADD CONSTRAINT fk_running_journey
FOREIGN KEY (journey_id) REFERENCES journey(journey_id),
ADD CONSTRAINT fk_running_route
FOREIGN KEY (route_id) REFERENCES route(route_id);

ALTER TABLE booking
ADD CONSTRAINT fk_booking_passenger
FOREIGN KEY (pnr) REFERENCES passenger(pnr),
ADD CONSTRAINT fk_booking_journey
FOREIGN KEY (journey_id) REFERENCES journey(journey_id),
ADD CONSTRAINT fk_booking_txn
FOREIGN KEY (txn_id) REFERENCES payment_transaction(txn_id),
ADD CONSTRAINT fk_booking_start_station
FOREIGN KEY (start_station_id) REFERENCES station(station_id),
ADD CONSTRAINT fk_booking_end_station
FOREIGN KEY (end_station_id) REFERENCES station(station_id),
ADD CONSTRAINT fk_booking_seat
FOREIGN KEY (seat_id) REFERENCES seat(seat_id);

ALTER TABLE cancellation_record
ADD CONSTRAINT fk_cancellation_booking
FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
ADD CONSTRAINT fk_cancellation_txn
FOREIGN KEY (txn_id) REFERENCES payment_transaction(txn_id);

ALTER TABLE reservation_status
ADD CONSTRAINT fk_reservation_passenger
FOREIGN KEY (pnr) REFERENCES passenger(pnr),
ADD CONSTRAINT fk_reservation_seat
FOREIGN KEY (seat_id) REFERENCES seat(seat_id);

ALTER TABLE passenger
ADD CONSTRAINT fk_passenger_email
FOREIGN KEY (email) REFERENCES users(email);

-- Add integrity constraint on journey
ALTER TABLE journey
ADD CONSTRAINT chk_journey_time CHECK (end_time > start_time);