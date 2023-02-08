-- Create a sequence 
CREATE SCHEMA amz ;  
GO 

CREATE SEQUENCE amz.CountBy1  
    START WITH 1  
    INCREMENT BY 1 ;  
GO
-- Create a new database called 'amazon'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT [name]
        FROM sys.databases
        WHERE [name] = N'amazon'
)
CREATE DATABASE amazon
GO

USE amazon
GO

--DOWN
--order_subcategories
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_os_order_id')
ALTER TABLE order_subcategories DROP CONSTRAINT fk_os_order_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_os_subcategory_id')
ALTER TABLE order_subcategories DROP CONSTRAINT fk_os_subcategory_id

DROP TABLE if EXISTS order_subcategories

--recommender_system
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_rs_payment_id')
ALTER TABLE recommender_systems DROP CONSTRAINT fk_rs_payment_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_rs_subcategory_id')
ALTER TABLE recommender_systems DROP CONSTRAINT fk_rs_subcategory_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_rs_order_id')
ALTER TABLE recommender_systems DROP CONSTRAINT fk_rs_order_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_rs_customer_id')
ALTER TABLE recommender_systems DROP CONSTRAINT fk_rs_customer_id

DROP TABLE IF EXISTS recommender_systems

--amz.payments
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_payment_subcategory_id')
ALTER TABLE amz.payments DROP CONSTRAINT fk_payment_subcategory_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_payment_customer_id')
ALTER TABLE amz.payments DROP CONSTRAINT fk_payment_customer_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_payment_order_id')
ALTER TABLE amz.payments DROP CONSTRAINT fk_payment_order_id

DROP TABLE IF EXISTS amz.payments

--orders
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_order_subcategory_id')
ALTER TABLE orders DROP CONSTRAINT fk_order_subcategory_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_order_customer_id')
ALTER TABLE orders DROP CONSTRAINT fk_order_customer_id

DROP TABLE IF EXISTS orders

--subcategories
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'fk_maincategory_id')
ALTER TABLE subcategories DROP CONSTRAINT fk_maincategory_id

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'u_subcategory_name')
ALTER TABLE subcategories DROP CONSTRAINT u_subcategory_name

DROP TABLE IF EXISTS subcategories

--amz.categories
DROP TABLE IF EXISTS amz.categories

--customers
IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'u_customer_phone')
ALTER TABLE customers DROP CONSTRAINT u_customer_phone

IF EXISTS (SELECT * FROM information_schema.table_constraints
    WHERE CONSTRAINT_NAME = 'u_customer_email')
ALTER TABLE customers DROP CONSTRAINT u_customer_email

DROP TABLE IF EXISTS customers


--UP
CREATE TABLE customers (
    customer_id          INT IDENTITY(1,1) NOT NULL,
    customer_firstname   VARCHAR(50)  NOT NULL,
    customer_lastname    VARCHAR(50)  NOT NULL,
    customer_city        VARCHAR(50)  NOT NULL,
    customer_email       VARCHAR(50)  NOT NULL,
    customer_phone       VARCHAR(12)  NOT NULL
    CONSTRAINT pk_customer_id PRIMARY KEY (customer_id),
    CONSTRAINT u_customer_email UNIQUE (customer_email),
    CONSTRAINT u_customer_phone UNIQUE (customer_phone)
)


CREATE TABLE amz.categories (
    category_id   INT IDENTITY(1,1) NOT NULL,
    category_name VARCHAR(50)  NOT NULL,
    category_type VARCHAR(50)  NULL
    CONSTRAINT pk_category_id PRIMARY KEY (category_id),
)


CREATE TABLE subcategories (
    subcategory_id   INT IDENTITY NOT NULL,
    subcategory_name VARCHAR(50)  NOT NULL,
    product_name     VARCHAR(100) NOT NULL,
    maincategory_id  INT          NOT NULL
    CONSTRAINT pk_subcategory_id PRIMARY KEY (subcategory_id),
)
ALTER TABLE subcategories 
ADD CONSTRAINT fk_maincategory_id FOREIGN KEY (maincategory_id)
REFERENCES amz.categories (category_id)

