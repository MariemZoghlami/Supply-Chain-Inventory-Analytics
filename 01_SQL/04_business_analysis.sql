-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- Business Analysis
-- ============================================================

USE SupplyChain_Analysis;


-- ============================================================
-- 1. EXECUTIVE KPI SUMMARY
-- Business question:
-- What are the company's core sales performance metrics?
-- ============================================================

SELECT
    COUNT(DISTINCT OrderID) AS TotalOrders,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit,

    ROUND(
        SUM(GrossProfit) /
        NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS GrossMarginPercent,

    ROUND(
        SUM(Revenue) /
        NULLIF(COUNT(DISTINCT OrderID), 0),
        2
    ) AS AverageOrderValue,

    SUM(Quantity) AS UnitsSold

FROM sales_performance_view;


-- ============================================================
-- 2. REVENUE BY PRODUCT CATEGORY
-- Business question:
-- Which product categories generate the most revenue?
-- ============================================================

SELECT
    Category,

    SUM(Quantity) AS UnitsSold,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit,

    ROUND(
        SUM(GrossProfit) /
        NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS GrossMarginPercent

FROM sales_performance_view

GROUP BY Category

ORDER BY TotalRevenue DESC;


-- ============================================================
-- 3. TOP 10 PRODUCTS BY REVENUE
-- Business question:
-- Which individual products contribute the most revenue?
-- ============================================================

SELECT
    ProductID,
    ProductName,
    Category,

    SUM(Quantity) AS UnitsSold,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit

FROM sales_performance_view

GROUP BY
    ProductID,
    ProductName,
    Category

ORDER BY TotalRevenue DESC

LIMIT 10;


-- ============================================================
-- 4. TOP 10 CUSTOMERS BY REVENUE
-- Business question:
-- Which customers contribute the most revenue?
-- ============================================================

SELECT
    CustomerID,
    CompanyName,
    Industry,
    CustomerType,

    COUNT(
        DISTINCT OrderID
    ) AS TotalOrders,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(Revenue) /
        NULLIF(
            COUNT(DISTINCT OrderID),
            0
        ),
        2
    ) AS AverageOrderValue

FROM sales_performance_view

GROUP BY
    CustomerID,
    CompanyName,
    Industry,
    CustomerType

ORDER BY TotalRevenue DESC

LIMIT 10;


-- ============================================================
-- 5. SALES PERFORMANCE BY CUSTOMER REGION
-- Business question:
-- Which customer regions generate the strongest sales?
-- ============================================================

SELECT
    CustomerRegion,

    COUNT(
        DISTINCT OrderID
    ) AS TotalOrders,

    SUM(Quantity) AS UnitsSold,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit

FROM sales_performance_view

GROUP BY CustomerRegion

ORDER BY TotalRevenue DESC;


-- ============================================================
-- 6. MONTHLY SALES TREND
-- Business question:
-- How do revenue and order volume change over time?
-- ============================================================

SELECT
    DATE_FORMAT(
        OrderDate,
        '%Y-%m'
    ) AS SalesMonth,

    COUNT(
        DISTINCT OrderID
    ) AS TotalOrders,

    SUM(Quantity) AS UnitsSold,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit

FROM sales_performance_view

GROUP BY
    DATE_FORMAT(
        OrderDate,
        '%Y-%m'
    )

ORDER BY SalesMonth;


-- ============================================================
-- 7. WAREHOUSE SALES PERFORMANCE
-- Business question:
-- Which warehouses fulfill the greatest sales volume?
-- ============================================================

SELECT
    WarehouseID,
    WarehouseName,
    WarehouseRegion,

    COUNT(
        DISTINCT OrderID
    ) AS OrdersFulfilled,

    SUM(Quantity) AS UnitsSold,

    ROUND(
        SUM(Revenue),
        2
    ) AS TotalRevenue,

    ROUND(
        SUM(GrossProfit),
        2
    ) AS GrossProfit

FROM sales_performance_view

GROUP BY
    WarehouseID,
    WarehouseName,
    WarehouseRegion

ORDER BY TotalRevenue DESC;


-- ============================================================
-- 8. INVENTORY KPI SUMMARY
-- Business question:
-- What is the current inventory position?
-- ============================================================

SELECT
    SUM(CurrentStock) AS TotalUnitsInStock,

    ROUND(
        SUM(InventoryCostValue),
        2
    ) AS InventoryCostValue,

    ROUND(
        SUM(InventoryRetailValue),
        2
    ) AS InventoryRetailValue,

    SUM(
        CASE
            WHEN StockStatus =
                 'Reorder Required'
            THEN 1
            ELSE 0
        END
    ) AS ReorderRequiredRecords,

    ROUND(
        SUM(
            CASE
                WHEN StockStatus =
                     'Reorder Required'
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS ReorderRatePercent

FROM inventory_performance_view;


-- ============================================================
-- 9. REORDER REQUIREMENTS BY WAREHOUSE
-- Business question:
-- Which warehouses have the greatest replenishment need?
-- ============================================================

SELECT
    WarehouseID,
    WarehouseName,
    WarehouseRegion,

    COUNT(*) AS ProductsTracked,

    SUM(
        CASE
            WHEN StockStatus =
                 'Reorder Required'
            THEN 1
            ELSE 0
        END
    ) AS ReorderRequired,

    SUM(
        UnitsBelowReorderLevel
    ) AS UnitsBelowReorderLevel,

    ROUND(
        SUM(InventoryCostValue),
        2
    ) AS InventoryCostValue

FROM inventory_performance_view

GROUP BY
    WarehouseID,
    WarehouseName,
    WarehouseRegion

ORDER BY ReorderRequired DESC;


-- ============================================================
-- 10. PRODUCTS REQUIRING REPLENISHMENT
-- Business question:
-- Which product/warehouse combinations need restocking?
-- ============================================================

SELECT
    WarehouseName,
    ProductID,
    ProductName,
    Category,
    CurrentStock,
    ReorderLevel,
    UnitsBelowReorderLevel

FROM inventory_performance_view

WHERE StockStatus =
      'Reorder Required'

ORDER BY
    UnitsBelowReorderLevel DESC,
    CurrentStock ASC

LIMIT 25;


-- ============================================================
-- 11. SHIPPING KPI SUMMARY
-- Business question:
-- How effectively are orders being delivered?
-- ============================================================

SELECT
    COUNT(*) AS TotalShipments,

    SUM(
        CASE
            WHEN DeliveryPerformance =
                 'On Time'
            THEN 1
            ELSE 0
        END
    ) AS OnTimeShipments,

    SUM(
        CASE
            WHEN DeliveryPerformance =
                 'Late'
            THEN 1
            ELSE 0
        END
    ) AS LateShipments,

    SUM(
        CASE
            WHEN DeliveryPerformance =
                 'In Transit'
            THEN 1
            ELSE 0
        END
    ) AS InTransitShipments,

    ROUND(
        SUM(
            CASE
                WHEN DeliveryPerformance =
                     'On Time'
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(
            SUM(
                CASE
                    WHEN DeliveryPerformance
                         IN ('On Time', 'Late')
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS OnTimeDeliveryRatePercent,

    ROUND(
        SUM(ShippingCost),
        2
    ) AS TotalShippingCost

FROM shipping_performance_view;


-- ============================================================
-- 12. CARRIER PERFORMANCE
-- Business question:
-- How does delivery performance compare by carrier?
-- ============================================================

SELECT
    Carrier,

    COUNT(*) AS TotalShipments,

    SUM(
        CASE
            WHEN DeliveryPerformance =
                 'On Time'
            THEN 1
            ELSE 0
        END
    ) AS OnTimeShipments,

    SUM(
        CASE
            WHEN DeliveryPerformance =
                 'Late'
            THEN 1
            ELSE 0
        END
    ) AS LateShipments,

    ROUND(
        SUM(
            CASE
                WHEN DeliveryPerformance =
                     'On Time'
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(
            SUM(
                CASE
                    WHEN DeliveryPerformance
                         IN ('On Time', 'Late')
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS OnTimeDeliveryRatePercent,

    ROUND(
        AVG(
            CASE
                WHEN ActualTransitDays
                     IS NOT NULL
                THEN ActualTransitDays
            END
        ),
        2
    ) AS AverageTransitDays,

    ROUND(
        SUM(ShippingCost),
        2
    ) AS TotalShippingCost

FROM shipping_performance_view

GROUP BY Carrier

ORDER BY
    OnTimeDeliveryRatePercent DESC;


-- ============================================================
-- 13. DELAY ANALYSIS
-- Business question:
-- Where are the largest shipment delays occurring?
-- ============================================================

SELECT
    Carrier,

    COUNT(*) AS LateShipments,

    ROUND(
        AVG(DelayDays),
        2
    ) AS AverageDelayDays,

    MAX(DelayDays)
        AS MaximumDelayDays,

    ROUND(
        SUM(ShippingCost),
        2
    ) AS ShippingCost

FROM shipping_performance_view

WHERE DeliveryPerformance = 'Late'

GROUP BY Carrier

ORDER BY AverageDelayDays DESC;


-- ============================================================
-- 14. SUPPLIER PERFORMANCE
-- Business question:
-- How do suppliers compare across sales, profitability,
-- inventory and operational characteristics?
-- ============================================================

SELECT
    SupplierID,
    SupplierName,
    Country,
    ProductCount,
    UnitsSold,

    ROUND(
        TotalRevenue,
        2
    ) AS TotalRevenue,

    ROUND(
        GrossProfit,
        2
    ) AS GrossProfit,

    LeadTimeDays,
    SupplierRating,
    TotalCurrentStock,
    ReorderRequiredCount

FROM supplier_performance_view

ORDER BY TotalRevenue DESC;


-- ============================================================
-- 15. TOP 10 SUPPLIERS BY REVENUE
-- ============================================================

SELECT
    SupplierID,
    SupplierName,
    SupplierRating,
    LeadTimeDays,
    ProductCount,
    UnitsSold,

    ROUND(
        TotalRevenue,
        2
    ) AS TotalRevenue,

    ROUND(
        GrossProfit,
        2
    ) AS GrossProfit

FROM supplier_performance_view

ORDER BY TotalRevenue DESC

LIMIT 10;


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