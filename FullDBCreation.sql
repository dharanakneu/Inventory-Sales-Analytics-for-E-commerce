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


-- Creating sequences
CREATE SEQUENCE SEQ_CUSTOMER_ID START WITH 10001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ADDRESS_ID START WITH 20001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CUSTOMER_ORDER_ID START WITH 30001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PAYMENT_ID START WITH 40001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ORDER_ITEM_ID START WITH 50001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_RETURN_ID START WITH 60001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PRODUCT_ID START WITH 70001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CATEGORY_ID START WITH 80001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_DISCOUNT_ID START WITH 90001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_SUPPLIER_ID START WITH 100001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_INVENTORY_ID START WITH 110001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WAREHOUSE_ID START WITH 120001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_SUPPLIERS_PRODUCTS_ID START WITH 130001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WAREHOUSE_ORDERS_ID START WITH 140001 INCREMENT BY 1;


-- Creating tables

CREATE TABLE Categories (
    category_id INTEGER PRIMARY KEY, 
    category_name VARCHAR2(100) NOT NULL UNIQUE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    is_deleted CHAR(1) DEFAULT 'N' NOT NULL,  
    CONSTRAINT chk_category_name CHECK (TRIM(category_name) IS NOT NULL AND LENGTH(TRIM(category_name)) > 0),  
    CONSTRAINT chk_is_deleted_categories CHECK (is_deleted IN ('Y', 'N'))
);

CREATE TABLE Warehouses (
    warehouse_id INTEGER PRIMARY KEY, 
    warehouse_code VARCHAR2(20) NOT NULL UNIQUE, 
    city VARCHAR2(100) NOT NULL, 
    state VARCHAR2(100) NOT NULL, 
    country VARCHAR2(100) NOT NULL,    
    manager_name VARCHAR2(255) NOT NULL,
    contact_number VARCHAR2(20) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    CONSTRAINT chk_contact_number CHECK (
        REGEXP_LIKE(contact_number, '^[0-9 +\\-]+$')
    )
);

CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY,  
    stock_level INTEGER NOT NULL CHECK (stock_level >= 0),  
    last_restock_date DATE,  
    reorder_threshold INTEGER NOT NULL CHECK (reorder_threshold >= 0),  
    warehouse_id INTEGER NOT NULL REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY, 
    product_name VARCHAR2(255) NOT NULL UNIQUE, 
    price NUMBER(10,2) NOT NULL,
    category_id INTEGER NOT NULL REFERENCES Categories(category_id) ON DELETE CASCADE, 
    inventory_id INTEGER UNIQUE NOT NULL REFERENCES Inventory(inventory_id) ON DELETE CASCADE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_product_name CHECK (LENGTH(TRIM(product_name)) > 0),
    CONSTRAINT chk_price CHECK (price >= 0)
);

CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(255) NOT NULL,
    phone VARCHAR2(15) UNIQUE NOT NULL,
    dob DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_format CHECK (
        REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$')
    ),
    CONSTRAINT chk_gender_customers CHECK (gender IN ('M', 'F', 'O'))
);

CREATE TABLE Addresses (
    address_id INTEGER PRIMARY KEY,
    address_line VARCHAR2(255) NOT NULL,
    city VARCHAR2(100) NOT NULL,
    state VARCHAR2(100) NOT NULL,
    zip_code VARCHAR2(20) NOT NULL,
    address_type VARCHAR2(50),
    customer_id INTEGER NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    is_default CHAR(1) DEFAULT 'N',
    is_deleted CHAR(1) DEFAULT 'N',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_isdefaultdeleted_addresses CHECK (is_default IN ('Y', 'N') AND is_deleted IN ('Y', 'N'))
);

