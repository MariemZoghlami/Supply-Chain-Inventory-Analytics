-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- Analytical Views
-- ============================================================

USE SupplyChain_Analysis;


-- ============================================================
-- VIEW 1: SALES PERFORMANCE
--
-- Purpose:
-- Creates order-line sales metrics used to analyze revenue,
-- quantity sold, customers, products, warehouses and regions.
-- ============================================================

CREATE OR REPLACE VIEW sales_performance_view AS

SELECT
    o.OrderID,
    o.OrderDate,

    c.CustomerID,
    c.CompanyName,
    c.Industry,
    c.CustomerType,
    c.Region AS CustomerRegion,

    w.WarehouseID,
    w.WarehouseName,
    w.Region AS WarehouseRegion,

    p.ProductID,
    p.ProductName,
    p.Category,

    od.Quantity,

    p.Cost AS UnitCost,
    p.SellingPrice AS UnitSellingPrice,

    ROUND(
        od.Quantity * p.SellingPrice,
        2
    ) AS Revenue,

    ROUND(
        od.Quantity * p.Cost,
        2
    ) AS ProductCost,

    ROUND(
        od.Quantity *
        (p.SellingPrice - p.Cost),
        2
    ) AS GrossProfit

FROM Orders o

JOIN Customers c
    ON o.CustomerID = c.CustomerID

JOIN Warehouses w
    ON o.WarehouseID = w.WarehouseID

JOIN OrderDetails od
    ON o.OrderID = od.OrderID

JOIN Products p
    ON od.ProductID = p.ProductID;


-- ============================================================
-- VIEW 2: INVENTORY PERFORMANCE
--
-- Purpose:
-- Identifies stock position and products requiring
-- replenishment.
-- ============================================================

CREATE OR REPLACE VIEW inventory_performance_view AS

SELECT
    i.InventoryID,

    i.WarehouseID,
    w.WarehouseName,
    w.Region AS WarehouseRegion,

    i.ProductID,
    p.ProductName,
    p.Category,

    i.CurrentStock,
    i.ReorderLevel,

    CASE
        WHEN i.CurrentStock <= i.ReorderLevel
            THEN 'Reorder Required'

        ELSE 'Stock Sufficient'
    END AS StockStatus,

    GREATEST(
        i.ReorderLevel - i.CurrentStock,
        0
    ) AS UnitsBelowReorderLevel,

    ROUND(
        i.CurrentStock * p.Cost,
        2
    ) AS InventoryCostValue,

    ROUND(
        i.CurrentStock * p.SellingPrice,
        2
    ) AS InventoryRetailValue

FROM Inventory i

JOIN Warehouses w
    ON i.WarehouseID = w.WarehouseID

JOIN Products p
    ON i.ProductID = p.ProductID;


-- ============================================================
-- VIEW 3: SHIPPING PERFORMANCE
--
-- Purpose:
-- Measures carrier and delivery performance.
-- ============================================================

CREATE OR REPLACE VIEW shipping_performance_view AS

SELECT
    s.ShipmentID,
    o.OrderID,
    o.OrderDate,

    s.ShipDate,
    s.ExpectedArrivalDate,
    s.ActualArrivalDate,

    s.Carrier,
    s.Status,
    s.ShippingCost,

    DATEDIFF(
        s.ExpectedArrivalDate,
        s.ShipDate
    ) AS ExpectedTransitDays,

    CASE
        WHEN s.ActualArrivalDate IS NOT NULL
        THEN DATEDIFF(
            s.ActualArrivalDate,
            s.ShipDate
        )
        ELSE NULL
    END AS ActualTransitDays,

    CASE
        WHEN s.ActualArrivalDate IS NULL
            THEN NULL

        WHEN s.ActualArrivalDate >
             s.ExpectedArrivalDate
            THEN DATEDIFF(
                s.ActualArrivalDate,
                s.ExpectedArrivalDate
            )

        ELSE 0
    END AS DelayDays,

    CASE
        WHEN s.Status = 'In Transit'
            THEN 'In Transit'

        WHEN s.ActualArrivalDate >
             s.ExpectedArrivalDate
            THEN 'Late'

        ELSE 'On Time'
    END AS DeliveryPerformance

