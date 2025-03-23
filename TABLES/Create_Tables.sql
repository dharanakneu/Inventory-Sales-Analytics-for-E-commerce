-- Clear the Oracle database recycle bin
PURGE RECYCLEBIN;


-- Enable output messages from PL/SQL scripts for debugging
SET SERVEROUTPUT ON

-- Drop existing tables and constraints
/
DECLARE
    CURSOR CUR_CONSTRAINTS IS SELECT TABLE_NAME, CONSTRAINT_NAME FROM USER_CONSTRAINTS;
    CURSOR CUR_SEQ IS SELECT SEQUENCE_NAME FROM USER_SEQUENCES; 
    CURSOR CUR_TABLES IS SELECT TABLE_NAME FROM USER_TABLES;
BEGIN
    FOR CONS IN CUR_CONSTRAINTS LOOP
        EXECUTE IMMEDIATE('ALTER TABLE ' || CONS.TABLE_NAME || ' DROP CONSTRAINT ' || CONS.CONSTRAINT_NAME);
    END LOOP;
    
    FOR TABL IN CUR_TABLES LOOP
        EXECUTE IMMEDIATE('DROP TABLE ' || TABL.TABLE_NAME);
    END LOOP;
    
    FOR SEQ IN CUR_SEQ LOOP
        EXECUTE IMMEDIATE ('DROP SEQUENCE ' || SEQ.SEQUENCE_NAME );
    END LOOP;
END;
/


-- Creating tables

CREATE TABLE Categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR2(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Warehouses (
    warehouse_id INTEGER PRIMARY KEY,
    warehouse_code VARCHAR2(20),
    city VARCHAR2(100),
    state VARCHAR2(100),
    country VARCHAR2(100),
    manager_name VARCHAR2(255),
    contact_number VARCHAR2(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY,
    stock_level INTEGER,
    last_restock_date DATE,
    reorder_threshold INTEGER,
    warehouse_id INTEGER REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR2(255),
    price NUMBER(10,2),
    category_id INTEGER REFERENCES Categories(category_id) ON DELETE CASCADE,
    inventory_id INTEGER UNIQUE REFERENCES Inventory(inventory_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(255),
    phone VARCHAR2(15) UNIQUE,
    dob DATE,
    gender CHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Addresses (
    address_id INTEGER PRIMARY KEY,
    address_line VARCHAR2(255),
    city VARCHAR2(100),
    state VARCHAR2(100),
    zip_code VARCHAR2(20),
    address_type VARCHAR2(50),
    customer_id INTEGER REFERENCES Customers(customer_id) ON DELETE CASCADE,
    is_default CHAR(1),
    is_deleted CHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customer_Orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE,
    total_amount NUMBER(10,2),
    status VARCHAR2(20),
    customer_id INTEGER REFERENCES Customers(customer_id) ON DELETE CASCADE,
    address_id INTEGER REFERENCES Addresses(address_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Payments (
    payment_id INTEGER PRIMARY KEY,
    payment_method VARCHAR2(50),
    payment_status VARCHAR2(20),
    payment_date DATE,
    amount_paid NUMBER(10,2),
    order_id INTEGER REFERENCES Customer_Orders(order_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Order_Items (
    order_item_id INTEGER PRIMARY KEY,
    product_quantity INTEGER,
    unit_price NUMBER(10,2),
    product_id INTEGER REFERENCES Products(product_id) ON DELETE CASCADE,
    order_id INTEGER REFERENCES Customer_Orders(order_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Returns (
    return_id INTEGER PRIMARY KEY,
    return_amount NUMBER(10,2),
    status VARCHAR2(50),
    reason VARCHAR2(255),
    returned_quantity INTEGER,
    order_item_id INTEGER UNIQUE REFERENCES Order_Items(order_item_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Discounts (
    discount_id INTEGER PRIMARY KEY,
    promo_code VARCHAR2(20),
    discount_percentage NUMBER(5,2),
    start_date DATE,
    end_date DATE,
    product_id INTEGER REFERENCES Products(product_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Suppliers (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name VARCHAR2(255),
    contact_number VARCHAR2(15),
    email VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Suppliers_Products (
    supplier_product_id INTEGER PRIMARY KEY,
    supply_price NUMBER(10,2),
    product_id INTEGER REFERENCES Products(product_id) ON DELETE CASCADE,
    supplier_id INTEGER REFERENCES Suppliers(supplier_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Warehouse_Orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE,
    total_quantity INTEGER,
    warehouse_id INTEGER REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE,
    supplier_id INTEGER REFERENCES Suppliers(supplier_id) ON DELETE CASCADE,
    inventory_id INTEGER REFERENCES Inventory(inventory_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

