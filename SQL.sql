/* Steps to set up local file upload -
1. Run this query and check if the status is 'ON'-
SHOW GLOBAL VARIABLES LIKE 'LOCAL_INFILE';

2.Edit SQL server settings -> Edit connection -> Advanced -> Others -> Add OPT_LOCAL_INFILE = 1

3. If not, run the following - 
SET GLOBAL LOCAL_INFILE = TRUE;

/* ----------------ORGANIZATION DATA---------------------
Creates information about the different organizations that Prayas Pens interacts with - 
either as Suppliers or Customers. The table contains Org_ID as the primary key, the org name,
org address, contact, GST, PAN and CIN
*/

DROP DATABASE IF EXISTS PRAYAS_PENS;

CREATE DATABASE PRAYAS_PENS;

USE PRAYAS_PENS;


DROP TABLE IF EXISTS ORGANIZATIONS;

CREATE TABLE ORGANIZATIONS (
Org_ID	varchar(100) NOT NULL,
Org_Name	varchar(100),
Address_1	varchar(100),
Address_2	varchar(100),
Street_Area	varchar(100),
City varchar(100),
State_UT varchar(100),
State_UT_Code VARCHAR(100),
Country	varchar(100),
ZIP_Code varchar(100),
Primary_Contact varchar(15),
GST	varchar(50),
CIN	varchar(50),
PAN	varchar(20),
PRIMARY KEY (Org_ID)
);


LOAD DATA LOCAL INFILE '/Users/akanksha/Desktop/Prayas/Organizations.csv'
INTO TABLE ORGANIZATIONS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from ORGANIZATIONS;

/*-----------------PRODUCT DATA------------------------
The table contains information about the different products Prayas Pens buys/sells.
Product_ID is the primary key. Other information includes Product_name, Product_Description,
Category and a flag that indicates if they buy or sell this product
*/

DROP TABLE IF EXISTS PRODUCTS;

CREATE TABLE PRODUCTS
(
Product_ID VARCHAR(100) NOT NULL,
Product_Name  VARCHAR(100),
Product_Description  VARCHAR(100),
Color  VARCHAR(100),
Product_Category VARCHAR(100),
Product_Type  VARCHAR(100),
PRIMARY KEY(Product_ID)
);

LOAD DATA LOCAL INFILE '/Users/akanksha/Desktop/Prayas/Products.csv'
INTO TABLE PRODUCTS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM PRODUCTS;

/*------------------ORDER DATA-----------------
This table includes information about the orders placed by Prayas or orders received by Prayas.
Order_ID is the primary key. The table includes all information about the orders -
the order date, expected completion date, completion date, information related to tax, 
total amount and the order type. Org_ID is the foreign key.
*/

DROP TABLE IF EXISTS ORDERS;

CREATE TABLE ORDERS
(
Order_ID VARCHAR(100) NOT NULL,
Reference_No	VARCHAR(100),
Org_ID	VARCHAR(100),
Order_Date	DATE NULL,
Order_Exp_Completion_Date	DATE,
Order_Completion_Date	DATE,
Taxable_Amt	NUMERIC(15,5) NULL,
SGST_Amt	NUMERIC(15,5) NULL,
CGST_Amt	NUMERIC(15,5) NULL,
IGST_Amt	NUMERIC(15,5) NULL,
Total_Amt	NUMERIC(15,5) NULL,
Payment_Term_Days	VARCHAR(100),
Order_Type	VARCHAR(100),
PRIMARY KEY(Order_ID),
FOREIGN KEY(Org_ID) REFERENCES ORGANIZATIONS(Org_ID)
);

LOAD DATA LOCAL INFILE '/Users/akanksha/Desktop/Prayas/Orders.csv'
INTO TABLE ORDERS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM ORDERS;

/*------------------------PRODUCTS_ORDERED---------------------
This table is an associative entity between Products and Orders. 
The primary key and foreign key is a combination of Product_ID and Order_ID.
The table contains information of all the products that were ordered.
*/