CREATE TABLE Customer_Orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE DEFAULT CURRENT_DATE NOT NULL,
    total_amount NUMBER(10,2) NOT NULL,
    order_status VARCHAR2(20) NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    shipping_address_id INTEGER NOT NULL REFERENCES Addresses(address_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status_orders CHECK (order_status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT chk_total_amount_orders CHECK (total_amount >= 0)
);

CREATE TABLE Payments (
    payment_id INTEGER PRIMARY KEY,  
    payment_method VARCHAR2(50) NOT NULL,  
    payment_status VARCHAR2(20) NOT NULL,  
    payment_date DATE NOT NULL,  
    amount_paid NUMBER(10,2) NOT NULL CHECK (amount_paid >= 0),  
    order_id INTEGER NOT NULL REFERENCES Customer_Orders(order_id) ON DELETE CASCADE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash', 'Other')),  
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Completed', 'Failed', 'Refunded', 'Cancelled'))  
);

CREATE TABLE Discounts (
    discount_id INTEGER PRIMARY KEY,  
    promo_code VARCHAR2(20) NOT NULL UNIQUE, 
    discount_percentage NUMBER(5,2) NOT NULL,
    start_date DATE NOT NULL,  
    end_date DATE NOT NULL, 
    product_id INTEGER REFERENCES Products(product_id) ON DELETE CASCADE, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    CONSTRAINT chk_promo_code_format CHECK (REGEXP_LIKE(promo_code, '^[A-Z0-9]+$')),  
    CONSTRAINT chk_discount_percentage CHECK (discount_percentage >= 0 AND discount_percentage <= 100), 
    CONSTRAINT chk_dates CHECK (start_date <= end_date) 
);

CREATE TABLE Order_Items (
    order_item_id INTEGER PRIMARY KEY,  
    product_quantity INTEGER NOT NULL,
    unit_price NUMBER(10,2) NOT NULL,
    product_id INTEGER NOT NULL REFERENCES Products(product_id) ON DELETE CASCADE,  
    order_id INTEGER NOT NULL REFERENCES Customer_Orders(order_id) ON DELETE CASCADE,
    discount_id INTEGER REFERENCES Discounts(discount_id) ON DELETE SET NULL,
    discounted_unit_price NUMBER(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    CONSTRAINT chk_product_quantity CHECK (product_quantity > 0),  
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0)  
);

CREATE TABLE Returns (
    return_id INTEGER PRIMARY KEY,  
    return_amount NUMBER(10,2) NOT NULL,
    status VARCHAR2(50) NOT NULL,  
    reason VARCHAR2(255),  
    returned_quantity INTEGER NOT NULL,
    order_item_id INTEGER NOT NULL UNIQUE REFERENCES Order_Items(order_item_id) ON DELETE CASCADE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  
    CONSTRAINT chk_return_status CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Completed')),  
    CONSTRAINT chk_return_amt CHECK (return_amount >= 0),  
    CONSTRAINT chk_return_qty CHECK (returned_quantity > 0)
);

CREATE TABLE Suppliers (
    supplier_id INTEGER PRIMARY KEY, 
    supplier_name VARCHAR2(255) NOT NULL, 
    contact_number VARCHAR2(15) NOT NULL UNIQUE, 
    email VARCHAR2(255) NOT NULL UNIQUE,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE Suppliers_Products (
    supplier_product_id INTEGER PRIMARY KEY,  
    supply_price NUMBER(10,2) NOT NULL CHECK (supply_price > 0), 
    product_id INTEGER NOT NULL,
    supplier_id INTEGER NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE CASCADE,
    CONSTRAINT uq_supplier_product UNIQUE (product_id, supplier_id) 
);

CREATE TABLE Warehouse_Orders (
    order_id INTEGER PRIMARY KEY,  
    order_date DATE NOT NULL,
    total_quantity INTEGER NOT NULL CHECK (total_quantity > 0),
    warehouse_id INTEGER NOT NULL, 
    supplier_id INTEGER NOT NULL, 
    inventory_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_warehouse_id FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE,
    CONSTRAINT fk_supplier_id FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_id FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id) ON DELETE CASCADE,
    CONSTRAINT uq_warehouse_supplier_inventory UNIQUE (warehouse_id, supplier_id, inventory_id)
);

CREATE TABLE Inventory_Threshold_Log (
    log_id INTEGER PRIMARY KEY,
    inventory_id INTEGER,
    product_id INTEGER,
    stock_level INTEGER,
    threshold INTEGER,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


-- Creating indexes
-- Indexes on foreign key columns
CREATE INDEX idx_inventory_warehouse_id ON Inventory (warehouse_id);
CREATE INDEX idx_products_category_id ON Products (category_id);
CREATE INDEX idx_addresses_customer_id ON Addresses (customer_id);
CREATE INDEX idx_customer_orders_customer_id ON Customer_Orders (customer_id);
CREATE INDEX idx_customer_orders_address_id ON Customer_Orders (shipping_address_id);
CREATE INDEX idx_payments_order_id ON Payments (order_id);
CREATE INDEX idx_order_items_product_id ON Order_Items (product_id);
CREATE INDEX idx_order_items_order_id ON Order_Items (order_id);
CREATE INDEX idx_discounts_product_id ON Discounts (product_id);
CREATE INDEX idx_suppliers_products_product_id ON Suppliers_Products (product_id);
CREATE INDEX idx_suppliers_products_supplier_id ON Suppliers_Products (supplier_id);
CREATE INDEX idx_warehouse_orders_warehouse_id ON Warehouse_Orders (warehouse_id);
CREATE INDEX idx_warehouse_orders_supplier_id ON Warehouse_Orders (supplier_id);
CREATE INDEX idx_warehouse_orders_inventory_id ON Warehouse_Orders (inventory_id);

-- Indexes for commonly queried fields
CREATE INDEX idx_customers_email ON Customers (email);
CREATE INDEX idx_orders_order_date ON Customer_Orders (order_date);
CREATE INDEX idx_payments_payment_method ON Payments (payment_method);
CREATE INDEX idx_returns_status ON Returns (status);
CREATE INDEX idx_suppliers_supplier_name ON Suppliers (supplier_name);
CREATE INDEX idx_warehouse_orders_order_date ON Warehouse_Orders (order_date);

COMMIT;



SET DEFINE OFF;

-- Truncate all data from tables
TRUNCATE TABLE Warehouse_Orders REUSE STORAGE;
TRUNCATE TABLE Suppliers_Products REUSE STORAGE;
TRUNCATE TABLE Suppliers REUSE STORAGE;
TRUNCATE TABLE Discounts REUSE STORAGE;
TRUNCATE TABLE Returns REUSE STORAGE;
TRUNCATE TABLE Payments REUSE STORAGE;
TRUNCATE TABLE Order_Items REUSE STORAGE;
TRUNCATE TABLE Customer_Orders REUSE STORAGE;
TRUNCATE TABLE Addresses REUSE STORAGE;
TRUNCATE TABLE Customers REUSE STORAGE;
TRUNCATE TABLE Products REUSE STORAGE;
TRUNCATE TABLE Inventory REUSE STORAGE;
TRUNCATE TABLE Warehouses REUSE STORAGE;
TRUNCATE TABLE Categories REUSE STORAGE;

SET SERVEROUTPUT ON
-- Drop sequences
/
DECLARE
    CURSOR CUR_SEQ IS SELECT SEQUENCE_NAME FROM USER_SEQUENCES;
BEGIN
    FOR SEQ IN CUR_SEQ LOOP
        EXECUTE IMMEDIATE ('DROP SEQUENCE ' || SEQ.SEQUENCE_NAME);
    END LOOP;
END;
/

-- Recreating sequences
CREATE SEQUENCE SEQ_CUSTOMER_ID START WITH 10001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ADDRESS_ID START WITH 20001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CUSTOMER_ORDER_ID START WITH 30001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PAYMENT_ID START WITH 40001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ORDER_ITEM_ID START WITH 50001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_RETURN_ID START WITH 60001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PRODUCT_ID START WITH 70001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CATEGORY_ID START WITH 80001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_DISCOUNT_ID START WITH 90001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_SUPPLIER_ID START WITH 100001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_INVENTORY_ID START WITH 110001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WAREHOUSE_ID START WITH 120001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_SUPPLIERS_PRODUCTS_ID START WITH 130001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WAREHOUSE_ORDERS_ID START WITH 140001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_INVENTORY_THRESHOLD_LOG_ID START WITH 150001 INCREMENT BY 1;



SET DEFINE OFF;
INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Electronics', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Books', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Clothing', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Home & Kitchen', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Beauty & Personal Care', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Toys & Games', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Automotive', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Sports & Outdoors', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Health & Household', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');

INSERT INTO Categories (category_id, category_name, created_at, updated_at, is_deleted)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 'Grocery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'N');



SET DEFINE OFF;
INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-NY-01', 'New York', 'New York', 'USA', 'Alice Johnson', '+1-212-555-1234');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-CA-02', 'Los Angeles', 'California', 'USA', 'Bob Smith', '+1 310 555 5678');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-IL-03', 'Chicago', 'Illinois', 'USA', 'Carlos Martinez', '312-555-8765');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-TX-04', 'Houston', 'Texas', 'USA', 'Diane Lee', '+1 713 555 1122');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-FL-05', 'Miami', 'Florida', 'USA', 'Ethan Brown', '+1-305-555-3344');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-ON-06', 'Toronto', 'Ontario', 'Canada', 'Fiona Clark', '+1 416 555 9988');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-BC-07', 'Vancouver', 'British Columbia', 'Canada', 'George Adams', '+1-604-555-2233');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-LDN-08', 'London', 'England', 'UK', 'Hannah Wilson', '+44 20 7946 0958');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-MUM-09', 'Mumbai', 'Maharashtra', 'India', 'Imran Khan', '+91 22 5555 7890');

INSERT INTO Warehouses (warehouse_id, warehouse_code, city, state, country, manager_name, contact_number)
VALUES (SEQ_WAREHOUSE_ID.NEXTVAL, 'WH-SYD-10', 'Sydney', 'New South Wales', 'Australia', 'Jessica Taylor', '+61-2-5550-1234');


SET DEFINE OFF;
INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 150, DATE '2025-03-01', 50, 120001);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 200, DATE '2025-03-10', 60, 120002);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 75, DATE '2025-02-20', 30, 120003);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 500, DATE '2025-03-15', 100, 120004);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 0, NULL, 20, 120005);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 90, DATE '2025-01-15', 40, 120006);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 300, DATE '2025-02-28', 120, 120007);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 25, DATE '2025-03-12', 25, 120008);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 110, DATE '2025-02-05', 50, 120009);

