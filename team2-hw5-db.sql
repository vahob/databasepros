/* Team 2 */
/* DatabasePros */
/* Vokhob Bazorov - vkb4@pitt.edu */
/* Luiza Urazaeva - lau4@pitt.edu */
/* Nathaniel Stump - nrs70@pitt.edu */

/* Task 1 */

DROP TABLE IF EXISTS Airline CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS OurTimestamp CASCADE;
DROP TABLE IF EXISTS Plane CASCADE;
DROP TABLE IF EXISTS Price CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Reservation_Detail CASCADE;


CREATE TABLE Airline (
   airline_id INTEGER,
   airline_name varchar(50) NOT NULL,
   airline_abbreviation varchar(50) NOT NULL,
   year_founded INTEGER NOT NULL,

   CONSTRAINT PK_Airline PRIMARY KEY(airline_id),
   CONSTRAINT UNIQUE_Airline UNIQUE(airline_abbreviation)
);

CREATE TABLE Plane (
    plane_type CHAR(4),
    manufacturer VARCHAR(10) NOT NULL,
    plane_capacity INTEGER NOT NULL,
    last_service_date DATE NOT NULL,
    year INTEGER,
    owner_id INTEGER,
    CONSTRAINT PK_Plane PRIMARY KEY (plane_type),
    CONSTRAINT FK_Plane FOREIGN KEY (owner_id) REFERENCES Airline(airline_id)
);

CREATE TABLE Flight (
    flight_number INTEGER,
    airline_id INTEGER NOT NULL,
    plane_type CHAR(4) NOT NULL, 
    departure_city CHAR(3) NOT NULL,
    arrival_city CHAR(3) NOT NULL,
    departure_time VARCHAR(4) NOT NULL,
    arrival_time VARCHAR(4) NOT NULL, 
    weekly_schedule VARCHAR(7) NOT NULL,
    CONSTRAINT PK_Flight PRIMARY KEY (flight_number),
    CONSTRAINT FK_Flight1 FOREIGN KEY (plane_type) REFERENCES Plane(plane_type),
    CONSTRAINT FK_Flight2 FOREIGN KEY (airline_id) REFERENCES Airline(airline_id)
);



CREATE TABLE Price (
    departure_city CHAR(3),
    arrival_city CHAR(3),
    airline_id INTEGER NOT NULL,
    high_price INTEGER NOT NULL,
    low_price INTEGER NOT NULL,
    CONSTRAINT PK_Price PRIMARY KEY (departure_city, arrival_city),
    CONSTRAINT FK_Price FOREIGN KEY (airline_id) REFERENCES Airline(airline_id)
);


CREATE TABLE Customer (
    cid INTEGER, 
    salutation VARCHAR(3) NOT NULL
    CHECK (salutation IN ('Mr','Mrs','Ms')),
    first_name VARCHAR(30) NOT NULL, 
    last_name VARCHAR(30) NOT NULL,
    credit_card_num VARCHAR(16) NOT NULL,
    credit_card_expire DATE NOT NULL,
    city VARCHAR(30) NOT NULL,
    street VARCHAR(30) NOT NULL,
    state VARCHAR(2) NOT NULL,
    phone VARCHAR(10) NOT NULL,
    email VARCHAR(30) NOT NULL,
    frequent_miles VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Customer PRIMARY KEY (cid),
    CONSTRAINT FK_Customer FOREIGN KEY (frequent_miles) REFERENCES Airline(airline_abbreviation),
    CONSTRAINT UNIQUE_Customer UNIQUE(credit_card_num)
);

CREATE TABLE Reservation (
    reservation_number INTEGER,
    cid INTEGER NOT NULL,
    cost DECIMAL NOT NULL,
    credit_card_num VARCHAR(16),
    reservation_date TIMESTAMP NOT NULL,
    ticketed BOOLEAN NOT NULL, 
    CONSTRAINT PK_Reservation PRIMARY KEY (reservation_number),
    CONSTRAINT FK_Reservation1 FOREIGN KEY (cid) REFERENCES Customer(cid),
    CONSTRAINT FK_Reservation2 FOREIGN KEY (credit_card_num) REFERENCES Customer(credit_card_num)
);


CREATE TABLE Reservation_Detail (
    reservation_number INTEGER, 
    flight_number INTEGER NOT NULL,
    flight_date TIMESTAMP NOT NULL,
    leg INTEGER NOT NULL,
    CONSTRAINT PK_Reservation_Detail PRIMARY KEY (reservation_number, leg),
    CONSTRAINT FK_Reservation_Detail1 FOREIGN KEY (reservation_number) REFERENCES Reservation(reservation_number),
    CONSTRAINT FK_Reservation_Detail2 FOREIGN KEY (flight_number) REFERENCES Flight(flight_number)
);
CREATE TABLE OurTimestamp (
    c_timestamp TIMESTAMP,
    CONSTRAINT PK_OurTimestamp PRIMARY KEY (c_timestamp)
);
