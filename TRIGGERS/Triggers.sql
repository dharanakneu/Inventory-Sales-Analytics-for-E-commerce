-- Trigger: Logs low-stock inventory events into Inventory_Threshold_Log
CREATE OR REPLACE TRIGGER trg_inventory_threshold_check
AFTER UPDATE ON Inventory
FOR EACH ROW
WHEN (NEW.stock_level < NEW.reorder_threshold)
BEGIN
    -- Insert a log record when inventory level drops below threshold
    INSERT INTO Inventory_Threshold_Log (inventory_id, product_id, stock_level, threshold)
    SELECT i.inventory_id, p.product_id, :NEW.stock_level, :NEW.reorder_threshold
    FROM Products p
    JOIN Inventory i ON p.inventory_id = i.inventory_id
    WHERE i.inventory_id = :NEW.inventory_id;
END;
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
   
