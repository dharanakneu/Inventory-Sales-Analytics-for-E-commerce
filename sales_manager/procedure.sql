

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


CREATE OR REPLACE FUNCTION Is_Valid_Status_Transition (
    p_old_status IN VARCHAR2,
    p_new_status IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
    IF p_old_status = 'Pending' AND p_new_status IN ('Shipped', 'Cancelled') THEN
        RETURN TRUE;
    ELSIF p_old_status = 'Shipped' AND p_new_status = 'Delivered' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
/


GRANT EXECUTE ON Place_Customer_Order TO ECOMM_SALES_USER;
GRANT EXECUTE ON Handle_Return TO ECOMM_SALES_USER;
GRANT EXECUTE ON Is_Valid_Status_Transition TO ECOMM_SALES_USER;

