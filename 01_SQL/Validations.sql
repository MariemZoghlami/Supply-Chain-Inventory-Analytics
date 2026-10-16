
-- =====================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- Supplier Performance Dashboard Validation
-- =====================================================

USE SupplyChain_Analysis;

-- 1. Check for duplicate supplier records
-- Expected: No rows returned

SELECT
    SupplierID,
    COUNT(*) AS RecordCount
FROM supplier_performance_view
GROUP BY SupplierID
HAVING COUNT(*) > 1;


-- 2. Validate supplier count and financial totals
-- Expected:
-- TotalRows = 25
-- TotalSuppliers = 25
-- TotalRevenue = 120663927.34
-- TotalReorders = 1053

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SupplierID) AS TotalSuppliers,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    SUM(ReorderRequiredCount) AS TotalReorders
FROM supplier_performance_view;


-- 3. Validate supplier KPIs from analytics view
-- Expected:
-- AverageSupplierRating = 2.78
-- AverageLeadTimeDays = 15.96
-- ActiveSuppliers = 25

SELECT
    ROUND(AVG(SupplierRating), 2) AS AverageSupplierRating,
    ROUND(AVG(LeadTimeDays), 2) AS AverageLeadTimeDays,
    SUM(IsActive = 1) AS ActiveSuppliers
FROM supplier_performance_view;


-- 4. Validate supplier KPIs from original source table
-- Expected:
-- TotalSuppliers = 25
-- AverageSupplierRating = 2.78
-- AverageLeadTimeDays = 15.96
-- ActiveSuppliers = 25

SELECT
    COUNT(*) AS TotalSuppliers,
    ROUND(AVG(SupplierRating), 2) AS AverageSupplierRating,
    ROUND(AVG(LeadTimeDays), 2) AS AverageLeadTimeDays,
    SUM(IsActive = 1) AS ActiveSuppliers
FROM Suppliers;


-- 5. Validate supplier revenue and reorder totals
-- Expected:
-- TotalRevenue = 120663927.34
-- TotalReordersRequired = 1053

SELECT
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    SUM(ReorderRequiredCount) AS TotalReordersRequired
FROM supplier_performance_view;


-- STEP 8A: Inspect supplier revenue calculation
-- Show the SQL definition of the analytics view

SHOW CREATE VIEW supplier_performance_view;



-- STEP 8B: Independent Revenue Validation
-- Calculate revenue directly from original source tables

SELECT
    ROUND(SUM(od.Quantity * p.SellingPrice), 2)
        AS IndependentTotalRevenue
FROM orderdetails od
JOIN products p
    ON od.ProductID = p.ProductID;
    
    
-- STEP 9A: Independent Reorder Validation
-- Count inventory records where stock is at or below reorder level

SELECT
    COUNT(*) AS IndependentReordersRequired
FROM inventory
WHERE CurrentStock <= ReorderLevel;


-- STEP 9B: Validate Inventory Join Integrity
-- Check whether joining products duplicates inventory rows

SELECT
    (SELECT COUNT(*) FROM inventory) AS OriginalInventoryRows,
    COUNT(*) AS JoinedInventoryRows,
    COUNT(DISTINCT i.ProductID) AS DistinctProducts
FROM inventory i
JOIN products p
    ON i.ProductID = p.ProductID;

-- STEP 10: Independent Shipment Count Validation
-- Verify shipment records and unique shipment IDs

SELECT
    COUNT(*) AS TotalShipmentRecords,
    COUNT(DISTINCT ShipmentID) AS UniqueShipments
FROM shipments;


-- STEP 11: Independent On-Time Delivery Rate Validation
-- Exclude shipments that are still in transit

USE SupplyChain_Analysis;

SELECT
    COUNT(DISTINCT CASE
        WHEN Status = 'Delivered'
        THEN ShipmentID
    END) AS OnTimeShipments,

    COUNT(DISTINCT CASE
        WHEN Status IN ('Delivered', 'Delayed')
        THEN ShipmentID
    END) AS CompletedShipments,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN Status = 'Delivered'
            THEN ShipmentID
        END)
        /
        NULLIF(
            COUNT(DISTINCT CASE
                WHEN Status IN ('Delivered', 'Delayed')
                THEN ShipmentID
            END), 0
        ), 2
    ) AS OnTimeDeliveryRatePercent

FROM shipping_performance_view;



-- STEP 12: Independent Average Delivery Delay Validation
-- Calculate the average delay for late shipments only

USE SupplyChain_Analysis;

SELECT
    COUNT(*) AS DelayedShipments,
    ROUND(AVG(DelayDays), 2) AS AverageDelayDays
FROM shipping_performance_view
WHERE DeliveryPerformance = 'Late';

-- STEP 13: Validate Delayed Shipments by Carrier
-- Independently count late shipments for each carrier

USE SupplyChain_Analysis;

SELECT
    Carrier,
    COUNT(*) AS DelayedShipments
FROM shipping_performance_view
WHERE DeliveryPerformance = 'Late'
GROUP BY Carrier
ORDER BY DelayedShipments DESC;

-- STEP 14: Validate On-Time Delivery Rate by Carrier
-- Exclude shipments that are still in transit

USE SupplyChain_Analysis;

SELECT
    Carrier,
    SUM(DeliveryPerformance = 'On Time') AS OnTimeShipments,
    SUM(DeliveryPerformance IN ('On Time', 'Late')) AS CompletedShipments,
    ROUND(
        100.0 * SUM(DeliveryPerformance = 'On Time') /
        NULLIF(SUM(DeliveryPerformance IN ('On Time', 'Late')), 0),
        2
    ) AS OnTimeDeliveryRatePercent
FROM shipping_performance_view
GROUP BY Carrier
ORDER BY OnTimeDeliveryRatePercent DESC;

-- STEP 15: Validate Average Delivery Delay by Carrier
-- Calculate average delay for late shipments only

USE SupplyChain_Analysis;

SELECT
    Carrier,
    COUNT(*) AS DelayedShipments,
    ROUND(AVG(DelayDays), 2) AS AverageDelayDays
FROM shipping_performance_view
WHERE DeliveryPerformance = 'Late'
GROUP BY Carrier
ORDER BY AverageDelayDays DESC;

-- STEP 16: Validate Sales Date Range
-- Check whether the first and last months contain partial data

USE SupplyChain_Analysis;

SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    COUNT(*) AS TotalOrders
FROM orders;

-- STEP 17: Investigate April 2025 Revenue Dip
-- Compare monthly order volume and revenue

USE SupplyChain_Analysis;

SELECT
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS YearMonth,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(SUM(od.Quantity * p.SellingPrice), 2) AS TotalRevenue,
    ROUND(
        SUM(od.Quantity * p.SellingPrice) /
        COUNT(DISTINCT o.OrderID), 2
    ) AS AverageOrderValue
FROM orders o
JOIN orderdetails od
    ON o.OrderID = od.OrderID
JOIN products p
    ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '2025-03-01'
  AND o.OrderDate < '2025-06-01'
GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY YearMonth;