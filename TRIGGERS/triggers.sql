CREATE OR REPLACE TRIGGER trg_inventory_threshold_check
AFTER UPDATE ON Inventory
FOR EACH ROW
WHEN (NEW.stock_level < NEW.reorder_threshold)
BEGIN
    INSERT INTO Inventory_Threshold_Log (inventory_id, product_id, stock_level, threshold)
    SELECT i.inventory_id, p.product_id, :NEW.stock_level, :NEW.reorder_threshold
    FROM Products p
    JOIN Inventory i ON p.inventory_id = i.inventory_id
    WHERE i.inventory_id = :NEW.inventory_id;
END;
/


CREATE OR REPLACE TRIGGER trg_prevent_discount_update
BEFORE UPDATE ON Discounts
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Discounts are immutable and cannot be updated.');
END;
/

CREATE OR REPLACE TRIGGER trg_prevent_discount_delete
BEFORE DELETE ON Discounts
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'Discounts are immutable and cannot be deleted.');
END;
/