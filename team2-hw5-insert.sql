/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

-- Airline

INSERT INTO Airline VALUES(1,'Alaska Airlines','ASA', 1932);
INSERT INTO Airline VALUES(2,'Allegiant Air','AAY', 1997);
INSERT INTO Airline VALUES(3,'American Airlines','AAL', 1926);
INSERT INTO Airline VALUES(4,'Delta Air Lines','DAL', 1924);
INSERT INTO Airline VALUES(5,'United Airlines','UAL', 1926);

-- Plane

INSERT INTO Plane VALUES('A320','Airbus',186, '11-03-2020', 1988, 1);
INSERT INTO Plane VALUES('E175','Emraer',76, '10-22-2020', 2004, 2);
INSERT INTO Plane VALUES('B737','Boeing',125, '09-09-2020', 2006, 3);
INSERT INTO Plane VALUES('E145','Embraer',50, '06-15-2020', 2018, 4);
INSERT INTO Plane VALUES('B777','Boeing',368, '09-16-2020', 1995, 5);

-- Flight

INSERT INTO Flight VALUES(1,1,'A320', 'PIT', 'JFK', '1355', '1730', 'SMTWTFS');
INSERT INTO Flight VALUES(2,2,'E175', 'JFK', 'LAX', '0825', '1845', '-MTWTFS');
INSERT INTO Flight VALUES(3,3,'B737', 'LAX', 'SEA', '1415', '1725', 'SMT-TFS');
INSERT INTO Flight VALUES(4,4,'E145', 'SEA', 'IAH', '1005', '2035', 'SMTW--S');
INSERT INTO Flight VALUES(5,5,'B777', 'IAH', 'PIT', '0630', '1620', '-MTW--S');

-- Price

INSERT INTO Price VALUES('PIT','JFK',1, 300, 165);
INSERT INTO Price VALUES('JFK','LAX',2, 480, 345);
INSERT INTO Price VALUES('LAX','SEA',3, 380, 270);
INSERT INTO Price VALUES('SEA','IAH',4, 515, 365);
INSERT INTO Price VALUES('IAH','PIT',5, 435, 255);
INSERT INTO Price VALUES('JFK','PIT',1, 440, 315);
INSERT INTO Price VALUES('LAX','PIT',2, 605, 420);
INSERT INTO Price VALUES('SEA','LAX',3, 245, 150);
INSERT INTO Price VALUES('IAH','SEA',4, 395, 260);
INSERT INTO Price VALUES('PIT','IAH',5, 505, 350);

-- Customer

INSERT INTO Customer VALUES(1,'Mr','Jon', 'Smith', '6859941825383380', 'Bigelow Boulevard', '04-13-2022', 'Pittsburgh','PA','412222222','jsmith@gmail.com','ASA');
INSERT INTO Customer VALUES(2,'Mrs','Latanya', 'Wood', '7212080255339668', 'Houston Street', '07-05-2023', 'New York','NY','7187181717','lw@aol.com','AAY');
INSERT INTO Customer VALUES(3,'Ms','Gabriella', 'Rojas', '4120892825130802', 'Melrose Avenue', '09-22-2024', 'Los Angeles','CA','2133234567','gar@yahoo.com','AAL');
INSERT INTO Customer VALUES(4,'Mr','Abbas', 'Malouf', '4259758505178751', 'Pine Street', '10-17-2021', 'Seattle','WA','2066170345','malouf.a@outlook.com','DAL');
INSERT INTO Customer VALUES(5,'Ms','Amy', 'Liu', '2538244543760285', 'Amber Drive', '03-24-2022', 'Houston','TX','2818880102','amyliu45@icloud.com','UAL');

-- Reservation

INSERT INTO Reservation VALUES(1,1,1160, '6859941825383380', '11-02-2020 19:45:25.000000', TRUE);
INSERT INTO Reservation VALUES(2,2,620, '7212080255339668', '11-22-2020 20:00:30.000000', TRUE);
INSERT INTO Reservation VALUES(3,3,380, '4120892825130802', '11-05-2020 09:30:05.000000', FALSE);
INSERT INTO Reservation VALUES(4,4,255, '4259758505178751', '12-01-2020 13:15:10.000000', TRUE);
INSERT INTO Reservation VALUES(5,5,615, '2538244543760285', '10-28-2020 15:50:15.000000', FALSE);

-- Reservation_Detail

INSERT INTO Reservation_Detail VALUES(1,1,'11-02-2020', 1);
INSERT INTO Reservation_Detail VALUES(1,2,'11-04-2020', 2);
INSERT INTO Reservation_Detail VALUES(1,3,'11-05-2020', 3);
INSERT INTO Reservation_Detail VALUES(2,4,'12-14-2020', 1);
INSERT INTO Reservation_Detail VALUES(2,5,'12-15-2020', 2);
INSERT INTO Reservation_Detail VALUES(3,3,'11-05-2020', 1);
INSERT INTO Reservation_Detail VALUES(4,5,'12-15-2020', 1);
INSERT INTO Reservation_Detail VALUES(5,2,'11-04-2020', 1);
INSERT INTO Reservation_Detail VALUES(5,3,'11-05-2020', 2);

-- OurTimestap

INSERT INTO OurTimestamp VALUES('11-05-2020 02:15');
INSERT INTO OurTimestamp VALUES('11-03-2020 20:25');
INSERT INTO OurTimestamp VALUES('12-13-2020 22:05');

-- Tests

SELECT getCancellationTime(1);
SELECT getCancellationTime(2);
SELECT getCancellationTime(3);
SELECT getCancellationTime(4);
SELECT getCancellationTime(5);
SELECT getCancellationTime(6);

INSERT INTO Plane VALUES('A123','TestPlane',2, '09-16-2020', 1995, 5);
INSERT INTO Flight VALUES(6,1,'A123', 'PIT', 'JFK', '1355', '1730', 'SMTWTFS');

BEGIN;
INSERT INTO Reservation VALUES(51,1,1160, '6859941825383380', (SELECT * FROM ourTimeStamp), TRUE);
CALL makeReservation(51, 6, '11-02-2020', 1);
CALL makeReservation(51, 6, '11-03-2020', 2);
CALL makeReservation(51, 6, '11-05-2020', 3);
COMMIT;

SELECT * FROM FLIGHT
SELECT * FROM RESERVATION

ROLLBACK;

SELECT isPlaneFull(1);
SELECT isPlaneFull(2);
SELECT isPlaneFull(3);
SELECT isPlaneFull(4);
SELECT isPlaneFull(5);
SELECT isPlaneFull(6);

-- Make an insert, delete, or update that causes the trigger to run then test output afterwords to see if it is as expected
