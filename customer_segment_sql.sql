CREATE TABLE customers(

  customer_id VARCHAR(20),
  customer_name TEXT,
  gender TEXT,
  age INT,
  city TEXT,
  signup_date DATE,
  month_name TEXT
);

SELECT * FROM customers;


CREATE TABLE orders(

  order_id VARCHAR(20),
  customer_id VARCHAR(10),
  order_date DATE,
  order_month TEXT,
  category TEXT,
  total_amount INT
);

SELECT * FROM orders;



COPY customers (customer_id,customer_name,gender,age,city,signup_date,month_name)
FROM 'C:\Program Files\PostgreSQL\17\data\customers.csv'
CSV HEADER;

SELECT * FROM customers;


COPY orders (order_id,customer_id,order_date,order_month,category,total_amount)
FROM 'C:\Program Files\PostgreSQL\17\data\orders.csv'
CSV HEADER;


SELECT * FROM orders;


----- SQL Queries ------

-- 1.	Total Customers

SELECT COUNT(DISTINCT c.customer_id) AS Total_Customers
FROM customers c;

-- 2. 	Total Revenue

SELECT SUM(o.total_amount) AS Total_Revenue
 FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;


-- 3.	Average Order Value (AOV)

SELECT AVG(o.total_amount) AS Average_Order_Value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;


-- 4.	Revenue by Customer

SELECT c.customer_id,c.customer_name,SUM(o.total_amount) AS Total_Spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY Total_Spent DESC
LIMIT 5;



-- 5.	High-Value Customers (Top Spenders)

SELECT c.customer_id,c.customer_name,SUM(o.total_amount) AS Total_Spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.customer_name
HAVING SUM(o.total_amount) > 50000
ORDER BY Total_Spent DESC
LIMIT 3;



-- 6.	Purchase Frequency per Customer

SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS Total_Orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY Total_Orders DESC
LIMIT 5;

 

-- 7.	Most Popular Product Category

SELECT o.category,COUNT(o.order_id) AS Total_Order
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY o.category
ORDER BY Total_Order DESC
LIMIT 5;



-- 8.	Customer Segmentation

SELECT c.customer_id,c.customer_name,SUM(o.total_amount) AS Total_Spent,
CASE
  WHEN SUM(o.total_amount) > 50000
  THEN 'High Value'

 WHEN SUM(o.total_amount) 
 BETWEEN 20000 AND 50000
 THEN 'Medium Value'

  ELSE 'Low Value'
  END AS customer_segment
  FROM customers c
  JOIN orders o
  ON c.customer_id = o.customer_id
  GROUP BY c.customer_id,c.customer_name
  ORDER BY Total_Spent DESC;
 


  
-- 9.	Which Customer Segment Contributes Maximum Revenue?

 WITH segments AS(

	SELECT
	   customer_id,SUM(total_amount) AS Total_Spent,
	   
	   CASE  

        WHEN SUM(total_amount) > 50000
        THEN 'High Value'
	   
        WHEN SUM(total_amount) 
        BETWEEN 20000 AND 50000
        THEN 'Medium Value'

         ELSE 'Low Value'

 END AS segment
 FROM orders
 GROUP BY customer_id

 )

 SELECT 
      segment,
	  SUM(Total_Spent) AS Segment_Revenue
	  FROM segments
	  GROUP BY segment
	  ORDER BY Segment_Revenue DESC;
    


  
-- 10.	Repeat vs New Customers

SELECT customer_id,COUNT(order_id) AS Total_Orders,
CASE
    WHEN COUNT(order_id) > 2 THEN 'Repeat Customer'
	ELSE 'New Customer'
	END AS Customer_Type
	FROM orders
	GROUP BY customer_id;




-- 11.	Which Month Has the Most Orders?


SELECT
   TO_CHAR(order_date,'Month') AS Month,

   COUNT(order_id) AS Total_Orders
   FROM orders
   GROUP BY TO_CHAR(order_date,'Month'),
   EXTRACT(MONTH FROM order_date)
   ORDER BY Total_Orders DESC;




-- 12.	Orders by Age Group

SELECT
  CASE
   WHEN c.age < 25 THEN 'Under 25'
   WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
    WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
    WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
	ELSE '55+'
	END AS Age_Group,

	COUNT(o.order_id) AS Total_Orders
	FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	GROUP BY Age_Group
	ORDER BY Total_Orders DESC;



-- 13.Top Cities by Revenue

SELECT c.city,SUM(o.total_amount) AS Top_City_Revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY Top_City_Revenue DESC
LIMIT 5;
   
	
-- ----------- END SQL QUERIES ----------------


