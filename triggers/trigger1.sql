
#Update Order Total Amount When an Order Item is Added or Updated
CREATE OR REPLACE TRIGGER update_order_total
AFTER INSERT OR UPDATE ON Order_Items
FOR EACH ROW
BEGIN
  UPDATE Customer_Orders
  SET total_amount = (SELECT SUM(quantity * unit_price) FROM Order_Items WHERE order_id = :NEW.order_id)
  WHERE order_id = :NEW.order_id;
END;
/
