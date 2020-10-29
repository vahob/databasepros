/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

/* Task 2 */

-- Assumed that the first leg is inserted first.

CREATE OR REPLACE FUNCTION getCancellationTime(res_num INTEGER)
RETURNS TIMESTAMP
AS $$
    DECLARE
        res_date Reservation_Detail.flight_date%TYPE;
        flight_num Reservation_Detail.flight_number%TYPE;
        departure_time Flight.departure_time%TYPE;
        timestamp_string VARCHAR(20);
        full_timestamp TIMESTAMP;
    BEGIN
        SELECT RD.flight_date INTO res_date
        FROM Reservation_Detail RD
        WHERE reservation_number = res_num;

        SELECT RD.flight_number INTO flight_num
        FROM Reservation_Detail RD
        WHERE reservation_number = res_num;

        SELECT Flight.departure_time INTO departure_time
        FROM Flight
        WHERE flight_number = flight_num;
        
        timestamp_string = CONCAT(TO_CHAR(res_date,'MM-DD-YYYY'), ' ', concat(SUBSTRING(departure_time,1,2), ':', SUBSTRING(departure_time,3)));
        full_timestamp = to_TimeStamp(timestamp_string, 'MM-DD-YYYY HH24:MI:SS');


        RETURN full_timestamp - INTERVAL '12 HOURS';
    END
$$ LANGUAGE plpgsql;


--  SELECT getCancellationTime(1);

/* Task 3 */

CREATE OR REPLACE FUNCTION isPlaneFull(flight_num INTEGER)
RETURNS BOOLEAN
AS $$
    DECLARE 
            capacity Plane.plane_capacity%TYPE;
            passenger_count INTEGER;
    BEGIN
        SELECT plane_capacity INTO capacity
        FROM Flight F NATURAL JOIN Plane P
        WHERE flight_number = flight_num;

        SELECT COUNT(reservation_number) INTO passenger_count
        FROM Reservation_Detail
        WHERE flight_number = flight_num
        GROUP by flight_number;

        IF passenger_count >= capacity
        THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END
$$ LANGUAGE plpgsql;

-- SELECT isPlaneFull(3);

/* Task 4 */

CREATE OR REPLACE PROCEDURE makeReservation
(
    reservation_number INTEGER,
    flight_num INTEGER,
    departure_date DATE,
    leg INTEGER
)
AS $$
    DECLARE
        weekday Integer;
		schedule CHAR(7);
        departure_time VARCHAR(4);
        timestamp_string VARCHAR(20);
        full_timestamp TIMESTAMP;
    BEGIN
        SELECT EXTRACT(DOW FROM departure_date) INTO weekday;
        
        SELECT weekly_schedule INTO schedule
        FROM Flight
        WHERE flight_number = flight_num;
        
        IF SUBSTRING(schedule, weekday+1, 1) = '-' THEN
           RAISE EXCEPTION 'No flight scheduled'
           USING HINT = 'That airline does not fly on that day';
        END IF;
        
        SELECT Flight.departure_time INTO departure_time
        FROM Flight
        WHERE flight_number = flight_num;
        
        timestamp_string = CONCAT(TO_CHAR(departure_date,'MM-DD-YYYY'), ' ', concat(SUBSTRING(departure_time,1,2), ':', SUBSTRING(departure_time,3)));
        full_timestamp = to_TimeStamp(timestamp_string, 'MM-DD-YYYY HH24:MI:SS');
        
        INSERT INTO Reservation_Detail VALUES
        (
            reservation_number, 
            flight_num, 
            full_timestamp, 
            leg
        );
    END;
$$ LANGUAGE plpgsql;
-- Uncomment to call the function.
/* BEGIN;
INSERT INTO Reservation VALUES(50,1,1160, '6859941825383380', (SELECT * FROM ourTimeStamp), TRUE);
CALL makeReservation(50, 1, '11-02-2020', 1);
CALL makeReservation(50, 2, '11-03-2020', 2);
CALL makeReservation(50, 3, '11-05-2020', 3);
COMMIT; */

-- will need if statement to make sure the weekly schedule lines up
-- extracts the weekday (DOW) from departure date 
-- see if it lines up with the weekly schedule
-- 0-6, 0 is Sunday, 6 is Saturday
-- if instead of the cooresponding letter, there is a dash, raise an exception and/or exit the function

-- the departure date that you are given is just a date, not a timestamp
-- the first thing you need to do is take the date and see if it lines up with the weekly schedule of the flight (day of week)
-- if it does not, report this
-- if it does line up, get the departure time from flights table
-- take that string and concatonate it with the given string
-- then convert to a timestamp and specify format

-- first insert into reservation
-- then use data from the most recently inserted reservation to call make reservation
-- just manually call the makeReservation the proper number of times based off of how many legs there are
-- functionality for doing that automatically will be added later

-- substr is 1-indexed - first character is 1

-- can type rollback to get rid of aborted function