INSERT INTO Inventory (inventory_id, stock_level, last_restock_date, reorder_threshold, warehouse_id)
VALUES (SEQ_INVENTORY_ID.NEXTVAL, 45, NULL, 35, 120010);


SET DEFINE OFF;
INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Wireless Mouse', 25.99, 80001, 110001);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Mechanical Keyboard', 79.50, 80001, 110002);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Noise Cancelling Headphones', 199.99, 80001, 110003);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'LED Desk Lamp', 45.00, 80004, 110004);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Smartphone Stand', 15.75, 80004, 110005);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Fiction Novel', 12.99, 80002, 110006);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Running Shoes', 89.95, 80003, 110007);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Stainless Steel Water Bottle', 22.49, 80008, 110008);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Kids Puzzle Set', 18.00, 80006, 110009);

INSERT INTO Products (product_id, product_name, price, category_id, inventory_id)
VALUES (SEQ_PRODUCT_ID.NEXTVAL, 'Organic Shampoo', 14.25, 80005, 110010);



SET DEFINE OFF;
INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Nina', 'Walker', 'ninawalker@samplemail.com', '9810011223', DATE '1990-05-12', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Liam', 'Anderson', 'liamanderson@samplemail.com', '9823344556', DATE '1985-08-25', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Sophie', 'Reed', 'sophiereed@domain.co', '9834455667', DATE '1993-11-10', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Ethan', 'Brown', 'ethanbrown@sample.org', '9845566778', DATE '1979-02-14', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Zara', 'Perry', 'zaraperry@mailhost.com', '9856677889', DATE '2000-01-01', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Owen', 'Foster', 'owenfoster@mailplace.com', '9867788990', DATE '1988-12-20', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Isla', 'Morgan', 'islamorgan@sample.org', '9878899001', DATE '1995-03-30', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Noah', 'Carter', 'noahcarter@domain.net', '9889900112', DATE '1982-07-07', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Mila', 'Chen', 'milachen@example.com', '9891011223', DATE '1999-09-09', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Riley', 'Singh', 'rileysingh@example.com', '9902122334', DATE '1991-04-18', 'O');



SET DEFINE OFF;

-- Customer 10001 - 2 addresses
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '123 Main St', 'New York', 'NY', '10001', 'Home', 10001, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '500 Broadway', 'New York', 'NY', '10012', 'Work', 10001, 'N', 'N');

-- Customer 10002 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '456 Maple Ave', 'Los Angeles', 'CA', '90001', 'Work', 10002, 'Y', 'N');

-- Customer 10003 - 2 addresses
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '789 Oak Blvd', 'Chicago', 'IL', '60601', 'Home', 10003, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '950 Lake Shore Dr', 'Chicago', 'IL', '60611', 'Other', 10003, 'N', 'N');

-- Customer 10004 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '321 Pine Rd', 'Houston', 'TX', '77001', 'Work', 10004, 'Y', 'N');

-- Customer 10005 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '654 Cedar Ln', 'Miami', 'FL', '33101', 'Home', 10005, 'Y', 'N');

-- Customer 10006 - 2 addresses
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '987 Birch St', 'Seattle', 'WA', '98101', 'Other', 10006, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '123 Rainier Ave', 'Seattle', 'WA', '98104', 'Home', 10006, 'N', 'N');

-- Customer 10007 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '111 Elm Dr', 'Denver', 'CO', '80201', 'Home', 10007, 'Y', 'N');

-- Customer 10008 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '222 Spruce Ave', 'Boston', 'MA', '02101', 'Work', 10008, 'Y', 'N');

-- Customer 10009 - 2 addresses
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '333 Aspen Ct', 'Phoenix', 'AZ', '85001', 'Home', 10009, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '120 Desert Dr', 'Phoenix', 'AZ', '85002', 'Work', 10009, 'N', 'N');

-- Customer 10010 - 1 address
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '444 Walnut St', 'Atlanta', 'GA', '30301', 'Work', 10010, 'Y', 'N');



SET DEFINE OFF;
INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 61.03, 'Pending', 10001, 20001);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 63.6, 'Shipped', 10002, 20002);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 749.87, 'Delivered', 10003, 20003);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 38.25, 'Cancelled', 10004, 20004);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 72.83, 'Pending', 10005, 20005);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 25.98, 'Shipped', 10006, 20006);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 89.95, 'Delivered', 10007, 20007);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 44.98, 'Pending', 10008, 20008);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 90.0, 'Delivered', 10009, 20009);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 42.75, 'Shipped', 10010, 20010);


SET DEFINE OFF;
INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SAVE10', 10.00, DATE '2025-03-01', DATE '2025-07-31', 70001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SPRING20', 20.00, DATE '2025-04-01', DATE '2025-05-30', 70002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'FREESHIP', 5.00, DATE '2025-02-01', DATE '2025-08-15', 70003, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SUMMER15', 15.00, DATE '2025-04-01', DATE '2025-08-30', 70004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'WELCOME5', 5.00, DATE '2024-01-01', DATE '2030-12-31', 70005, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'WINTER25', 25.00, DATE '2025-12-01', DATE '2025-12-31', 70006, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'HOLIDAY50', 50.00, DATE '2025-03-25', DATE '2025-11-30', 70007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'BLACKFRI', 40.00, DATE '2025-11-28', DATE '2025-11-29', 70008, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'CYBERMON', 30.00, DATE '2025-04-02', DATE '2025-12-02', 70009, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'CLEARANCE', 60.00, DATE '2025-01-01', DATE '2025-07-15', 70010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);



SET DEFINE OFF;

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id, discount_id, discounted_unit_price)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 2, 25.99, 70001, 30001, 90001, 23.39);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id, discount_id, discounted_unit_price)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 79.5, 70002, 30002, 90002, 63.60);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id, discount_id, discounted_unit_price)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 3, 199.99, 70003, 30003, 90003, 189.99);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id, discount_id, discounted_unit_price)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 45.0, 70004, 30004, 90004, 38.25);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id, discount_id, discounted_unit_price)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 4, 15.75, 70005, 30005, 90005, 14.96);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 2, 12.99, 70006, 30006);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 89.95, 70007, 30007);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 2, 22.49, 70008, 30008);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 5, 18.00, 70009, 30009);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 3, 14.25, 70010, 30010);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 14.25, 70010, 30001);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 2, 89.95, 70007, 30003);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 12.99, 70006, 30005);



SET DEFINE OFF;

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Completed', DATE '2025-03-01', 66.23, 30001);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'PayPal', 'Completed', DATE '2025-03-02', 79.50, 30002);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Debit Card', 'Completed', DATE '2025-03-02', 779.87, 30003);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Refunded', DATE '2025-03-03', 45.00, 30004);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Cash', 'Completed', DATE '2025-03-03', 75.99, 30005);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Bank Transfer', 'Pending', DATE '2025-03-04', 25.98, 30006);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'PayPal', 'Completed', DATE '2025-03-04', 89.95, 30007);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Other', 'Failed', DATE '2025-03-05', 44.98, 30008);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Debit Card', 'Completed', DATE '2025-03-05', 90.00, 30009);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Completed', DATE '2025-03-06', 42.75, 30010);



