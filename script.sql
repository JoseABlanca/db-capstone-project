-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema little_lemon
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema little_lemon
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `little_lemon` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `little_lemon` ;

-- -----------------------------------------------------
-- Table `little_lemon`.`customers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon`.`customers` ;

CREATE TABLE IF NOT EXISTS `little_lemon`.`customers` (
  `CustomerID` INT NOT NULL,
  `FullName` VARCHAR(50) NULL DEFAULT NULL,
  `ContactNumber` VARCHAR(50) NULL DEFAULT NULL,
  `Email` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `little_lemon`.`bookings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon`.`bookings` ;

CREATE TABLE IF NOT EXISTS `little_lemon`.`bookings` (
  `BookingID` INT NULL DEFAULT NULL,
  `TableNumber` INT NULL DEFAULT NULL,
  `BookingDate` DATE NULL DEFAULT NULL,
  `CustomerID` INT NULL DEFAULT NULL,
  INDEX `CustomerID` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `bookings_ibfk_1`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `little_lemon`.`customers` (`CustomerID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `little_lemon`.`menuitems`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon`.`menuitems` ;

CREATE TABLE IF NOT EXISTS `little_lemon`.`menuitems` (
  `MenuItemsID` INT NOT NULL,
  `CourseName` VARCHAR(45) NULL DEFAULT NULL,
  `StarterName` VARCHAR(45) NULL DEFAULT NULL,
  `DessertName` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`MenuItemsID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `little_lemon`.`menu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon`.`menu` ;

CREATE TABLE IF NOT EXISTS `little_lemon`.`menu` (
  `MenuID` INT NOT NULL,
  `MenuItemsID` INT NULL DEFAULT NULL,
  `MenuName` VARCHAR(45) NULL DEFAULT NULL,
  `Cuisine` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`MenuID`),
  INDEX `MenuItemsID` (`MenuItemsID` ASC) VISIBLE,
  CONSTRAINT `menu_ibfk_1`
    FOREIGN KEY (`MenuItemsID`)
    REFERENCES `little_lemon`.`menuitems` (`MenuItemsID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `little_lemon`.`orders`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `little_lemon`.`orders` ;

CREATE TABLE IF NOT EXISTS `little_lemon`.`orders` (
  `OrderID` INT NOT NULL,
  `Quantity` INT NULL DEFAULT NULL,
  `TotalCost` DECIMAL(10,2) NULL DEFAULT NULL,
  `BookingID` INT NULL DEFAULT NULL,
  `MenuID` INT NULL DEFAULT NULL,
  `CustomerID` INT NULL DEFAULT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `BookingID` (`BookingID` ASC) VISIBLE,
  CONSTRAINT `orders_ibfk_4`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `little_lemon`.`customers` (`CustomerID`),
  CONSTRAINT `orders_ibfk_6`
    FOREIGN KEY (`MenuID`)
    REFERENCES `little_lemon`.`menu` (`MenuID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `little_lemon` ;

-- -----------------------------------------------------
-- procedure AddBooking
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`AddBooking`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `AddBooking`(IN mesa INT,IN cliente INT,IN fecha DATE,IN numerodemesa INT)
begin 
insert into Bookings (BookingID,CustomerID,BookingDate,TableNumber) VALUES ( mesa,cliente,fecha,numerodemesa);
select concat ("new booking with client ", cliente , " added") as "Booking Confirmation";
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AddValidBooking
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`AddValidBooking`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `AddValidBooking`( IN fecha DATE, IN numerodemesa INT)
BEGIN
declare booking_status INT DEFAULT 0;
start transaction
;
insert into Bookings (BookingDate,TableNumber) VALUES (fecha,numerodemesa);
select count(*) into booking_status from Bookings where BookingDate = fecha AND TableNumber = numerodemesa;
if booking_status>1 Then 
	ROLLBACK;
	select concat( "Table ",numerodemesa," is alredy booked - booking cancel") as "Booking status";
else
	COMMIT;
	select concat ("table ",numerodemesa," booking confirmed") as "Booking Status";
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelBooking
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`CancelBooking`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `CancelBooking`(IN reserva INT)
begin
delete from Bookings where BookingID = reserva;
select concat (" Booking ", reserva, " is cancelled") as "Cancel confirmation";
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancellOrder
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`CancellOrder`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `CancellOrder`(IN order_id INT)
BEGIN
delete from orders where OrderID = order_id;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CheckBooking
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`CheckBooking`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `CheckBooking`( IN fecha Date, IN numerodemesa INT)
BEGIN
declare booking_date INT DEFAULT 0;
select count(*) into booking_date from Bookings where TableNumber = numerodemesa;
if booking_date < 0 then 
	select concat("table ", numerodemesa, "is already booked") as "Booking Status" ;
else 
	select concat("table", numerodemesa, "is available") as "Booking Status";
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetMaxQuantity
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`GetMaxQuantity`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `GetMaxQuantity`()
BEGIN
	SELECT max(Quantity) from orders;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdateBooking
-- -----------------------------------------------------

USE `little_lemon`;
DROP procedure IF EXISTS `little_lemon`.`UpdateBooking`;

DELIMITER $$
USE `little_lemon`$$
CREATE DEFINER=`userdbproject`@`localhost` PROCEDURE `UpdateBooking`(IN reserva INT, IN fecha DATE)
begin 
update Bookings set BookingDate = fecha where BookingID = reserva;
select concat (" Booking ", reserva , " updated") as "Reserve confirmation";
end$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