DROP TABLE IF EXISTS PRODUCTS_ORDERED;

CREATE TABLE PRODUCTS_ORDERED
(
Order_ID	VARCHAR(100)  NOT NULL,
Product_ID	VARCHAR(100)  NOT NULL,
Order_Qty	NUMERIC(15,2),
Exp_Completion_Date DATE NULL,
Actual_Completion_Date DATE NULL,
Taxable_Amt	NUMERIC(15,2) NULL,
SGST_Amt	NUMERIC(15,2) NULL,
CGST_Amt	NUMERIC(15,2) NULL,
IGST_Amt	NUMERIC(15,2) NULL,
Total_Amt	NUMERIC(15,2) NULL,
PRIMARY KEY (Order_ID, Product_ID)
);

LOAD DATA LOCAL INFILE '/Users/akanksha/Desktop/Prayas/Products_Ordered.csv'
INTO TABLE PRODUCTS_ORDERED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM PRODUCTS_ORDERED;

/*----------------------ORG_PRODUCT---------------
This table is an associative entity between Customers and Products.
The primary key and foreign key is a combination of Org_ID and Product_ID.
The table contains information about the products ordered/sold by the organizations
from/to Prayas Pens.
*/

DROP TABLE IF EXISTS ORGANIZATIONS_PRODUCT;

CREATE TABLE ORGANIZATIONS_PRODUCT
(
Org_ID	VARCHAR (100) NOT NULL,
Product_ID	VARCHAR (100) NOT NULL,
Price_Before_Tax	NUMERIC(15,2) NULL,
Effective_From_Date	DATE NOT NULL,
Effective_To_Date	DATE NULL,
SGST_Slab	NUMERIC(15,2) NULL,
SGST_Per_Unit	NUMERIC(15,2) NULL,
CGST_Slab	NUMERIC(15,2) NULL,
CGST_Per_Unit	NUMERIC(15,2) NULL,
IGST_Slab	NUMERIC(15,2) NULL,
IGST_Per_Unit	NUMERIC(15,2) NULL,
Total_Unit_Price	NUMERIC(15,2) NULL,
PRIMARY KEY (Org_ID,Product_ID,Effective_From_Date),
FOREIGN KEY (Org_ID) REFERENCES ORGANIZATIONS(Org_ID),
FOREIGN KEY (Product_ID) REFERENCES PRODUCTS(Product_ID)
);


LOAD DATA LOCAL INFILE '/Users/akanksha/Desktop/Prayas/Organization_Product.csv'
INTO TABLE ORGANIZATIONS_PRODUCT
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM ORGANIZATIONS_PRODUCT;

-- ----------------------------------- DATA ANALYSIS ---------------------------------------------------

USE PRAYAS_PENS;

-- 1(Using basic SQL functions) Which order ID had the maximum number of orders (In amount)?
SELECT Order_ID
FROM orders
ORDER BY Total_Amt DESC
LIMIT 1;

-- 2(Using basic SQL functions) Count all unique products in the Product table grouped by whether Prayas sells or buys the product
SELECT Product_Type, COUNT(DISTINCT Product_ID) AS Unique_Products_Count
FROM products
GROUP BY Product_Type;

-- 3(Using basic SQL functions) Which organizations does Prayas do business with that is based in Mumbai
SELECT DISTINCT Org_Name
FROM organizations 
WHERE City LIKE '%Mumbai%';

-- 4(Using basic SQL functions) Calculate total amount from orders, average order value, and the number of orders for Prayas in the year 2023
SELECT
    SUM(Total_Amt) AS TotalAmount,
    AVG(Total_Amt) AS AverageOrderAmount,
    COUNT(Order_ID) AS NumberOfOrders
FROM orders
WHERE YEAR(Order_Date) = 2023;
 
