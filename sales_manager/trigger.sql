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
   
