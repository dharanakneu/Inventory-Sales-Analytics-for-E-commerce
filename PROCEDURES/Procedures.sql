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
        RAISE ex_invalid_email_format;
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
CREATE OR REPLACE PROCEDURE place_restock_order(p_inventory_id NUMBER) AS
  v_stock_level NUMBER;
  v_threshold NUMBER;
  v_needed_qty NUMBER;
  v_supplier_id NUMBER := 1;
BEGIN
  SELECT stock_level, reorder_threshold
  INTO v_stock_level, v_threshold
  FROM Inventory
  WHERE inventory_id = p_inventory_id;

  IF v_stock_level < v_threshold THEN
    v_needed_qty := v_threshold - v_stock_level;
    INSERT INTO Warehouse_Orders (
      order_id, inventory_id, supplier_id, warehouse_id, total_quantity,
      order_date, created_at, updated_at
    )
    VALUES (
      WAREHOUSE_ORDER_SEQ.NEXTVAL,
      p_inventory_id,
      v_supplier_id,
      120001,
      v_needed_qty,
      SYSDATE, SYSTIMESTAMP, SYSTIMESTAMP
    );
  END IF;
END;
/

-- Procedure: Receive Shipment
CREATE OR REPLACE PROCEDURE receive_shipment(
  p_inventory_id NUMBER,
  p_quantity NUMBER
) AS
BEGIN
  UPDATE Inventory
  SET stock_level = stock_level + p_quantity,
      last_restock_date = SYSDATE,
      updated_at = SYSTIMESTAMP
  WHERE inventory_id = p_inventory_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Inventory ID not found for shipment.');
  END IF;
END;
/