-- 5(Joins) Which product has had an order quantity greater than 20000
SELECT p.Product_Name
FROM products p
JOIN products_ordered po ON p.Product_ID = po.Product_ID
GROUP BY p.Product_Name
HAVING SUM(po.Order_Qty) > 20000;

-- 6(Joins) What is Prayas's top bought products in volume (Ordered descending) and how much revenue are they generating for that particular product?
SELECT 
    p.Product_ID,
    pr.Product_Name,
    SUM(p.Order_Qty) AS TotalQuantityOrdered,
    SUM(p.Total_Amt) AS TotalRevenue
FROM products_ordered p
JOIN products pr ON p.Product_ID = pr.Product_ID
GROUP BY p.Product_ID, pr.Product_Name
ORDER BY TotalQuantityOrdered DESC;

-- 7(Basic SQL functions)List products that have never been ordered 
SELECT p.Product_ID, p.Product_Name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM products_ordered po
    WHERE p.Product_ID = po.Product_ID
);

-- 8(Joins)Product_Category values in descending order based on the frequency of orders for each category
SELECT p.Product_Category, COUNT(o.Order_ID) AS OrderCount
FROM products p
LEFT JOIN products_ordered po ON p.Product_ID = po.Product_ID
LEFT JOIN orders o ON po.Order_ID = o.Order_ID
GROUP BY p.Product_Category
ORDER BY OrderCount DESC;

-- 9(Basic SQL Functions) Compute the running total of sales for month for 2022 and 2023
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
    SUM(Total_Amt) AS RunningTotalSales
FROM orders
WHERE Order_Date  BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY Month
ORDER BY Month;

-- 10(Joins) Find Products Purchased Together atleast 3 times
SELECT po1.Product_ID, po2.Product_ID, COUNT(*) AS PurchaseCount
FROM products_ordered po1
INNER JOIN products_ordered po2 ON po1.Order_ID = po2.Order_ID AND po1.Product_ID < po2.Product_ID
GROUP BY po1.Product_ID, po2.Product_ID
HAVING PurchaseCount >= 3
ORDER BY PurchaseCount DESC;


    
-- 11(Window function) Provide a list of orders with their respective total amounts, the average total amount for each organization,
-- and the difference between each order's total amount and the organization's average.
SELECT
    o.Order_ID,
    o.Total_Amt,
    org.Org_Name,
    AVG(o.Total_Amt) OVER (PARTITION BY org.Org_ID) AS AvgTotalAmt,
    o.Total_Amt - AVG(o.Total_Amt) OVER (PARTITION BY org.Org_ID) AS DifferenceFromAvg
FROM
    orders o
JOIN
    organizations org ON o.Org_ID = org.Org_ID;

-- 12(Window function)Provide a list of orders with their respective total amounts, the total sales for the organization,
 -- and the percentage contribution of each order to the organization's total sales.
SELECT
    o.Order_ID,
    o.Total_Amt,
    org.Org_Name,
    SUM(o.Total_Amt) OVER (PARTITION BY org.Org_ID) AS TotalSalesForOrg,
    (o.Total_Amt / SUM(o.Total_Amt) OVER (PARTITION BY org.Org_ID)) * 100 AS PercentageContribution
FROM
    orders o
JOIN
    organizations org ON o.Org_ID = org.Org_ID;
    
-- 13 Identify orders that were delivered before time, on time and delayed

select org_id, order_type, count(order_id) as Total_Counts, 
sum(case when Order_Completion_Date > Order_Exp_Completion_Date then 1 else 0 end) * 100/count(order_id)  as Orders_delayed,
sum(case when Order_Completion_Date < Order_Exp_Completion_Date then 1 else 0 end) * 100/count(order_id)  as Orders_delivered_ahead, 
sum(case when Order_Completion_Date = Order_Exp_Completion_Date then 1 else 0 end) * 100/count(order_id)  as Orders_ontime
from ORDERS group by 1,2; 

