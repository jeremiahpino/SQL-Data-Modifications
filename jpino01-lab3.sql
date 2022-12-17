-- Lab 3
-- jpino01
-- Oct 17, 2022

USE `jpino01`;
-- BAKERY-1
-- Using a single SQL statement, reduce the prices of Lemon Cake and Napoleon Cake by $2.
-- update goods table
UPDATE goods

-- reduce the price column by 2 where...
SET
    Price = Price - 2
    
-- reduce price WHERE Food is Cake and Flavor is Lemon or Napoleon
WHERE 
    Food = "Cake" AND Flavor = "Lemon" OR Flavor = "Napoleon";


USE `jpino01`;
-- BAKERY-2
-- Using a single SQL statement, increase by 15% the price of all Apricot or Chocolate flavored items with a current price below $5.95.
-- update goods table
UPDATE goods
-- set the colum of price
SET
    -- CASE statment is an if-else statement
    Price = CASE 
        WHEN (Price < 5.95) 
        THEN Price + ((Price * 15) / 100) 
        ELSE Price 
    END
-- set above column if column Flavor is Apricot or Chocolate    
WHERE
    Flavor = "Apricot" OR Flavor = "Chocolate";


USE `jpino01`;
-- BAKERY-3
-- Add the capability for the database to record payment information for each receipt in a new table named payments (see assignment PDF for task details)
-- refresh new table every Run SQL
DROP TABLE IF EXISTS payments;

-- payments table
CREATE TABLE payments(

-- payments table variables
Receipt VARCHAR(255),
Amount DECIMAL(5,2),
PaymentSettled DATETIME,
PaymentType VARCHAR(255),

-- first go
-- PRIMARY KEY(Receipt, PaymentType),
PRIMARY KEY(Amount),

-- Receipt is a foreign key to the Rnumber in receipts
FOREIGN KEY(Receipt) REFERENCES receipts(RNumber)

);


USE `jpino01`;
-- BAKERY-4
-- Create a database trigger to prevent the sale of Meringues (any flavor) and all Almond-flavored items on Saturdays and Sundays.
-- drop trigger
-- DROP TRIGGER IF EXISTS preventSale;

-- create trigger before insertion on items table
CREATE TRIGGER preventSale BEFORE INSERT
ON items
-- iterate through all inserts for multi row inserts 
FOR EACH ROW
BEGIN

    -- declare variables
    DECLARE sold_date DATE;
    DECLARE preventFlavor VARCHAR(255);
    DECLARE preventFood VARCHAR(255);
    
    --  place SaleDates into var where Reciept (inserted from items table) equals RNumber in receipts table
    SELECT SaleDate INTO sold_date FROM receipts WHERE New.Receipt = receipts.RNumber;
    
    --  place Flavor into var where Item (inserted from items table) equals GId in goods table
    SELECT Flavor INTO preventFlavor FROM goods WHERE NEW.Item = goods.GId;
    
    --  place Food into var where Item (inserted from items table) equals GId in goods table
    SELECT Food INTO preventFood FROM goods WHERE NEW.Item = goods.GId;
   
    -- check if insert falls on the weekend (Saturday or Sunday)
    IF (DAYNAME(sold_date) = "Saturday" OR DAYNAME(sold_date) = "Sunday") THEN
    
        -- check if insert is Almond or Meringue
        IF (preventFlavor = "Almond" OR preventFood = "Meringue") THEN
        
            -- send error
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'On the weekends these items are not sold.';
        end if;
    end if;
END;


USE `jpino01`;
-- AIRLINES-1
-- Enforce the constraint that flights should never have the same airport as both source and destination (see assignment PDF)
-- drop trigger
-- DROP TRIGGER IF EXISTS preventDup;

-- create trigger before insertion on flights
CREATE TRIGGER preventDup BEFORE INSERT
on flights
FOR EACH ROW
BEGIN
    -- prevent data inserts of flights that have same source and destination airport
    IF(NEW.SourceAirport = NEW.DestAirport) THEN
    
        -- send error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Same source and destination airport.';
    end if;
END;


USE `jpino01`;
-- AIRLINES-2
-- Add a "Partner" column to the airlines table to indicate optional corporate partnerships between airline companies (see assignment PDF)
-- alter table airlines
ALTER TABLE airlines
DROP COLUMN Partner;

-- drop trigger
-- DROP TRIGGER IF EXISTS preventPartner;

-- add column Partner
ALTER TABLE airlines
ADD COLUMN Partner VARCHAR(255) AFTER Country;

-- add foreign key constraint
ALTER TABLE airlines 
ADD FOREIGN KEY(Partner) REFERENCES airlines(Abbreviation);

-- make column Partner have unique variables
ALTER TABLE airlines ADD UNIQUE (Partner);

-- update airlines table create partnership between Southwest and JetBlue
UPDATE airlines
SET 
    Partner = "JetBlue"
WHERE
    Abbreviation = "Southwest";

-- update airlines table create partnership between JetBlue and Southwest
UPDATE airlines
SET 
    Partner = "Southwest"
WHERE
    Abbreviation = "JetBlue";
    
-- create trigger before insertion on airlines
CREATE TRIGGER preventPartner BEFORE INSERT
on airlines
FOR EACH ROW
BEGIN
    -- disallow self partnerships
    IF(NEW.Abbreviation = NEW.Partner) THEN
    
        -- send error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create partnership.';
    end if;
END;


USE `jpino01`;
-- KATZENJAMMER-1
-- Change the name of two instruments: 'bass balalaika' should become 'awesome bass balalaika', and 'guitar' should become 'acoustic guitar'. This will require several steps. You may need to change the length of the instrument name field to avoid data truncation. Make this change using a schema modification command, rather than a full DROP/CREATE of the table.
-- update Instruments table
UPDATE Instruments

-- update column name to awesome bass balalaika
SET
    Instrument = "awesome bass balalaika"
    
-- set above column if column Instrument is bass balalaika
WHERE
    Instrument = "bass balalaika";
    
-- update Instruments table
UPDATE Instruments

-- update column name to acoustic guitar
SET
    Instrument = "acoustic guitar"
    
-- set above column if column Instrument is guitar
WHERE
    Instrument = "guitar";


USE `jpino01`;
-- KATZENJAMMER-2
-- Keep in the Vocals table only those rows where Solveig (id 1 -- you may use this numeric value directly) sang, but did not sing lead.
-- keep rows where Solveig sang (Id = 1)
DELETE FROM Vocals WHERE Bandmate != 1;

-- delete rows where Solveig is the lead
DELETE FROM Vocals WHERE vType = "lead";

-- rename column vType to Type
ALTER TABLE Vocals RENAME COLUMN vType TO `Type`;