SET DEFINE OFF;

-- Order Item 50001: 1 unit, unit price 25.99 → return for 1 defective unit
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 25.99, 'Pending', 'Product defective upon arrival', 1, 50001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Order Item 50002: 1 unit, unit price 39.50 → return for wrong item
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 39.50, 'Approved', 'Wrong item shipped', 1, 50002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Order Item 50004: 1 unit, unit price 45.00 → return for damage
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 45.00, 'Completed', 'Damaged in transit', 1, 50004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Order Item 50007: 1 unit, unit price 89.95 → partial return due to missing parts
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 89.95, 'Pending', 'Missing parts', 1, 50007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Order Item 50010: 1 unit, unit price 42.75 → return due to changed mind
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 42.75, 'Completed', 'Changed mind', 1, 50010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


SET DEFINE OFF;
INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Global Supplies Ltd.', '5551234567', 'info@globalsupplies.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'TechSource Inc.', '5552345678', 'sales@techsource.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Mega Distributors', '5553456789', 'contact@megadist.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Quality Parts Co.', '5554567890', 'support@qualityparts.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Express Wholesale', '5555678901', 'orders@expresswholesale.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Prime Supplies', '5556789012', 'prime@supplies.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'NextGen Suppliers', '5557890123', 'info@nextgensuppliers.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Innovative Goods Ltd.', '5558901234', 'hello@innovativegoods.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'FastTrack Supply', '5559012345', 'sales@fasttracksupply.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers (supplier_id, supplier_name, contact_number, email, created_at, updated_at)
VALUES (SEQ_SUPPLIER_ID.NEXTVAL, 'Dependable Sources Inc.', '5550123456', 'contact@dependablesources.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


SET DEFINE OFF;
INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 12.50, 70001, 100001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 25.00, 70002, 100002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 9.75, 70003, 100003, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 45.99, 70004, 100004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 15.20, 70005, 100005, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 30.50, 70006, 100006, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 22.80, 70007, 100007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 18.75, 70008, 100008, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 29.99, 70009, 100009, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Suppliers_Products (supplier_product_id, supply_price, product_id, supplier_id, created_at, updated_at)
VALUES (SEQ_SUPPLIERS_PRODUCTS_ID.NEXTVAL, 40.00, 70010, 100010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);



SET DEFINE OFF;
INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-01', 100, 120001, 100001, 110001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-05', 250, 120002, 100002, 110002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-10', 75, 120003, 100003, 110003, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-15', 300, 120004, 100004, 110004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-20', 150, 120005, 100005, 110005, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-25', 50, 120006, 100006, 110006, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-03-30', 400, 120007, 100007, 110007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-04-01', 120, 120008, 100008, 110008, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-04-05', 220, 120009, 100009, 110009, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Warehouse_Orders (order_id, order_date, total_quantity, warehouse_id, supplier_id, inventory_id, created_at, updated_at)
VALUES (SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL, DATE '2024-04-10', 180, 120010, 100010, 110010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);


COMMIT;


-- ======================
-- Section 2: Reporting Views
-- ======================

-- 1. Current Inventory Status
CREATE OR REPLACE VIEW Current_Inventory_Status AS
SELECT 
    i.inventory_id,
    i.warehouse_id,
    w.city AS warehouse_city,
    w.state AS warehouse_state,
    i.stock_level,
    i.last_restock_date
FROM Inventory i
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id;

-- 2. Weekly Sales Report
CREATE OR REPLACE VIEW Week_Wise_Sales AS
SELECT 
    TO_CHAR(order_date, 'WW') AS sales_week,
    TO_CHAR(order_date, 'YYYY') AS sales_year,
    SUM(total_amount) AS weekly_sales
FROM Customer_Orders
GROUP BY TO_CHAR(order_date, 'YYYY'), TO_CHAR(order_date, 'WW')
ORDER BY sales_year, sales_week;


-- 3. Total Sales Region Wise
CREATE OR REPLACE VIEW Total_Sales_Region_Wise AS
SELECT 
    a.state AS region,
    SUM(co.total_amount) AS total_sales
FROM Customer_Orders co
JOIN Customers c ON co.customer_id = c.customer_id
JOIN Addresses a ON c.customer_id = a.customer_id
GROUP BY a.state;


-- 4. Top Selling Products
CREATE OR REPLACE VIEW Top_Selling_Products AS
SELECT 
    oi.product_id,
    p.product_name,
    SUM(oi.product_quantity) AS total_units_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_units_sold DESC;

-- 5. Customer Return Trends
CREATE OR REPLACE VIEW Customer_Return_Trends AS
SELECT 
    oi.product_id,
    p.product_name,
    COUNT(r.return_id) AS total_returns,
    ROUND(AVG(r.return_amount), 2) AS avg_refund
FROM Returns r
JOIN Order_Items oi ON r.order_item_id = oi.order_item_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_returns DESC;

-- 6. Discount Effectiveness Summary
CREATE OR REPLACE VIEW discount_effectiveness_summary AS
SELECT
    d.discount_id,
    d.promo_code,
    d.discount_percentage,
    d.start_date,
    d.end_date,
    p.product_id,
    p.product_name,

    COUNT(DISTINCT oi.order_id) AS total_orders_with_discount,
    SUM(oi.product_quantity) AS total_units_sold_with_discount,
    ROUND(SUM(oi.discounted_unit_price * oi.product_quantity), 2) AS total_revenue_with_discount,
    ROUND(AVG(oi.discounted_unit_price), 2) AS average_discounted_price

FROM Discounts d
JOIN Products p ON d.product_id = p.product_id
JOIN Order_Items oi ON oi.discount_id = d.discount_id
WHERE oi.discounted_unit_price IS NOT NULL

GROUP BY
    d.discount_id,
    d.promo_code,
    d.discount_percentage,
    d.start_date,
    d.end_date,
    p.product_id,
    p.product_name;

-- 7. Supplier Lead Times
CREATE OR REPLACE VIEW Supplier_Lead_Times AS
SELECT 
    s.supplier_id,
    s.supplier_name,
    ROUND(AVG((CAST(wo.updated_at AS DATE) - CAST(wo.created_at AS DATE))), 2) AS avg_lead_time_days
FROM Warehouse_Orders wo
JOIN Suppliers s ON s.supplier_id = wo.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

-- 8. Customer Purchase Frequency
CREATE OR REPLACE VIEW Customer_Purchase_Frequency AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(co.order_id) AS total_orders,
    MIN(co.order_date) AS first_order,
    MAX(co.order_date) AS last_order
FROM Customers c
JOIN Customer_Orders co ON co.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;

-- 9. Customer Behavior View 
CREATE OR REPLACE VIEW Customer_Behavior_Insights AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(co.order_id) AS total_orders,
    ROUND(SUM(co.total_amount), 2) AS total_spent,
    ROUND(AVG(co.total_amount), 2) AS avg_order_value,
    MIN(co.order_date) AS first_order_date,
    MAX(co.order_date) AS last_order_date,
    ROUND(SYSDATE - MAX(co.order_date)) AS days_since_last_order,
    
    NVL(ret.total_returns, 0) AS total_returns,
    ROUND(NVL(ret.total_returns / NULLIF(COUNT(co.order_id), 0), 0), 2) AS return_ratio,

    CASE
        WHEN ROUND(SYSDATE - MAX(co.order_date)) > 90 OR NVL(ret.total_returns, 0) > 3 THEN 'High'
        WHEN ROUND(SYSDATE - MAX(co.order_date)) > 60 THEN 'Medium'
        ELSE 'Low'
    END AS churn_risk

FROM Customers c
JOIN Customer_Orders co ON c.customer_id = co.customer_id
LEFT JOIN (
    SELECT
        co.customer_id,
        COUNT(r.return_id) AS total_returns
    FROM
        Returns r
        JOIN Order_Items oi ON r.order_item_id = oi.order_item_id
        JOIN Customer_Orders co ON oi.order_id = co.order_id
    GROUP BY co.customer_id
) ret ON ret.customer_id = c.customer_id

GROUP BY c.customer_id, c.first_name, c.last_name, ret.total_returns
ORDER BY total_orders DESC;


-- 10. Sales Payment Summary
CREATE OR REPLACE VIEW sales_payment_summary AS
SELECT
    co.order_id,
    co.order_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email AS customer_email,
    p.product_id,
    p.product_name,
    oi.product_quantity,
    oi.unit_price,
    (oi.product_quantity * oi.unit_price) AS total_order_amount,
    pay.amount_paid,
    pay.payment_status,
    pay.payment_method,
    pay.payment_date
FROM
    Customer_Orders co
    JOIN Customers c ON co.customer_id = c.customer_id
    JOIN Order_Items oi ON oi.order_id = co.order_id
    JOIN Products p ON oi.product_id = p.product_id
    LEFT JOIN Payments pay ON pay.order_id = co.order_id;

COMMIT;

-- ======================
-- End of Views Section
-- ======================


-- Trigger: Logs low-stock inventory events into Inventory_Threshold_Log
CREATE OR REPLACE TRIGGER trg_inventory_threshold_check
FOR UPDATE ON Inventory
COMPOUND TRIGGER
    TYPE inventory_id_list IS TABLE OF Inventory.inventory_id%TYPE INDEX BY PLS_INTEGER;
    v_inventory_ids inventory_id_list;
    v_index PLS_INTEGER := 0;
    
    BEFORE STATEMENT IS
    BEGIN
        v_inventory_ids := inventory_id_list();
        v_index := 0;
    END BEFORE STATEMENT;
    
    AFTER EACH ROW IS
    BEGIN
        IF :NEW.stock_level < :NEW.reorder_threshold THEN
            v_index := v_index + 1;
            v_inventory_ids(v_index) := :NEW.inventory_id;
        END IF;
    END AFTER EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_index LOOP
            INSERT INTO Inventory_Threshold_Log (log_id, inventory_id, product_id, stock_level, threshold)
            SELECT SEQ_INVENTORY_THRESHOLD_LOG_ID.NEXTVAL, i.inventory_id, p.product_id, i.stock_level, i.reorder_threshold
            FROM Inventory i
            JOIN Products p ON p.inventory_id = i.inventory_id
            WHERE i.inventory_id = v_inventory_ids(i);
        END LOOP;
    END AFTER STATEMENT;
END trg_inventory_threshold_check;
/


-- Trigger: Prevent updates to Discounts table to enforce immutability
CREATE OR REPLACE TRIGGER trg_prevent_discount_update
BEFORE UPDATE ON Discounts
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Discounts are immutable and cannot be updated.');
END;
/

-- Trigger: Prevent deletion of Discounts to preserve history and reporting accuracy
CREATE OR REPLACE TRIGGER trg_prevent_discount_delete
BEFORE DELETE ON Discounts
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'Discounts are immutable and cannot be deleted.');
END;
/

