
#Prevent Over-Selling
CREATE OR REPLACE TRIGGER check_stock_before_order
BEFORE INSERT ON Order_Items
FOR EACH ROW
DECLARE
  current_stock INT;
BEGIN
  SELECT stock_level INTO current_stock FROM Inventory WHERE product_id = :NEW.product_id;
  IF current_stock < :NEW.quantity THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for this product.');
  END IF;
END;
/
