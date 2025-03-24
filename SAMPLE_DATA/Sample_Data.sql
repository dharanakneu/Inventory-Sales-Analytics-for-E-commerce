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
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Alice', 'Johnson', 'alice.johnson@example.com', '9876543210', DATE '1990-05-12', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Bob', 'Smith', 'bob.smith@example.com', '9123456789', DATE '1985-08-25', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Carol', 'Martinez', 'carol.m@example.com', '9988776655', DATE '1993-11-10', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'David', 'Lee', 'david.lee@example.org', '8877665544', DATE '1979-02-14', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Eve', 'Clark', 'eve.clark@domain.com', '9001122334', DATE '2000-01-01', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Frank', 'Turner', 'frank.turner@mail.com', '9345678901', DATE '1988-12-20', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Grace', 'Taylor', 'grace.taylor@domain.org', '9112233445', DATE '1995-03-30', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Henry', 'White', 'henry.white@domain.net', '9887766554', DATE '1982-07-07', 'M');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Ivy', 'Nguyen', 'ivy.nguyen@example.com', '9776655443', DATE '1999-09-09', 'F');

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, dob, gender)
VALUES (SEQ_CUSTOMER_ID.NEXTVAL, 'Jordan', 'Kim', 'jordan.kim@example.com', '9665544332', DATE '1991-04-18', 'O');




SET DEFINE OFF;
INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '123 Main St', 'New York', 'NY', '10001', 'Home', 10001, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '456 Maple Ave', 'Los Angeles', 'CA', '90001', 'Work', 10002, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '789 Oak Blvd', 'Chicago', 'IL', '60601', 'Home', 10003, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '321 Pine Rd', 'Houston', 'TX', '77001', 'Work', 10004, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '654 Cedar Ln', 'Miami', 'FL', '33101', 'Home', 10005, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '987 Birch St', 'Seattle', 'WA', '98101', 'Other', 10006, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '111 Elm Dr', 'Denver', 'CO', '80201', 'Home', 10007, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '222 Spruce Ave', 'Boston', 'MA', '02101', 'Work', 10008, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '333 Aspen Ct', 'Phoenix', 'AZ', '85001', 'Home', 10009, 'Y', 'N');

INSERT INTO Addresses (address_id, address_line, city, state, zip_code, address_type, customer_id, is_default, is_deleted)
VALUES (SEQ_ADDRESS_ID.NEXTVAL, '444 Walnut St', 'Atlanta', 'GA', '30301', 'Work', 10010, 'Y', 'N');



SET DEFINE OFF;
INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 89.99, 'Pending', 10001, 20001);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 149.49, 'Shipped', 10002, 20002);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 45.00, 'Delivered', 10003, 20003);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 199.99, 'Cancelled', 10004, 20004);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 72.25, 'Pending', 10005, 20005);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 330.00, 'Shipped', 10006, 20006);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 18.50, 'Delivered', 10007, 20007);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 250.10, 'Pending', 10008, 20008);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 305.75, 'Delivered', 10009, 20009);

INSERT INTO Customer_Orders (order_id, total_amount, order_status, customer_id, shipping_address_id)
VALUES (SEQ_CUSTOMER_ORDER_ID.NEXTVAL, 120.00, 'Shipped', 10010, 20010);



SET DEFINE OFF;
INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 2, 25.99, 70001, 30001);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 79.50, 70002, 30002);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 3, 199.99, 70003, 30003);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 1, 45.00, 70004, 30004);

INSERT INTO Order_Items (order_item_id, product_quantity, unit_price, product_id, order_id)
VALUES (SEQ_ORDER_ITEM_ID.NEXTVAL, 4, 15.75, 70005, 30005);

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



SET DEFINE OFF;
INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Completed', DATE '2025-03-01', 89.99, 30001);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'PayPal', 'Completed', DATE '2025-03-02', 149.49, 30002);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Debit Card', 'Completed', DATE '2025-03-02', 45.00, 30003);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Refunded', DATE '2025-03-03', 199.99, 30004);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Cash', 'Completed', DATE '2025-03-03', 72.25, 30005);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Bank Transfer', 'Pending', DATE '2025-03-04', 330.00, 30006);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'PayPal', 'Completed', DATE '2025-03-04', 18.50, 30007);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Other', 'Failed', DATE '2025-03-05', 250.10, 30008);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Debit Card', 'Completed', DATE '2025-03-05', 305.75, 30009);

INSERT INTO Payments (payment_id, payment_method, payment_status, payment_date, amount_paid, order_id)
VALUES (SEQ_PAYMENT_ID.NEXTVAL, 'Credit Card', 'Completed', DATE '2025-03-06', 120.00, 30010);



SET DEFINE OFF;
INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 59.99, 'Pending', 'Product defective upon arrival', 1, 50001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 39.50, 'Approved', 'Wrong item shipped', 2, 50002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 0.00, 'Rejected', 'Return window expired', 1, 50003, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 120.00, 'Completed', 'Damaged in transit', 1, 50004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 24.99, 'Approved', 'Product doesn’t match description', 1, 50005, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 14.75, 'Completed', 'Incorrect size sent', 1, 50006, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 85.00, 'Pending', 'Missing parts', 3, 50007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 0.00, 'Rejected', 'Minor scratches, non-returnable', 1, 50008, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 95.00, 'Approved', 'Late delivery', 2, 50009, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Returns (return_id, return_amount, status, reason, returned_quantity, order_item_id, created_at, updated_at)
VALUES (SEQ_RETURN_ID.NEXTVAL, 49.99, 'Completed', 'Changed mind', 1, 50010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);



SET DEFINE OFF;
INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SAVE10', 10.00, DATE '2024-03-01', DATE '2024-03-31', 70001, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SPRING20', 20.00, DATE '2024-04-01', DATE '2024-04-30', 70002, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'FREESHIP', 5.00, DATE '2024-05-01', DATE '2024-05-15', 70003, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'SUMMER15', 15.00, DATE '2024-06-01', DATE '2024-06-30', 70004, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'WELCOME5', 5.00, DATE '2024-01-01', DATE '2024-12-31', 70005, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'WINTER25', 25.00, DATE '2024-12-01', DATE '2024-12-31', 70006, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'HOLIDAY50', 50.00, DATE '2024-11-25', DATE '2024-11-30', 70007, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'BLACKFRI', 40.00, DATE '2024-11-28', DATE '2024-11-29', 70008, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'CYBERMON', 30.00, DATE '2024-12-02', DATE '2024-12-02', 70009, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Discounts (discount_id, promo_code, discount_percentage, start_date, end_date, product_id, created_at, updated_at)
VALUES (SEQ_DISCOUNT_ID.NEXTVAL, 'CLEARANCE', 60.00, DATE '2024-07-01', DATE '2024-07-15', 70010, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);



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