CREATE TABLE orders (
   order_id               INT IDENTITY NOT NULL,
   order_customer_id      INT          NOT NULL,
   order_date             DATE         NOT NULL,
   order_subcategory_id   INT          NOT NULL
   CONSTRAINT pk_order_id PRIMARY KEY (order_id)
)
ALTER TABLE orders 
ADD CONSTRAINT fk_order_customer_id FOREIGN KEY (order_customer_id)
REFERENCES customers (customer_id)

ALTER TABLE orders 
ADD CONSTRAINT fk_order_subcategory_id FOREIGN KEY (order_subcategory_id)
REFERENCES subcategories (subcategory_id)


CREATE TABLE amz.payments (
    payment_id             INT IDENTITY NOT NULL,
    payment_mode           VARCHAR(50)  NOT NULL,
    payment_date           DATE         NOT NULL,
    payment_order_id       INT          NOT NULL,
    payment_customer_id    INT          NOT NULL,
    payment_category_id    INT          NOT NULL,
    payment_subcategory_id INT          NOT NULL,
    payment_amount         MONEY        NOT NULL
    CONSTRAINT pk_payment_id PRIMARY KEY (payment_id)
)
ALTER TABLE amz.payments 
ADD CONSTRAINT fk_payment_order_id FOREIGN KEY (payment_order_id)
REFERENCES orders (order_id)

ALTER TABLE amz.payments 
ADD CONSTRAINT fk_payment_customer_id FOREIGN KEY (payment_customer_id)
REFERENCES customers (customer_id)

ALTER TABLE amz.payments 
ADD CONSTRAINT fk_payment_subcategory_id FOREIGN KEY (payment_subcategory_id)
REFERENCES subcategories (subcategory_id)

ALTER TABLE amz.payments
ADD payment_status VARCHAR(30);
UPDATE amz.payments
SET payment_status = 'Complete'
ALTER TABLE amz.payments
ALTER COLUMN payment_date DATE NULL

ALTER TABLE recommender_systems
ADD rs_product_name VARCHAR(50);

ALTER TABLE recommender_systems
ADD rs_subcategory_name VARCHAR(50);


CREATE TABLE recommender_systems (
    rs_order_id        INT  NOT NULL,
    rs_customer_id     INT  NOT NULL,
    rs_order_date      DATE NOT NULL,
    rs_subcategory_id  INT  NOT NULL,
    rs_payment_id      INT  NOT NULL
)
ALTER TABLE recommender_systems 
ADD CONSTRAINT fk_rs_customer_id FOREIGN KEY (rs_customer_id)
REFERENCES customers (customer_id)

ALTER TABLE recommender_systems 
ADD CONSTRAINT fk_rs_order_id FOREIGN KEY (rs_order_id)
REFERENCES orders (order_id)

ALTER TABLE recommender_systems 
ADD CONSTRAINT fk_rs_subcategory_id FOREIGN KEY (rs_subcategory_id)
REFERENCES subcategories (subcategory_id)

ALTER TABLE recommender_systems 
ADD CONSTRAINT fk_rs_payment_id FOREIGN KEY (rs_payment_id)
REFERENCES amz.payments (payment_id)

CREATE TABLE order_subcategories (
    os_order_id INT NOT NULL,
    os_subcategory_id INT NOT NULL
)
ALTER TABLE order_subcategories 
ADD CONSTRAINT fk_os_order_id FOREIGN KEY (os_order_id)
REFERENCES orders (order_id)

ALTER TABLE order_subcategories
ADD CONSTRAINT fk_os_subcategory_id FOREIGN KEY (os_subcategory_id)
REFERENCES subcategories (subcategory_id)

--insert values | Customer table
-- Books
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('James', 'Butt', 'New Orleans', 'jbutt@gmail.com', '504-621-8927');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Williard', 'Kolmetz', 'Irving', 'willard@hotmail.com', '972-303-9197');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Erick', 'Ferencz', 'Fairbanks', 'erick.ferencz@aol.com', '907-741-1044');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Maurine', 'Yglesias', 'Milwaukee', 'maurine_yglesias@yglesias.com', '414-748-1374');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Lettie', 'Isenhower', 'Beachwood', 'lettie_isenhower@yahoo.com', '216-657-7668');

