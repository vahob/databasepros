--triggers.sql

--Q5 planeUpgrade Trigger
--Trigger Function for upgrading Plane

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
