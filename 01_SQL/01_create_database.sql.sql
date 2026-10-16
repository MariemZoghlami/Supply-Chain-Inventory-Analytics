-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS SupplyChain_Analysis;
USE SupplyChain_Analysis;


-- 1. SUPPLIERS
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL UNIQUE,
    ContactPerson VARCHAR(100),
    Email VARCHAR(100),
    Country VARCHAR(50) NOT NULL,
    LeadTimeDays INT NOT NULL CHECK (LeadTimeDays >= 0),
    SupplierRating DECIMAL(2,1)
        CHECK (SupplierRating BETWEEN 1.0 AND 5.0),
    IsActive BOOLEAN NOT NULL
);


-- 2. CUSTOMERS
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    Industry VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Region VARCHAR(50),
    ContactPerson VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    CustomerType VARCHAR(50),
    IsActive BOOLEAN NOT NULL
);


-- 3. WAREHOUSES
CREATE TABLE Warehouses (
    WarehouseID INT PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL UNIQUE,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(2) NOT NULL,
    Region VARCHAR(50),
    Capacity INT NOT NULL CHECK (Capacity > 0),
    ManagerName VARCHAR(100),
    IsActive BOOLEAN NOT NULL
);


-- 4. PRODUCTS
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    SupplierID INT NOT NULL,
    Cost DECIMAL(10,2) NOT NULL CHECK (Cost >= 0),
    SellingPrice DECIMAL(10,2) NOT NULL CHECK (SellingPrice >= 0),
    ProductWeight DECIMAL(10,2) CHECK (ProductWeight > 0),
    UnitOfMeasure VARCHAR(20),
    IsActive BOOLEAN NOT NULL,

    FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID)
);


-- 5. SHIPMENTS
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    ShipDate DATE NOT NULL,
    ExpectedArrivalDate DATE NOT NULL,
    ActualArrivalDate DATE,
    Carrier VARCHAR(50) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    ShippingCost DECIMAL(10,2) CHECK (ShippingCost >= 0)
);


-- 6. ORDERS
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    WarehouseID INT NOT NULL,
    ShipmentID INT,
    OrderDate DATE NOT NULL,

    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    FOREIGN KEY (WarehouseID)
        REFERENCES Warehouses(WarehouseID),

    FOREIGN KEY (ShipmentID)
        REFERENCES Shipments(ShipmentID)
);


-- 7. INVENTORY
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    WarehouseID INT NOT NULL,
    ProductID INT NOT NULL,
    CurrentStock INT NOT NULL CHECK (CurrentStock >= 0),
    ReorderLevel INT NOT NULL CHECK (ReorderLevel >= 0),

    CONSTRAINT UQ_Inventory
        UNIQUE (WarehouseID, ProductID),

    FOREIGN KEY (WarehouseID)
        REFERENCES Warehouses(WarehouseID),

    FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);


-- 8. ORDER DETAILS
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),

    CONSTRAINT UQ_Order_Product
        UNIQUE (OrderID, ProductID),

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);


-- ============================================================
-- VERIFY DATABASE STRUCTURE
-- ============================================================

SHOW TABLES;