-- Trigger to prevent negative stock
CREATE OR REPLACE TRIGGER trg_prevent_negative_stock
BEFORE INSERT OR UPDATE ON Inventory
FOR EACH ROW
BEGIN
  IF :NEW.stock_level < 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Stock level cannot be negative.');
  END IF;
END;
/

-- This trigger ensures that when a new address is marked as default, all other addresses for the same customer are updated to non-default.
CREATE OR REPLACE TRIGGER trg_single_default_address
BEFORE INSERT OR UPDATE ON Addresses
FOR EACH ROW
BEGIN
    IF :NEW.is_default = 'Y' THEN
        UPDATE Addresses
        SET is_default = 'N'
        WHERE customer_id = :NEW.customer_id
          AND address_id != :NEW.address_id
          AND is_default = 'Y';
    END IF;
END;
/

-- Trigger: Reduce inventory stock level after a new order item is inserted
CREATE OR REPLACE TRIGGER trg_reduce_inventory
AFTER INSERT ON Order_Items
FOR EACH ROW
DECLARE
    v_inventory_id Inventory.inventory_id%TYPE;
BEGIN
    SELECT inventory_id INTO v_inventory_id
    FROM Products WHERE product_id = :NEW.product_id;

    UPDATE Inventory
    SET stock_level = stock_level - :NEW.product_quantity
    WHERE inventory_id = v_inventory_id;
END;
/

-- Trigger: Restock inventory when a return is approved
CREATE OR REPLACE TRIGGER trg_restock_inventory_on_approved_return
AFTER UPDATE OF status ON Returns
FOR EACH ROW
WHEN (NEW.status = 'Approved' AND OLD.status != 'Approved')
DECLARE
    v_inventory_id Inventory.inventory_id%TYPE;
BEGIN
    -- Get inventory_id linked to returned product
    SELECT p.inventory_id
    INTO v_inventory_id
    FROM Order_Items oi
    JOIN Products p ON oi.product_id = p.product_id
    WHERE oi.order_item_id = :NEW.order_item_id;

    -- Restock quantity
    UPDATE Inventory
    SET stock_level = stock_level + :NEW.returned_quantity
    WHERE inventory_id = v_inventory_id;
END;
/

-- Trigger: Validate order status transitions before updating order status
CREATE OR REPLACE TRIGGER trg_order_status_transition
BEFORE UPDATE OF order_status ON Customer_Orders
FOR EACH ROW
BEGIN
    IF NOT Is_Valid_Status_Transition(:OLD.order_status, :NEW.order_status) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid order status transition.');
    END IF;
END;
/    
   
COMMIT;


-- Procedure for onboarding customer
CREATE OR REPLACE PROCEDURE Onboard_Customer (
    p_first_name     IN Customers.first_name%TYPE,
    p_last_name      IN Customers.last_name%TYPE,
    p_email          IN Customers.email%TYPE,
    p_phone          IN Customers.phone%TYPE,
    p_dob            IN Customers.dob%TYPE,
    p_gender         IN Customers.gender%TYPE,
    p_address_line   IN Addresses.address_line%TYPE,
    p_city           IN Addresses.city%TYPE,
    p_state          IN Addresses.state%TYPE,
    p_zip            IN Addresses.zip_code%TYPE,
    p_customer_id    OUT Customers.customer_id%TYPE
)
AS
    -- Custom exceptions
    ex_invalid_input EXCEPTION;
    ex_email_exists  EXCEPTION;
    ex_invalid_email_format EXCEPTION;
    ex_invalid_dob EXCEPTION;
    ex_invalid_gender EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_invalid_input, -20001);
    PRAGMA EXCEPTION_INIT(ex_email_exists, -20002);
    PRAGMA EXCEPTION_INIT(ex_invalid_email_format,-20003);
    PRAGMA EXCEPTION_INIT(ex_invalid_dob, -20004);
    PRAGMA EXCEPTION_INIT(ex_invalid_gender, -20005);

    v_customer_id Customers.customer_id%TYPE;
