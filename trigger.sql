
#UPDATE INVENTORY AFTER ORDER PLACEMENT
CREATE OR REPLACE TRIGGER trg_update_inventory_after_order
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
  UPDATE Inventory
  SET stock_level = stock_level - :NEW.product_quantity
  WHERE inventory_id = (SELECT inventory_id FROM Products WHERE product_id = :NEW.Products_product_id);
END;
