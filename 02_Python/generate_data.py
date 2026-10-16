import random
from datetime import timedelta
from pathlib import Path

import pandas as pd
from faker import Faker


# ============================================================
# SUPPLY CHAIN & INVENTORY ANALYTICS
# Synthetic Business Data Generator
# ============================================================

fake = Faker()

# Reproducible results
Faker.seed(42)
random.seed(42)


# ============================================================
# PROJECT PATHS
# ============================================================

# generate_data.py is stored inside 02_Python.
# parent.parent points to the main project folder.
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "03_Data"

# Create the data folder if it does not exist.
DATA_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# 1. SUPPLIERS
# ============================================================

suppliers = []

supplier_countries = [
    "United States",
    "Canada",
    "Mexico",
    "Germany",
    "China"
]

for supplier_id in range(1, 26):

    suppliers.append({
        "SupplierID": supplier_id,
        "SupplierName": f"Supplier {supplier_id}",
        "ContactPerson": fake.name(),
        "Email": fake.unique.email(),
        "Country": random.choice(supplier_countries),
        "LeadTimeDays": random.randint(3, 30),
        "SupplierRating": round(
            random.uniform(1.0, 5.0),
            1
        ),
        "IsActive": True
    })

suppliers_df = pd.DataFrame(suppliers)


# ============================================================
# 2. CUSTOMERS
# ============================================================

customers = []

industries = [
    "Retail",
    "Healthcare",
    "Manufacturing",
    "Technology",
    "Hospitality"
]

regions = [
    "Midwest",
    "Northeast",
    "South",
    "West"
]

customer_types = [
    "Small Business",
    "Mid-Market",
    "Enterprise"
]

for customer_id in range(1, 201):

    customers.append({
        "CustomerID": customer_id,
        "CompanyName": f"{fake.company()} {customer_id}",
        "Industry": random.choice(industries),
        "City": fake.city(),
        "State": fake.state_abbr(),
        "Region": random.choice(regions),
        "ContactPerson": fake.name(),
        "Email": fake.unique.email(),
        "CustomerType": random.choice(customer_types),
        "IsActive": random.choices(
            [True, False],
            weights=[95, 5],
            k=1
        )[0]
    })

customers_df = pd.DataFrame(customers)


# ============================================================
# 3. WAREHOUSES
# ============================================================

warehouses = []

warehouse_locations = [
    (
        "Chicago Distribution Center",
        "Chicago",
        "IL",
        "Midwest"
    ),
    (
        "Milwaukee Distribution Center",
        "Milwaukee",
        "WI",
        "Midwest"
    ),
    (
        "Dallas Distribution Center",
        "Dallas",
        "TX",
        "South"
    ),
    (
        "Atlanta Distribution Center",
        "Atlanta",
        "GA",
        "South"
    ),
    (
        "New York Distribution Center",
        "New York",
        "NY",
        "Northeast"
    ),
    (
        "Boston Distribution Center",
        "Boston",
        "MA",
        "Northeast"
    ),
    (
        "Los Angeles Distribution Center",
        "Los Angeles",
        "CA",
        "West"
    ),
    (
        "Seattle Distribution Center",
        "Seattle",
        "WA",
        "West"
    )
]

for warehouse_id, location in enumerate(
    warehouse_locations,
    start=1
):

    warehouse_name, city, state, region = location

    warehouses.append({
        "WarehouseID": warehouse_id,
        "WarehouseName": warehouse_name,
        "City": city,
        "State": state,
        "Region": region,
        "Capacity": random.randint(
            30000,
            80000
        ),
        "ManagerName": fake.name(),
        "IsActive": True
    })

warehouses_df = pd.DataFrame(warehouses)


# ============================================================
# 4. PRODUCTS
# ============================================================

products = []

categories = [
    "Electronics",
    "Office Supplies",
    "Industrial Equipment",
    "Packaging",
    "Safety Equipment"
]

units = [
    "Unit",
    "Box",
    "Case",
    "Pallet"
]