BEGIN
    -- Input validations
    IF p_first_name IS NULL OR p_last_name IS NULL OR p_email IS NULL OR p_dob IS NULL OR p_gender IS NULL THEN
        RAISE ex_invalid_input;
    END IF;
    
    -- Validate that DOB is not in the future
    IF p_dob > SYSDATE THEN
        RAISE ex_invalid_dob;
    END IF;
    
    IF UPPER(p_gender) NOT IN ('M', 'F', 'O') THEN
        RAISE ex_invalid_gender;
    END IF;

    -- Validate email format
    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$') THEN
        RAISE ex_invalid_email_format;
    END IF;

    -- Check for existing email
    BEGIN
        SELECT customer_id INTO v_customer_id
        FROM Customers
        WHERE email = p_email;

        -- If found, raise exception
        RAISE ex_email_exists;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Email is unique, proceed
    END;

    -- Insert into Customers table
    INSERT INTO Customers (
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        dob,
        gender,
        created_at,
        updated_at
    ) VALUES (
        SEQ_CUSTOMER_ID.NEXTVAL,
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_dob,
        p_gender,
        SYSDATE,
        SYSDATE
    )
    RETURNING customer_id INTO v_customer_id;

    -- Insert into Addresses table with is_default = 'Y'
    INSERT INTO Addresses (
        address_id,
        customer_id,
        address_line,
        city,
        state,
        zip_code,
        is_default,
        created_at,
        updated_at
    ) VALUES (
        SEQ_ADDRESS_ID.NEXTVAL,
        v_customer_id,
        p_address_line,
        p_city,
        p_state,
        p_zip,
        'Y',
        SYSDATE,
        SYSDATE
    );

    -- Return the new customer ID
    p_customer_id := v_customer_id;

EXCEPTION
    WHEN ex_invalid_input THEN
        RAISE_APPLICATION_ERROR(-20001, 'First name, last name, and email are required.');
    WHEN ex_invalid_email_format THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid email format.');
    WHEN ex_invalid_gender THEN
        RAISE_APPLICATION_ERROR(-20005, 'Invalid gender. Accepted values are M, F, or O.');
    WHEN ex_invalid_dob THEN
        RAISE_APPLICATION_ERROR(-20004, 'Date of birth cannot be in the future.');
    WHEN ex_email_exists THEN
        RAISE_APPLICATION_ERROR(-20002, 'Email already exists.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'An unexpected error occurred: ' || SQLERRM);
END Onboard_Customer;
/



-- Procedure: Place Restock Order
CREATE OR REPLACE PROCEDURE place_restock_order (
    p_product_id      IN Products.product_id%TYPE,
    p_supplier_email  IN Suppliers.email%TYPE,
    p_warehouse_code  IN Warehouses.warehouse_code%TYPE
)
AS
    -- Custom exceptions
    ex_invalid_input          EXCEPTION;
    ex_product_not_found      EXCEPTION;
    ex_inventory_not_found    EXCEPTION;
    ex_supplier_not_found     EXCEPTION;
    ex_warehouse_not_found    EXCEPTION;
    ex_no_restock_needed      EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_invalid_input, -20001);
    PRAGMA EXCEPTION_INIT(ex_product_not_found, -20002);
    PRAGMA EXCEPTION_INIT(ex_inventory_not_found, -20003);
    PRAGMA EXCEPTION_INIT(ex_supplier_not_found, -20004);
    PRAGMA EXCEPTION_INIT(ex_warehouse_not_found, -20005);
    PRAGMA EXCEPTION_INIT(ex_no_restock_needed, -20006);

    -- Variables to hold retrieved data
    v_inventory_id    Inventory.inventory_id%TYPE;
    v_stock_level     Inventory.stock_level%TYPE;
    v_threshold       Inventory.reorder_threshold%TYPE;
    v_needed_qty      NUMBER;
    v_supplier_id     Suppliers.supplier_id%TYPE;
    v_warehouse_id    Warehouses.warehouse_id%TYPE;
BEGIN
    -- Input validations
    IF p_product_id IS NULL OR p_supplier_email IS NULL OR p_warehouse_code IS NULL THEN
        RAISE ex_invalid_input;
    END IF;

    -- Retrieve inventory_id from Products
    BEGIN
        SELECT inventory_id
        INTO v_inventory_id
        FROM Products
        WHERE product_id = p_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_product_not_found;
    END;

    -- Retrieve stock_level and reorder_threshold from Inventory
    BEGIN
        SELECT stock_level, reorder_threshold
        INTO v_stock_level, v_threshold
        FROM Inventory
        WHERE inventory_id = v_inventory_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_inventory_not_found;
    END;

    -- Retrieve supplier_id from Suppliers
    BEGIN
        SELECT supplier_id
        INTO v_supplier_id
        FROM Suppliers
        WHERE email = p_supplier_email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_supplier_not_found;
    END;

    -- Retrieve warehouse_id from Warehouses
    BEGIN
        SELECT warehouse_id
        INTO v_warehouse_id
        FROM Warehouses
        WHERE warehouse_code = p_warehouse_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_warehouse_not_found;
    END;

    -- Check if restock is needed
    IF v_stock_level >= v_threshold THEN
        RAISE ex_no_restock_needed;
    END IF;

    -- Calculate needed quantity
    v_needed_qty := v_threshold - v_stock_level;

    -- Insert restock order
    INSERT INTO Warehouse_Orders (
        order_id,
        inventory_id,
        supplier_id,
        warehouse_id,
        total_quantity,
        order_date,
        created_at,
        updated_at
    )
    VALUES (
        SEQ_WAREHOUSE_ORDERS_ID.NEXTVAL,
        v_inventory_id,
        v_supplier_id,
        v_warehouse_id,
        v_needed_qty,
        SYSDATE,
        SYSTIMESTAMP,
        SYSTIMESTAMP
    );

EXCEPTION
    WHEN ex_invalid_input THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid input: All parameters are required.');
    WHEN ex_product_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Product not found for the given product ID.');
    WHEN ex_inventory_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Inventory not found for the given product.');
    WHEN ex_supplier_not_found THEN
        RAISE_APPLICATION_ERROR(-20004, 'Supplier not found for the given email.');
    WHEN ex_warehouse_not_found THEN
        RAISE_APPLICATION_ERROR(-20005, 'Warehouse not found for the given code.');
    WHEN ex_no_restock_needed THEN
        RAISE_APPLICATION_ERROR(-20006, 'Restock not needed: Stock level meets or exceeds threshold.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'An unexpected error occurred: ' || SQLERRM);
END place_restock_order;
/




-- Procedure: Receive Shipment
CREATE OR REPLACE PROCEDURE receive_shipment (
    p_product_id IN Products.product_id%TYPE,
    p_quantity   IN NUMBER
)
AS
    -- Custom exceptions
    ex_invalid_input       EXCEPTION;
    ex_product_not_found   EXCEPTION;
    ex_inventory_not_found EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_invalid_input, -20001);
    PRAGMA EXCEPTION_INIT(ex_product_not_found, -20002);
    PRAGMA EXCEPTION_INIT(ex_inventory_not_found, -20003);

    -- Variables to hold retrieved data
    v_inventory_id Inventory.inventory_id%TYPE;
