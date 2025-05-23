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
