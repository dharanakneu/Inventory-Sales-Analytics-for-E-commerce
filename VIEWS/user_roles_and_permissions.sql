-- ======================
-- User Creation & Permissions
-- ======================

-- 🔐 Create Users with compliant passwords
CREATE USER sales_user IDENTIFIED BY "SalesUser123!";
CREATE USER inventory_user IDENTIFIED BY "InventoryUser123!";
CREATE USER analytics_user IDENTIFIED BY "AnalyticsUser123!";
CREATE USER support_user IDENTIFIED BY "SupportUser123!";

-- 📜 Grant SELECT privileges to sales_user
GRANT SELECT ON Week_Wise_Sales TO sales_user;
GRANT SELECT ON Total_Sales_Region_Wise TO sales_user;
GRANT SELECT ON Top_Selling_Products TO sales_user;
GRANT SELECT ON Customer_Behavior_Insights TO sales_user;

-- 🏷 Grant SELECT privileges to inventory_user
GRANT SELECT ON Current_Inventory_Status TO inventory_user;
GRANT SELECT ON Discount_Effectiveness TO inventory_user;
GRANT SELECT ON Supplier_Lead_Times TO inventory_user;
GRANT SELECT ON Customer_Return_Trends TO inventory_user;

-- 📊 Grant full view access to analytics_user
GRANT SELECT ON Current_Inventory_Status TO analytics_user;
GRANT SELECT ON Week_Wise_Sales TO analytics_user;
GRANT SELECT ON Total_Sales_Region_Wise TO analytics_user;
GRANT SELECT ON Top_Selling_Products TO analytics_user;
GRANT SELECT ON Customer_Return_Trends TO analytics_user;
GRANT SELECT ON Discount_Effectiveness TO analytics_user;
GRANT SELECT ON Supplier_Lead_Times TO analytics_user;
GRANT SELECT ON Customer_Purchase_Frequency TO analytics_user;
GRANT SELECT ON Customer_Behavior_Insights TO analytics_user;

-- 🤝 Grant limited customer insights to support_user
GRANT SELECT ON Customer_Purchase_Frequency TO support_user;
GRANT SELECT ON Customer_Behavior_Insights TO support_user;
GRANT SELECT ON Customer_Return_Trends TO support_user;

-- ======================
-- End of Permissions Section
-- ======================