BEGIN
    -- Input validations
    IF p_product_id IS NULL OR p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE ex_invalid_input;
    END IF;

    -- Retrieve inventory_id from Products
    BEGIN
        SELECT inventory_id
        INTO v_inventory_id
        FROM Products
        WHERE product_id = p_product_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE ex_product_not_found;
    END;

    -- Update stock_level in Inventory
    BEGIN
        UPDATE Inventory
        SET stock_level = stock_level + p_quantity,
            last_restock_date = SYSDATE,
            updated_at = SYSTIMESTAMP
        WHERE inventory_id = v_inventory_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE ex_inventory_not_found;
        END IF;
    END;

EXCEPTION
    WHEN ex_invalid_input THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid input: Product ID and quantity must be provided, and quantity must be greater than zero.');
    WHEN ex_product_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Product not found for the given Product ID.');
    WHEN ex_inventory_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Inventory record not found for the given Product.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'An unexpected error occurred: ' || SQLERRM);
END receive_shipment;
/



CREATE OR REPLACE PROCEDURE Place_Customer_Order (
    p_customer_id         IN Customer_Orders.customer_id%TYPE,
    p_shipping_address_id IN Customer_Orders.shipping_address_id%TYPE,
    p_order_items         IN SYS.ODCIVARCHAR2LIST,  -- Format: 'product_id|quantity'
    p_order_date          IN DATE,
    p_payment_method      IN Payments.payment_method%TYPE
)
IS
    v_order_id      Customer_Orders.order_id%TYPE;
    v_total_amount  NUMBER := 0;
BEGIN
    -- Validate Customer and Address
    DECLARE
        v_check NUMBER;
    BEGIN
        SELECT 1 INTO v_check FROM Customers WHERE customer_id = p_customer_id;
        SELECT 1 INTO v_check FROM Addresses WHERE address_id = p_shipping_address_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Customer or Address does not exist.');
    END;

    -- Insert Order
    INSERT INTO Customer_Orders (
        order_id, customer_id, shipping_address_id, order_date, order_status, total_amount
    )
    VALUES (
        SEQ_CUSTOMER_ORDER_ID.NEXTVAL, p_customer_id, p_shipping_address_id,
        p_order_date, 'Pending', 0
    )
    RETURNING order_id INTO v_order_id;

    -- Process each item
    FOR i IN 1 .. p_order_items.COUNT LOOP
        DECLARE
            v_product_id   NUMBER;
            v_quantity     NUMBER;
            v_unit_price   NUMBER;
            v_discount     NUMBER := 0;
            v_discount_id  Discounts.discount_id%TYPE := NULL;
            v_inventory_id NUMBER;
            v_stock        NUMBER;
            v_discounted_price NUMBER;
        BEGIN
            -- Parse input
            v_product_id := TO_NUMBER(REGEXP_SUBSTR(p_order_items(i), '[^|]+', 1, 1));
            v_quantity   := TO_NUMBER(REGEXP_SUBSTR(p_order_items(i), '[^|]+', 1, 2));

            -- Validate product and get price, inventory
            BEGIN
                SELECT price, inventory_id INTO v_unit_price, v_inventory_id
                FROM Products WHERE product_id = v_product_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20011, 'Invalid product ID: ' || v_product_id);
            END;

            -- Lock inventory row and check stock
            SELECT stock_level INTO v_stock
            FROM Inventory
            WHERE inventory_id = v_inventory_id
            FOR UPDATE;

            IF v_quantity > v_stock THEN
                RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for product ' || v_product_id);
            END IF;

            -- Get active discount (if any)
            BEGIN
                SELECT discount_id, discount_percentage
                INTO v_discount_id, v_discount
                FROM Discounts
                WHERE product_id = v_product_id
                  AND p_order_date BETWEEN start_date AND end_date
                FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_discount := 0;
                    v_discount_id := NULL;
            END;

            v_discounted_price := ROUND(v_unit_price * (1 - v_discount / 100), 2);

            -- Insert into Order_Items
            INSERT INTO Order_Items (
                order_item_id, product_quantity, unit_price, product_id, order_id,
                discount_id, discounted_unit_price
            )
            VALUES (
                SEQ_ORDER_ITEM_ID.NEXTVAL, v_quantity, v_unit_price, v_product_id, v_order_id,
                v_discount_id, v_discounted_price
            );

            -- Accumulate total
            v_total_amount := v_total_amount + (v_quantity * v_discounted_price);
        END;
    END LOOP;

    -- Update total amount in Customer_Orders
    UPDATE Customer_Orders
    SET total_amount = v_total_amount
    WHERE order_id = v_order_id;

    -- Insert payment record
    INSERT INTO Payments (
        payment_id, payment_method, payment_status,
        payment_date, amount_paid, order_id
    ) VALUES (
        SEQ_PAYMENT_ID.NEXTVAL, p_payment_method, 'Completed',
        SYSDATE, v_total_amount, v_order_id
    );
END;
/



CREATE OR REPLACE PROCEDURE Handle_Return (
    p_order_item_id IN Returns.order_item_id%TYPE,
    p_quantity      IN Returns.returned_quantity%TYPE,
    p_reason        IN Returns.reason%TYPE
)
IS
    v_price         NUMBER;
    v_product_id    NUMBER;
    v_order_qty     NUMBER;
    v_returned_qty  NUMBER;
BEGIN
    -- Try to get discounted price, fallback to unit_price
    BEGIN
        SELECT NVL(discounted_unit_price, unit_price), product_id, product_quantity 
        INTO v_price, v_product_id, v_order_qty
        FROM Order_Items 
        WHERE order_item_id = p_order_item_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20012, 'Invalid order_item_id.');
    END;

    -- Check return limits
    SELECT NVL(SUM(returned_quantity), 0)
    INTO v_returned_qty
    FROM Returns
    WHERE order_item_id = p_order_item_id;

    IF p_quantity + v_returned_qty > v_order_qty THEN
        RAISE_APPLICATION_ERROR(-20006, 'Over-return detected.');
    END IF;

    -- Insert return
    INSERT INTO Returns (
        return_id, return_amount, status, reason,
        returned_quantity, order_item_id, created_at, updated_at
    )
    VALUES (
        SEQ_RETURN_ID.NEXTVAL, ROUND(p_quantity * v_price, 2), 'Pending', p_reason,
        p_quantity, p_order_item_id, SYSDATE, SYSDATE
    );
END;
/


COMMIT;



