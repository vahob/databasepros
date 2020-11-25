CREATE OR REPLACE FUNCTION is_connecting
(
    schedule1 flight.weekly_schedule%TYPE,
    schedule2 flight.weekly_schedule%TYPE,
    departure_time flight.departure_time%TYPE,
    arrival_time flight.arrival_time%TYPE
)
RETURNS BOOLEAN
AS $$
    DECLARE
        avail BOOLEAN;
    BEGIN
        avail := FALSE;
        IF departure_time::INTEGER > (arrival_time::INTEGER + 100)
        THEN 
            FOR i IN 1.. 7 BY 1
            LOOP
            EXIT WHEN i = 7 AND avail = TRUE;
            IF SUBSTRING(schedule1,i,1) != '-' AND 
                SUBSTRING(schedule1,i,1) = SUBSTRING(schedule2,i,1)
            THEN avail := TRUE;
            END IF;
            END LOOP;
        END IF;
        
        RETURN avail;
    END
$$ LANGUAGE plpgsql;

--Q2 getCancellationTime Function
CREATE OR REPLACE FUNCTION getCancellationTime(reservation_num integer)
    RETURNS timestamp AS
$$
DECLARE
    cancellation_time timestamp;
BEGIN
    SELECT (flight_date - INTERVAL '12 hours')
    INTO cancellation_time
    FROM RESERVATION_DETAIL
    WHERE reservation_number = reservation_num
      AND LEG = 1; -- ALTERNATIVE: ORDER BY flight_date FETCH FIRST ROW ONLY;

    RETURN cancellation_time;
END;
$$ LANGUAGE plpgsql;

--TEST: Check that the function is working properly as expected
SELECT getCancellationTime(1);


CREATE OR REPLACE FUNCTION getFlightTime(flight_num integer, flight_date timestamp)
    RETURNS TIMESTAMP AS
$$
DECLARE
    departure_time flight.departure_time%TYPE;
    timestamp_string VARCHAR(20);
    full_timestamp TIMESTAMP;
BEGIN
    SELECT Flight.departure_time INTO departure_time
    FROM flight
    WHERE flight_number = flight_num;
    
    timestamp_string = CONCAT(TO_CHAR(flight_date,'MM-DD-YYYY'), ' ', concat(SUBSTRING(departure_time,1,2), ':', SUBSTRING(departure_time,3)));
    full_timestamp = to_TimeStamp(timestamp_string, 'MM-DD-YYYY HH24:MI:SS');

    RETURN full_timestamp;
END;
$$ language plpgsql;


--Q3 isPlaneFull Function

-- Q3 Helper function
-- Gets the number of reservations for a specific flight and datetime
-- Returns NULL if the flight or/and the timestamp do not exist
CREATE OR REPLACE FUNCTION getNumberOfSeats(flight_num integer, flight_time timestamp)
    RETURNS INTEGER AS
$$
DECLARE
    result integer;
BEGIN
    SELECT COUNT(reservation_number)
    INTO result
    FROM reservation_detail
    WHERE flight_number = flight_num
      AND flight_date = flight_time
    GROUP BY flight_number, flight_date;

    RETURN result;
