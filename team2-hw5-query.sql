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
    BEGIN
        SELECT flight_date INTO res_date
        FROM Reservation_Detail
        WHERE reservation_number = res_num;
        RETURN res_date - INTERVAL '12 HOURS';
    END
$$ LANGUAGE plpgsql;

SELECT getCancellationTime(1);

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

SELECT isPlaneFull(3);

/* Task 4 */

CREATE OR REPLACE PROCEDURE makeReservation
(
    reservation_number INTEGER,
    flight_num INTEGER,
    departure_date DATE,
    leg INTEGER
)
AS $$
    BEGIN
        -- will need if statement to make sure the weekly schedule lines up
        -- extracts the weekday (DOW) from departure date 
        -- see if it lines up with the weekly schedule
        -- 0-6, 0 is Sunday, 6 is Saturday
        -- if instead of the cooresponding letter, there is a dash, raise an exception and/or exit the function
        INSERT INTO Reservation_Detail VALUES
        (
            reservation_number, 
            flight_num, 
            to_TimeStamp(to_char(departure_date), 'YYYY-MM-DD'), 
            leg
        );
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE callMakeReservation
(
    flight_num INTEGER,
    departure_date DATE,
    leg INTEGER
)
AS $$
    DECLARE
        reservation_number Reservation.reservation_number%TYPE;
        departure_date Reservation.reservation_date%TYPE;
    BEGIN
        CALL makeReservation(reservation_number, flight_num, reservation_date, leg);
    END;
$$ LANGUAGE plpgsql;


BEGIN;
INSERT INTO Reservation VALUES(50,1,1160, '6859941825383380', (SELECT * FROM ourTimeStamp), TRUE);
CALL callMakeReservation(7, '11-02-2020', 1);
CALL callMakeReservation(8, '11-03-2020', 2);
CALL callMakeReservation(9, '11-04-2020', 3);
COMMIT;

-- the departure date that you are given is just a date, not a timestamp
-- the first thing you need to do is take the date and see if it lines up with the weekly schedule of the flight (day of week)
-- if it does not, report this
-- if it does line up, get the departure time from flights table
-- take that string and concatonate it with the given string
-- then convert to a timestamp and specify format

-- make "callMakeReservation" wrapper function to declare variables for reservation_number and reservation_date, then use these as arguments for makeReservation

-- first insert into reservation
-- then use data from the most recently inserted reservation to call make reservation
-- just manually call the makeReservation the proper number of times based off of how many legs there are
-- functionality for doing that automatically will be added later

-- substr is 1-indexed - first character is 1

-- can type rollback to get rid of aborted function