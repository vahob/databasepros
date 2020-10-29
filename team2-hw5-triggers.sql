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
        SELECT INTO cancellation_time_flights
        FROM Flight
        WHERE OurTimestamp.c_timestamp <= getCancellationTime(flight_number);
        
        -- join cancellation_time_flights with reservation details table
        
        -- THEN join with Reservation where ticketed = FALSE
        
        -- that will give you all the rows where it is non-ticketed and needs to be canceled
        -- cancel every row in this table
        
        -- should only need a single loop
        
        -- delete where reservation number is in ... query result
        
        FOR ROW IN cancellation_time_flights LOOP
            FOR ROW IN Reservation LOOP
                DELETE FROM Reservation
                WHERE Reservation.ticketed = FALSE AND Reservation.;
                -- remove non-ticketed reservations from each of those flights
                -- Delete from reservation_detail as well?
            END LOOP;
        END LOOP;
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