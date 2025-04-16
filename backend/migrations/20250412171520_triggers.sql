DROP TRIGGER IF EXISTS after_booking_update;
DROP TRIGGER IF EXISTS after_payment_complete;
DROP TRIGGER IF EXISTS adjust_schedule_stop_numbers;
DROP TRIGGER IF EXISTS after_journey_insert;

-- This sql script creates a trigger for after booking update, to update the booking status of the seat
CREATE TRIGGER after_booking_update
AFTER UPDATE ON booking
FOR EACH ROW
BEGIN 
    DECLARE v_seat_id BIGINT;
    DECLARE v_booking_status VARCHAR(20);
    DECLARE v_journey_id BIGINT;

    -- Get the seat_id and booking status
    SELECT seat_id, booking_status, journey_id INTO v_seat_id, v_booking_status, v_journey_id
    FROM booking
    WHERE booking_id = NEW.booking_id;

    -- Update the seat status in the seat table
    if v_booking_status = 'CONFIRMED' THEN
        UPDATE seat SET is_booked = TRUE WHERE seat_id = v_seat_id;
    ELSEIF v_booking_status = 'CANCELLED' THEN
        UPDATE seat SET is_booked = FALSE WHERE seat_id = v_seat_id;
    END IF;

END;

-- This sql script creates a trigger for after payment complete, to update the booking status
CREATE TRIGGER after_payment_complete
AFTER UPDATE ON payment_transaction
FOR EACH ROW
BEGIN
    -- Check if the payment status is COMPLETE
    IF NEW.txn_status = 'COMPLETE' THEN
        -- Update the booking status to 'CONFIRMED'
        UPDATE booking SET booking_status = 'CONFIRMED' WHERE txn_id = NEW.txn_id;
    END IF;
END;

CREATE TRIGGER after_journey_insert
AFTER INSERT ON journey
FOR EACH ROW
BEGIN
    -- Insert the start station into the schedule table
    INSERT INTO schedule (station_id, sched_toa, sched_tod, journey_id, stop_number, route_id)
    VALUES (NEW.start_station_id, NEW.start_time, NEW.start_time, NEW.journey_id, 1, NULL);

    -- Insert the end station into the schedule table
    INSERT INTO schedule (station_id, sched_toa, sched_tod, journey_id, stop_number, route_id)
    VALUES (NEW.end_station_id, NEW.end_time, NEW.end_time, NEW.journey_id, 2, NULL);
END;