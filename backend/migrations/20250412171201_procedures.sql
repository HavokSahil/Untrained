DROP PROCEDURE IF EXISTS calculate_group_price;
DROP PROCEDURE IF EXISTS create_group_booking;
DROP PROCEDURE IF EXISTS update_booking_status;
DROP PROCEDURE IF EXISTS cancel_booking;
DROP PROCEDURE IF EXISTS get_available_cnf_seats;
DROP PROCEDURE IF EXISTS get_available_rac_seats;
DROP PROCEDURE IF EXISTS calculate_individual_price;
DROP PROCEDURE IF EXISTS get_routes_between_stations;
DROP PROCEDURE IF EXISTS get_stop_options_between_stations;
DROP PROCEDURE IF EXISTS get_trains_between_stations_by_date;
DROP PROCEDURE IF EXISTS get_all_trains_detailed;
DROP PROCEDURE IF EXISTS get_trains_count;
DROP PROCEDURE IF EXISTS insert_schedule_and_shift;

-- This SQL script creates a stored procedure for getting available CNF seats for a given train and journey.
CREATE PROCEDURE get_available_cnf_seats (
    IN p_train_id BIGINT,
    IN p_journey_id BIGINT,
    IN p_limit INT
)
BEGIN
    INSERT INTO temp_available_seats (seat_id, seat_category)
    SELECT s.seat_id, 'CNF'
    FROM seat s
    JOIN coach c ON s.coach_id = c.coach_id
    WHERE c.train_id = p_train_id
      AND s.seat_category = 'CNF'
      AND s.seat_id NOT IN (
          SELECT b.seat_id
          FROM booking b
          WHERE b.journey_id = p_journey_id
            AND b.booking_status IN ('CONFIRMED', 'PENDING')
      )
    LIMIT p_limit;
END;


-- This SQL script creates a stored procedure for getting available RAC seats for a given train and journey.
CREATE PROCEDURE get_available_rac_seats (
    IN p_train_id BIGINT,
    IN p_journey_id BIGINT,
    IN p_limit INT
)
BEGIN
    INSERT INTO temp_available_seats (seat_id, seat_category)
    SELECT s.seat_id, 'RAC'
    FROM seat s
    JOIN coach c ON s.coach_id = c.coach_id
    WHERE c.train_id = p_train_id
      AND s.seat_category = 'RAC'
      AND s.seat_id NOT IN (
          SELECT b.seat_id
          FROM booking b
          WHERE b.journey_id = p_journey_id
            AND b.booking_status IN ('CONFIRMED', 'PENDING')
      )
    LIMIT p_limit;
END;

CREATE PROCEDURE calculate_individual_price(
    IN p_passenger_sex CHAR(1),
    IN p_passenger_disability BOOLEAN,
    IN p_passenger_age INT,
    IN p_base_amount FLOAT,
    OUT p_individual_amount FLOAT
)
BEGIN
    IF p_passenger_sex = 'F' THEN
        -- Women get a 10% discount
        SET p_individual_amount = p_base_amount * 0.9;
    ELSEIF p_passenger_disability = TRUE THEN
        -- Disabled people get a 20% discount
        SET p_individual_amount = p_base_amount * 0.8;
    ELSEIF p_passenger_age < 12 THEN
        -- Children under 12 get a 50% discount
        SET p_individual_amount = p_base_amount * 0.5;
    ELSEIF p_passenger_age >= 60 THEN
        -- Senior citizens get a 30% discount
        SET p_individual_amount = p_base_amount * 0.7;
    ELSE
        -- Men or others pay full price
        SET p_individual_amount = p_base_amount;
    END IF;
END;

-- This SQL script creates a stored procedure for calculating the total price of a group booking.
CREATE PROCEDURE calculate_group_price(
    IN p_group_size INT,  -- Number of passengers in the group
    IN p_passenger_data JSON,  -- A JSON array of passenger details (name, age, sex, disability)
    IN p_base_amount FLOAT,  -- Base amount for a ticket (before any discount)
    OUT p_total_price FLOAT  -- Output: total price of the group
)
BEGIN
    DECLARE i INT;
    DECLARE p_passenger_sex CHAR(1);
    DECLARE p_passenger_disability BOOLEAN;
    DECLARE p_passenger_age INT;
    DECLARE p_individual_amount FLOAT;
    DECLARE p_individual_price FLOAT;

    SET i = 0;
    SET p_individual_price = 0;
    SET p_total_price = 0;

    -- Loop through the group size and calculate price for each passenger
    WHILE i < p_group_size DO
        -- Extract passenger data from JSON
        SET p_passenger_sex = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].sex')));
        SET p_passenger_disability = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].disability')));
        SET p_passenger_age = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].age')));

        -- Calculate individual price based on gender and disability
        CALL calculate_individual_price(p_passenger_sex, p_passenger_disability, p_passenger_age, p_base_amount, p_individual_amount);

        -- Add individual amount to the total price
        SET p_total_price = p_total_price + p_individual_amount;

        -- Increment loop counter
        SET i = i + 1;
    END WHILE;

