# Trigger for updating inventory on placing an order
CREATE OR REPLACE TRIGGER update_inventory_on_order
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
  UPDATE Inventory
  SET stock_level = stock_level - :NEW.quantity
  WHERE product_id = :NEW.product_id;
END;
/

