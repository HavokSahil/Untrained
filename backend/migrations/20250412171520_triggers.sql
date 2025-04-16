DROP TRIGGER IF EXISTS after_booking_update;
DROP TRIGGER IF EXISTS after_payment_complete;
DROP TRIGGER IF EXISTS adjust_schedule_stop_numbers;
DROP TRIGGER IF EXISTS after_journey_insert;

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