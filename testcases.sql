DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  Onboard_Customer(
    p_first_name   => 'Alice',
    p_last_name    => 'Smith',
    p_email        => 'alice.smith@example.com',
    p_phone        => '555-1234',
    p_dob          => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
    p_gender       => 'F',
    p_address_line => '123 Main St',
    p_city         => 'Boston',
    p_state        => 'MA',
    p_zip          => '02118',
    p_customer_id  => v_customer_id
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 1 Passed. New Customer ID: ' || v_customer_id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 1 Failed: ' || SQLERRM);
END;


DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  Onboard_Customer(
    p_first_name   => NULL,
    p_last_name    => 'Smith',
    p_email        => 'alice.smith@example.com',
    p_phone        => '555-1234',
    p_dob          => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
    p_gender       => 'F',
    p_address_line => '123 Main St',
    p_city         => 'Boston',
    p_state        => 'MA',
    p_zip          => '02118',
    p_customer_id  => v_customer_id
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 2 Failed: ' || SQLERRM);  -- Expected failure due to NULL first_name
END;



DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  Onboard_Customer(
    p_first_name   => 'Alice',
    p_last_name    => 'Smith',
    p_email        => 'alice.smith@com',  -- Invalid email format
    p_phone        => '555-1234',
    p_dob          => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
    p_gender       => 'F',
    p_address_line => '123 Main St',
    p_city         => 'Boston',
    p_state        => 'MA',
    p_zip          => '02118',
    p_customer_id  => v_customer_id
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 3 Failed: ' || SQLERRM);  -- Expected failure due to invalid email format
END;


DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  -- Second insert with the same email
  Onboard_Customer(
    p_first_name   => 'Bob',
    p_last_name    => 'Jones',
    p_email        => 'sophiereed@domain.co',  -- Email already exists
    p_phone        => '555-5678',
    p_dob          => TO_DATE('1985-07-22', 'YYYY-MM-DD'),
    p_gender       => 'M',
    p_address_line => '456 Oak St',
    p_city         => 'Cambridge',
    p_state        => 'MA',
    p_zip          => '02139',
    p_customer_id  => v_customer_id
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 4 Failed: ' || SQLERRM);  -- Expected failure due to duplicate email
END;


DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  Onboard_Customer(
    p_first_name   => 'Charlie',
    p_last_name    => 'Brown',
    p_email        => 'brown@example.com',
    p_phone        => '555-6789',
    p_dob          => TO_DATE('2025-12-01', 'YYYY-MM-DD'),  -- DOB in the future
    p_gender       => 'M',
    p_address_line => '789 Pine St',
    p_city         => 'Brookline',
    p_state        => 'MA',
    p_zip          => '02445',
    p_customer_id  => v_customer_id
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 5 Failed: ' || SQLERRM);  -- Expected failure due to future DOB
END;

DECLARE
  v_customer_id Customers.customer_id%TYPE;
BEGIN
  Onboard_Customer(
    p_first_name   => 'Diana',
    p_last_name    => 'Ross',
    p_email        => 'diana.ross@example.com',
    p_phone        => '555-4321',
    p_dob          => TO_DATE('1992-11-03', 'YYYY-MM-DD'),
    p_gender       => 'X',  -- Invalid gender
    p_address_line => '1010 Birch St',
    p_city         => 'Quincy',
    p_state        => 'MA',
    p_zip          => '02169',
    p_customer_id  => v_customer_id
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 6 Failed: ' || SQLERRM);  -- Expected failure due to invalid gender
END;



-- Disable the trigger temporarily
ALTER TRIGGER ADMIN.TRG_INVENTORY_THRESHOLD_CHECK DISABLE;

UPDATE Inventory
SET stock_level = reorder_threshold - 10
WHERE inventory_id = (SELECT inventory_id FROM Products WHERE product_id = 70001);

DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Valid input where restock is needed
  PLACE_RESTOCK_ORDER(
    p_product_id      => 70001,    -- Existing product_id
    p_supplier_email  => 'sales@techsource.com',  -- Existing supplier email
    p_warehouse_code  => 'WH-BC-07' -- Existing warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 1 Passed: Restock order placed successfully.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 1 Failed: ' || SQLERRM);
END;

ALTER TRIGGER ADMIN.TRG_INVENTORY_THRESHOLD_CHECK ENABLE;



DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Valid input where no restock is needed
  PLACE_RESTOCK_ORDER(
    p_product_id      => 70002,    -- Existing product_id with stock level >= threshold
    p_supplier_email  => 'sales@techsource.com',  -- Existing supplier email
    p_warehouse_code  => 'WH-TX-04' -- Existing warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 2 Failed: Restock should not have been placed.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 2 Passed: ' || SQLERRM);  -- Expected failure due to no restock needed
END;


DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Invalid input: Null product_id
  PLACE_RESTOCK_ORDER(
    p_product_id      => NULL,    -- Invalid product_id
    p_supplier_email  => 'supplier@example.com',  -- Existing supplier email
    p_warehouse_code  => 'WH001' -- Existing warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 3 Failed: Procedure should fail due to null product_id.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 3 Passed: ' || SQLERRM);  -- Expected failure due to null product_id
END;



DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Invalid input: Non-existent product_id
  PLACE_RESTOCK_ORDER(
    p_product_id      => 9999,   -- Non-existent product_id
    p_supplier_email  => 'supplier@example.com',  -- Existing supplier email
    p_warehouse_code  => 'WH001' -- Existing warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 4 Failed: Procedure should fail due to product not found.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 4 Passed: ' || SQLERRM);  -- Expected failure due to product not found
END;


DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Invalid input: Non-existent supplier email
  PLACE_RESTOCK_ORDER(
    p_product_id      => 70001,    -- Valid product_id
    p_supplier_email  => 'nonexistent_supplier@example.com',  -- Non-existent supplier email
    p_warehouse_code  => 'WH001' -- Existing warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 7 Failed: Procedure should fail due to supplier not found.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 7 Passed: ' || SQLERRM);  -- Expected failure due to supplier not found
END;




DECLARE
  v_order_id  NUMBER;
BEGIN
  -- Invalid input: Non-existent warehouse code
  PLACE_RESTOCK_ORDER(
    p_product_id      => 70001,    -- Valid product_id
    p_supplier_email  => 'sales@techsource.com',  -- Existing supplier email
    p_warehouse_code  => 'WH999' -- Non-existent warehouse code
  );
  DBMS_OUTPUT.PUT_LINE('Test Case 8 Failed: Procedure should fail due to warehouse not found.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 8 Passed: ' || SQLERRM);  -- Expected failure due to warehouse not found
END;





DECLARE
  v_product_id Products.product_id%TYPE := 70003; -- Replace with a valid product_id
  v_quantity   NUMBER := 50;
BEGIN
  receive_shipment(p_product_id => v_product_id, p_quantity => v_quantity);
  DBMS_OUTPUT.PUT_LINE('Test Case 1 Passed: Shipment received successfully.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 1 Failed: ' || SQLERRM);
END;
/


DECLARE
  v_product_id Products.product_id%TYPE := NULL;
  v_quantity   NUMBER := 50;
BEGIN
  receive_shipment(p_product_id => v_product_id, p_quantity => v_quantity);
  DBMS_OUTPUT.PUT_LINE('Test Case 2 Failed: Procedure should have raised an error for null product_id.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 2 Passed: ' || SQLERRM);
END;
/

DECLARE
  v_product_id Products.product_id%TYPE := 999999; -- Replace with a non-existent product_id
  v_quantity   NUMBER := 50;
BEGIN
  receive_shipment(p_product_id => v_product_id, p_quantity => v_quantity);
  DBMS_OUTPUT.PUT_LINE('Test Case 6 Failed: Procedure should have raised an error for non-existent product_id.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test Case 6 Passed: ' || SQLERRM);
END;
/



-- Attempt negative stock (should fail)
UPDATE Inventory SET stock_level = -10 WHERE inventory_id = 100;


--Valid Order Placement
BEGIN
    Place_Customer_Order(
        p_customer_id         => 10001,
        p_shipping_address_id => 20001,
        p_order_items         => SYS.ODCIVARCHAR2LIST('70001|1', '70002|2'),
        p_order_date          => SYSDATE,
        p_payment_method      => 'Credit Card'
    );
END;
/

--Valid Order Status Update
UPDATE Customer_Orders
SET order_status = 'Shipped'
WHERE order_id = 30001; -- Make sure this order exists and is 'Pending'
/


--Valid Return 
BEGIN
    Handle_Return(
        p_order_item_id => 50011,
        p_quantity      => 1,
        p_reason        => 'Item partially defective'
    );
END;
/


--Failed Test Case

--Customer ID does not exist
BEGIN
    Place_Customer_Order(
        p_customer_id         => 99999,  -- Invalid
        p_shipping_address_id => 20001,
        p_order_items         => SYS.ODCIVARCHAR2LIST('70001|1'),
        p_order_date          => SYSDATE,
        p_payment_method      => 'UPI'
    );
END;
/

--Insufficient Stock
BEGIN
    Place_Customer_Order(
        p_customer_id         => 10001,
        p_shipping_address_id => 20001,
        p_order_items         => SYS.ODCIVARCHAR2LIST('70001|9999'),  -- Exceeds available stock
        p_order_date          => SYSDATE,
        p_payment_method      => 'Credit Card'
    );
END;
/

-- Invalid Order item id 

BEGIN
    Handle_Return(
        p_order_item_id => 999999,  -- Non-existent
        p_quantity      => 1,
        p_reason        => 'Invalid'
    );
END;
/

--Over Retrun Dectection
BEGIN
    Handle_Return(
        p_order_item_id => 50001,  -- Already partially returned or only ordered 1
        p_quantity      => 5,      -- Exceeds allowed
        p_reason        => 'Testing Over-return'
    );
END;
/


-- Invalid Order ID
BEGIN
    Place_Customer_Order(
        p_customer_id         => 10001,
        p_shipping_address_id => 20001,
        p_order_items         => SYS.ODCIVARCHAR2LIST('99999|1'),  -- Non-existent product
        p_order_date          => SYSDATE,
        p_payment_method      => 'Credit Card'
    );
END;
/


-Trigger Reduce Update
SELECT stock_level FROM Inventory WHERE inventory_id = 110001;

INSERT INTO Order_Items (
    order_item_id, product_quantity, unit_price, product_id, order_id
) VALUES (
    SEQ_ORDER_ITEM_ID.NEXTVAL, 3, 25.99, 70001, 30001
);

SELECT stock_level FROM Inventory WHERE inventory_id = 110001;

--Trigger Restock Inventory on Return 
SELECT stock_level FROM Inventory WHERE inventory_id = 110001;


UPDATE Returns
SET status = 'Approved'
WHERE return_id = 60001;

SELECT stock_level FROM Inventory WHERE inventory_id = 110001;

--Trigger Order Status Transition
--success
UPDATE Customer_Orders
SET order_status = 'Shipped'
WHERE order_id = 30001;

--fail
UPDATE Customer_Orders
SET order_status = 'Pending'
WHERE order_id = 30001;




