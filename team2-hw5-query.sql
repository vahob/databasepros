/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

/* Task 2 */

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
    cid INTEGER,
    start_city CHAR(3),
    destination_city CHAR(3)
)
AS $$
    DECLARE
       reservation_date OurTimestamp.c_timestamp%TYPE;
       temp_arrival_city CHAR(3);
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
        WHILE destination_city != temp_arrival_city
            LOOP
                
            END LOOP
    COMMIT;
    END
$$ LANGUAGE plpgsql;

SELECT makeReservation();
