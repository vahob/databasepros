/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

/* Task 5 */

CREATE OR REPLACE FUNCTION update_plane()
RETURNS TRIGGER
AS $$
    DECLARE
        plane_cap Plane.plane_capacity%TYPE;
        plane_type1 Flight.plane_type%TYPE;
        plane_rec RECORD;
    BEGIN

        SELECT plane_capacity INTO plane_cap
        FROM Flight NATURAL JOIN Plane
        WHERE flight_number = NEW.flight_number;

        SELECT plane_type INTO plane_type1
        FROM Plane
        WHERE plane_capacity > plane_cap
        ORDER BY plane_capacity;
        
        UPDATE Flight
        SET plane_type = plane_type1
        WHERE flight_number = NEW.flight_number;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER planeUpgrade
BEFORE INSERT ON Reservation_Detail
FOR EACH ROW
WHEN (isPlaneFull(NEW.flight_number))
EXECUTE FUNCTION update_plane();

INSERT INTO Reservation VALUES(6,3,380, '4120892825130802', '11-05-2020 09:30:05.000000', FALSE);
INSERT INTO Reservation_Detail VALUES(6,3,'11-05-2020', 1);

/* Task 6 */

CREATE OR REPLACE FUNCTION remove_reservation()
RETURNS TRIGGER
AS $$
    DECLARE
        cancellationTime Timestamp;
    BEGIN
        cancellationTime = getCancellationTime();
        
        CREATE TEMP TABLE cancellation_time_flights AS
        SELECT *
        FROM Flight
        WHERE OurTimestamp.c_timestamp <= getCancellationTime(flight_number);
        
        -- join cancellation_time_flights with reservation details table
        CREATE TEMP TABLE cancellation_time_flights_with_details AS
        SELECT *
        FROM cancellation_time_flights
        JOIN Reservation_Detail ON flight_number;
        
        -- THEN join with Reservation where ticketed = FALSE
        CREATE TEMP TABLE cancellation_time_flights_with_reservations_and_details AS
        SELECT *
        FROM cancellation_time_flights_with_details
        JOIN Reservation ON reservation_number
        WHERE Reservation.ticketed = FALSE;
        
        -- that will give you all the rows where it is non-ticketed and needs to be canceled
        -- cancel every row in this table
        -- should only need a single loop
        DELETE FROM cancellation_time_flights_with_reservations_and_details CASCADE;
        
        -- downsize flights
    END
$$ LANGUAGE plpgsql;

-- This part is complete - any time OurTimestamp is updated, you just generally call remove_reservation once and handle all flights in one call
CREATE TRIGGER cancelReservation
AFTER INSERT OR UPDATE ON OurTimestamp
FOR EACH ROW
EXECUTE FUNCTION remove_reservation();

-- Cancellation time is the time at which unpaid (ticketed = false) are removed from the table
-- It has nothing to do with the flight itself being cancelled