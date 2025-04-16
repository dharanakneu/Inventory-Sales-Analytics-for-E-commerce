-- ======================
-- Section 2: Reporting Views
-- ======================

-- 1. Current Inventory Status
CREATE OR REPLACE VIEW Current_Inventory_Status AS
SELECT 
    i.inventory_id,
    i.warehouse_id,
    w.city AS warehouse_city,
    w.state AS warehouse_state,
    i.stock_level,
    i.last_restock_date
FROM Inventory i
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id;

-- 2. Weekly Sales Report
CREATE OR REPLACE VIEW Week_Wise_Sales AS
SELECT 
    TO_CHAR(order_date, 'WW') AS sales_week,
    TO_CHAR(order_date, 'YYYY') AS sales_year,
    SUM(total_amount) AS weekly_sales
FROM Customer_Orders
GROUP BY TO_CHAR(order_date, 'YYYY'), TO_CHAR(order_date, 'WW')
ORDER BY sales_year, sales_week;


-- 3. Total Sales Region Wise
CREATE OR REPLACE VIEW Total_Sales_Region_Wise AS
SELECT 
    a.state AS region,
    SUM(co.total_amount) AS total_sales
FROM Customer_Orders co
JOIN Customers c ON co.customer_id = c.customer_id
JOIN Addresses a ON c.customer_id = a.customer_id
GROUP BY a.state;


-- 4. Top Selling Products
CREATE OR REPLACE VIEW Top_Selling_Products AS
SELECT 
    oi.product_id,
    p.product_name,
    SUM(oi.product_quantity) AS total_units_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_units_sold DESC;

-- 5. Customer Return Trends
CREATE OR REPLACE VIEW Customer_Return_Trends AS
SELECT 
    oi.product_id,
    p.product_name,
    COUNT(r.return_id) AS total_returns,
    ROUND(AVG(r.return_amount), 2) AS avg_refund
FROM Returns r
JOIN Order_Items oi ON r.order_item_id = oi.order_item_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_returns DESC;

-- 6. Discount Effectiveness Summary
CREATE OR REPLACE VIEW discount_effectiveness_summary AS
SELECT
    d.discount_id,
    d.promo_code,
    d.discount_percentage,
    d.start_date,
    d.end_date,
    p.product_id,
    p.product_name,

    COUNT(DISTINCT oi.order_id) AS total_orders_with_discount,
    SUM(oi.product_quantity) AS total_units_sold_with_discount,
    ROUND(SUM(oi.discounted_unit_price * oi.product_quantity), 2) AS total_revenue_with_discount,
    ROUND(AVG(oi.discounted_unit_price), 2) AS average_discounted_price

FROM Discounts d
JOIN Products p ON d.product_id = p.product_id
JOIN Order_Items oi ON oi.discount_id = d.discount_id
WHERE oi.discounted_unit_price IS NOT NULL

-- 7. Supplier Lead Times
CREATE OR REPLACE VIEW Supplier_Lead_Times AS
SELECT 
    s.supplier_id,
    s.supplier_name,
    ROUND(AVG((CAST(wo.updated_at AS DATE) - CAST(wo.created_at AS DATE))), 2) AS avg_lead_time_days
FROM Warehouse_Orders wo
JOIN Suppliers s ON s.supplier_id = wo.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

-- 8. Customer Purchase Frequency
CREATE OR REPLACE VIEW Customer_Purchase_Frequency AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(co.order_id) AS total_orders,
    MIN(co.order_date) AS first_order,
    MAX(co.order_date) AS last_order
FROM Customers c
JOIN Customer_Orders co ON co.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;

-- 9. Customer Behavior View 
CREATE OR REPLACE VIEW Customer_Behavior_Insights AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(co.order_id) AS total_orders,
    ROUND(SUM(co.total_amount), 2) AS total_spent,
    ROUND(AVG(co.total_amount), 2) AS avg_order_value,
    MIN(co.order_date) AS first_order_date,
    MAX(co.order_date) AS last_order_date,
    ROUND(SYSDATE - MAX(co.order_date)) AS days_since_last_order,
    
    NVL(ret.total_returns, 0) AS total_returns,
    ROUND(NVL(ret.total_returns / NULLIF(COUNT(co.order_id), 0), 0), 2) AS return_ratio,

    CASE
        WHEN ROUND(SYSDATE - MAX(co.order_date)) > 90 OR NVL(ret.total_returns, 0) > 3 THEN 'High'
        WHEN ROUND(SYSDATE - MAX(co.order_date)) > 60 THEN 'Medium'
        ELSE 'Low'
    END AS churn_risk

FROM Customers c
JOIN Customer_Orders co ON c.customer_id = co.customer_id
LEFT JOIN (
    SELECT
        co.customer_id,
        COUNT(r.return_id) AS total_returns
    FROM
        Returns r
        JOIN Order_Items oi ON r.order_item_id = oi.order_item_id
        JOIN Customer_Orders co ON oi.order_id = co.order_id
    GROUP BY co.customer_id
) ret ON ret.customer_id = c.customer_id

GROUP BY c.customer_id, c.first_name, c.last_name, ret.total_returns
ORDER BY total_orders DESC;


-- 10. Sales Payment Summary
CREATE OR REPLACE VIEW sales_payment_summary AS
SELECT
    co.order_id,
    co.order_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email AS customer_email,
    p.product_id,
    p.product_name,
    oi.product_quantity,
    oi.unit_price,
    (oi.product_quantity * oi.unit_price) AS total_order_amount,
    pay.amount_paid,
    pay.payment_status,
    pay.payment_method,
    pay.payment_date
FROM
    Customer_Orders co
    JOIN Customers c ON co.customer_id = c.customer_id
    JOIN Order_Items oi ON oi.order_id = co.order_id
    JOIN Products p ON oi.product_id = p.product_id
    LEFT JOIN Payments pay ON pay.order_id = co.order_id;

COMMIT;


-- ======================
-- End of Views Section
-- =====================