for product_id in range(1, 501):

    cost = round(
        random.uniform(5, 500),
        2
    )

    markup = random.uniform(
        1.20,
        1.80
    )

    selling_price = round(
        cost * markup,
        2
    )

    products.append({
        "ProductID": product_id,
        "ProductName": f"Product {product_id}",
        "Category": random.choice(categories),
        "SupplierID": random.randint(1, 25),
        "Cost": cost,
        "SellingPrice": selling_price,
        "ProductWeight": round(
            random.uniform(0.5, 50.0),
            2
        ),
        "UnitOfMeasure": random.choice(units),
        "IsActive": random.choices(
            [True, False],
            weights=[97, 3],
            k=1
        )[0]
    })

products_df = pd.DataFrame(products)


# ============================================================
# 5. INVENTORY
# ============================================================

# Every warehouse receives one inventory record
# for every product:
#
# 8 warehouses x 500 products = 4,000 records.

inventory = []
inventory_id = 1

for warehouse_id in range(1, 9):

    for product_id in range(1, 501):

        reorder_level = random.randint(
            20,
            100
        )

        current_stock = random.randint(
            0,
            reorder_level * 4
        )

        inventory.append({
            "InventoryID": inventory_id,
            "WarehouseID": warehouse_id,
            "ProductID": product_id,
            "CurrentStock": current_stock,
            "ReorderLevel": reorder_level
        })

        inventory_id += 1

inventory_df = pd.DataFrame(inventory)


# ============================================================
# 6. ORDERS
# ============================================================

orders = []

for order_id in range(1, 10001):

    # Stop 15 days before today so shipments have time
    # to move through the delivery process.
    order_date = fake.date_between(
        start_date="-2y",
        end_date="-15d"
    )

    orders.append({
        "OrderID": order_id,
        "CustomerID": random.randint(1, 200),
        "WarehouseID": random.randint(1, 8),

        # One shipment is associated with each order.
        "ShipmentID": order_id,

        "OrderDate": order_date
    })

orders_df = pd.DataFrame(orders)


# ============================================================
# 7. SHIPMENTS
# ============================================================

# Shipment dates are generated from their related order dates.
#
# Business process:
#
# Order Date
#     ↓
# Ship Date
#     ↓
# Expected Arrival
#     ↓
# Actual Arrival / In Transit

shipments = []

carriers = [
    "UPS",
    "FedEx",
    "DHL",
    "USPS"
]

for order in orders:

    order_date = order["OrderDate"]

    ship_date = order_date + timedelta(
        days=random.randint(0, 3)
    )

    expected_arrival = ship_date + timedelta(
        days=random.randint(2, 7)
    )

    status = random.choices(
        [
            "Delivered",
            "Delayed",
            "In Transit"
        ],
        weights=[
            82,
            10,
            8
        ],
        k=1
    )[0]

    if status == "Delivered":

        actual_arrival = (
            expected_arrival
            + timedelta(
                days=random.randint(-2, 0)
            )
        )

    elif status == "Delayed":

        actual_arrival = (
            expected_arrival
            + timedelta(
                days=random.randint(1, 7)
            )
        )

    else:

        # In-transit shipments have not arrived yet.
        actual_arrival = None

    shipments.append({
        "ShipmentID": order["ShipmentID"],
        "ShipDate": ship_date,
        "ExpectedArrivalDate": expected_arrival,
        "ActualArrivalDate": actual_arrival,
        "Carrier": random.choice(carriers),
        "Status": status,
        "ShippingCost": round(
            random.uniform(10, 250),
            2
        )
    })

shipments_df = pd.DataFrame(shipments)


# ============================================================
# 8. ORDER DETAILS
# ============================================================

order_details = []
order_detail_id = 1

for order_id in range(1, 10001):

    # Each order contains 1-5 unique products.
    number_of_products = random.randint(
        1,
        5
    )

    selected_products = random.sample(
        range(1, 501),
        number_of_products
    )

    for product_id in selected_products:

        order_details.append({
            "OrderDetailID": order_detail_id,
            "OrderID": order_id,
            "ProductID": product_id,
            "Quantity": random.randint(1, 20)
        })

        order_detail_id += 1