-- Video games 
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Mitsue', 'Tollner', 'Chicago', 'mitsue_tollner@yahoo.com', '773-573-6914');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Abel', 'Maclead', 'Middle Island', 'amaclead@gmail.com', '631-335-3414');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Albina', 'Glick', 'Dunellen', 'albina@glick.com', '732-924-7882');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Brock', 'Bolognia', 'New York', 'bbolognia@yahoo.com', '212-402-9216');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Tonette', 'Wenner', 'Westbury', 'twenner@aol.com', '516-968-6051');


-- Pet Supplies
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Art', 'Venere', 'Bridgeport', 'art@venere.org', '856-636-8749');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Mattie', 'Poquette', 'Phoenix', 'mattie@aol.com', '602-277-4385');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Rozella', 'Ostrosky', 'Camarillo', 'rozella.ostrosky@ostrosky.com', '805-832-6163');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Jina', 'Briddick', 'Boston', 'jina_briddick@briddick.com', '617-399-5124');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Deeanna', 'Wenner', 'Westbury', 'dwenner@aol.com', '215-211-9589');


-- Electronics
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Josephine', 'Darakjy', 'Brighton', 'josephine_darakjy@darakjy.org', '810-292-9388');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Bette', 'Nicka', 'Aston', 'bette_nicka@cox.net', '610-545-3615');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Maryann', 'Royster', 'Albany', 'mroyster@royster.com', '518-966-7987');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Fatima', 'Saylors', 'Hopkins', 'fsaylors@saylors.org', '952-768-2416');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Tawna', 'Buvens', 'New York', 'tawna@gmail.com', '212-674-9610');


-- Beauty
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Graciela', 'Ruta', 'Rochester', 'gruta@cox.net', '440-780-8425');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Solange', 'Shinko', 'Hamilton', 'solange@shinko.com', '504-979-9175');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Shenika', 'Seewald', 'Madison', 'shenika@gmail.com', '818-423-4007');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Delisa', 'Crupi', 'Newark', 'delisa.crupi@crupi.com', '973-354-2040');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Natalie', 'Fern', 'Rock Springs', 'natalie.fern@hotmail.com', '307-704-8713');


-- Toys and Games
INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Minna', 'Amigon', 'Newark', 'minna_amigon@yahoo.com', '215-874-1229');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Willow', 'Kusko', 'New York', 'wkusko@yahoo.com', '212-582-4976');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Ernie', 'Stenseth', 'Madison', 'ernie_stenseth@aol.com', '201-709-6245');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Roxane', 'Campain', 'Newark', 'roxane@hotmail.com', '907-231-4722');

INSERT INTO customers (customer_firstname, customer_lastname, customer_city, customer_email, customer_phone)
VALUES ('Karl', 'Klonowski', 'Irving', 'karl_klonowski@yahoo.com', '908-877-6135');










-- INSERT VALUES | Categories table
-- Books
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Books', 'Education & Teaching')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Books', 'Calendars')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Books', 'History')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Books', 'Law')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Books', 'Business & Money')


-- Video games 
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Video Games', 'PlayStation 5')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Video Games', 'Xbox One')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Video Games', 'Mac')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Video Games', 'Legacy Systems')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Video Games', 'Virtual Reality')

-- Pet Supplies
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Pet Supplies', 'dogs')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Pet Supplies', 'cats')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Pet Supplies', 'cats')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Pet Supplies', 'Horses')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Pet Supplies', 'Cats')

-- Electronics
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Electronics', 'Television & Video')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Electronics', 'Camera & Photo')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Electronics', 'Camera & Photo')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Electronics', 'Home Audio')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Electronics', 'Home Audio')

-- Beauty
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Beauty', 'Makeup')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Beauty', 'Hair Care')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Beauty', 'Hair Care')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Beauty', 'Skin Care')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Beauty', 'Fragrance')


-- Toys and Games
INSERT INTO amz.categories (category_name, category_type)
VALUES ('Toys and Games', 'Arts & Crafts')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Toys and Games', 'Building Toys')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Toys and Games', 'Collectible Toys')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Toys and Games', 'Kids Electronics')

INSERT INTO amz.categories (category_name, category_type)
VALUES ('Toys and Games', 'Puzzles')

-- insert values | subcategories table
-- Books
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Schools & Teaching','Learn-to-Write Workbook', '1')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Architecture','Wall Calendar 2022', '2')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Americas', 'This Will Not Pass', '3')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Business','Tax-Free Wealth', '4')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Job Hunting & Careers','From Strength to Strength', '5')

