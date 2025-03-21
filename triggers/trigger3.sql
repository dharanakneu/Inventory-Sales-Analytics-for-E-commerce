
# Update Warehouse Stock Levels After Receiving a Warehouse Order
CREATE OR REPLACE TRIGGER update_warehouse_stock
AFTER INSERT ON Warehouse_Orders
FOR EACH ROW
BEGIN
  UPDATE Inventory
  SET stock_level = stock_level + :NEW.total_quantity
  WHERE inventory_id = :NEW.inventory_id;
END;
/