order_details_df = pd.DataFrame(order_details)


# ============================================================
# 9. DATA QUALITY VALIDATION
# ============================================================

datasets = {
    "Suppliers": suppliers_df,
    "Customers": customers_df,
    "Warehouses": warehouses_df,
    "Products": products_df,
    "Inventory": inventory_df,
    "Orders": orders_df,
    "Shipments": shipments_df,
    "OrderDetails": order_details_df
}


print("\nDATASET SUMMARY")
print("=" * 50)

for name, dataframe in datasets.items():

    print(
        f"{name}: "
        f"{len(dataframe):,} records"
    )


print("\nNULL VALUE CHECK")
print("=" * 50)

for name, dataframe in datasets.items():

    null_count = (
        dataframe
        .isnull()
        .sum()
        .sum()
    )

    print(
        f"{name}: "
        f"{null_count:,} null values"
    )


print("\nDUPLICATE PRIMARY KEY CHECK")
print("=" * 50)

primary_keys = {
    "Suppliers": (
        "SupplierID",
        suppliers_df
    ),
    "Customers": (
        "CustomerID",
        customers_df
    ),
    "Warehouses": (
        "WarehouseID",
        warehouses_df
    ),
    "Products": (
        "ProductID",
        products_df
    ),
    "Inventory": (
        "InventoryID",
        inventory_df
    ),
    "Orders": (
        "OrderID",
        orders_df
    ),
    "Shipments": (
        "ShipmentID",
        shipments_df
    ),
    "OrderDetails": (
        "OrderDetailID",
        order_details_df
    )
}

for name, item in primary_keys.items():

    column, dataframe = item

    duplicate_count = (
        dataframe[column]
        .duplicated()
        .sum()
    )

    print(
        f"{name}: "
        f"{duplicate_count:,} duplicate "
        f"{column} values"
    )


# ------------------------------------------------------------
# Additional business-rule validation
# ------------------------------------------------------------

invalid_shipment_dates = 0
invalid_delayed_shipments = 0
invalid_in_transit_shipments = 0

for order, shipment in zip(
    orders,
    shipments
):

    if shipment["ShipDate"] < order["OrderDate"]:
        invalid_shipment_dates += 1

    if (
        shipment["ExpectedArrivalDate"]
        < shipment["ShipDate"]
    ):
        invalid_shipment_dates += 1

    if shipment["Status"] == "Delayed":

        if (
            shipment["ActualArrivalDate"] is None
            or shipment["ActualArrivalDate"]
            <= shipment["ExpectedArrivalDate"]
        ):
            invalid_delayed_shipments += 1

    if shipment["Status"] == "In Transit":

        if shipment["ActualArrivalDate"] is not None:
            invalid_in_transit_shipments += 1


print("\nBUSINESS RULE VALIDATION")
print("=" * 50)

print(
    "Invalid shipment dates:",
    invalid_shipment_dates
)

print(
    "Invalid delayed shipments:",
    invalid_delayed_shipments
)

print(
    "Invalid in-transit shipments:",
    invalid_in_transit_shipments
)


# ============================================================
# 10. EXPORT CSV FILES
# ============================================================

suppliers_df.to_csv(
    DATA_DIR / "Suppliers.csv",
    index=False
)

customers_df.to_csv(
    DATA_DIR / "Customers.csv",
    index=False
)

warehouses_df.to_csv(
    DATA_DIR / "Warehouses.csv",
    index=False
)

products_df.to_csv(
    DATA_DIR / "Products.csv",
    index=False
)

inventory_df.to_csv(
    DATA_DIR / "Inventory.csv",
    index=False
)

shipments_df.to_csv(
    DATA_DIR / "Shipments.csv",
    index=False
)

orders_df.to_csv(
    DATA_DIR / "Orders.csv",
    index=False
)

order_details_df.to_csv(
    DATA_DIR / "OrderDetails.csv",
    index=False
)


print("\nCSV files generated successfully.")
print(
    f"Files saved to: {DATA_DIR}"
)