-- Video games 
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Accessories','PlayStation DualSense Wireless Controller', '6')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Consoles', 'Microsoft Xbox One HD Gaming Console','7')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Mac Accessories','USB C Hub Adapter', '8')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Atari Systems','Honeycomb Alpha Flight Controls ', '9')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('PC Hardware','Pimax Vision X VR Headset', '10')


-- Pet Supplies
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Food','Wag Wholesome Grains Dry Dog Food', '11')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Beds & Furniture','Fluffy Donut Cuddler Anxiety Cat Bed', '12')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Beds & Furniture','Fur Fluffy Donut Cuddler Anxiety Cat Bed', '13')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Treats','Apple & Oat Flavored Horse Treats', '14')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Cameras & Monitors', 'Nooie Dog Camera with SD Card', '15')

-- Electronics
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('AV Receivers & Amplifiers','Sony Sound Home Theater AV Receiver', '16')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Bags & Cases','Camera Backpack Bag Professional', '17')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Flashes','Godox Round Head Camera Flash ', '18')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Compact Radios & Stereos','PHILIPS Digital Alarm Clock Radio', '19')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Turntables & Accessories','Wireless Turntable Player', '20')


-- Beauty
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Eyes','Got? Brands Got Lashes', '21')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Hair Accessories','FRAMAR Large Claw Clips', '22')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Hair Accessories','FRAMAR Large Claw Clips', '23')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Lip Care','Burts Bees Overnight Lip Treatment', '24')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Sets','Lavanila - The Healthy Fragrance', '25')


-- Toys and Games
INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Kids Art Clay & Dough','Play-Doh Modeling Compound', '26')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Toy Building Sets','Treehouse Model Building Kits ', '27')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Collectible Postage Stamps','Year of the Dog: Lunar New Year', '28')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Electronic Pets','Tamagotchi Electronic Game', '29')

INSERT INTO subcategories (subcategory_name, product_name, maincategory_id)
VALUES ('Floor Puzzles','MINIWHALE Kids Puzzle', '30')


-- insert values | order table
--books
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-31', '1','1')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-25', '2','2')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-22', '3','3')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-19', '4','4')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-17', '5','5')

--Video games
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-28', '6','6')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-27', '7','7')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-24', '8','8')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-21', '9','9')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-21', '10','10')

--Pet Supplies
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-31', '11','11')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-26', '12','12')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-24', '13','13')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-22', '14','14')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-20', '15','15')

--Electronics
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-31', '16','16')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-25', '17','17')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-25', '18','18')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-22', '19','19')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-19', '20','20')

--Beauty
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-27', '21','21')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-24', '22','22')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-20', '23','23')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-18', '24','24')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-15', '25','25')

--Toys and Games
INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-27', '26','26')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-25', '27','27')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-24', '28','28')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-23', '29','29')

INSERT INTO orders ( order_date,order_subcategory_id, order_customer_id)
VALUES ('2021-12-21', '30','30')

-- insert values | payment table
--books
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Visa', '2021-12-31','1','1','1','1','$4.53')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('China UnionPay', '2021-12-25','2','2','2','2','$9.31')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('NYCE', '2021-12-22','3','3','3','3','$24.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Discover Network', '2021-12-19','4','4','4','4','$17.95')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Visa', '2021-12-17','5','5','5','5','$16.99')

--Video Games
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Diners Club', '2021-12-28','6','6','6','6','$74.00')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Gift Card', '2021-12-27','7','7','7','7','$463.00')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('STAR', '2021-12-24','8','8','8','8','$16.98')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Secured Card', '2021-12-21','9','9','9','9','$499.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('JCB', '2021-12-21','10','10','10','10','$999.00')

--Pet supplies
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Secured Card', '2021-12-31','11','11','11','11','$49.40')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('MasterCard', '2021-12-26','12','12','12','12','$35.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Store Card', '2021-12-24','13','13','13','13','$35.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('China UnionPay', '2021-12-22','14','14','14','14','$36.67')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Gift Card', '2021-12-20','15','15','15','15','$52.99')

