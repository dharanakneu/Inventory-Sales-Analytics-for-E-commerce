-- Procedure: Place Restock Order
CREATE OR REPLACE PROCEDURE place_restock_order(p_inventory_id NUMBER) AS
  v_stock_level NUMBER;
  v_threshold NUMBER;
  v_needed_qty NUMBER;
  v_supplier_id NUMBER := 1;
BEGIN
  SELECT stock_level, reorder_threshold
  INTO v_stock_level, v_threshold
  FROM Inventory
  WHERE inventory_id = p_inventory_id;

  IF v_stock_level < v_threshold THEN
    v_needed_qty := v_threshold - v_stock_level;
    INSERT INTO Warehouse_Orders (
      order_id, inventory_id, supplier_id, warehouse_id, total_quantity,
      order_date, created_at, updated_at
    )
    VALUES (
      WAREHOUSE_ORDER_SEQ.NEXTVAL,
      p_inventory_id,
      v_supplier_id,
      120001,
      v_needed_qty,
      SYSDATE, SYSTIMESTAMP, SYSTIMESTAMP
    );
  END IF;
END;
/

-- Procedure: Receive Shipment
CREATE OR REPLACE PROCEDURE receive_shipment(
  p_inventory_id NUMBER,
  p_quantity NUMBER
) AS
BEGIN
  UPDATE Inventory
  SET stock_level = stock_level + p_quantity,
      last_restock_date = SYSDATE,
      updated_at = SYSTIMESTAMP
  WHERE inventory_id = p_inventory_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Inventory ID not found for shipment.');
  END IF;
END;
/