END;


-- This SQL script creates a stored procedure for creating a group booking.
CREATE PROCEDURE create_group_booking(
    IN p_group_size INT,
    IN p_passenger_data JSON,
    IN p_journey_id BIGINT,
    IN p_train_id BIGINT,
    IN p_start_station_id BIGINT,
    IN p_end_station_id BIGINT,
    IN p_base_amount FLOAT,
    IN p_mode VARCHAR(20)
)
BEGIN
    DECLARE p_txn_id BIGINT;
    DECLARE p_total_price FLOAT;
    DECLARE i INT;
    DECLARE p_pnr BIGINT;
    DECLARE p_passenger_name VARCHAR(100);
    DECLARE p_passenger_age INT;
    DECLARE p_passenger_sex CHAR(1);
    DECLARE p_passenger_disability BOOLEAN;
    DECLARE p_seat_id BIGINT;
    DECLARE p_individual_amount FLOAT;
    DECLARE p_seat_category ENUM('CNF', 'RAC');
    DECLARE temp_total_seats INT;

    SET i = 0;

    -- Temp table for available seats
    CREATE TEMPORARY TABLE temp_available_seats (
        seat_id BIGINT,
        seat_category ENUM('CNF', 'RAC')
    );

    -- Fill CNF seats first
    CALL get_available_cnf_seats(p_train_id, p_journey_id, p_group_size);

    -- Add RAC seats if CNF not enough
    SET temp_total_seats = (SELECT COUNT(*) FROM temp_available_seats);

    IF temp_total_seats < p_group_size THEN
        CALL get_available_rac_seats(p_train_id, p_journey_id, (p_group_size - temp_total_seats));
    END IF;

    -- Calculate group price
    CALL calculate_group_price(p_group_size, p_passenger_data, p_base_amount, p_total_price);

    -- Create payment transaction
    INSERT INTO payment_transaction (total_amount, txn_status, payment_mode)
    VALUES (p_total_price, 'PENDING', p_mode);
    SET p_txn_id = LAST_INSERT_ID();

    -- Booking loop
    WHILE i < p_group_size DO
        -- Extract passenger data
        SET p_passenger_name = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].name')));
        SET p_passenger_age = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].age')));
        SET p_passenger_sex = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].sex')));
        SET p_passenger_disability = JSON_UNQUOTE(JSON_EXTRACT(p_passenger_data, CONCAT('$[', i, '].disability')));

        -- Insert passenger
        INSERT INTO passenger (pass_name, age, sex, disability)
        VALUES (p_passenger_name, p_passenger_age, p_passenger_sex, p_passenger_disability);
        SET p_pnr = LAST_INSERT_ID();

        CALL calculate_individual_price(p_passenger_sex, p_passenger_disability, p_passenger_age, p_base_amount, p_individual_amount);

        -- Assign seat if available
        SELECT seat_id, seat_category
        INTO p_seat_id, p_seat_category
        FROM temp_available_seats
        LIMIT 1;

        IF p_seat_id IS NOT NULL THEN
            -- Insert booking with seat
            INSERT INTO booking (
                booking_time, booking_status, pnr, journey_id, seat_id,
                start_station_id, end_station_id, amount, txn_id
            ) VALUES (
                NOW(), 'PENDING', p_pnr, p_journey_id, p_seat_id,
                p_start_station_id, p_end_station_id, p_individual_amount, p_txn_id
            );

            -- Insert reservation status
            INSERT INTO reservation_status (
                pnr, seat_id, reservation_status, booking_time
            ) VALUES (
                p_pnr, p_seat_id, p_seat_category, NOW()
            );

            -- Remove assigned seat
            DELETE FROM temp_available_seats WHERE seat_id = p_seat_id;
        ELSE
            -- No seats available, mark as waiting
            INSERT INTO booking (
                booking_time, booking_status, pnr, journey_id, seat_id,
                start_station_id, end_station_id, amount, txn_id
            ) VALUES (
                NOW(), 'PENDING', p_pnr, p_journey_id, NULL,
                p_start_station_id, p_end_station_id, p_individual_amount, p_txn_id
            );

            INSERT INTO reservation_status (
                pnr, seat_id, reservation_status, booking_time
            ) VALUES (
                p_pnr, NULL, 'WL', NOW()
            );
        END IF;

        SET i = i + 1;
    END WHILE;

    -- Output
    SELECT p_txn_id AS transaction_id;

    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_available_seats;