--Electronics
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Store Card', '2021-12-31','16','16','16','16','$448.00')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('NYCE', '2021-12-25','17','17','17','17','$29.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Gift Card', '2021-12-25','18','18','18','18','$229.00')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('STAR', '2021-12-22','19','19','19','19','$29.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('American Express', '2021-12-19','20','20','20','20','$59.98')

--Beauty
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Store Card', '2021-12-27','21','21','21','21','$24.95')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Gift Card', '2021-12-24','22','22','22','22','$13.97')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('STAR', '2021-12-20','23','23','23','23','$13.97')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('American Express', '2021-12-18','24','24','24','24','$8.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Amazon Store Card', '2021-12-15','25','25','25','25','$56.00')

--Toys and Games
INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('China UnionPay', '2021-12-27','26','26','26','26','$4.90')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Discover Network', '2021-12-25','27','27','27','27','$188.99')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('NYCE', '2021-12-24','28','28','28','28','$11.88')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Diners Club', '2021-12-23','29','29','29','29','$36.00')

INSERT INTO amz.payments (payment_mode, payment_date, payment_order_id, payment_customer_id, payment_category_id,payment_subcategory_id, payment_amount )
VALUES ('Diners Club', '2021-12-21','30','30','30','30','$12.99')


-- insert values | recommender systems table
-- pet supplies
INSERT INTO recommender_systems(rs_order_id, rs_customer_id, rs_order_date, rs_subcategory_id, rs_payment_id, rs_subcategory_name, rs_product_name)
VALUES('11','11','2021-12-31','11','11','Food','Wag Wholesome Grains Dry Dog Food')

INSERT INTO recommender_systems(rs_order_id, rs_customer_id, rs_order_date, rs_subcategory_id, rs_payment_id, rs_subcategory_name, rs_product_name)
VALUES('12','12', '2021-12-26','12','12','Beds & Furniture','Fluffy Donut Cuddler Anxiety Cat Bed')

INSERT INTO recommender_systems(rs_order_id, rs_customer_id, rs_order_date, rs_subcategory_id, rs_payment_id, rs_subcategory_name, rs_product_name)
VALUES('13','13','2021-12-24','13','13','Beds & Furniture','Fur Fluffy Donut Cuddler Anxiety Cat Bed')

INSERT INTO recommender_systems(rs_order_id, rs_customer_id, rs_order_date, rs_subcategory_id, rs_payment_id, rs_subcategory_name, rs_product_name)
VALUES('14','14','2021-12-22','14','14','Treats','Apple & Oat Flavored Horse Treats')

INSERT INTO recommender_systems(rs_order_id, rs_customer_id, rs_order_date, rs_subcategory_id, rs_payment_id, rs_subcategory_name, rs_product_name)
VALUES('15','15','2021-12-20','15','15','Cameras & Monitors', 'Nooie Dog Camera with SD Card')

--test inserted values
SELECT * FROM customers
SELECT * FROM amz.categories
SELECT * FROM subcategories
SELECT * FROM orders
SELECT * FROM amz.payments
SELECT * FROM recommender_systems
--Business problems
--1. Which 10 customers had the maximum payment amount in December?
SELECT 
    c.customer_id,
    c.customer_firstname + ' ' + c.customer_lastname AS customer_name,
    MAX(p.payment_amount) AS max_payment_amount
FROM customers c 
INNER JOIN amz.payments p ON c.customer_id = p.payment_customer_id
GROUP BY c.customer_id, c.customer_firstname, c.customer_lastname
ORDER BY max_payment_amount DESC

--2. Which 10 customers had the maximum payment amount in the last week of December? (Holiday season)
SELECT 
    c.customer_id,
    c.customer_firstname + ' ' + c.customer_lastname AS customer_name,
    MAX(p.payment_amount) AS max_payment_amount
FROM customers c 
INNER JOIN amz.payments p ON c.customer_id = p.payment_customer_id
WHERE p.payment_date BETWEEN '2021-12-26' AND '2021-12-31' 
GROUP BY c.customer_id, c.customer_firstname, c.customer_lastname
ORDER BY max_payment_amount DESC

--3. Which cities do these customers(in question 2) belong to?
SELECT 
    c.customer_id,
    c.customer_firstname + ' ' + c.customer_lastname AS customer_name,
    MAX(p.payment_amount) AS max_payment_amount,
    c.customer_city
