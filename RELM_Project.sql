-- We're starting DB Project - Real Estate Listing Management (27/09/2024)
DROP DATABASE IF EXISTS realestatedb;
CREATE DATABASE IF NOT EXISTS RealEstateDB;
USE RealEstateDB;


/*=================================================== Create Tables ==========================================================*/

/* Country table to store country details */
DROP TABLE IF EXISTS country;
CREATE TABLE IF NOT EXISTS country (
    countrycode CHAR(2) NOT NULL,
    countryname VARCHAR(200) NOT NULL,
    countrycapital VARCHAR(255) NOT NULL,
    PRIMARY KEY (countrycode),
    UNIQUE (countryname)
);

/* Living Area table to store state, city, and zip code details */
DROP TABLE IF EXISTS living_area;
CREATE TABLE IF NOT EXISTS living_area (
    living_area_id INT NOT NULL AUTO_INCREMENT,
    countrycode CHAR(2) NOT NULL,
    state VARCHAR(100) NOT NULL,
    county VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (living_area_id),
    UNIQUE (state, city, zip_code),
    FOREIGN KEY (countrycode) REFERENCES country (countrycode)
);

/* Property Type table (replaces house_type) */
DROP TABLE IF EXISTS property_type;
CREATE TABLE IF NOT EXISTS property_type (
    property_type_id int not null auto_increment,
    house boolean default 0,
    apartment boolean default 0,
    villa boolean default 0,
    studio boolean default 0,
    condo boolean default 0,
    cabin boolean default 0,
    primary key (property_type_id)
);

/* House table to store house details */
DROP TABLE IF EXISTS house;
CREATE TABLE IF NOT EXISTS house (
    houseid int not null auto_increment,
    property_type_id int not null,
    countrycode char(2) not null,
    living_area_id int not null,
    primary key (houseid),
    foreign key (property_type_id) references property_type (property_type_id),
    foreign key (countrycode) references country (countrycode),
    foreign key (living_area_id) references living_area (living_area_id)
);

/* Room Type table to store room specifications */
DROP TABLE IF EXISTS room_type;
CREATE TABLE IF NOT EXISTS room_type (
    room_id int not null auto_increment,
    houseid int not null,
    sq_ft decimal(8, 2),
    bed_num int,
    bath_num int,
    kitchen boolean default 0,
    living_room boolean default 0,
    layer int,
    store_space int,
    primary key (room_id),
    foreign key (houseid) references house (houseid)
);

/* Amenity table to store available amenities */
DROP TABLE IF EXISTS amenity;
CREATE TABLE IF NOT EXISTS amenity (
    amenity_id int not null auto_increment,
    houseid int not null,
    front_yard boolean default 0,
    back_yard boolean default 0,
    gym int,
    dog_park int,
    swimming_pool int,
    study_room int,
    recreation_center int,
    grocery_store int,
    costco int,
    primary key (amenity_id),
    foreign key (houseid) references house (houseid)
);

/* Transportation table to store transportation details for the house */
DROP TABLE IF EXISTS transportation;
CREATE TABLE IF NOT EXISTS transportation (
    transport_id int not null auto_increment,
    houseid int not null,
    gas_station decimal(10, 2),
    bus_stop decimal(10, 2),
    tram_stop decimal(10, 2),
    strain_stop decimal(10, 2),
    subway decimal(10, 2),
    airport decimal(10, 2),
    hobart decimal(10, 2),
    primary key (transport_id),
    foreign key (houseid) references house (houseid)
);

/* Utility table to store utility costs for the house */
DROP TABLE IF EXISTS utility;
CREATE TABLE IF NOT EXISTS utility (
    utility_id int not null auto_increment,
    houseid int not null,
    electricity decimal(10, 2),
    water decimal(10, 2),
    gas decimal(10, 2),
    sewer decimal(10, 2),
    trash_disposal decimal(10, 2),
    internet decimal(10, 2),
    waste_management decimal(10, 2),
    insurance decimal(10, 2),
    primary key (utility_id),
    foreign key (houseid) references house (houseid)
);

DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    user_type ENUM('buyer', 'seller', 'agent'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Properties;
CREATE TABLE IF NOT EXISTS Properties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    property_type ENUM('house', 'condo', 'apartment'),
    price DECIMAL(15, 2),
    listing_date DATE,
    status ENUM('available', 'sold', 'under_offer'),
    agent_id INT,
    FOREIGN KEY (agent_id) REFERENCES Users(user_id)
);