END;


-- This SQL script creates a stored procedure for updating the booking status.
CREATE PROCEDURE update_booking_status(
    IN p_booking_id BIGINT,
    IN p_status VARCHAR(20)
)
BEGIN
    -- Update booking status
    UPDATE booking SET booking_status = p_status WHERE booking_id = p_booking_id;
END;

-- This SQL script creates a stored procedure for cancelling a booking.
CREATE PROCEDURE get_routes_between_stations (
    IN in_station_start_id BIGINT,
    IN in_station_end_id BIGINT
)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_stop_option_routes;

    CREATE TEMPORARY TABLE temp_stop_option_routes AS
    SELECT
        dm_start.route_id,
        r.route_name,
        dm_start.station_id AS station_start_id,
        dm_end.station_id AS station_end_id,
        dm_start.order_from_start AS start_order,
        dm_end.order_from_start AS end_order,
        ABS(dm_end.distance - dm_start.distance) AS distance_between
    FROM
        distance_map dm_start
    JOIN
        distance_map dm_end ON dm_start.route_id = dm_end.route_id
    JOIN
        route r ON r.route_id = dm_start.route_id
    WHERE
        dm_start.station_id = in_station_start_id
        AND dm_end.station_id = in_station_end_id
        AND dm_start.station_id != dm_end.station_id
    ORDER BY
        distance_between;
END;

-- This SQL script creates a stored procedure for getting routes between two stations.
CREATE PROCEDURE get_stop_options_between_stations (
    IN in_station_start_id BIGINT,
    IN in_station_end_id BIGINT
)
BEGIN
    DECLARE done INT;
    DECLARE dist_source_station FLOAT;
    DECLARE v_route_id BIGINT;
    DECLARE v_route_name VARCHAR(100);
    DECLARE v_station_start_id BIGINT;
    DECLARE v_station_end_id BIGINT;
    DECLARE v_start_order INT;
    DECLARE v_end_order INT;
    DECLARE v_distance_between FLOAT;

    -- Cursor must be declared before any other SQL statements
    DECLARE cur_routes_cursor CURSOR FOR
        SELECT
            route_id,
            route_name,
            station_start_id,
            station_end_id,
            start_order,
            end_order,
            distance_between
        FROM
            temp_stop_option_routes;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SET done = 0;

    -- Call base procedure to populate routes
    CALL get_routes_between_stations(in_station_start_id, in_station_end_id);

    -- Prepare temporary table for output
    DROP TEMPORARY TABLE IF EXISTS temp_stop_options;
    CREATE TEMPORARY TABLE temp_stop_options (
        station_id BIGINT,
        station_name VARCHAR(100),
        route_id BIGINT,
        route_name VARCHAR(100),
        distance_start_station FLOAT,
        order_from_start INT
    );

    OPEN cur_routes_cursor;

    read_loop: LOOP
        FETCH cur_routes_cursor INTO v_route_id, v_route_name, v_station_start_id, v_station_end_id, v_start_order, v_end_order, v_distance_between;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Get distance of start station in current route
        SELECT distance INTO dist_source_station
        FROM distance_map
        WHERE route_id = v_route_id AND station_id = v_station_start_id;

        -- Insert intermediate stations between start and end stop_order (inclusive)
        INSERT INTO temp_stop_options (station_id, station_name, route_id, route_name, distance_start_station, order_from_start)
        SELECT
            dm.station_id,
            s.station_name,
            dm.route_id,
            r.route_name,
            ABS(dm.distance - dist_source_station),
            dm.order_from_start
        FROM
            distance_map dm
        JOIN
            station s ON dm.station_id = s.station_id
        JOIN
            route r ON r.route_id = dm.route_id
        WHERE
            dm.route_id = v_route_id
            AND dm.order_from_start BETWEEN LEAST(v_start_order, v_end_order) AND GREATEST(v_start_order, v_end_order);
    END LOOP;

    CLOSE cur_routes_cursor;
