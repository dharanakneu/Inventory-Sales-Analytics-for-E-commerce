# Inventory-Sales-Analytics-for-E-commerce 
The Predictive Inventory & Sales Analytics for E-commerce system empowers businesses with real-time insights into inventory and sales, enabling data-driven decision-making. By identifying top-selling products over different time periods, businesses can optimize stock levels and ensure high-demand items remain available. The system also predicts upcoming demand using historical sales trends, helping businesses estimate the required stock for the next month and proactively manage inventory. Additionally, it analyzes customer return rates and refund reasons, allowing businesses to detect potential product quality issues and refine return policies for improved customer satisfaction.

To maximize revenue, the system determines optimal discount strategies by analyzing which discount levels drive the highest sales, ensuring promotions are both effective and profitable. It also helps prevent stockouts and overstocking by flagging products at risk of running out of stock or accumulating excess inventory. By identifying seasonal demand patterns, businesses can anticipate peak sales periods and align inventory accordingly. The system further supports clearance sales planning by tracking low-selling products and supplier lead time management, ensuring timely restocking based on supplier efficiency. Lastly, it improves customer retention by analyzing purchase frequency, enabling businesses to engage frequent shoppers and re-engage less active customers with personalized strategies.


## Running the Project
This project implements an Inventory Management and Sales Analytics system using Oracle SQL.

## Running the SQL Locally / On Your Own Server
You can run this project on any Oracle-compatible environment. The scripts are structured to be executed in the following order to ensure proper dependency management and data flow.

## Step-by-Step Execution Order
1. Create Tables  
Navigate to the TABLES folder and run Create_Tables.sql scripts to create base tables.  
This defines all primary keys, foreign keys, data types, and constraints.

2. Insert Sample Data  
Go to the SAMPLE_DATA folder and run the Sample_Data.sql script.  
This populates the tables with test records for development and analytics testing.

3. Create Views  
Navigate to the VIEWS folder and execute the Views.sql script to define analytical views.
These views are used to simplify complex queries and enable reporting.

4. Grant Permissions  
Go to the GRANTS folder and run the Grants.sql script.  
This grants access permissions to user roles or other schemas for querying views or tables.

## Folder Structure Overview
TABLES : Contains all DDL scripts to create the relational schema.

SAMPLE_DATA : Insert statements to populate initial data.

VIEWS : Holds view creation scripts for analytics/reporting.

GRANTS : Includes SQL files to assign user access rights.

ERD : Entity Relationship Diagrams and visual schema documents.

Business_Outcomes.pdf : Describes the business goals of the project.

Constraints_and_Validation.pdf : Lists all constraints used across the schema.

DFDs (Data Flow Diagrams):

DMDD_CustomerOnboarding.pdf: Explains the customer registration and address flow.
DMDD_OrderManagment.pdf: Details the order placement, payment, and shipping processes.
DMDD_OrderReturn.pdf: Captures the return initiation, validation, and refund workflow.
DMDD_WarehouseInventoryManagement.pdf: Describes the stock inflow, inventory update, and supplier interaction processes.

Normalization_Process.pdf : Documents all the normalization process steps the team has taken to prove the model is normalized.

DMDD_Project1.pdf: Project overview or initial proposal documentation.


