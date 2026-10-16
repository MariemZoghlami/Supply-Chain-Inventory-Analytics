import os
from pathlib import Path

import pandas as pd
import mysql.connector


# ============================================================
# SUPPLY CHAIN & INVENTORY ANALYTICS
# CSV TO MYSQL DATA LOADER
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "03_Data"


# ============================================================
# DATABASE CONNECTION
# ============================================================

connection = mysql.connector.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password=os.getenv("MYSQL_PASSWORD"),
    database="SupplyChain_Analysis"
)

cursor = connection.cursor()


# ============================================================
# CSV LOADING FUNCTION
# ============================================================

def load_csv(table_name, file_name, columns):

    file_path = DATA_DIR / file_name

    dataframe = pd.read_csv(file_path)

    placeholders = ", ".join(
        ["%s"] * len(columns)
    )

    column_names = ", ".join(columns)

    query = (
        f"INSERT INTO {table_name} "
        f"({column_names}) "
        f"VALUES ({placeholders})"
    )

    values = []

    for _, row in dataframe.iterrows():

        record = []

        for column in columns:

            value = row[column]

            if pd.isna(value):
                value = None

            # Convert NumPy values to normal Python values
            if hasattr(value, "item"):
                value = value.item()

            record.append(value)

        values.append(tuple(record))

    cursor.executemany(
        query,
        values
    )

    connection.commit()

    print(
        f"{table_name}: "
        f"{len(dataframe):,} records loaded."
    )


# ============================================================
# LOAD TABLES
# ============================================================

try:

    # --------------------------------------------------------
    # 1. SUPPLIERS
    # --------------------------------------------------------

    load_csv(
        "Suppliers",
        "Suppliers.csv",
        [
            "SupplierID",
            "SupplierName",
            "ContactPerson",
            "Email",
            "Country",
            "LeadTimeDays",
            "SupplierRating",
            "IsActive"
        ]
    )


    # --------------------------------------------------------
    # 2. CUSTOMERS
    # --------------------------------------------------------

    load_csv(
        "Customers",
        "Customers.csv",
        [
            "CustomerID",
            "CompanyName",
            "Industry",
            "City",
            "State",
            "Region",
            "ContactPerson",
            "Email",
            "CustomerType",
            "IsActive"
        ]
    )


    # --------------------------------------------------------
    # 3. WAREHOUSES
    # --------------------------------------------------------

    load_csv(
        "Warehouses",
        "Warehouses.csv",
        [
            "WarehouseID",
            "WarehouseName",
            "City",
            "State",
            "Region",
            "Capacity",
            "ManagerName",
            "IsActive"
        ]
    )


    # --------------------------------------------------------
    # 4. PRODUCTS
    # --------------------------------------------------------

    load_csv(
        "Products",
        "Products.csv",
        [
            "ProductID",
            "ProductName",
            "Category",
            "SupplierID",
            "Cost",
            "SellingPrice",
            "ProductWeight",
            "UnitOfMeasure",
            "IsActive"
        ]
    )


    # --------------------------------------------------------
    # 5. INVENTORY
    # --------------------------------------------------------

    load_csv(
        "Inventory",
        "Inventory.csv",
        [
            "InventoryID",
            "WarehouseID",
            "ProductID",
            "CurrentStock",
            "ReorderLevel"
        ]
    )


    # --------------------------------------------------------
    # 6. SHIPMENTS
    #
    # Must be loaded BEFORE Orders because Orders contains
    # ShipmentID as a foreign key.
    # --------------------------------------------------------

    load_csv(
        "Shipments",
        "Shipments.csv",
        [
            "ShipmentID",
            "ShipDate",
            "ExpectedArrivalDate",
            "ActualArrivalDate",
            "Carrier",
            "Status",
            "ShippingCost"
        ]
    )


    # --------------------------------------------------------
    # 7. ORDERS
    # --------------------------------------------------------

    load_csv(
        "Orders",
        "Orders.csv",
        [
            "OrderID",
            "CustomerID",
            "WarehouseID",
            "ShipmentID",
            "OrderDate"
        ]
    )


    # --------------------------------------------------------
    # 8. ORDER DETAILS
    # --------------------------------------------------------

    load_csv(
        "OrderDetails",
        "OrderDetails.csv",
        [
            "OrderDetailID",
            "OrderID",
            "ProductID",
            "Quantity"
        ]
    )


    print("\n" + "=" * 50)
    print("ALL DATA LOADED SUCCESSFULLY")
    print("=" * 50)


except Exception as error:

    connection.rollback()

    print("\n" + "=" * 50)
    print("DATA LOADING FAILED")
    print("=" * 50)

    print(error)


finally:

    cursor.close()
    connection.close()