FROM customers c 
INNER JOIN amz.payments p ON c.customer_id = p.payment_customer_id
WHERE p.payment_date BETWEEN '2021-12-26' AND '2021-12-31' 
GROUP BY c.customer_id, c.customer_firstname, c.customer_lastname, c.customer_city
ORDER BY max_payment_amount DESC

--4. What is the total payment amount in each city? Which city has the maximum payment amount in pet supplies?
WITH pivot_city_subcate AS(
SELECT 
    c.customer_city,
    SUM(p.payment_amount) AS payment_amount_sum,
    s.subcategory_name
FROM orders o 
    JOIN amz.payments p ON o.order_id = p.payment_order_id
    JOIN subcategories s ON o.order_subcategory_id = s.subcategory_id
    JOIN customers c ON o.order_customer_id = c.customer_id
GROUP BY c.customer_city, s.subcategory_name
)

SELECT * FROM pivot_city_subcate PIVOT (
    COUNT(payment_amount_sum) FOR subcategory_name IN ([Food], [Beds & Furniture], [Treats], [Cameras & Monitors]) 
) AS pivot_table

--5. Which sub-category has the highest sales in December?
SELECT 
    s.subcategory_name,
    COUNT(*) AS subcate_freq
FROM orders o
    JOIN subcategories s ON o.order_subcategory_id = s.subcategory_id
GROUP BY s.subcategory_name
ORDER BY subcate_freq DESC

--6. Which mode of payment is the most popular among customers?
SELECT 
    payment_mode,
    COUNT(*) AS payment_mode_freq
FROM amz.payments
GROUP BY payment_mode
ORDER BY payment_mode_freq DESC

--7. Show the related sub category of the purchase_category in pet supplies
select Distinct
category_name Main_Category,
rs.rs_subcategory_name as Purchased_Category,
case when rs_subcategory_name like 'Food' then 'Treats'
when rs_subcategory_name like 'Treats' then 'Food'
when rs_subcategory_name like 'Beds & Furniture' then 'Food'
end Recommended_Category_1,
case when rs_subcategory_name like 'Food' then 'Beds & Furniture'
when rs_subcategory_name like 'Treats' then 'Beds & Furniture'
when rs_subcategory_name like 'Beds & Furniture' then 'Treats'
end Recommended_Category_2,
case when rs_subcategory_name like 'Food' then 'Cameras & Monitors'
when rs_subcategory_name like 'Treats' then 'Cameras & Monitors'
when rs_subcategory_name like 'Beds & Furniture' then 'Cameras & Monitors'
end Recommended_Category_3
from recommender_systems rs, subcategories sc, amz.categories ac where sc.subcategory_id =rs.rs_subcategory_id
and ac.category_id =sc.subcategory_id and rs_subcategory_name in ('Food','Treats','Beds & Furniture')

--8. We set a trigger when an order has 0 payment amount. 
--If a customer did not pay, the payment status would be 'Incomplete'.
SELECT * FROM amz.payments

DROP TRIGGER IF EXISTS t_payment_status
GO

CREATE TRIGGER t_payment_status
ON amz.payments
AFTER INSERT
AS BEGIN
    UPDATE amz.payments
        SET payment_status = 'Incomplete'
            FROM amz.payments
            WHERE payment_amount = 0
END

INSERT orders (order_customer_id, order_date, order_subcategory_id)
    VALUES ('30', '2021-12-28', '30')

INSERT amz.payments (payment_mode, 
                    payment_date, 
                    payment_order_id, 
                    payment_customer_id,
                    payment_category_id, 
                    payment_subcategory_id,
                    payment_amount)
    VALUES ('Amazon Gift Card', NULL, '32', '30', '30', '30', '0')

SELECT * FROM amz.payments





select
case 
when sc1.product_name like '% Wag Wholesome Grains%' then (
select sc.product_name,sc.sub_category_name
FROM amz.categories ac,sub_categories sc,recommender_system rs
where ac.category_id =sc.main_category_id and 
sc.sub_category_id = rs.sub_category_id and 
ac.category_name like 'Pet Supplies' and 
sc.sub_category_name in ('Beds & Furniture', 'Treats','Cameras & Monitors') 
and payment_id is not null
from Sub_Catgories sc1