END;

-- This SQL script creates a stored procedure for getting trains between two stations on a specific date.
CREATE PROCEDURE get_trains_between_stations_by_date (
    IN in_station_start_id BIGINT,
    IN in_station_end_id BIGINT,
    IN journey_date DATE
)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_train_schedule;

    -- Create temporary table of all valid journeys
    CREATE TEMPORARY TABLE temp_train_schedule AS
    SELECT
        j.journey_id,
        t.train_id,
        t.train_name,
        sch_start.station_id AS start_station_id,
        sch_end.station_id AS end_station_id,
        sch_start.sched_toa AS start_time,
        sch_end.sched_toa AS end_time
    FROM
        schedule sch_start
    JOIN
        schedule sch_end ON sch_start.journey_id = sch_end.journey_id
    JOIN
        journey j ON sch_start.journey_id = j.journey_id
    JOIN
        train t ON j.train_id = t.train_id
    WHERE
        sch_start.station_id = in_station_start_id
        AND sch_end.station_id = in_station_end_id
        AND sch_start.stop_number < sch_end.stop_number
        AND DATE(j.start_time) = journey_date;

    -- Return result
    SELECT * FROM temp_train_schedule;
END;


-- This SQL script creates a stored procedure for getting all trains with detailed information.
CREATE PROCEDURE get_all_trains_detailed(
    IN search_train_id BIGINT,
    IN search_train_name VARCHAR(255),
    IN search_train_type VARCHAR(255),
    IN page INT,
    IN page_limit INT,
    IN offset INT
)
BEGIN
    SELECT
        t.train_id AS train_no,
        t.train_name AS train_name,
        t.train_type AS train_type,
        -- Efficient counting of coaches, seats, and journeys using subqueries
        (SELECT COUNT(DISTINCT c.coach_id) 
         FROM coach c
         WHERE c.train_id = t.train_id) AS coaches,
        (SELECT COUNT(DISTINCT s.seat_id) 
         FROM seat s
         WHERE s.coach_id IN (SELECT coach_id FROM coach c WHERE c.train_id = t.train_id)) AS seats,
        (SELECT COUNT(DISTINCT j.journey_id) 
         FROM journey j
         WHERE j.train_id = t.train_id) AS journeys,
        -- Counting upcoming journeys using an optimized condition
        (SELECT COUNT(DISTINCT j.journey_id)
         FROM journey j
         WHERE j.train_id = t.train_id
         AND j.start_time >= NOW()) AS upcoming_journeys
    FROM
        train t
    WHERE
        (search_train_name IS NULL OR t.train_name LIKE CONCAT('%', search_train_name, '%'))
        AND (search_train_type IS NULL OR t.train_type = search_train_type)
        AND (search_train_id = 0 OR t.train_id = search_train_id)
    LIMIT page_limit OFFSET offset;

END;

CREATE PROCEDURE get_trains_count(
    IN search_train_id BIGINT,
    IN search_train_name VARCHAR(255),
    IN search_train_type VARCHAR(255)
)
BEGIN
    -- Select the count of trains based on the provided filters
    SELECT COUNT(*) AS total
    FROM train t
    WHERE
        (search_train_name IS NULL OR t.train_name LIKE CONCAT('%', search_train_name, '%'))
        AND (search_train_type IS NULL OR t.train_type = search_train_type)
        AND (search_train_id = 0 OR t.train_id = search_train_id);
END;

CREATE PROCEDURE insert_schedule_and_shift(
  IN p_journey_id BIGINT,
  IN p_station_id BIGINT,
  IN p_sched_toa DATETIME,
  IN p_sched_tod DATETIME,
  IN p_stop_number INT,
  IN p_route_id BIGINT
)
BEGIN
  -- Shift existing stop_numbers
  UPDATE schedule
  SET stop_number = stop_number + 1
  WHERE journey_id = p_journey_id AND stop_number >= p_stop_number;

  -- Insert new schedule
  INSERT INTO schedule (
    journey_id, station_id, sched_toa, sched_tod, stop_number, route_id
  ) VALUES (
    p_journey_id, p_station_id, p_sched_toa, p_sched_tod, p_stop_number, p_route_id
  );
END;
