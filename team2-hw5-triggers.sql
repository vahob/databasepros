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