DROP TABLE IF EXISTS Property_Features;
CREATE TABLE IF NOT EXISTS Property_Features (
    feature_id INT unsigned NOT NULL auto_increment PRIMARY KEY,
    property_id INT,
    bedrooms INT,
    bathrooms DECIMAL(2, 1),
    square_feet INT,
    lot_size DECIMAL(10, 2),
    year_built YEAR,
    parking_spaces INT,
    approx_price DECIMAL(15, 2), -- New column for approximate price
    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS  Transactions;
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    buyer_id INT,
    seller_id INT,
    property_id INT,
    transaction_date DATE,
    transaction_price DECIMAL(15, 2),
    payment_method VARCHAR(50),
    FOREIGN KEY (buyer_id) REFERENCES Users(user_id),
    FOREIGN KEY (seller_id) REFERENCES Users(user_id),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Reviews;
CREATE TABLE IF NOT EXISTS Reviews (
    review_id INT PRIMARY KEY,
    user_id INT,
    property_id INT,
    agent_id INT,
    review_text TEXT,
    rating DECIMAL(2, 1) CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES Users(user_id)
);

DROP TABLE IF EXISTS property_listing;
CREATE TABLE IF NOT EXISTS property_listing (
    listing_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    houseid INT NOT NULL,
    listing_price DECIMAL(12, 2) NOT NULL,
    listing_date DATE,
    listing_status ENUM('available', 'sold', 'under contract') DEFAULT 'available',
    listing_agent_id INT,
    FOREIGN KEY (houseid) REFERENCES house (houseid),
    FOREIGN KEY (listing_agent_id) REFERENCES Users (user_id)
);

DROP TABLE IF EXISTS sales_transaction;
CREATE TABLE IF NOT EXISTS sales_transaction (
    transaction_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    buyer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_price DECIMAL(12, 2) NOT NULL,
    transaction_status ENUM('completed', 'pending', 'cancelled') DEFAULT 'completed',
    FOREIGN KEY (listing_id) REFERENCES property_listing (listing_id),
    FOREIGN KEY (buyer_id) REFERENCES Users (user_id)
);

DROP TABLE IF EXISTS payment;
CREATE TABLE IF NOT EXISTS payment (
    payment_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('credit card', 'bank transfer', 'cash', 'check') NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES sales_transaction (transaction_id)
);

DROP TABLE IF EXISTS property_inspection;
CREATE TABLE IF NOT EXISTS property_inspection (
    inspection_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    houseid INT NOT NULL,
    inspection_date DATE NOT NULL,
    inspector_name VARCHAR(100),
    inspection_notes TEXT,
    FOREIGN KEY (houseid) REFERENCES house (houseid)
);

DROP TABLE IF EXISTS lease;
CREATE TABLE IF NOT EXISTS lease (
    lease_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    houseid INT NOT NULL,
    tenant_id INT NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    monthly_rent DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (houseid) REFERENCES house (houseid),
    FOREIGN KEY (tenant_id) REFERENCES Users (user_id)
);

DROP TABLE IF EXISTS user_feedback;
CREATE TABLE IF NOT EXISTS user_feedback (
    feedback_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    houseid INT NOT NULL,
    user_id INT NOT NULL,
    feedback_date DATE NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback_text TEXT,
    FOREIGN KEY (houseid) REFERENCES house (houseid),
    FOREIGN KEY (user_id) REFERENCES Users (user_id)
);

DROP TABLE IF EXISTS real_estate_agent;
CREATE TABLE IF NOT EXISTS real_estate_agent (
    agent_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    agency_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users (user_id)
);

DROP TABLE IF EXISTS property_feature;
CREATE TABLE IF NOT EXISTS property_feature (
    feature_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    houseid INT NOT NULL,
    feature_name VARCHAR(255) NOT NULL,
    feature_description TEXT,
    FOREIGN KEY (houseid) REFERENCES house (houseid)
);

DROP TABLE IF EXISTS Neighborhoods;
CREATE TABLE Neighborhoods (
    neighborhood_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(2),
    avg_property_value DECIMAL(15, 2),
    safety_rating DECIMAL(3, 2)
);

DROP TABLE IF EXISTS Schools;
CREATE TABLE Schools (
    school_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    type ENUM('Elementary', 'Middle', 'High'),
    rating DECIMAL(3, 2),
    neighborhood_id INT,
    FOREIGN KEY (neighborhood_id) REFERENCES Neighborhoods(neighborhood_id)
);

DROP TABLE IF EXISTS OpenHouses;
CREATE TABLE OpenHouses (
    open_house_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT,
    date DATE,
    start_time TIME,
    end_time TIME,
    host_agent_id INT,
    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (host_agent_id) REFERENCES Users(user_id)
);

DROP TABLE IF EXISTS PropertyAmenities;
CREATE TABLE PropertyAmenities (
    amenity_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
);

-- Many-to-many relationship table
DROP TABLE IF EXISTS PropertyAmenityLink;
CREATE TABLE PropertyAmenityLink (
    property_id INT,
    amenity_id INT,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES PropertyAmenities(amenity_id)
);


/*=================================================== Insert Values ==========================================================*/

insert into country (countrycode, countryname, countrycapital) values
('US', 'United States', 'Washington, D.C.'),
('CA', 'Canada', 'Ottawa'),
('GB', 'United Kingdom', 'London'),
('AU', 'Australia', 'Canberra'),
('FR', 'France', 'Paris'),
('DE', 'Germany', 'Berlin'),
('IN', 'India', 'New Delhi'),
('JP', 'Japan', 'Tokyo'),
('IT', 'Italy', 'Rome'),
('ES', 'Spain', 'Madrid'),
('BR', 'Brazil', 'Brasilia'),
('MX', 'Mexico', 'Mexico City'),
('CN', 'China', 'Beijing'),
('RU', 'Russia', 'Moscow'),
('ZA', 'South Africa', 'Pretoria');

insert into living_area (countrycode, state, county, city, zip_code) values
('US', 'California', 'Los Angeles County', 'Los Angeles', '90001'),
('US', 'New York', 'Kings County', 'Brooklyn', '11201'),
('CA', 'Ontario', null, 'Toronto', 'M5A 1A1'),
('GB', 'England', 'Greater London', 'London', 'E1 6AN'),
('AU', 'New South Wales', null, 'Sydney', '2000'),
('FR', 'Île-de-France', null, 'Paris', '75001'),
('DE', 'Bavaria', null, 'Munich', '80331'),
('IN', 'Maharashtra', null, 'Mumbai', '400001'),
('JP', 'Tokyo', null, 'Tokyo', '100-0001'),
('IT', 'Lazio', null, 'Rome', '00100'),
('ES', 'Madrid', null, 'Madrid', '28001'),
('BR', 'São Paulo', null, 'São Paulo', '01000-000'),
('MX', 'CDMX', null, 'Mexico City', '01000'),
('CN', 'Beijing', null, 'Beijing', '100000'),
('RU', 'Moscow', null, 'Moscow', '101000');

insert into property_type (house, apartment, villa, studio, condo, cabin) values
(1, 0, 0, 0, 0, 0),
(0, 1, 0, 1, 0, 0),
(1, 0, 0, 0, 1, 0),
(0, 1, 0, 0, 0, 1),
(1, 0, 1, 0, 0, 0),
(0, 0, 1, 0, 0, 0),
(1, 0, 0, 1, 0, 0),
(0, 1, 0, 0, 1, 0),
(1, 0, 0, 0, 0, 1),
(0, 0, 1, 1, 0, 0),
(1, 0, 0, 0, 1, 1),
(0, 1, 0, 0, 0, 0),
(1, 0, 0, 0, 0, 0),
(0, 0, 0, 1, 0, 1),
(1, 0, 0, 1, 0, 0);

insert into house (property_type_id, countrycode, living_area_id) values
(1, 'US', 1),
(2, 'CA', 2),
(3, 'GB', 3),
(4, 'AU', 4),
(5, 'FR', 5),
(6, 'DE', 6),
(7, 'IN', 7),
(8, 'JP', 8),
(9, 'IT', 9),
(10, 'ES', 10),
(11, 'BR', 11),
(12, 'MX', 12),
(13, 'CN', 13),
(14, 'RU', 14),
(15, 'ZA', 15);

insert into room_type (houseid, sq_ft, bed_num, bath_num, kitchen, living_room, layer, store_space) values
(1, 1500, 3, 2, 1, 1, 1, 1),
(2, 1200, 2, 1, 1, 1, 1, 1),
(3, 1800, 4, 3, 1, 1, 2, 1),
(4, 1300, 2, 2, 1, 1, 1, 1),
(5, 1600, 3, 2, 1, 1, 1, 1),
(6, 1400, 2, 1, 1, 1, 1, 1),
(7, 2000, 4, 3, 1, 1, 2, 1),
(8, 1700, 3, 2, 1, 1, 1, 1),
(9, 1500, 3, 2, 1, 1, 1, 1),
(10, 1200, 2, 1, 1, 1, 1, 1),
(11, 1800, 4, 3, 1, 1, 2, 1),
(12, 1300, 2, 2, 1, 1, 1, 1),
(13, 1600, 3, 2, 1, 1, 1, 1),
(14, 1400, 2, 1, 1, 1, 1, 1),
(15, 2000, 4, 3, 1, 1, 2, 1);

insert into amenity (houseid, front_yard, back_yard, gym, dog_park, swimming_pool, study_room, recreation_center, grocery_store, costco) values
(1, 1, 1, 3, 1, 2, 1, 2, 1, 0),
(2, 0, 0, 1, 0, 1, 0, 1, 1, 0),
(3, 1, 1, 5, 2, 3, 2, 4, 2, 1),
(4, 0, 0, 2, 1, 1, 0, 1, 1, 0),
(5, 1, 1, 4, 1, 2, 1, 2, 1, 0),
(6, 0, 0, 1, 0, 1, 0, 1, 1, 0),
(7, 1, 1, 5, 2, 3, 2, 4, 2, 1),
(8, 0, 0, 2, 1, 1, 0, 1, 1, 0),
(9, 1, 1, 4, 1, 2, 1, 2, 1, 0),
(10, 0, 0, 1, 0, 1, 0, 1, 1, 0),
(11, 1, 1, 5, 2, 3, 2, 4, 2, 1),
(12, 0, 0, 2, 1, 1, 0, 1, 1, 0),
(13, 1, 1, 4, 1, 2, 1, 2, 1, 0),
(14, 0, 0, 1, 0, 1, 0, 1, 1, 0),
(15, 1, 1, 5, 2, 3, 2, 4, 2, 1);

insert into transportation (houseid, gas_station, bus_stop, tram_stop, strain_stop, subway, airport, hobart) values
(1, 0.5, 0.2, 0.3, 0.4, 0.6, 1.0, 0.7),
(2, 0.6, 0.3, 0.4, 0.5, 0.7, 1.1, 0.8),
(3, 0.7, 0.4, 0.5, 0.6, 0.8, 1.2, 0.9),
(4, 0.8, 0.5, 0.6, 0.7, 0.9, 1.3, 1.0),
(5, 0.9, 0.6, 0.7, 0.8, 1.0, 1.4, 1.1),
(6, 1.0, 0.7, 0.8, 0.9, 1.1, 1.5, 1.2),
(7, 1.1, 0.8, 0.9, 1.0, 1.2, 1.6, 1.3),
(8, 1.2, 0.9, 1.0, 1.1, 1.3, 1.7, 1.4),
(9, 1.3, 1.0, 1.1, 1.2, 1.4, 1.8, 1.5),
(10, 1.4, 1.1, 1.2, 1.3, 1.5, 1.9, 1.6),
(11, 1.5, 1.2, 1.3, 1.4, 1.6, 2.0, 1.7),
(12, 1.6, 1.3, 1.4, 1.5, 1.7, 2.1, 1.8),
(13, 1.7, 1.4, 1.5, 1.6, 1.8, 2.2, 1.9),
(14, 1.8, 1.5, 1.6, 1.7, 1.9, 2.3, 2.0),
(15, 1.9, 1.6, 1.7, 1.8, 2.0, 2.4, 2.1);

insert into utility (houseid, electricity, water, gas, sewer, trash_disposal, internet, waste_management, insurance) values
(1, 0.5, 0.3, 0.6, 0.4, 0.3, 1.0, 0.8, 1.2),
(2, 0.6, 0.4, 0.7, 0.5, 0.4, 1.1, 0.9, 1.3),
(3, 0.7, 0.5, 0.8, 0.6, 0.5, 1.2, 1.0, 1.4),
(4, 0.8, 0.6, 0.9, 0.7, 0.6, 1.3, 1.1, 1.5),
(5, 0.9, 0.7, 1.0, 0.8, 0.7, 1.4, 1.2, 1.6),
(6, 1.0, 0.8, 1.1, 0.9, 0.8, 1.5, 1.3, 1.7),
(7, 1.1, 0.9, 1.2, 1.0, 0.9, 1.6, 1.4, 1.8),
(8, 1.2, 1.0, 1.3, 1.1, 1.0, 1.7, 1.5, 1.9),
(9, 1.3, 1.1, 1.4, 1.2, 1.1, 1.8, 1.6, 2.0),
(10, 1.4, 1.2, 1.5, 1.3, 1.2, 1.9, 1.7, 2.1),
(11, 1.5, 1.3, 1.6, 1.4, 1.3, 2.0, 1.8, 2.2),
(12, 1.6, 1.4, 1.7, 1.5, 1.4, 2.1, 1.9, 2.3),
(13, 1.7, 1.5, 1.8, 1.6, 1.5, 2.2, 2.0, 2.4),
(14, 1.8, 1.6, 1.9, 1.7, 1.6, 2.3, 2.1, 2.5),
(15, 1.9, 1.7, 2.0, 1.8, 1.7, 2.4, 2.2, 2.6);

INSERT INTO Users (name, email, phone, user_type) VALUES
('Emily Davis', 'emily.davis@gmail.com', '123-123-1234', 'buyer'),
('David Wilson', 'david.wilson@gmail.com', '456-456-4567', 'seller'),
('Linda Moore', 'linda.moore@gmail.com', '789-789-7890', 'agent'),
('Chris Evans', 'chris.evans@gmail.com', '222-333-4444', 'buyer'),
('Olivia Miller', 'olivia.miller@gmail.com', '555-666-7777', 'seller'),
('James Taylor', 'james.taylor@gmail.com', '888-999-0000', 'agent'),
('Sophia White', 'sophia.white@gmail.com', '333-444-5555', 'buyer'),
('Ethan Martin', 'ethan.martin@gmail.com', '666-777-8888', 'seller'),
('Ava Anderson', 'ava.anderson@gmail.com', '999-111-2222', 'agent'),
('Logan Harris', 'logan.harris@gmail.com', '444-555-6666', 'buyer'),
('Grace Scott', 'grace.scott@gmail.com', '123-987-6543', 'agent');

INSERT INTO Properties (address, city, state, zip_code, property_type, price, listing_date, status, agent_id) VALUES
('333 Willow St', 'San Antonio', 'TX', '78201', 'house', 480000, '2024-01-10', 'available', 6),
('222 Oak Dr', 'Fort Worth', 'TX', '76101', 'condo', 270000, '2024-03-25', 'available', 7),
('567 Cypress Ln', 'Plano', 'TX', '75001', 'apartment', 210000, '2024-04-30', 'sold', 8),
('890 Elm St', 'Austin', 'TX', '73301', 'house', 700000, '2024-02-18', 'under_offer', 9),
('555 Palm Dr', 'Houston', 'TX', '77002', 'condo', 330000, '2024-05-05', 'available', 10),
('789 Poplar Ave', 'Dallas', 'TX', '75201', 'house', 520000, '2024-03-15', 'available', 3),
('123 Spruce St', 'Dallas', 'TX', '75201', 'condo', 400000, '2024-04-20', 'available', 11),
('456 Oak Ln', 'Houston', 'TX', '77001', 'house', 630000, '2024-05-12', 'sold', 7),
('789 Pine St', 'Austin', 'TX', '73301', 'apartment', 280000, '2024-02-25', 'available', 8),
('101 Cedar Ave', 'Fort Worth', 'TX', '76101', 'condo', 350000, '2024-03-12', 'available', 6),
('789 Oak Dr', 'Dallas', 'TX', '75202', 'condo', 375000, '2024-05-20', 'available', 11);

-- Inserting updated data with approximate prices
INSERT INTO Property_Features (feature_id, property_id, bedrooms, bathrooms, square_feet, lot_size, year_built, parking_spaces, approx_price) VALUES
(1, 1, 3, 2.5, 1900, 0.20, 2008, 2, 480000),
(2, 2, 2, 1, 1200, 0.10, 2016, 1, 270000),
(3, 3, 1, 1.5, 900, 0.05, 2018, 1, 210000),
(4, 4, 4, 3.5, 2500, 0.30, 2012, 2, 700000),
(5, 5, 3, 2, 1600, 0.25, 2010, 2, 330000),
(6, 6, 4, 3, 2300, 0.40, 2015, 3, 520000),
(7, 7, 2, 2, 1500, 0.12, 2017, 2, 400000),
(8, 8, 3, 2.5, 2000, 0.28, 2014, 2, 630000),
(9, 9, 2, 1, 1100, 0.08, 2016, 1, 280000),
(10, 10, 3, 2, 1700, 0.22, 2013, 2, 350000),
(11, 11, 2, 1.5, 1400, 0.18, 2011, 2, 375000);

INSERT INTO Transactions (transaction_id, buyer_id, seller_id, property_id, transaction_date, transaction_price, payment_method) VALUES
(1, 1, 1, 1, '2024-02-22', 475000, 'credit_card'),
(2, 2, 2, 2, '2024-03-10', 265000, 'bank_transfer'),
(3, 3, 3, 3, '2024-04-25', 205000, 'cash'),
(4, 4, 4, 4, '2024-02-28', 690000, 'cash'),
(5, 5, 5, 5, '2024-05-18', 325000, 'credit_card'),
(6, 6, 6, 6, '2024-03-20', 510000, 'bank_transfer'),
(7, 7, 7, 7, '2024-04-25', 395000, 'credit_card'),
(8, 8, 8, 8, '2024-05-14', 620000, 'cash'),
(9, 9, 9, 9, '2024-02-10', 270000, 'cash'),
(10, 10, 10, 10, '2024-03-19', 345000, 'bank_transfer'),
(11, 11, 11, 11, '2024-06-01', 360000, 'bank_transfer');

INSERT INTO Reviews (review_id, user_id, property_id, agent_id, review_text, rating) VALUES
(1, 1, 1, 6, 'The house was well-maintained, and the agent was very helpful.', 4.8),
(2, 2, 4, 7, 'Amazing property and excellent support from the agent.', 5.0),
(3, 3, 6, 8, 'The property was perfect, and the agent provided great insights.', 4.9),
(4, 4, 8, 9, 'Loved the house and the professionalism of the agent.', 4.7),
(5, 5, 10, 10, 'The agent guided us smoothly, and the property was fantastic.', 4.9),
(6, 6, 1, 6, 'The house met our expectations, and the agent was responsive.', 4.6),
(7, 7, 4, 7, 'The property had all the amenities we needed, thanks to the agent.', 4.9),
(8, 8, 6, 8, 'The agent and property both exceeded expectations.', 4.8),
(9, 9, 8, 9, 'Great collaboration with the agent, and the house was perfect.', 4.7),
(10, 10, 10, 10, 'The property and agent were both outstanding.', 4.9);

-- Insert data into property_listing
INSERT INTO property_listing (houseid, listing_price, listing_date, listing_status, listing_agent_id) VALUES
(1, 500000.00, '2024-10-01', 'available', 1),
(2, 450000.00, '2024-10-02', 'sold', 2),
(3, 600000.00, '2024-10-03', 'under contract', 3),
(4, 700000.00, '2024-10-04', 'available', 1),
(5, 550000.00, '2024-10-05', 'available', 2),
(6, 650000.00, '2024-10-06', 'sold', 3),
(7, 800000.00, '2024-10-07', 'under contract', 1),
(8, 750000.00, '2024-10-08', 'available', 2),
(9, 850000.00, '2024-10-09', 'sold', 3),
(10, 900000.00, '2024-10-10', 'under contract', 1),
(11, 950000.00, '2024-10-11', 'available', 2);

INSERT INTO sales_transaction (listing_id, buyer_id, transaction_date, transaction_price, transaction_status) VALUES
(1, 3, '2024-10-12', 500000.00, 'completed'),
(2, 4, '2024-10-13', 450000.00, 'completed'),
(3, 5, '2024-10-14', 600000.00, 'pending'),
(4, 6, '2024-10-15', 700000.00, 'completed'),
(5, 2, '2024-10-16', 550000.00, 'completed'),
(6, 8, '2024-10-17', 650000.00, 'pending'),
(7, 9, '2024-10-18', 800000.00, 'completed'),
(8, 10, '2024-10-19', 750000.00, 'completed'),
(9, 11, '2024-10-20', 850000.00, 'completed'),
(10, 7, '2024-10-21', 900000.00, 'pending'),
(11, 1, '2024-10-22', 950000.00, 'completed');

INSERT INTO payment (transaction_id, payment_date, amount_paid, payment_method) VALUES
(1, '2024-10-12', 500000.00, 'bank transfer'),
(2, '2024-10-13', 450000.00, 'credit card'),
(3, '2024-10-14', 600000.00, 'bank transfer'),
(4, '2024-10-15', 700000.00, 'cash'),
(5, '2024-10-16', 550000.00, 'credit card'),
(6, '2024-10-17', 650000.00, 'bank transfer'),
(7, '2024-10-18', 800000.00, 'cash'),
(8, '2024-10-19', 750000.00, 'check'),
(9, '2024-10-20', 850000.00, 'credit card'),
(10, '2024-10-21', 900000.00, 'bank transfer'),
(11, '2024-10-22', 950000.00, 'cash');

INSERT INTO property_inspection (houseid, inspection_date, inspector_name, inspection_notes) VALUES
(1, '2024-10-10', 'John Doe', 'Good condition, no repairs needed'),
(2, '2024-10-11', 'Jane Smith', 'Minor repairs in kitchen and bathroom'),
(3, '2024-10-12', 'Robert Johnson', 'Needs landscaping work'),
(4, '2024-10-13', 'Emily Davis', 'Foundation in excellent condition'),
(5, '2024-10-14', 'Michael Brown', 'Roof requires inspection'),
(6, '2024-10-15', 'Linda Williams', 'Swimming pool needs cleaning'),
(7, '2024-10-16', 'David Lee', 'All systems functioning well'),
(8, '2024-10-17', 'Sara White', 'Water damage in basement'),
(9, '2024-10-18', 'Kevin Clark', 'Newly renovated kitchen'),
(10, '2024-10-19', 'Laura Martinez', 'Modern and well-maintained'),
(11, '2024-10-20', 'Mark Taylor', 'Needs minor plumbing fixes');

INSERT INTO lease (houseid, tenant_id, lease_start_date, lease_end_date, monthly_rent) VALUES
(1, 1, '2024-10-01', '2025-10-01', 1500.00),
(2, 2, '2024-10-05', '2025-10-05', 1200.00),
(3, 3, '2024-10-10', '2025-10-10', 1800.00),
(4, 4, '2024-10-15', '2025-10-15', 2200.00),
(5, 5, '2024-10-20', '2025-10-20', 1600.00),
(6, 6, '2024-10-25', '2025-10-25', 2000.00),
(7, 7, '2024-11-01', '2025-11-01', 2500.00),
(8, 8, '2024-11-05', '2025-11-05', 2300.00),
(9, 9, '2024-11-10', '2025-11-10', 2400.00),
(10, 10, '2024-11-15', '2025-11-15', 2600.00),
(11, 11, '2024-11-20', '2025-11-20', 2800.00);

INSERT INTO user_feedback (houseid, user_id, feedback_date, rating, feedback_text) VALUES
(1, 1, '2024-10-02', 5, 'Beautiful property, everything was in great condition.'),
(2, 2, '2024-10-06', 4, 'Nice location, but kitchen could use an update.'),
(3, 3, '2024-10-08', 3, 'Decent property, but the backyard needs work.'),
(4, 4, '2024-10-12', 5, 'Amazing house with modern amenities and great neighborhood.'),
(5, 5, '2024-10-14', 4, 'Nice, spacious house, though the roof needs fixing.'),
(6, 6, '2024-10-18', 4, 'Great place but some plumbing issues in the bathroom.'),
(7, 7, '2024-10-22', 5, 'Everything works perfectly, highly recommended!'),
(8, 8, '2024-10-25', 3, 'House is nice, but needs landscaping and pool maintenance.'),
(9, 9, '2024-10-30', 5, 'Newly renovated, all systems are up-to-date and functional.'),
(10, 10, '2024-11-02', 5, 'Modern, stylish, and well-maintained property.'),
(11, 11, '2024-11-06', 4, 'Great location, but needs a few minor fixes around the house.');

INSERT INTO real_estate_agent (user_id, agency_name, phone, email) VALUES
(1, 'Elite Realty', '123-456-7890', 'agent1@eliterealty.com'),
(2, 'Premium Properties', '234-567-8901', 'agent2@premiumproperties.com'),
(3, 'Top Tier Real Estate', '345-678-9012', 'agent3@toptier.com'),
(4, 'Luxury Homes Realty', '456-789-0123', 'agent4@luxuryhomes.com'),
(5, 'Prime Listings', '567-890-1234', 'agent5@primelistings.com'),
(6, 'Dream Homes Agency', '678-901-2345', 'agent6@dreamhomes.com'),
(7, 'Urban Estates', '789-012-3456', 'agent7@urbanestates.com'),
(8, 'Skyline Properties', '890-123-4567', 'agent8@skylineproperties.com'),
(9, 'Greenfield Realty', '901-234-5678', 'agent9@greenfieldrealty.com'),
(10, 'City Living Realty', '012-345-6789', 'agent10@cityliving.com'),
(11, 'Golden Key Realty', '123-456-7890', 'agent11@goldenkey.com');

INSERT INTO property_feature (houseid, feature_name, feature_description) VALUES
(1, 'Swimming Pool', 'Large in-ground pool with poolside seating area.'),
(2, 'Garden', 'Spacious garden with a variety of flowers and plants.'),
(3, 'Fireplace', 'Cozy living room with a large stone fireplace.'),
(4, 'Home Office', 'Dedicated home office space with built-in shelves.'),
(5, 'Basement', 'Finished basement with ample storage space.'),
(6, 'Patio', 'Covered patio area perfect for outdoor dining.'),
(7, 'Garage', 'Two-car garage with additional storage space.'),
(8, 'Walk-in Closet', 'Large walk-in closet with ample shelving and storage.'),
(9, 'Deck', 'Spacious deck with beautiful views of the surrounding area.'),
(10, 'Outdoor Kitchen', 'Fully equipped outdoor kitchen with grill and sink.'),
(11, 'Jacuzzi', 'Private jacuzzi in the backyard for relaxation.');

-- Inserting values into new tables
INSERT INTO Neighborhoods (name, city, state, avg_property_value, safety_rating) VALUES
('Downtown', 'Dallas', 'TX', 500000, 4.2),
('Uptown', 'Dallas', 'TX', 600000, 4.5),
('Oak Lawn', 'Dallas', 'TX', 550000, 4.3),
('Lakewood', 'Dallas', 'TX', 700000, 4.7),
('Preston Hollow', 'Dallas', 'TX', 1000000, 4.8),
('Deep Ellum', 'Dallas', 'TX', 450000, 3.9),
('Bishop Arts District', 'Dallas', 'TX', 520000, 4.1),
('Knox-Henderson', 'Dallas', 'TX', 580000, 4.4),
('Lower Greenville', 'Dallas', 'TX', 540000, 4.2),
('Oak Cliff', 'Dallas', 'TX', 400000, 3.8),
('White Rock Lake', 'Dallas', 'TX', 650000, 4.6);

INSERT INTO Schools (name, type, rating, neighborhood_id) VALUES
('Dallas Elementary', 'Elementary', 4.2, 1),
('Uptown Middle School', 'Middle', 4.5, 2),
('Oak Lawn High', 'High', 4.3, 3),
('Lakewood Elementary', 'Elementary', 4.7, 4),
('Preston Hollow Middle', 'Middle', 4.8, 5),
('Deep Ellum High', 'High', 3.9, 6),
('Bishop Arts Elementary', 'Elementary', 4.1, 7),
('Knox Middle School', 'Middle', 4.4, 8),
('Greenville High', 'High', 4.2, 9),
('Oak Cliff Elementary', 'Elementary', 3.8, 10),
('White Rock Middle', 'Middle', 4.6, 11);

INSERT INTO OpenHouses (property_id, date, start_time, end_time, host_agent_id) VALUES
(1, '2024-11-20', '10:00:00', '14:00:00', 3),
(2, '2024-11-21', '11:00:00', '15:00:00', 6),
(3, '2024-11-22', '12:00:00', '16:00:00', 7),
(4, '2024-11-23', '13:00:00', '17:00:00', 8),
(5, '2024-11-24', '14:00:00', '18:00:00', 9),
(6, '2024-11-25', '10:30:00', '14:30:00', 10),
(7, '2024-11-26', '11:30:00', '15:30:00', 11),
(8, '2024-11-27', '12:30:00', '16:30:00', 3),
(9, '2024-11-28', '13:30:00', '17:30:00', 6),
(10, '2024-11-29', '14:30:00', '18:30:00', 7),
(11, '2024-11-30', '15:00:00', '19:00:00', 8);

INSERT INTO PropertyAmenities (name, description) VALUES
('Swimming Pool', 'In-ground swimming pool'),
('Gym', 'Fully equipped fitness center'),
('Tennis Court', 'Professional-grade tennis court'),
('Garage', 'Enclosed parking space'),
('Fireplace', 'Wood-burning fireplace'),
('Smart Home System', 'Integrated home automation'),
('Solar Panels', 'Eco-friendly energy solution'),
('Garden', 'Landscaped garden area'),
('Balcony', 'Private outdoor space'),
('Security System', '24/7 monitored security'),
('Home Theater', 'Dedicated entertainment room');

-- Inserting values into the many-to-many relationship table
INSERT INTO PropertyAmenityLink (property_id, amenity_id) VALUES
(1, 1), (1, 4), (1, 5),
(2, 2), (2, 6), (2, 9),
(3, 3), (3, 7), (3, 10),
(4, 1), (4, 2), (4, 3),
(5, 4), (5, 5), (5, 6),
(6, 7), (6, 8), (6, 9),
(7, 10), (7, 11), (7, 1),
(8, 2), (8, 3), (8, 4),
(9, 5), (9, 6), (9, 7),
(10, 8), (10, 9), (10, 10),
(11, 11), (11, 1), (11, 2);


/*=================================================== Basic Queries ==========================================================*/

SELECT * FROM Properties WHERE status = 'available'; -- retrieve all available properties

SELECT name, email, phone FROM Users WHERE user_type = 'buyer'; -- List all the buyers

/* Joins */

-- Retrieve the details of a property and its features
SELECT p.address, pf.bedrooms, pf.bathrooms, pf.square_feet
FROM Properties p
INNER JOIN Property_Features pf ON p.property_id = pf.property_id
WHERE p.property_id = 1;

-- List agents with their average review ratings
SELECT u.name, AVG(r.rating) AS avg_rating
FROM Reviews r
INNER JOIN Users u ON r.agent_id = u.user_id
GROUP BY r.agent_id;


-- All Properties and Their Features (Left Join)
select p.address, pf.bedrooms, pf.bathrooms, pf.square_feet
from Properties p
LEFT JOIN Property_Features pf on p.property_id = pf.property_id;

-- Group By: Average Transaction Price by Seller 
-- Groups transactions by sellers and calculates the average transaction price for each seller.
SELECT u.name AS seller_name, AVG(t.transaction_price) AS avg_price
FROM Users u
JOIN Transactions t ON u.user_id = t.seller_id
GROUP BY u.name;

-- Left Join: Properties with their neighborhoods and schools
SELECT p.property_id, p.address, n.name AS neighborhood, s.name AS nearest_school
FROM Properties p
LEFT JOIN Neighborhoods n ON p.city = n.city AND p.state = n.state
LEFT JOIN Schools s ON n.neighborhood_id = s.neighborhood_id
ORDER BY p.property_id;

-- Right Join: All neighborhoods with properties
SELECT n.name AS neighborhood, p.address, p.price
FROM Properties p
RIGHT JOIN Neighborhoods n ON p.city = n.city AND p.state = n.state
ORDER BY n.name;

-- Self Join: Find properties in the same neighborhood
SELECT p1.property_id, p1.address, p2.property_id AS nearby_property_id, p2.address AS nearby_address
FROM Properties p1
JOIN Properties p2 ON p1.zip_code = p2.zip_code AND p1.property_id < p2.property_id
ORDER BY p1.property_id;

-- Complex Join with Subquery: Properties with amenities and their average price
SELECT p.property_id, p.address,
  GROUP_CONCAT(pa.name SEPARATOR ', ') AS amenities,
  p.price,
  (SELECT AVG(price) FROM Properties WHERE zip_code = p.zip_code) AS avg_neighborhood_price
FROM Properties p
JOIN PropertyAmenityLink pal ON p.property_id = pal.property_id
JOIN PropertyAmenities pa ON pal.amenity_id = pa.amenity_id
GROUP BY p.property_id
HAVING COUNT(pa.amenity_id) > 2
ORDER BY p.price DESC;

-- Complex Query with Window Function: Ranking properties by price within each neighborhood
SELECT p.property_id, p.address, n.name AS neighborhood, p.price,
  RANK() OVER (PARTITION BY n.neighborhood_id ORDER BY p.price DESC) AS price_rank
FROM Properties p
JOIN Neighborhoods n ON p.city = n.city AND p.state = n.state
ORDER BY n.name, price_rank;

-- Many-to-Many Relationship Query: Properties with their amenities
SELECT p.property_id, p.address,
  GROUP_CONCAT(pa.name ORDER BY pa.name ASC SEPARATOR ', ') AS amenities
FROM Properties p
JOIN PropertyAmenityLink pal ON p.property_id = pal.property_id
JOIN PropertyAmenities pa ON pal.amenity_id = pa.amenity_id
GROUP BY p.property_id
ORDER BY p.property_id;


/*=================================================== Stored Procedures ==========================================================*/

-- 1. Procedure to add a new user to the Users table
DELIMITER //
CREATE PROCEDURE AddUser(
    IN userName VARCHAR(100),
    IN userEmail VARCHAR(100),
    IN userPhone VARCHAR(20),
    IN userType ENUM('buyer', 'seller', 'agent')
)
BEGIN
    INSERT INTO Users (name, email, phone, user_type)
    VALUES (userName, userEmail, userPhone, userType);
END //
DELIMITER ;

CALL AddUser('John Doe', 'john.doe@gmail.com', '123-456-7890', 'buyer');
select * from Users;


-- 2. Procedure to List Properties by City and Status
DELIMITER //
CREATE PROCEDURE GetPropertiesByCityAndStatus(
    IN cityName VARCHAR(100),
    IN propertyStatus ENUM('available', 'sold', 'under_offer')
)
BEGIN
    SELECT p.property_id, p.address, p.city, p.state, p.zip_code, 
           p.property_type, p.price, p.status, u.name AS agent_name
    FROM Properties p
    JOIN Users u ON p.agent_id = u.user_id
    WHERE p.city = cityName AND p.status = propertyStatus;
END //
DELIMITER ;

CALL GetPropertiesByCityAndStatus('Dallas', 'available');


-- 3. Procedure to Retrieve All Reviews for an Agent
DELIMITER $$

CREATE PROCEDURE GetAllReviewsOrderedByRating()
BEGIN
    SELECT 
        r.review_id,
        u.name AS reviewer_name,
        p.address AS property_address,
        a.name AS agent_name,
        r.review_text,
        r.rating,
        r.created_at
    FROM Reviews r
    LEFT JOIN Users u ON r.user_id = u.user_id
    LEFT JOIN Properties p ON r.property_id = p.property_id
    LEFT JOIN Users a ON r.agent_id = a.user_id
    WHERE a.user_type = 'agent'
    ORDER BY r.rating DESC;
END$$

DELIMITER ;

CALL GetAllReviewsOrderedByRating();


-- 4. Procedure to Log a Transaction
drop procedure if exists LogTransaction;;
DELIMITER $$

CREATE PROCEDURE LogTransaction(
    IN p_buyer_id INT,
    IN p_seller_id INT,
    IN p_property_id INT,
    IN p_transaction_date DATE,
    IN p_transaction_price DECIMAL(15, 2),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    -- Check if the buyer, seller, and property exist
    IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_buyer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Buyer does not exist.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id = p_seller_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seller does not exist.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Properties WHERE property_id = p_property_id AND status = 'available') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Property does not exist or is not available.';
    END IF;

    -- Insert the transaction record
    INSERT INTO Transactions (buyer_id, seller_id, property_id, transaction_date, transaction_price, payment_method)
    VALUES (p_buyer_id, p_seller_id, p_property_id, p_transaction_date, p_transaction_price, p_payment_method);

    -- Update property status to 'sold'
    UPDATE Properties
    SET status = 'sold'
    WHERE property_id = p_property_id;

    -- Optional: Log the transaction success
    SELECT 'Transaction logged successfully.' AS Message;
END$$

DELIMITER ;

CALL LogTransaction(1, 2, 1, '2024-11-15', 475000, 'credit_card');
select * from Transactions;


-- 5. Procedure to order the prices from lowest to highest
drop procedure if exists GetPropertiesByAscendingPrice;
DELIMITER $$

CREATE PROCEDURE GetPropertiesByAscendingPrice()
BEGIN
    SELECT 
        pf.property_id,
        p.address,
        p.city,
        p.state,
        p.zip_code,
        pf.bedrooms,
        pf.bathrooms,
        pf.square_feet,
        pf.lot_size,
        pf.year_built,
        pf.parking_spaces,
        pf.approx_price
    FROM 
        Property_Features pf
    JOIN 
        Properties p ON pf.property_id = p.property_id
    ORDER BY 
        pf.approx_price ASC;
END$$

DELIMITER ;

CALL GetPropertiesByAscendingPrice();


/*=================================================== Triggers ==========================================================*/

-- 1. Create triggers when inserting transactions
create table if not exists After_Insert_Transactions (
	transaction_id INT UNSIGNED NOT NULL PRIMARY KEY,
    buyer_id INT,
    seller_id INT,
    property_id INT,
    transaction_date DATE,
    transaction_price DECIMAL(15, 2),
    payment_method VARCHAR(50),
    insert_time DATETIME
);

DROP TRIGGER IF EXISTS after_insert_transaction;

delimiter //
create trigger after_insert_transactions
	after insert on transactions
    for each row
    begin
		insert into After_Insert_Transactions (transaction_id, buyer_id, seller_id, property_id,
        transaction_price, transaction_date, payment_method, insert_time)
		values
		(new.transaction_id, new.buyer_id, new.seller_id, new.property_id, new.transaction_price, new.transaction_date, 
        new.payment_method, now());
    end //
delimiter ;

-- Test trigger - after_insert_transactions
select * from transactions;
CALL LogTransaction(8, 4, 2, '2024-10-09', 850000, 'banck_transfer');
select * from transactions;
select * from After_Insert_Transactions;


-- 2. Create triggers when inserting new users
create table if not exists After_Insert_Users (
	user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    user_type ENUM('buyer', 'seller', 'agent'),
    insert_time DATETIME
);

delimiter //
create trigger after_insert_users
	after insert on Users
    for each row
    begin
		insert into After_Insert_Users  (user_id, name, email, phone, user_type, insert_time)
        values
        (new.user_id, new.name, new.email, new.phone, new.user_type, now());
	end //
delimiter ;

-- Test trigger - after_insert_properties
select * from properties;
select * from property_features;
INSERT INTO Properties (address, city, state, zip_code, property_type, price, listing_date, status, agent_id) VALUES
('444 Oak St', 'Austin', 'TX', '78701', 'apartment', 520000, '2024-02-15', 'available', 7);
INSERT INTO Property_Features (feature_id, property_id, bedrooms, bathrooms, square_feet, lot_size, year_built, parking_spaces, approx_price) 
VALUES
(12, 12, 2, 1.5, 1500, 0.15, 2015, 1, 520000);
select * from After_Insert_Users;
select * from properties;
select * from property_features;


-- 3. Create triggers to record when deleting old users
create table if not exists After_Delete_Users (
	user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    user_type ENUM('buyer', 'seller', 'agent'),
    delete_time DATETIME
);

delimiter //
create trigger after_delete_users
	after delete on Users
    for each row
	begin
		insert into After_Delete_Users (user_id, name, email, phone, user_type, delete_time)
        values
        (old.user_id, old.name, old.email, old.phone, old.user_type, now());
	end //
delimiter ;

-- Test trigger - before_delete_properties
select * from properties;
delete from properties
where property_id = 12;
select * from After_Delete_Users;
select * from properties;


-- 4. Create triggers when inserting new property
create table if not exists After_Insert_Properties (
	property_id INT,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    property_type ENUM('house', 'condo', 'apartment'),
    price DECIMAL(15, 2),
    listing_date DATE,
    status ENUM('available', 'sold', 'under_offer'),
    agent_id INT,
    insert_time DATETIME
);

delimiter //
create trigger after_insert_properties
	after insert on Properties
    for each row
    begin
		insert into After_Insert_Properties (property_id, address, city, state, zip_code, property_type, price, listing_date, status, agent_id, insert_time)
        values
        (new.property_id, new.address, new.city, new.state, new.zip_code, new.property_type, new.price, new.listing_date, new.status, new.agent_id, now());
	end //
delimiter ;

-- Test trigger - after_insert_users
select * from users;
INSERT INTO Users (name, email, phone, user_type) VALUES
('Mia Robinson', 'mia.robinson@gmail.com', '777-888-9999', 'buyer');
select * from users;
select * from after_insert_users;


-- 5. Create triggers when deleting property
create table if not exists Before_Delete_Properties (
	property_id INT,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    property_type ENUM('house', 'condo', 'apartment'),
    price DECIMAL(15, 2),
    listing_date DATE,
    status ENUM('available', 'sold', 'under_offer'),
    agent_id INT,
    insert_time DATETIME
);

delimiter //
create trigger before_delete_properties
	before delete on Properties
    for each row
    begin
		insert into Before_Delete_Properties (property_id, address, city, state, zip_code, property_type, price, listing_date, status, agent_id, insert_time)
        values
        (old.property_id, old.address, old.city, old.state, old.zip_code, old.property_type, old.price, old.listing_date, old.status, old.agent_id, now());
	end //
delimiter ;

-- Test trigger - after_delete_users
select * from users;
delete from users
where user_id = 12;
select * from users;
select * from after_delete_users;


/*=================================================== Functions ==========================================================*/


-- 1. Function to count properties within a specified price range
DROP FUNCTION IF EXISTS CountPropertiesByPriceRange;

DELIMITER $$
CREATE FUNCTION CountPropertiesByPriceRange(
    min_price DECIMAL(15, 2),
    max_price DECIMAL(15, 2)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE property_count INT;
    SELECT COUNT(*) INTO property_count
    FROM Properties
    WHERE price BETWEEN min_price AND max_price;
    RETURN property_count;
END$$
DELIMITER ;

-- Call Function:
SELECT CountPropertiesByPriceRange(200000, 700000);


-- 2.Function to calculate the average rating of an agent
DROP FUNCTION IF EXISTS GetAgentAverageRating;

DELIMITER $$
CREATE FUNCTION GetAgentAverageRating(agent_id INT)
RETURNS DECIMAL(3, 2)
DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3, 2);
    SELECT AVG(rating) INTO avg_rating
    FROM Reviews
    WHERE agent_id = agent_id;
    RETURN avg_rating;
END$$
DELIMITER ;

-- Call Function:
SELECT GetAgentAverageRating(6);


-- 3. Function to calculate total revenue from transactions
DROP FUNCTION IF EXISTS GetTotalTransactionRevenue;

DELIMITER $$
CREATE FUNCTION GetTotalTransactionRevenue()
RETURNS DECIMAL(15, 2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(15, 2);
    SELECT SUM(transaction_price) INTO total_revenue
    FROM Transactions;
    RETURN total_revenue;
END$$
DELIMITER ;

-- Call Function:
SELECT GetTotalTransactionRevenue();


-- 4.Function to fetch property details in a given zip code
DROP FUNCTION IF EXISTS GetPropertyDetailsByZip;

DELIMITER $$
CREATE FUNCTION GetPropertyDetailsByZip(zip_code VARCHAR(10))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE property_details VARCHAR(255);
    SELECT GROUP_CONCAT(address SEPARATOR ', ') INTO property_details
    FROM Properties
    WHERE zip_code = zip_code;
    RETURN property_details;
END$$
DELIMITER ;

-- Call Function:
SELECT GetPropertyDetailsByZip('75201');

