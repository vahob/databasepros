/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

-- Create table

DROP TABLE IF EXISTS AIRLINE CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PLANE CASCADE;
DROP TABLE IF EXISTS PRICE CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS RESERVATION_DETAIL CASCADE;
DROP TABLE IF EXISTS OURTIMESTAMP CASCADE;
DROP DOMAIN IF EXISTS EMAIL_DOMAIN CASCADE;

--Note: This is a simplified email domain and is not intended to exhaustively check for all requirements of an email
CREATE DOMAIN EMAIL_DOMAIN AS varchar(30)
    CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+\/=?^_`{|}~\-]+@(?:[a-zA-Z0-9\-]+\.)+[a-zA-Z0-9\-]+$' );

CREATE TABLE AIRLINE (
  airline_id            integer,
  airline_name          varchar(50)     NOT NULL,
  airline_abbreviation  varchar(10)     NOT NULL,
  year_founded          integer         NOT NULL,
  CONSTRAINT AIRLINE_PK PRIMARY KEY (airline_id),
  CONSTRAINT AIRLINE_UQ1 UNIQUE (airline_name),
  CONSTRAINT AIRLINE_UQ2 UNIQUE (airline_abbreviation)
);

CREATE TABLE PLANE (
    plane_type      char(4),
    manufacturer    varchar(10)     NOT NULL,
    plane_capacity  integer         NOT NULL,
    last_service    date            NOT NULL,
    year            integer         NOT NULL,
    owner_id        integer         NOT NULL,
    CONSTRAINT PLANE_PK PRIMARY KEY (plane_type,owner_id),
    CONSTRAINT PLANE_FK FOREIGN KEY (owner_id) REFERENCES AIRLINE(airline_id)
);

CREATE TABLE FLIGHT (
    flight_number   integer,
    airline_id      integer     NOT NULL,
    plane_type      char(4)     NOT NULL,
    departure_city  char(3)     NOT NULL,
    arrival_city    char(3)     NOT NULL,
    departure_time  varchar(4)  NOT NULL,
    arrival_time    varchar(4)  NOT NULL,
    weekly_schedule varchar(7)  NOT NULL,
    CONSTRAINT FLIGHT_PK PRIMARY KEY (flight_number),
    CONSTRAINT FLIGHT_FK1 FOREIGN KEY (plane_type,airline_id) REFERENCES PLANE(plane_type,owner_id),
    CONSTRAINT FLIGHT_FK2 FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT FLIGHT_UQ UNIQUE (departure_city, arrival_city)
);

CREATE TABLE PRICE (
    departure_city  char(3),
    arrival_city    char(3),
    airline_id      integer,
    high_price      integer     NOT NULL,
    low_price       integer     NOT NULL,
    CONSTRAINT PRICE_PK PRIMARY KEY (departure_city, arrival_city),
    CONSTRAINT PRICE_FK FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT PRICE_CHECK_HIGH CHECK (high_price >= 0),
    CONSTRAINT PRICE_CHECK_LOW CHECK (low_price >= 0)
);

--Assuming salutation can be NULL as many people don't use salutations on online forms
--Assuming last_name can be NULL as not everyone has a last name, like Cher
--Assuming phone is optional (can be NULL) but email is required
--Assuming that duplicate first_name and last_name pairs are possible since cid will be unique
--Assuming that email addresses should be unique in the table since multiple customers shouldn't sign up with
---the same email
CREATE TABLE CUSTOMER (
    cid                 integer,
    salutation          varchar(3),
    first_name          varchar(30)     NOT NULL,
    last_name           varchar(30),
    credit_card_num     varchar(16)     NOT NULL,
    credit_card_expire  date            NOT NULL,
    street              varchar(30)     NOT NULL,
    city                varchar(30)     NOT NULL,
    state               varchar(2)      NOT NULL,
    phone               varchar(10),
    email               EMAIL_DOMAIN    NOT NULL,
    frequent_miles      varchar(10),
    CONSTRAINT CUSTOMER_PK PRIMARY KEY (cid),
    CONSTRAINT CUSTOMER_FK FOREIGN KEY (frequent_miles) REFERENCES AIRLINE(airline_abbreviation),
    CONSTRAINT CUSTOMER_CCN CHECK (credit_card_num ~ '\d{16}'),
    CONSTRAINT CUSTOMER_UQ1 UNIQUE (credit_card_num),
    CONSTRAINT CUSTOMER_UQ2 UNIQUE (email)
);

--Assuming that a customer can make multiple reservations, i.e., cid and credit_card_num are not unique here
---since multiple reservations will have unique reservation_numbers
CREATE TABLE RESERVATION (
  reservation_number    integer,
  cid                   integer     NOT NULL,
  cost                  decimal     NOT NULL,
  credit_card_num       varchar(16) NOT NULL,
  reservation_date      timestamp   NOT NULL,
  ticketed              boolean     NOT NULL    DEFAULT FALSE,
  CONSTRAINT RESERVATION_PK PRIMARY KEY (reservation_number),
  CONSTRAINT RESERVATION_FK1 FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  CONSTRAINT RESERVATION_FK2 FOREIGN KEY (credit_card_num) REFERENCES CUSTOMER(credit_card_num),
  CONSTRAINT RESERVATION_COST CHECK (cost >= 0)
);

CREATE TABLE RESERVATION_DETAIL (
  reservation_number    integer,
  flight_number         integer     NOT NULL,
  flight_date           timestamp   NOT NULL,
  leg                   integer,
  CONSTRAINT RESERVATION_DETAIL_PK PRIMARY KEY (reservation_number, leg),
  CONSTRAINT RESERVATION_DETAIL_FK1 FOREIGN KEY (reservation_number) REFERENCES RESERVATION(reservation_number) ON DELETE CASCADE,
  CONSTRAINT RESERVATION_DETAIL_FK2 FOREIGN KEY (flight_number) REFERENCES FLIGHT(flight_number),
  CONSTRAINT RESERVATION_DETAIL_CHECK_LEG CHECK (leg > 0)
);

-- The c_timestamp is initialized once using INSERT and updated subsequently
CREATE TABLE OURTIMESTAMP (
    c_timestamp     timestamp,
    CONSTRAINT OURTIMESTAMP_PK PRIMARY KEY (c_timestamp)
);


-- functions

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


-- triggers




CREATE OR REPLACE VIEW CustomerWithMostFaresPerAirline
AS
SELECT G.CID, S, airline_abbreviation
FROM
(SELECT S, CID, flight_number, D.airline_id AS airline_id, A.airline_abbreviation AS airline_abbreviation
FROM
(SELECT S, CID, T.flight_number AS flight_number, F.airline_id AS airline_id
FROM
(SELECT sum(R.cost) as S, R.CID AS CID, RD.flight_number AS flight_number
FROM reservation_detail RD LEFT JOIN reservation R
ON RD.reservation_number = R.reservation_number
GROUP BY R.CID, RD.flight_number
ORDER BY S DESC) T LEFT JOIN flight F ON T.flight_number = F.flight_number
ORDER BY airline_id ASC, S DESC) AS D LEFT JOIN airline A
ON D.airline_id = A.airline_id) AS G LEFT JOIN customer C
ON G.cid = C.cid GROUP BY G.CID, S, G.airline_abbreviation
ORDER BY G.CID, S DESC;



CREATE OR REPLACE VIEW CustomersWithLegPerAirline
AS
SELECT G.cid, SUM(S) AS W, airline_abbreviation
FROM (SELECT S, CID, flight_number, D.airline_id AS airline_id, A.airline_abbreviation AS airline_abbreviation
FROM (SELECT S, CID, T.flight_number AS flight_number, F.airline_id AS airline_id
FROM (SELECT count(leg) AS S, cid, flight_number
FROM (SELECT cid, flight_number, leg
FROM reservation_detail NATURAL JOIN reservation) R
GROUP BY cid, flight_number 
ORDER BY flight_number ASC, S DESC) T LEFT JOIN flight F ON T.flight_number = F.flight_number
ORDER BY airline_id ASC, S DESC) AS D LEFT JOIN airline A
ON D.airline_id = A.airline_id) AS G LEFT JOIN customer C
ON G.cid = C.cid
GROUP BY G.CID, G.airline_abbreviation
ORDER BY G.CID, W DESC;

CREATE OR REPLACE FUNCTION updateFrequentMiles()
    RETURNS TRIGGER AS
$$
DECLARE
    count INTEGER;
    freq_miles customer.frequent_miles%TYPE;
        
BEGIN
        raise notice 'Updating frequent_miles';
         
        SELECT COUNT(CID) AS C INTO count
        FROM (SELECT CID,W, R, airline_abbreviation
        FROM (SELECT  RANK() OVER (PARTITION BY CID ORDER BY W DESC) AS R,
        T.* FROM customerswithlegperairline T) X where X.R <= 2) S
        WHERE CID = NEW.cid AND R = 1
        GROUP BY CID;

        SELECT airline_abbreviation INTO freq_miles FROM
        (SELEct airline_abbreviation, MAX(W) M, cid 
        FROM customerswithlegperairline
        GROUP BY CID, airline_abbreviation
        ORDER BY M DESC) T WHERE
        cid = 1 LIMIT 1; 

		IF NEW.ticketed = TRUE AND count = 1
        THEN UPDATE customer
        SET frequent_miles = freq_miles
        WHERE CID = NEW.cid;
        ELSE

        SELECT airline_abbreviation INTO freq_miles FROM
        (SELEct airline_abbreviation, MAX(S) M, cid 
        FROM CustomersWithMostFaresPerAirline
        GROUP BY CID, airline_abbreviation
        ORDER BY M DESC) T WHERE
        cid = 1 LIMIT 1;
        END IF;

        RETURN NEW;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS frequetFlyer ON reservation;
CREATE TRIGGER frequentFlyer
BEFORE UPDATE OF ticketed
ON reservation
FOR EACH ROW
EXECUTE PROCEDURE updateFrequentMiles();



CREATE OR REPLACE FUNCTION adjustCost()
    RETURNS TRIGGER AS
$$
BEGIN	
        IF NEW.high_price != OLD.high_price THEN
		UPDATE RESERVATION
		SET Cost = Cost - OLD.high_price + NEW.high_price
		WHERE reservation_number IN 
		(
			SELECT Reservation_Number
			FROM reservation_detail RD LEFT JOIN flight F
            ON RD.flight_number = F.flight_number
            WHERE departure_city = new.departure_city
            AND arrival_city= NEW.arrival_city
		) AND ticketed = 'N';
        END IF;

        IF NEW.low_price != OLD.low_price THEN
		UPDATE RESERVATION
		SET Cost = Cost - OLD.low_price + NEW.low_price
		WHERE reservation_number IN 
		(
			SELECT Reservation_Number
			FROM reservation_detail RD LEFT JOIN flight F
            ON RD.flight_number = F.flight_number
            WHERE departure_city = new.departure_city
            AND arrival_city= NEW.arrival_city
		) AND ticketed = 'N';
        END IF;


        RETURN NEW;
END;
$$ language plpgsql;



DROP TRIGGER IF EXISTS adjustTicket ON price;
CREATE TRIGGER adjustTicket
BEFORE UPDATE OF high_price, low_price
ON price
FOR EACH ROW
EXECUTE PROCEDURE adjustCost();

CREATE OR REPLACE PROCEDURE upgradePlaneHelper(flight_num integer, flight_time timestamp) AS
$$
DECLARE
    numberOfSeats    integer;
    upgradeFound     boolean := FALSE;
    currentPlaneType varchar(4);
    airplane_row     RECORD;
    airlinePlanes CURSOR FOR
        SELECT p.plane_type, p.plane_capacity
        FROM flight f
                 JOIN plane p ON f.airline_id = p.owner_id
        WHERE f.flight_number = flight_num
        ORDER BY plane_capacity;
BEGIN
    -- get number of seats for the flight
    numberOfSeats = getNumberOfSeats(flight_num, flight_time);
    raise notice '% number of seats for %', numberOfSeats, flight_num;

    -- get plane type
    SELECT plane_type
    INTO currentPlaneType
    FROM flight
    WHERE flight_number = flight_num;

    -- open cursor
    OPEN airlinePlanes;

    -- check if another plane owned by the airlines can fit current seats
    LOOP
        -- get next plane
        FETCH airlinePlanes INTO airplane_row;
        --exit when done
        EXIT WHEN NOT FOUND;

        -- found a plane can fit (we are starting from the smallest)
        IF numberOfSeats IS NULL OR numberOfSeats + 1 <= airplane_row.plane_capacity THEN
            upgradeFound := TRUE;
            raise notice '% should be upgraded', flight_num;
            -- if the next smallest plane can fit is not the one already scheduled for the flight, then change it
            IF airplane_row.plane_type <> currentPlaneType THEN
                raise notice '% is being upgraded to %', flight_num, airplane_row.plane_type;
                UPDATE flight SET plane_type = airplane_row.plane_type WHERE flight_number = flight_num;
            END IF;
            -- mission accomplished (either we changed the plane OR it is already the next smallest we can fit)
            EXIT;
        END IF;

    END LOOP;

    -- close cursor
    CLOSE airlinePlanes;
    IF NOT upgradeFound THEN
        RAISE EXCEPTION 'There is not any upgrade for the flight % on %',flight_num,flight_time;
    END IF;
END;
$$ language plpgsql;




CREATE OR REPLACE FUNCTION upgradePlane()
    RETURNS TRIGGER AS
$$
BEGIN
    raise notice '% is attempting upgrading', new.flight_number;
    -- downgrade plane in case it is upgradable
    CALL upgradePlaneHelper(new.flight_number, new.flight_date);
    RETURN NEW;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS upgradePlane ON RESERVATION_DETAIL;
CREATE TRIGGER upgradePlane
    BEFORE INSERT
    ON RESERVATION_DETAIL
    FOR EACH ROW
EXECUTE PROCEDURE upgradePlane();



--TEST: Check the trigger upgradePlane

INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t001', 'Plane 01', 1, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t002', 'Plane 02', 2, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t003', 'Plane 03', 3, '2020-12-12', 2020, 3);
UPDATE flight
SET plane_type = 't001'
WHERE flight_number = 3;

INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (2, 3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI'), 3);

SELECT getNumberOfSeats(3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI')::timestamp without time zone);
-- should return 3





CREATE OR REPLACE FUNCTION downgradePlane()
    RETURNS TRIGGER AS
$$

BEGIN
    raise notice '% is attempting upgrading', new.flight_number;
    -- downgrade plane in case it is upgradable
    CALL upgradePlaneHelper(new.flight_number, new.flight_date);
    RETURN NEW;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS planeDowngrade ON RESERVATION_DETAIL;
CREATE TRIGGER planeDowngrade
    BEFORE DELETE
    ON RESERVATION_DETAIL
    FOR EACH ROW
EXECUTE PROCEDURE downgradePlane();

--Q6 cancelReservation Trigger
CREATE OR REPLACE PROCEDURE downgradePlaneHelper(flight_num integer, flight_time timestamp)
AS
$$
DECLARE
    numberOfSeats    integer;
    currentPlaneType varchar(4);
    airplane_row     RECORD;
    airlinePlanes CURSOR FOR
        SELECT p.plane_type, p.plane_capacity
        FROM flight f
                 JOIN plane p ON f.airline_id = p.owner_id
        WHERE f.flight_number = flight_num
        ORDER BY plane_capacity;
BEGIN
    -- get number of seats for the flight
    numberOfSeats = getNumberOfSeats(flight_num, flight_time);
    raise notice '% number of seats for %', numberOfSeats, flight_num;

    -- get plane type
    SELECT plane_type
    INTO currentPlaneType
    FROM flight
    WHERE flight_number = flight_num;

    -- open cursor
    OPEN airlinePlanes;

    -- check if another plane owned by the airlines can fit current seats
    LOOP
        -- get next plane
        FETCH airlinePlanes INTO airplane_row;
        --exit when done
        EXIT WHEN NOT FOUND;

        -- found a plane can fit (we are starting from the smallest)
        IF numberOfSeats - 1 <= airplane_row.plane_capacity THEN
            raise notice '% should be downgraded', flight_num;
            -- if the smallest plane can fit is not the one already scheduled for the flight, then change it
            IF airplane_row.plane_type <> currentPlaneType THEN
                raise notice '% is beign downgraded to %', flight_num, airplane_row.plane_type;
                UPDATE flight SET plane_type = airplane_row.plane_type WHERE flight_number = flight_num;
            END IF;
            -- mission accomplished (either we changed the plane OR it is already the smallest we can fit)
            EXIT;
        END IF;

    END LOOP;

    -- close cursor
    CLOSE airlinePlanes;

END;
$$ language plpgsql;





CREATE OR REPLACE FUNCTION reservationCancellation()
    RETURNS TRIGGER AS
$$
DECLARE
    currentTime      timestamp;
    cancellationTime timestamp;
    reservation_row  RECORD;
    reservations CURSOR FOR
        SELECT *
        FROM (SELECT DISTINCT reservation_number
              FROM RESERVATION AS R
              WHERE R.ticketed = FALSE) AS NONTICKETED
                 NATURAL JOIN (SELECT DISTINCT reservation_number, flight_date, flight_number
                               FROM RESERVATION_DETAIL AS RD
                               WHERE (RD.flight_date >= currentTime)) AS CANCELLABLEFLIGHT ;
BEGIN
    -- capture our simulated current time
    currentTime := new.c_timestamp;

    -- open cursor
    OPEN reservations;

    LOOP
        -- get the next reservation number that is not ticketed
        FETCH reservations INTO reservation_row;

        -- exit loop when all records are processed
        EXIT WHEN NOT FOUND;

        -- get the cancellation time for the fetched reservation
        cancellationTime = getcancellationtime(reservation_row.reservation_number);
        raise notice 'cancellationTime = % and currentTime = %', cancellationTime,currentTime;
        -- delete customer reservation if departures is less than or equal 12 hrs
        IF (cancellationTime <= currentTime) THEN
            raise notice '% is being cancelled', reservation_row.reservation_number;
            -- delete the reservation
            DELETE FROM RESERVATION WHERE reservation_number = reservation_row.reservation_number;
            raise notice '% is attempting downgrading', reservation_row.flight_number;
            CALL downgradePlaneHelper(reservation_row.flight_number, reservation_row.flight_date);
        END IF;

    END LOOP;

    -- close cursor
    CLOSE reservations;

    RETURN new;
END;
$$ LANGUAGE plpgsql;





DROP TRIGGER IF EXISTS cancelReservation ON ourtimestamp;
CREATE TRIGGER cancelReservation
    AFTER UPDATE
    ON OURTIMESTAMP
    FOR EACH ROW
EXECUTE PROCEDURE reservationCancellation();

--TEST: Check the trigger cancelReservation
-- Insert the following tuples if you haven't already done it for Q5
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t001', 'Plane 01', 1, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t002', 'Plane 02', 2, '2020-12-12', 2020, 3);
INSERT INTO plane (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
VALUES ('t003', 'Plane 03', 3, '2020-12-12', 2020, 3);
UPDATE flight
SET plane_type = 't001'
WHERE flight_number = 3;

--INSERT values of RESERVATION_DETAIL Table
BEGIN;
INSERT INTO OURTIMESTAMP (c_timestamp)
VALUES (TO_TIMESTAMP('11-05-2020 02:15', 'MM-DD-YYYY HH24:MI'));
COMMIT;
SELECT getNumberOfSeats(3, TO_TIMESTAMP('11-05-2020 14:15', 'MM-DD-YYYY HH24:MI')::timestamp without time zone);
-- should return 3

BEGIN;
UPDATE OURTIMESTAMP
SET c_timestamp = TO_TIMESTAMP('11-03-2020 20:25', 'MM-DD-YYYY HH24:MI')
WHERE TRUE;
COMMIT;





