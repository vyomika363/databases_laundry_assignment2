-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: laundry_2
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auditlog`
--

DROP TABLE IF EXISTS `auditlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditlog` (
  `LogID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `Username` varchar(50) DEFAULT NULL,
  `Role` varchar(20) DEFAULT NULL,
  `Action` varchar(100) DEFAULT NULL,
  `Status` varchar(20) DEFAULT NULL,
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`LogID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlog`
--

LOCK TABLES `auditlog` WRITE;
/*!40000 ALTER TABLE `auditlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bill`
--

DROP TABLE IF EXISTS `bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill` (
  `BillID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `BillDate` varchar(20) NOT NULL,
  `TotalAmount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`BillID`),
  UNIQUE KEY `OrderID` (`OrderID`),
  CONSTRAINT `bill_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bill_chk_1` CHECK ((`TotalAmount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill`
--

LOCK TABLES `bill` WRITE;
/*!40000 ALTER TABLE `bill` DISABLE KEYS */;
INSERT INTO `bill` VALUES (21,60,'Pending',535.00),(22,41,'2025-01-04',300.00),(23,42,'Pending',640.00),(24,43,'2025-01-06',145.00),(25,44,'Pending',680.00),(26,45,'2025-01-08',780.00),(27,46,'Pending',555.00),(28,47,'2025-01-10',250.00),(29,48,'Pending',510.00),(30,49,'2025-01-12',545.00),(31,50,'Pending',1140.00),(32,51,'2025-01-16',595.00),(33,52,'Pending',480.00),(34,53,'2025-01-16',240.00),(35,54,'Pending',1220.00),(36,55,'2025-01-18',435.00),(37,56,'Pending',1000.00),(38,57,'2025-01-20',780.00),(39,58,'Pending',270.00),(40,59,'2025-01-22',560.00);
/*!40000 ALTER TABLE `bill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `MemberID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PhoneNumber` varchar(10) NOT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Age` int NOT NULL,
  `RegistrationDate` date NOT NULL DEFAULT (curdate()),
  `Image` mediumblob,
  `UserID` int DEFAULT NULL,
  PRIMARY KEY (`MemberID`),
  UNIQUE KEY `Email` (`Email`),
  UNIQUE KEY `PhoneNumber` (`PhoneNumber`),
  KEY `idx_customer_userid_name_email` (`UserID`,`Name`,`Email`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `customer_chk_1` CHECK ((`Age` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (26,'Aarav Sharma','aarav1@gmail.com','9876500001','Mumbai',23,'2025-01-01',NULL,3),(27,'Diya Patel','diya2@gmail.com','9876500002','Ahmedabad',22,'2025-01-02',NULL,5),(28,'Rohan Mehta','rohan3@gmail.com','9876500003','Mumbai',24,'2025-01-03',NULL,6),(29,'Ananya Iyer','ananya4@gmail.com','9876500004','Chennai',23,'2025-01-04',NULL,7),(30,'Kabir Singh','kabir5@gmail.com','9876500005','Lucknow',25,'2025-01-05',NULL,8),(31,'Meera Nair','meera6@gmail.com','9876500006','Kochi',24,'2025-01-06',NULL,9),(32,'Aditya Verma','aditya7@gmail.com','9876500007','Jaipur',23,'2025-01-07',NULL,10),(33,'Priya Reddy','priya8@gmail.com','9876500008','Hyderabad',22,'2025-01-08',NULL,11),(34,'Kunal Joshi','kunal9@gmail.com','9876500009','Pune',24,'2025-01-09',NULL,12),(35,'Sneha Das','sneha10@gmail.com','9876500010','Kolkata',23,'2025-01-10',NULL,13),(36,'Rahul Khanna','rahul11@gmail.com','9876500011','Delhi',25,'2025-01-11',NULL,14),(37,'Neha Agarwal','neha12@gmail.com','9876500012','Noida',24,'2025-01-12',NULL,15),(38,'Vikram Rao','vikram13@gmail.com','9876500013','Bangalore',26,'2025-01-13',NULL,16),(39,'Ishita Kapoor','ishita14@gmail.com','9876500014','Chandigarh',23,'2025-01-14',NULL,17),(40,'Arjun Menon','arjun15@gmail.com','9876500015','Trivandrum',22,'2025-01-15',NULL,18),(41,'Pooja Bansal','pooja16@gmail.com','9876500016','Indore',24,'2025-01-16',NULL,19),(42,'Nikhil Jain','nikhil17@gmail.com','9876500017','Surat',23,'2025-01-17',NULL,20),(43,'Tanya Chatterjee','tanya18@gmail.com','9876500018','Kolkata',22,'2025-01-18',NULL,21),(44,'Manish Yadav','manish19@gmail.com','9876500019','Patna',25,'2025-01-19',NULL,22),(45,'Simran Kaur','simran20@gmail.com','9876500020','Amritsar',24,'2025-01-20',NULL,23),(100,'vyom vv','vyom@gmial.com','9999999999','Hyderabad',22,'2026-03-22',NULL,43),(112,'vyomi','vyomika@gmail.com','9900999000','Hyderabad',56,'2026-03-22',NULL,45);
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery`
--

DROP TABLE IF EXISTS `delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery` (
  `OrderID` int NOT NULL,
  `DeliveryDate` varchar(20) NOT NULL,
  `DeliveryTime` varchar(20) NOT NULL,
  `StaffID` int NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `idx_delivery_staffid` (`StaffID`),
  CONSTRAINT `delivery_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `delivery_ibfk_2` FOREIGN KEY (`StaffID`) REFERENCES `staff` (`StaffID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery`
--

LOCK TABLES `delivery` WRITE;
/*!40000 ALTER TABLE `delivery` DISABLE KEYS */;
INSERT INTO `delivery` VALUES (41,'2025-01-04','16:00:00',25),(42,'Pending','Pending',22),(43,'2025-01-06','18:00:00',34),(44,'Pending','Pending',22),(45,'2025-01-08','16:30:00',40),(46,'Pending','Pending',22),(47,'2025-01-10','18:30:00',25),(48,'Pending','Pending',22),(49,'2025-01-12','16:45:00',34),(50,'Pending','Pending',22),(51,'2025-01-16','18:45:00',40),(52,'Pending','Pending',22),(53,'2025-01-16','16:15:00',25),(54,'Pending','Pending',22),(55,'2025-01-18','18:15:00',34),(56,'Pending','Pending',22),(57,'2025-01-20','16:20:00',40),(58,'Pending','Pending',22),(59,'2025-01-22','18:20:00',25),(60,'Pending','Pending',22);
/*!40000 ALTER TABLE `delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `FeedbackID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `Rating` int NOT NULL,
  `Comments` varchar(500) DEFAULT NULL,
  `FeedbackDate` varchar(20) NOT NULL,
  PRIMARY KEY (`FeedbackID`),
  UNIQUE KEY `OrderID` (`OrderID`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `feedback_chk_1` CHECK ((`Rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (11,42,4,'Clothes were well ironed','2025-01-04'),(12,44,5,'Excellent service and fast delivery','2025-01-06'),(13,46,4,'Good washing quality','2025-01-08'),(14,48,5,'Very satisfied with packaging','2025-01-10'),(15,50,4,'Staff were polite','2025-01-12'),(16,52,5,'Perfect dry cleaning','2025-01-16'),(17,54,4,'Neatly folded clothes','2025-01-16'),(18,56,5,'Quick and reliable service','2025-01-18'),(19,58,4,'Good quality work','2025-01-20'),(20,60,5,'Very professional handling','2025-01-22');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `garment`
--

DROP TABLE IF EXISTS `garment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `garment` (
  `GarmentID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `ItemID` int NOT NULL,
  `ServiceID` int NOT NULL,
  PRIMARY KEY (`GarmentID`),
  KEY `OrderID` (`OrderID`),
  KEY `ItemID` (`ItemID`),
  KEY `ServiceID` (`ServiceID`),
  CONSTRAINT `garment_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `garment_ibfk_2` FOREIGN KEY (`ItemID`) REFERENCES `item` (`ItemID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `garment_ibfk_3` FOREIGN KEY (`ServiceID`) REFERENCES `service` (`ServiceID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garment`
--

LOCK TABLES `garment` WRITE;
/*!40000 ALTER TABLE `garment` DISABLE KEYS */;
INSERT INTO `garment` VALUES (77,60,1,1),(78,60,3,1),(79,60,19,1),(80,60,5,4),(81,60,4,1),(82,41,4,2),(83,41,1,2),(84,41,14,2),(85,42,6,3),(86,42,13,2),(87,42,5,4),(88,42,2,1),(89,43,3,1),(90,43,20,2),(91,44,5,4),(92,44,1,1),(93,44,15,4),(94,44,3,1),(95,44,19,1),(96,44,14,1),(97,45,8,5),(98,45,10,1),(99,45,13,2),(100,45,2,1),(101,46,7,1),(102,46,3,1),(103,46,14,1),(104,46,19,1),(105,46,1,1),(106,47,2,2),(107,47,4,2),(108,47,20,2),(109,48,9,3),(110,48,13,2),(111,49,10,1),(112,49,15,4),(113,49,1,1),(114,49,4,1),(115,50,11,5),(116,50,6,3),(117,50,5,4),(118,50,13,2),(119,50,19,1),(120,51,12,3),(121,51,3,1),(122,51,1,1),(123,52,13,2),(124,52,20,1),(125,52,5,4),(126,52,4,1),(127,53,14,1),(128,53,19,1),(129,54,11,5),(130,54,6,3),(131,54,7,1),(132,54,3,1),(133,54,15,4),(134,54,1,1),(135,55,16,1),(136,55,20,1),(137,55,19,1),(138,55,3,1),(139,56,17,3),(140,56,18,3),(141,56,13,2),(142,56,5,4),(143,56,1,1),(144,57,18,3),(145,57,17,3),(146,57,13,2),(147,58,19,1),(148,58,16,1),(149,59,20,2),(150,59,9,2),(151,59,4,1),(152,59,1,1);
/*!40000 ALTER TABLE `garment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item`
--

DROP TABLE IF EXISTS `item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item` (
  `ItemID` int NOT NULL AUTO_INCREMENT,
  `Type` varchar(100) NOT NULL,
  `ItemMaterial` varchar(100) NOT NULL,
  `ItemPrice` decimal(10,2) NOT NULL,
  `EstimatedTime` varchar(50) NOT NULL,
  PRIMARY KEY (`ItemID`),
  CONSTRAINT `item_chk_1` CHECK ((`ItemPrice` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item`
--

LOCK TABLES `item` WRITE;
/*!40000 ALTER TABLE `item` DISABLE KEYS */;
INSERT INTO `item` VALUES (1,'Shirt','Cotton',40.00,'2:00:00'),(2,'Shirt','Linen',50.00,'2:30:00'),(3,'T-Shirt','Polyester',35.00,'1:30:00'),(4,'Jeans','Denim',80.00,'3:00:00'),(5,'Kurta','Cotton',60.00,'2:30:00'),(6,'Saree','Silk',150.00,'5:00:00'),(7,'Saree','Cotton',90.00,'4:00:00'),(8,'Blazer','Wool',200.00,'6:00:00'),(9,'Jacket','Leather',250.00,'8:00:00'),(10,'Dress','Georgette',140.00,'5:00:00'),(11,'Lehenga','Silk',350.00,'8:00:00'),(12,'Sherwani','Silk',300.00,'7:00:00'),(13,'Sweater','Wool',110.00,'4:30:00'),(14,'Tracksuit','Polyester',90.00,'3:00:00'),(15,'School Uniform','Cotton',65.00,'3:00:00'),(16,'Bedsheet','Cotton',120.00,'4:30:00'),(17,'Curtains','Polyester',180.00,'6:00:00'),(18,'Blanket','Wool',220.00,'7:00:00'),(19,'Towel','Cotton',50.00,'2:30:00'),(20,'Pillow Cover','Cotton',30.00,'2:00:00');
/*!40000 ALTER TABLE `item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `OrderID` int NOT NULL AUTO_INCREMENT,
  `MemberID` int NOT NULL,
  `OrderDate` date NOT NULL DEFAULT (curdate()),
  `OrderStatus` varchar(50) NOT NULL,
  `Quantity` int NOT NULL,
  `DeliveryStatus` varchar(50) NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `idx_orders_memberid` (`MemberID`),
  KEY `idx_orders_status` (`OrderStatus`),
  KEY `idx_orders_orderdate` (`OrderDate`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`MemberID`) REFERENCES `customer` (`MemberID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orders_chk_1` CHECK ((`Quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (41,26,'2025-01-01','Processing',5,'Pending'),(42,27,'2025-01-02','Completed',3,'Delivered'),(43,28,'2025-01-03','Processing',4,'Pending'),(44,29,'2025-01-04','Completed',2,'Delivered'),(45,30,'2025-01-05','Processing',6,'Pending'),(46,31,'2025-01-06','Completed',4,'Delivered'),(47,32,'2025-01-07','Processing',5,'Pending'),(48,33,'2025-01-08','Completed',3,'Delivered'),(49,34,'2025-01-09','Processing',2,'Pending'),(50,35,'2025-01-10','Completed',4,'Delivered'),(51,36,'2025-01-11','Completed',5,'Pending'),(52,37,'2025-01-12','Completed',3,'Delivered'),(53,38,'2025-01-13','Processing',4,'Pending'),(54,39,'2025-01-14','Completed',2,'Delivered'),(55,40,'2025-01-15','Processing',6,'Pending'),(56,41,'2025-01-16','Completed',4,'Delivered'),(57,42,'2025-01-17','Processing',5,'Pending'),(58,43,'2025-01-18','Completed',3,'Delivered'),(59,44,'2025-01-19','Processing',2,'Pending'),(60,45,'2025-01-20','Completed',4,'Delivered');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `BillID` int NOT NULL,
  `PaymentMode` varchar(50) NOT NULL,
  `PaymentStatus` varchar(50) NOT NULL,
  `PaymentDate` varchar(20) NOT NULL,
  PRIMARY KEY (`PaymentID`),
  UNIQUE KEY `BillID` (`BillID`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`BillID`) REFERENCES `bill` (`BillID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (61,22,'Pending','Pending','Pending'),(62,23,'Cash','Completed','2025-02-03'),(63,24,'Pending','Pending','Pending'),(64,25,'UPI','Completed','2025-02-05'),(65,26,'Pending','Pending','Pending'),(66,27,'UPI','Completed','2025-02-08'),(67,28,'Pending','Pending','Pending'),(68,29,'Credit Card','Completed','2025-02-09'),(69,30,'Pending','Pending','Pending'),(70,31,'Cash','Completed','2025-02-11'),(71,32,'Pending','Pending','Pending'),(72,33,'UPI','Completed','2025-02-13'),(73,34,'Pending','Pending','Pending'),(74,35,'Credit Card','Completed','2025-02-15'),(75,36,'Pending','Pending','Pending'),(76,37,'Cash','Completed','2025-02-18'),(77,38,'Pending','Pending','Pending'),(78,39,'UPI','Completed','2025-02-19'),(79,40,'Pending','Pending','Pending'),(80,21,'Debit Card','Completed','2025-02-22');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup`
--

DROP TABLE IF EXISTS `pickup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup` (
  `OrderID` int NOT NULL,
  `PickupDate` date NOT NULL,
  `PickupTime` time NOT NULL,
  `StaffID` int NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `idx_pickup_staffid` (`StaffID`),
  CONSTRAINT `pickup_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pickup_ibfk_2` FOREIGN KEY (`StaffID`) REFERENCES `staff` (`StaffID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup`
--

LOCK TABLES `pickup` WRITE;
/*!40000 ALTER TABLE `pickup` DISABLE KEYS */;
INSERT INTO `pickup` VALUES (41,'2025-01-02','10:00:00',24),(42,'2025-01-03','11:00:00',29),(43,'2025-01-04','12:00:00',26),(44,'2025-01-05','13:00:00',37),(45,'2025-01-06','09:30:00',21),(46,'2025-01-07','10:30:00',24),(47,'2025-01-08','11:30:00',29),(48,'2025-01-09','12:30:00',33),(49,'2025-01-10','13:30:00',37),(50,'2025-01-11','09:15:00',21),(51,'2025-01-12','10:15:00',24),(52,'2025-01-13','11:15:00',29),(53,'2025-01-14','12:15:00',33),(54,'2025-01-15','13:15:00',37),(55,'2025-01-16','09:45:00',21),(56,'2025-01-17','10:45:00',24),(57,'2025-01-18','11:45:00',29),(58,'2025-01-19','12:45:00',33),(59,'2025-02-20','13:45:00',37),(60,'2025-01-01','09:00:00',21);
/*!40000 ALTER TABLE `pickup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service` (
  `ServiceID` int NOT NULL AUTO_INCREMENT,
  `ServiceType` varchar(50) NOT NULL,
  `ServiceCost` decimal(10,2) NOT NULL,
  `EstimatedTime` varchar(50) NOT NULL,
  PRIMARY KEY (`ServiceID`),
  CONSTRAINT `service_chk_1` CHECK ((`ServiceCost` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service`
--

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (1,'Wash',50.00,'4:00:00'),(2,'Iron',30.00,'2:00:00'),(3,'Dry Clean',120.00,'15:00:00'),(4,'Washing & Iron',70.00,'5:00:00'),(5,'Dry Clean & Iron',150.00,'20:00:00'),(6,'Express Wash',80.00,'2:00:00'),(7,'Express Dry Clean',200.00,'8:00:00'),(8,'Steam Iron',45.00,'1:30:00'),(9,'Premium Wash',100.00,'6:00:00'),(10,'Delicate Fabric Wash',110.00,'7:00:00'),(11,'Curtain Cleaning',180.00,'18:00:00'),(12,'Blanket Dry Clean',220.00,'24:00:00');
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `StaffID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Role` varchar(50) NOT NULL,
  `ContactNumber` varchar(15) NOT NULL,
  `UserID` int DEFAULT NULL,
  PRIMARY KEY (`StaffID`),
  UNIQUE KEY `ContactNumber` (`ContactNumber`),
  UNIQUE KEY `idx_staff_userid` (`UserID`),
  KEY `idx_staff_name` (`Name`),
  CONSTRAINT `fk_staff_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL,
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (21,'Rajesh Kumar','Pickup Staff','9898000001',4),(22,'Suresh Yadav','Delivery Staff','9898000002',24),(23,'Mahesh Gupta','Manager','9898000003',25),(24,'Ravi Nair','Pickup Staff','9898000004',26),(25,'Amit Shah','Delivery Staff','9898000005',27),(26,'Deepak Singh','Washing Staff','9898000006',28),(27,'Vikas Jain','Ironing Staff','9898000007',29),(28,'Sunil Patil','Supervisor','9898000008',30),(29,'Harish Iyer','Pickup Staff','9898000009',31),(30,'Gaurav Bansal','Delivery Staff','9898000010',32),(31,'Karthik Reddy','Washing Staff','9898000011',33),(32,'Mohan Verma','Ironing Staff','9898000012',34),(33,'Ajay Mehta','Pickup Staff','9898000013',35),(34,'Rakesh Joshi','Delivery Staff','9898000014',36),(35,'Tarun Kapoor','Washing Staff','9898000015',37),(36,'Pankaj Agarwal','Ironing Staff','9898000016',38),(37,'Manoj Das','Pickup Staff','9898000017',39),(38,'Ashok Rao','Delivery Staff','9898000018',40),(39,'Vinay Kulkarni','Washing Staff','9898000019',41),(40,'Yash Malhotra','Delivery Staff','9898000020',42);
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `Role` enum('admin','staff','customer') NOT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `idx_username_role` (`Username`,`Role`),
  UNIQUE KEY `idx_users_username_role` (`Username`,`Role`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin123','admin','2026-03-21 09:12:22'),(3,'aarav1','user123','customer','2026-03-21 09:02:21'),(4,'rajeshkumar','staff123','staff','2026-03-21 09:02:21'),(5,'diya2','user123','customer','2026-03-21 09:05:07'),(6,'rohan3','user123','customer','2026-03-21 09:05:07'),(7,'ananya4','user123','customer','2026-03-21 09:05:07'),(8,'kabir5','user123','customer','2026-03-21 09:05:07'),(9,'meera6','user123','customer','2026-03-21 09:05:07'),(10,'aditya7','user123','customer','2026-03-21 09:09:02'),(11,'priya8','user123','customer','2026-03-21 09:09:02'),(12,'kunal9','user123','customer','2026-03-21 09:09:02'),(13,'sneha10','user123','customer','2026-03-21 09:09:02'),(14,'rahul11','user123','customer','2026-03-21 09:09:02'),(15,'neha12','user123','customer','2026-03-21 09:09:02'),(16,'vikram13','user123','customer','2026-03-21 09:09:02'),(17,'ishita14','user123','customer','2026-03-21 09:09:02'),(18,'arjun15','user123','customer','2026-03-21 09:09:02'),(19,'pooja16','user123','customer','2026-03-21 09:09:02'),(20,'nikhil17','user123','customer','2026-03-21 09:09:02'),(21,'tanya18','user123','customer','2026-03-21 09:09:02'),(22,'manish19','user123','customer','2026-03-21 09:09:02'),(23,'simran20','user123','customer','2026-03-21 09:09:02'),(24,'sureshyadav','staff123','staff','2026-03-21 09:09:02'),(25,'maheshgupta','staff123','staff','2026-03-21 09:09:02'),(26,'ravinair','staff123','staff','2026-03-21 09:09:02'),(27,'amitshah','staff123','staff','2026-03-21 09:09:02'),(28,'deepaksingh','staff123','staff','2026-03-21 09:09:02'),(29,'vikasjain','staff123','staff','2026-03-21 09:09:02'),(30,'sunilpatil','staff123','staff','2026-03-21 09:09:02'),(31,'harishiyer','staff123','staff','2026-03-21 09:09:02'),(32,'gauravbansal','staff123','staff','2026-03-21 09:09:02'),(33,'karthikreddy','staff123','staff','2026-03-21 09:09:02'),(34,'mohanverma','staff123','staff','2026-03-21 09:09:02'),(35,'ajaymehta','staff123','staff','2026-03-21 09:09:02'),(36,'rakeshjoshi','staff123','staff','2026-03-21 09:09:02'),(37,'tarunkapoor','staff123','staff','2026-03-21 09:09:02'),(38,'pankajagarwal','staff123','staff','2026-03-21 09:09:02'),(39,'manojdas','staff123','staff','2026-03-21 09:09:02'),(40,'ashokrao','staff123','staff','2026-03-21 09:09:02'),(41,'vinaykulkarni','staff123','staff','2026-03-21 09:09:02'),(42,'yashmalhotra','staff123','staff','2026-03-21 09:09:02'),(43,'vyom','user1','customer','2026-03-22 09:18:45'),(45,'vyomi','vyomi','customer','2026-03-22 11:18:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'laundry_2'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-22 17:44:20
