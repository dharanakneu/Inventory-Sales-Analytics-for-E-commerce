-- Insert warehouse required by FK
INSERT INTO Warehouses (
  warehouse_id, warehouse_code, city, state, country,
  manager_name, contact_number, created_at, updated_at
) VALUES (
  120001, 'WH-NY-01', 'New York', 'New York', 'USA',
  'Alice Johnson', '+1-212-555-1234', SYSTIMESTAMP, SYSTIMESTAMP
);

-- Insert test inventory
INSERT INTO Inventory (
  inventory_id, stock_level, reorder_threshold, warehouse_id, created_at, updated_at
) VALUES (
  100, 5, 15, 120001, SYSTIMESTAMP, SYSTIMESTAMP
);

-- Run restock order
EXEC place_restock_order(100);

-- Simulate shipment
EXEC receive_shipment(100, 20);

-- Attempt negative stock (should fail)
UPDATE Inventory SET stock_level = -10 WHERE inventory_id = 100;