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
    cid INTEGER NOT NULL,
    start_city CHAR(3),
    destination_city CHAR(3)
)
AS $$
    DECLARE
       reservation_date OurTimestamp.c_timestamp%TYPE
    BEGIN
        WITH possible_starting_flights AS
        (
            SELECT *
            FROM flight
            WHERE departure_city = start_city;
        ),
        possible_ending_flights AS
        (
            SELECT *
            FROM flight
            WHERE arrival_city = destination_city;
        )
        
    END
$$ LANGUAGE plpgsql;

SELECT makeReservation();
