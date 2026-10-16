
# Supply Chain & Inventory Performance Analytics

**End-to-End Data Analytics Project | SQL • MySQL • Python • Power BI**

## Project Overview

This project demonstrates an end-to-end supply chain analytics workflow using Python, MySQL, SQL, and Power BI to analyze sales performance, inventory management, supplier efficiency, and shipping operations.

The project combines synthetic data generation, relational database development, data validation, business analysis, and interactive dashboard reporting.

## Business Problem

Supply chain organizations manage information across orders, products, warehouses, suppliers, and shipments. Without consolidated reporting, it can be difficult to identify inventory shortages, evaluate supplier performance, and monitor delivery efficiency.

This project develops an analytical reporting solution to provide visibility into these business operations and support data-driven decisions.

## Project Objectives

- Evaluate sales performance and profitability.
- Monitor inventory value, stock levels, and replenishment requirements.
- Assess supplier ratings, lead times, and activity.
- Analyze delivery performance and carrier efficiency.
- Present operational KPIs through interactive Power BI dashboards.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL / SQL | Database design, validation, analytical queries, and reporting views |
| Python | Synthetic data generation and MySQL data loading |
| Power Query | Data preparation and transformation |
| Power BI / DAX | Data modeling, KPI calculations, and dashboard development |

## Dataset

The project uses a synthetic relational supply chain dataset containing eight tables:

- Suppliers
- Customers
- Warehouses
- Products
- Inventory
- Shipments
- Orders
- OrderDetails

The dataset includes approximately 10,000 orders, 500 products, 200 customers, 25 suppliers, and 8 warehouses.

## Project Workflow

1. **Data Generation:** Generated synthetic supply chain datasets using Python.
2. **Database Development:** Created a relational MySQL database and imported operational data.
3. **Data Validation:** Performed SQL-based data quality and consistency checks.
4. **Business Analysis:** Developed SQL queries and analytical views to evaluate supply chain performance.
5. **Data Visualization:** Built a four-page Power BI dashboard using Power Query, data modeling, and DAX measures.

## Power BI Dashboard

### 1. Executive Overview

Provides a high-level summary of sales performance, order volume, profitability, and business trends.

### 2. Inventory Analysis

Examines inventory value, stock distribution, reorder levels, and replenishment requirements.

### 3. Supplier Performance

Evaluates supplier ratings, lead times, active suppliers, and supplier-level performance.

### 4. Shipping & Delivery

Analyzes shipment status, on-time delivery rates, delivery delays, and carrier performance.

## Selected Dashboard KPIs

| KPI | Result |
|---|---:|
| Total Orders | 10,000 |
| Profit Margin | 33.07% |
| Total Inventory Value | Approximately $123.24M |
| Total Inventory Units | Approximately 475K |
| Inventory Records Below Reorder Level | 1,032 |
| Total Suppliers | 25 |
| Average Supplier Rating | 2.78 |
| Average Supplier Lead Time | 16.0 days |
| Total Shipments | 10,000 |
| On-Time Delivery Rate | 89.2% |
| Delayed Shipments | 993 |
| Average Delay for Late Deliveries | 4.0 days |

*Results are based on the project's synthetic dataset and dashboard calculations.*

## Repository Structure

```text
01_SQL/       Database schema, validation, SQL analysis, and reporting views
02_Python/    Data generation and MySQL loading scripts
03_Data/      Synthetic CSV datasets
04_PowerBI/   Power BI dashboard and PDF report
README.md     Project documentation
```

## Business Value

This project demonstrates how SQL, Python, and Power BI can be integrated to support supply chain reporting.

The resulting dashboard provides a centralized view of sales, inventory, supplier performance, and shipping operations, helping users identify operational trends and areas requiring attention.

## Project Deliverables

- SQL database creation and analysis scripts
- Python data generation and loading scripts
- Synthetic CSV datasets
- Four-page Power BI dashboard
- PDF dashboard report

## Author

**Mariem Zoghlami**

Data Analytics | SQL | Python | Power BI | Business Intelligence