END;
$$ language plpgsql;
--TEST: Check that Function is working as expected
SELECT getNumberOfSeats(3,
                        TO_TIMESTAMP('2020-11-05 14:15:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return 2
-- Returns true if the plane is full for a specific flight and datetime
CREATE OR REPLACE FUNCTION isPlaneFull(flight_num integer, flight_d timestamp)
    RETURNS BOOLEAN AS
$$
DECLARE
    max_capacity     integer;
    current_capacity integer;
    result           BOOLEAN := TRUE;
BEGIN
    --Get appropriate plane's capacity
    SELECT plane_capacity
    INTO max_capacity
    FROM PLANE AS P
             NATURAL JOIN (SELECT plane_type
                           FROM FLIGHT
                           WHERE FLIGHT.flight_number = flight_num) AS F;

    --Get number of seats filled on flight
    current_capacity = getNumberOfSeats(flight_num, flight_d);

    IF current_capacity IS NULL THEN
        result := FALSE;
    ELSEIF current_capacity < max_capacity THEN
        result := FALSE;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

--TEST: Check this function is working as expected
SELECT isPlaneFull(1,
                   TO_TIMESTAMP('2020-11-02 13:55:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone); -- should return false
SELECT isPlaneFull(1, TO_TIMESTAMP('2020-11-02 13:56:00', 'YYYY-MM-DD HH24:MI')::timestamp without time zone);
-- should return true with error message



CREATE OR REPLACE FUNCTION validateReservationInfo(reservation_num integer, flight_num integer)
    RETURNS BOOLEAN AS
$$
DECLARE
    reservation_exist BOOLEAN := FALSE;
    flight_exist      BOOLEAN := FALSE;
    result            BOOLEAN := FALSE;
BEGIN
    SELECT (reservation_number = reservation_num)
    INTO reservation_exist
    FROM reservation
    WHERE reservation_number = reservation_num;

    SELECT (flight_number = flight_num)
    INTO flight_exist
    FROM flight
    WHERE flight_number = flight_num;

    IF (reservation_exist IS NULL OR flight_exist IS NULL) THEN
        result := FALSE;
    ELSE
        result := reservation_exist AND flight_exist;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;





-- Get a letter if there is a flight or '-' if there isn't one
CREATE OR REPLACE FUNCTION getDayLetterFromSchedule(departure_date date, flight_num integer)
    RETURNS VARCHAR AS
$$
DECLARE
    day_of_week integer;
    weekly      varchar(7);
    day         varchar(1);
BEGIN
    SELECT EXTRACT(dow FROM departure_date) INTO day_of_week;

    SELECT weekly_schedule
    INTO weekly
    FROM FLIGHT AS F
    WHERE F.flight_number = flight_num;

    --CAUTION: substring function is one-index based and not zero
    SELECT substring(weekly from (day_of_week + 1) for 1) INTO day;

    RETURN day;
END;
$$ language plpgsql;



-- Calculate the departure time based on the date and the flight schedule
CREATE OR REPLACE FUNCTION getCalculatedDepartureDate(departure_date date, flight_num integer)
    RETURNS timestamp AS
$$
DECLARE
    flight_time varchar(5);
BEGIN
    SELECT (substring(DEPT_TABLE.departure_time from 1 for 2) || ':' ||
            substring(DEPT_TABLE.departure_time from 3 for 2))
    INTO flight_time
    FROM (SELECT departure_time
          FROM FLIGHT AS F
          WHERE F.flight_number = flight_num) AS DEPT_TABLE;

    RETURN to_timestamp(departure_date || ' ' || flight_time, 'YYYY-MM-DD HH24:MI');
END;
$$ language plpgsql;



CREATE OR REPLACE PROCEDURE makeReservation(reservation_num integer, flight_num integer, departure_date date,
                                            leg_trip integer)
AS
$$
DECLARE
    information_valid      BOOLEAN := FALSE;
    calculated_flight_date timestamp;
    day                    varchar(1);
BEGIN

    -- make sure arguments are valid
    information_valid = validateReservationInfo(reservation_num, flight_num);

    IF (NOT information_valid) THEN
        RAISE EXCEPTION 'reservation number and/or flight number not valid';
    END IF;

    -- get the letter day from flight schedule corresponding to customer desired departure
    day = getDayLetterFromSchedule(departure_date, flight_num);

    IF day = '-' THEN
        RAISE EXCEPTION 'no available flights on desired departure day';
    END IF;

    -- check flight schedule to get the exact flight_date
    calculated_flight_date = getCalculatedDepartureDate(departure_date, flight_num);

    -- make the reservation
    INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
    VALUES (reservation_num, flight_num, calculated_flight_date, leg_trip);
END;
$$ LANGUAGE plpgsql;





