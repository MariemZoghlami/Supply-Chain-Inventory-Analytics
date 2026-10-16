-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- Data Quality & Database Validation
-- ============================================================

USE SupplyChain_Analysis;


-- ============================================================
-- 1. RECORD COUNTS
-- Confirm all expected records were loaded
-- ============================================================

SELECT 'Suppliers' AS TableName, COUNT(*) AS RecordCount
FROM Suppliers

UNION ALL

SELECT 'Customers', COUNT(*)
FROM Customers

UNION ALL

SELECT 'Warehouses', COUNT(*)
FROM Warehouses

UNION ALL

SELECT 'Products', COUNT(*)
FROM Products

UNION ALL

SELECT 'Inventory', COUNT(*)
FROM Inventory

UNION ALL

SELECT 'Shipments', COUNT(*)
FROM Shipments

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Orders

UNION ALL

SELECT 'OrderDetails', COUNT(*)
FROM OrderDetails;


-- ============================================================
-- 2. DUPLICATE ORDER IDs
-- Expected result: 0 rows
-- ============================================================

SELECT
    OrderID,
    COUNT(*) AS DuplicateCount
FROM Orders
GROUP BY OrderID
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. DUPLICATE PRODUCTS WITHIN THE SAME ORDER
-- Expected result: 0 rows
-- ============================================================

SELECT
    OrderID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM OrderDetails
GROUP BY
    OrderID,
    ProductID
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. DUPLICATE PRODUCT / WAREHOUSE INVENTORY RECORDS
-- Expected result: 0 rows
-- ============================================================

SELECT
    WarehouseID,
    ProductID,
    COUNT(*) AS DuplicateCount
FROM Inventory
GROUP BY
    WarehouseID,
    ProductID
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. INVALID PRODUCT VALUES
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidProductValues
FROM Products
WHERE Cost < 0
   OR SellingPrice < 0
   OR ProductWeight <= 0;


-- ============================================================
-- 6. INVALID INVENTORY VALUES
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidInventoryRecords
FROM Inventory
WHERE CurrentStock < 0
   OR ReorderLevel < 0;


-- ============================================================
-- 7. INVALID ORDER QUANTITIES
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidOrderQuantities
FROM OrderDetails
WHERE Quantity <= 0;


-- ============================================================
-- 8. INVALID SUPPLIER VALUES
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidSupplierValues
FROM Suppliers
WHERE LeadTimeDays < 0
   OR SupplierRating < 1
   OR SupplierRating > 5;


-- ============================================================
-- 9. ORDER / SHIPMENT DATE VALIDATION
-- Shipment cannot occur before its order
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidShipmentDates
FROM Orders o
JOIN Shipments s
    ON o.ShipmentID = s.ShipmentID
WHERE s.ShipDate < o.OrderDate
   OR s.ExpectedArrivalDate < s.ShipDate;


-- ============================================================
-- 10. DELAYED SHIPMENT VALIDATION
-- Delayed shipments must arrive after expected date
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidDelayedShipments
FROM Shipments
WHERE Status = 'Delayed'
  AND (
        ActualArrivalDate IS NULL
        OR ActualArrivalDate <= ExpectedArrivalDate
      );


-- ============================================================
-- 11. IN-TRANSIT SHIPMENT VALIDATION
-- In-transit shipments should not have an arrival date
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS InvalidInTransitShipments
FROM Shipments
WHERE Status = 'In Transit'
  AND ActualArrivalDate IS NOT NULL;


-- ============================================================
-- 12. ORPHANED ORDER DETAILS
-- Every OrderDetail must have a valid Order and Product
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS OrphanedOrderDetails
FROM OrderDetails od
LEFT JOIN Orders o
    ON od.OrderID = o.OrderID
LEFT JOIN Products p
    ON od.ProductID = p.ProductID
WHERE o.OrderID IS NULL
   OR p.ProductID IS NULL;


-- ============================================================
-- 13. ORPHANED ORDERS
-- Every Order must reference valid Customer, Warehouse,
-- and Shipment records
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS OrphanedOrders
FROM Orders o
LEFT JOIN Customers c
    ON o.CustomerID = c.CustomerID
LEFT JOIN Warehouses w
    ON o.WarehouseID = w.WarehouseID
LEFT JOIN Shipments s
    ON o.ShipmentID = s.ShipmentID
WHERE c.CustomerID IS NULL
   OR w.WarehouseID IS NULL
   OR s.ShipmentID IS NULL;


-- ============================================================
-- 14. NULL ARRIVAL DATE VALIDATION
-- NULL ActualArrivalDate should belong only to In Transit
-- ============================================================

SELECT
    Status,
    COUNT(*) AS NullArrivalDates
FROM Shipments
WHERE ActualArrivalDate IS NULL
GROUP BY Status;


-- ============================================================
-- 15. ORDER DATE RANGE
-- Review the period covered by the dataset
-- ============================================================

SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM Orders;


-- ============================================================
-- 16. SHIPMENT STATUS DISTRIBUTION
-- Review generated shipping activity
-- ============================================================

SELECT
    Status,
    COUNT(*) AS ShipmentCount,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Shipments),
        2
    ) AS Percentage
FROM Shipments
GROUP BY Status
ORDER BY ShipmentCount DESC;


-- ============================================================
-- 17. FINAL VALIDATION SUMMARY
-- PASS = no detected data-quality issue
-- ============================================================

SELECT
    CASE
        WHEN
            (SELECT COUNT(*)
             FROM Products
             WHERE Cost < 0
                OR SellingPrice < 0
                OR ProductWeight <= 0) = 0

        AND
            (SELECT COUNT(*)
             FROM Inventory
             WHERE CurrentStock < 0
                OR ReorderLevel < 0) = 0

        AND
            (SELECT COUNT(*)
             FROM OrderDetails
             WHERE Quantity <= 0) = 0

        AND
            (SELECT COUNT(*)
             FROM Orders o
             JOIN Shipments s
                 ON o.ShipmentID = s.ShipmentID
             WHERE s.ShipDate < o.OrderDate
                OR s.ExpectedArrivalDate < s.ShipDate) = 0

        AND
            (SELECT COUNT(*)
             FROM Shipments
             WHERE Status = 'Delayed'
               AND (
                    ActualArrivalDate IS NULL
                    OR ActualArrivalDate <= ExpectedArrivalDate
               )) = 0

        AND
            (SELECT COUNT(*)
             FROM Shipments
             WHERE Status = 'In Transit'
               AND ActualArrivalDate IS NOT NULL) = 0

        THEN 'PASS'

        ELSE 'REVIEW REQUIRED'

    END AS DataQualityStatus;
    
    

