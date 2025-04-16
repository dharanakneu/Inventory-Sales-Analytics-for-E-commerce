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