FROM Shipments s

JOIN Orders o
    ON s.ShipmentID = o.ShipmentID;


-- ============================================================
-- VIEW 4: SUPPLIER PERFORMANCE
--
-- IMPORTANT:
-- Sales and inventory are aggregated BEFORE joining them.
-- This prevents row multiplication and inflated supplier
-- totals.
-- ============================================================

CREATE OR REPLACE VIEW supplier_performance_view AS

SELECT
    s.SupplierID,
    s.SupplierName,
    s.Country,
    s.LeadTimeDays,
    s.SupplierRating,
    s.IsActive,

    COALESCE(
        product_summary.ProductCount,
        0
    ) AS ProductCount,

    COALESCE(
        sales_summary.UnitsSold,
        0
    ) AS UnitsSold,

    COALESCE(
        sales_summary.TotalRevenue,
        0
    ) AS TotalRevenue,

    COALESCE(
        sales_summary.TotalProductCost,
        0
    ) AS TotalProductCost,

    COALESCE(
        sales_summary.GrossProfit,
        0
    ) AS GrossProfit,

    COALESCE(
        inventory_summary.TotalCurrentStock,
        0
    ) AS TotalCurrentStock,

    COALESCE(
        inventory_summary.InventoryCostValue,
        0
    ) AS InventoryCostValue,

    COALESCE(
        inventory_summary.ReorderRequiredCount,
        0
    ) AS ReorderRequiredCount

FROM Suppliers s


LEFT JOIN (

    SELECT
        SupplierID,
        COUNT(*) AS ProductCount

    FROM Products

    GROUP BY SupplierID

) product_summary

    ON s.SupplierID =
       product_summary.SupplierID


LEFT JOIN (

    SELECT
        p.SupplierID,

        SUM(od.Quantity)
            AS UnitsSold,

        ROUND(
            SUM(
                od.Quantity *
                p.SellingPrice
            ),
            2
        ) AS TotalRevenue,

        ROUND(
            SUM(
                od.Quantity *
                p.Cost
            ),
            2
        ) AS TotalProductCost,

        ROUND(
            SUM(
                od.Quantity *
                (
                    p.SellingPrice -
                    p.Cost
                )
            ),
            2
        ) AS GrossProfit

    FROM OrderDetails od

    JOIN Products p
        ON od.ProductID =
           p.ProductID

    GROUP BY p.SupplierID

) sales_summary

    ON s.SupplierID =
       sales_summary.SupplierID


LEFT JOIN (

    SELECT
        p.SupplierID,

        SUM(i.CurrentStock)
            AS TotalCurrentStock,

        ROUND(
            SUM(
                i.CurrentStock *
                p.Cost
            ),
            2
        ) AS InventoryCostValue,

        SUM(
            CASE
                WHEN i.CurrentStock <=
                     i.ReorderLevel
                THEN 1
                ELSE 0
            END
        ) AS ReorderRequiredCount

    FROM Inventory i

    JOIN Products p
        ON i.ProductID =
           p.ProductID

    GROUP BY p.SupplierID

) inventory_summary

    ON s.SupplierID =
       inventory_summary.SupplierID;


-- ============================================================
-- VERIFY VIEWS
-- ============================================================

SHOW FULL TABLES
WHERE Table_type = 'VIEW';


-- Expected row counts:
-- sales_performance_view     = 29,971
-- inventory_performance_view = 4,000
-- shipping_performance_view  = 10,000
-- supplier_performance_view  = 25

SELECT
    'sales_performance_view' AS ViewName,
    COUNT(*) AS RecordCount
FROM sales_performance_view

UNION ALL

SELECT
    'inventory_performance_view',
    COUNT(*)
FROM inventory_performance_view

UNION ALL

SELECT
    'shipping_performance_view',
    COUNT(*)
FROM shipping_performance_view

UNION ALL

SELECT
    'supplier_performance_view',
    COUNT(*)
FROM supplier_performance_view;


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