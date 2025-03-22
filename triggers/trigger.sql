-- Ensure Stock Availability before placing an Order
CREATE OR REPLACE TRIGGER trg_check_stock_before_order
BEFORE INSERT ON Order_Items
FOR EACH ROW
DECLARE
    v_stock_level INTEGER;
BEGIN
    -- Get stock level for the product
    SELECT stock_level INTO v_stock_level 
    FROM Inventory 
    WHERE inventory_id = (SELECT inventory_id FROM Products WHERE product_id = :NEW.product_id);

    -- Check if enough stock exists
    IF v_stock_level < :NEW.product_quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough stock available for this product.');
    END IF;
END;
/


-- Update Inventory After Order Placement
CREATE OR REPLACE TRIGGER trg_update_stock_after_order
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET stock_level = stock_level - :NEW.product_quantity
    WHERE inventory_id = (SELECT inventory_id FROM Products WHERE product_id = :NEW.product_id);
END;
/


-- Automatically Apply Discounts before inserting order item
CREATE OR REPLACE TRIGGER trg_apply_discount
BEFORE INSERT ON Order_Items
FOR EACH ROW
DECLARE
    v_discount_percentage NUMBER(5,2);
BEGIN
    -- Get discount percentage if active
    SELECT discount_percentage INTO v_discount_percentage
    FROM Discounts
    WHERE product_id = :NEW.product_id
      AND SYSDATE BETWEEN start_date AND end_date;

    -- Apply discount if available
    IF v_discount_percentage IS NOT NULL THEN
        :NEW.unit_price := :NEW.unit_price * (1 - v_discount_percentage / 100);
    END IF;
END;
/


-- Enforce Maximum Return Window
CREATE OR REPLACE TRIGGER trg_prevent_late_returns
BEFORE INSERT ON Returns
FOR EACH ROW
DECLARE
    v_order_date DATE;
BEGIN
    -- Get order date
    SELECT order_date INTO v_order_date
    FROM Customer_Orders
    WHERE order_id = (SELECT order_id FROM Order_Items WHERE order_item_id = :NEW.order_item_id);

    -- Prevent return if order is older than 30 days
    IF SYSDATE > v_order_date + 30 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Returns are not allowed after 30 days.');
    END IF;
END;
/


-- Calculate Order Total
CREATE OR REPLACE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON Order_Items
FOR EACH ROW
BEGIN
  UPDATE Customer_Orders co
  SET total_amount = (SELECT NVL(SUM(product_quantity * unit_price), 0) 
                      FROM Order_Items oi 
                      WHERE oi.order_id = :NEW.order_id)
  WHERE co.order_id = :NEW.order_id;
END;
/


-- Prevent Over-Selling
CREATE OR REPLACE TRIGGER trg_check_stock_before_order
BEFORE INSERT ON Order_Items
FOR EACH ROW
DECLARE
  current_stock INT;
  inventory_id INT;
BEGIN
  -- Get inventory ID and lock the row for update to prevent race conditions
  SELECT i.inventory_id, i.stock_level 
  INTO inventory_id, current_stock
  FROM Inventory i
  JOIN Products p ON i.inventory_id = p.inventory_id
  WHERE p.product_id = :NEW.product_id
  FOR UPDATE;

  -- Check if there's enough stock
  IF current_stock < :NEW.product_quantity THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for this product.');
  END IF;
END;
/


-- Update Inventory after Warehouse Order
CREATE OR REPLACE TRIGGER update_inventory_warehouse_order
AFTER INSERT ON Warehouse_Orders
FOR EACH ROW
DECLARE
  v_exists NUMBER;
BEGIN
  -- Check if the inventory_id exists in Inventory table
  SELECT COUNT(*) INTO v_exists FROM Inventory WHERE inventory_id = :NEW.inventory_id;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Inventory record does not exist.');
  ELSE
    -- Update inventory stock level
    UPDATE Inventory
    SET stock_level = stock_level + :NEW.total_quantity
    WHERE inventory_id = :NEW.inventory_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20003, 'Error updating inventory stock level.');
END;
/


-- Update Return Status and Inventory 
CREATE OR REPLACE TRIGGER update_return_and_inventory
AFTER INSERT ON Returns
FOR EACH ROW
DECLARE
  v_order_quantity NUMBER;
  v_inventory_id   NUMBER;
  v_exists         NUMBER;
BEGIN
  -- Fetch the ordered quantity
  SELECT product_quantity INTO v_order_quantity
  FROM Order_Items
  WHERE order_item_id = :NEW.order_item_id;

  -- Prevent reducing quantity below zero
  IF :NEW.returned_quantity > v_order_quantity THEN
    RAISE_APPLICATION_ERROR(-20005, 'Returned quantity exceeds ordered quantity.');
  END IF;

  -- Update Order_Items table
  UPDATE Order_Items
  SET product_quantity = product_quantity - :NEW.returned_quantity
  WHERE order_item_id = :NEW.order_item_id;

  -- Get inventory_id
  SELECT inventory_id INTO v_inventory_id
  FROM Products
  WHERE product_id = (SELECT product_id FROM Order_Items WHERE order_item_id = :NEW.order_item_id);

  -- Ensure inventory record exists
  SELECT COUNT(*) INTO v_exists FROM Inventory WHERE inventory_id = v_inventory_id;
  
  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20006, 'Inventory record does not exist.');
  ELSE
    -- Update Inventory stock level
    UPDATE Inventory
    SET stock_level = stock_level + :NEW.returned_quantity
    WHERE inventory_id = v_inventory_id;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20007, 'Invalid return: Order item does not exist.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20008, 'Error processing return update.');
END;
/


-- Prevent Negative Inventory
CREATE OR REPLACE TRIGGER trg_prevent_negative_inventory
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN
  IF :NEW.stock_level < 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Inventory cannot go negative.');
  END IF;
END;
/


-- Recalculate Discounts on Updates
CREATE OR REPLACE TRIGGER trg_apply_discount_on_update
BEFORE UPDATE ON Order_Items
FOR EACH ROW
DECLARE
    v_discount_percentage NUMBER(5,2);
BEGIN
    -- Get discount percentage if active
    SELECT discount_percentage INTO v_discount_percentage
    FROM Discounts
    WHERE product_id = :NEW.product_id
      AND SYSDATE BETWEEN start_date AND end_date;

    -- Apply discount if available
    IF v_discount_percentage IS NOT NULL THEN
        :NEW.unit_price := :NEW.unit_price * (1 - v_discount_percentage / 100);
    END IF;
END;
/


-- Track Order Item Deletions (Update Total)
CREATE OR REPLACE TRIGGER trg_update_order_total_on_delete
AFTER DELETE ON Order_Items
FOR EACH ROW
BEGIN
  UPDATE Customer_Orders
  SET total_amount = total_amount - (:OLD.product_quantity * :OLD.unit_price)
  WHERE order_id = :OLD.order_id;
END;
/


-- Prevent Overlapping Discount Periods
CREATE OR REPLACE TRIGGER trg_prevent_overlapping_discounts
BEFORE INSERT ON Discounts
FOR EACH ROW
DECLARE
    v_existing_discount_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_existing_discount_count
    FROM Discounts
    WHERE product_id = :NEW.product_id
      AND (SYSDATE BETWEEN start_date AND end_date
           OR :NEW.start_date BETWEEN start_date AND end_date);
    IF v_existing_discount_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Discount period overlaps with an existing discount.');
    END IF;
END;
/


