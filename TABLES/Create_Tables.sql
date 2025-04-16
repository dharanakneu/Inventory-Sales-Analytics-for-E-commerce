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
        REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
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