SET SERVEROUTPUT ON
/
CREATE OR REPLACE PROCEDURE ROLE_CLEANUP_PROCEDURE AS
    CURSOR CUR_ROLES IS SELECT ROLE FROM DBA_ROLES WHERE ROLE LIKE 'ECOMM_%';
    CURSOR CUR_USERS IS SELECT USERNAME FROM DBA_USERS WHERE USERNAME LIKE 'ECOMM_%';
    CURSOR CUR_SESSIONS IS SELECT SID, SERIAL# FROM v$session WHERE USERNAME LIKE 'ECOMM_%';
BEGIN
    -- Kill active sessions
    FOR SESS IN CUR_SESSIONS LOOP
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || SESS.sid || ',' || SESS.serial# || ''' IMMEDIATE';
    END LOOP;

    -- Drop roles
    FOR ROL IN CUR_ROLES LOOP
        EXECUTE IMMEDIATE 'DROP ROLE ' || ROL.ROLE;
    END LOOP;

    -- Drop users
    FOR USR IN CUR_USERS LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || USR.USERNAME || ' CASCADE';
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Cleanup complete. Users and roles removed.');
END;
/
EXECUTE ROLE_CLEANUP_PROCEDURE;
/

-- Creating Roles
CREATE ROLE ECOMM_ADMIN;
CREATE ROLE ECOMM_INVENTORY_MANAGER;
CREATE ROLE ECOMM_SALES_MANAGER;
CREATE ROLE ECOMM_ANALYST;

-- Granting common permissions
GRANT CREATE SESSION, CONNECT TO ECOMM_ADMIN, ECOMM_INVENTORY_MANAGER, ECOMM_SALES_MANAGER, ECOMM_ANALYST;


-- ECOMM_ADMIN (Super Admin - Full Access)
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER TO ECOMM_ADMIN;

GRANT ALL PRIVILEGES ON customers TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON addresses TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON customer_orders TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON payments TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON order_items TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON returns TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON products TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON categories TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON discounts TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON suppliers TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON suppliers_products TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON inventory TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON warehouse_orders TO ECOMM_ADMIN;
GRANT ALL PRIVILEGES ON warehouses TO ECOMM_ADMIN;


-- ECOMM_INVENTORY_MANAGER (Manages Products & Stock)
GRANT INSERT, UPDATE, DELETE ON products TO ECOMM_INVENTORY_MANAGER;
GRANT INSERT, UPDATE, DELETE ON inventory TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT ON suppliers TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT ON suppliers_products TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT, INSERT, UPDATE ON warehouse_orders TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT ON warehouses TO ECOMM_INVENTORY_MANAGER;


-- ECOMM_SALES_MANAGER (Handles Orders & Customers)
GRANT INSERT, UPDATE, DELETE ON customer_orders TO ECOMM_SALES_MANAGER;
GRANT INSERT, UPDATE, DELETE ON order_items TO ECOMM_SALES_MANAGER;
GRANT INSERT, UPDATE, DELETE ON returns TO ECOMM_SALES_MANAGER;
GRANT INSERT, UPDATE, DELETE ON payments TO ECOMM_SALES_MANAGER;
GRANT SELECT ON customers TO ECOMM_SALES_MANAGER;
GRANT SELECT ON addresses TO ECOMM_SALES_MANAGER;


-- ECOMM_ANALYST (Access to Reports & Insights)
GRANT SELECT ON customer_orders TO ECOMM_ANALYST;
GRANT SELECT ON order_items TO ECOMM_ANALYST;
GRANT SELECT ON returns TO ECOMM_ANALYST;
GRANT SELECT ON payments TO ECOMM_ANALYST;
GRANT SELECT ON products TO ECOMM_ANALYST;
GRANT SELECT ON inventory TO ECOMM_ANALYST;
GRANT SELECT ON suppliers TO ECOMM_ANALYST;
GRANT SELECT ON categories TO ECOMM_ANALYST;
GRANT SELECT ON discounts TO ECOMM_ANALYST;
GRANT SELECT ON suppliers_products TO ECOMM_ANALYST;
GRANT SELECT ON warehouses TO ECOMM_ANALYST;
GRANT SELECT ON warehouse_orders TO ECOMM_ANALYST;
GRANT SELECT ON customers TO ECOMM_ANALYST;

-- Assign views to ECOMM roles
GRANT SELECT ON Week_Wise_Sales TO ECOMM_SALES_MANAGER;
GRANT SELECT ON Total_Sales_Region_Wise TO ECOMM_SALES_MANAGER;
GRANT SELECT ON Top_Selling_Products TO ECOMM_SALES_MANAGER;
GRANT SELECT ON Customer_Behavior_Insights TO ECOMM_SALES_MANAGER;

GRANT SELECT ON Current_Inventory_Status TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT ON Supplier_Lead_Times TO ECOMM_INVENTORY_MANAGER;
GRANT SELECT ON Customer_Return_Trends TO ECOMM_INVENTORY_MANAGER;

GRANT SELECT ON Current_Inventory_Status TO ECOMM_ANALYST;
GRANT SELECT ON Week_Wise_Sales TO ECOMM_ANALYST;
GRANT SELECT ON Total_Sales_Region_Wise TO ECOMM_ANALYST;
GRANT SELECT ON Top_Selling_Products TO ECOMM_ANALYST;
GRANT SELECT ON Customer_Return_Trends TO ECOMM_ANALYST;
GRANT SELECT ON discount_effectiveness_summary TO ECOMM_ANALYST;
GRANT SELECT ON Supplier_Lead_Times TO ECOMM_ANALYST;
GRANT SELECT ON Customer_Purchase_Frequency TO ECOMM_ANALYST;
GRANT SELECT ON Customer_Behavior_Insights TO ECOMM_ANALYST;
GRANT SELECT ON sales_payment_summary TO ECOMM_ANALYST;

GRANT SELECT ON Customer_Purchase_Frequency TO ECOMM_SALES_MANAGER;
GRANT SELECT ON sales_payment_summary TO ECOMM_SALES_MANAGER;
GRANT SELECT ON Customer_Return_Trends TO ECOMM_SALES_MANAGER;

-- Grant EXECUTE privileges on your stored procedures
GRANT EXECUTE ON Onboard_Customer TO ECOMM_ADMIN;
GRANT EXECUTE ON place_restock_order TO ECOMM_INVENTORY_MANAGER;
GRANT EXECUTE ON receive_shipment TO ECOMM_INVENTORY_MANAGER;

GRANT EXECUTE ON Place_Customer_Order TO ECOMM_SALES_MANAGER;
GRANT EXECUTE ON Handle_Return TO ECOMM_SALES_MANAGER;


-- Creating Users and Assigning Roles
CREATE USER ecomm_admin_user IDENTIFIED BY InvSalAdmin123;
GRANT ECOMM_ADMIN TO ecomm_admin_user;

CREATE USER ecomm_inventory_user IDENTIFIED BY InvManager123;
GRANT ECOMM_INVENTORY_MANAGER TO ecomm_inventory_user;

CREATE USER ecomm_sales_user IDENTIFIED BY SalManager123;
GRANT ECOMM_SALES_MANAGER TO ecomm_sales_user;

CREATE USER ecomm_analyst_user IDENTIFIED BY InvSalAna123;
GRANT ECOMM_ANALYST TO ecomm_analyst_user;


COMMIT;