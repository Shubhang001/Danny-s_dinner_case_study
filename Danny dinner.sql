CREATE DATABASE danny;

USE danny;

CREATE TABLE sales(
customer_id VARCHAR(1),
order_date DATE,
product_id INTEGER
);

INSERT INTO sales(customer_id, order_date, product_id)
VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu(product_id, product_name, price)
VALUES 
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


SELECT * FROM sales;

-- What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS amount_spend FROM sales
LEFT JOIN menu
ON sales.product_id= menu.product_id
GROUP BY customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS no_of_dates
FROM sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
WITH cte AS(
SELECT customer_id, product_name,RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM sales 
LEFT JOIN menu
ON sales.product_id= menu.product_id
)
SELECT customer_id, product_name
FROM cte
WHERE rnk= 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, COUNT(product_name)
FROM sales
LEFT JOIN menu
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY COUNT(product_name) DESC
LIMIT 1;

-- Which item was the most popular for each customer? 
SELECT product_name
FROM sales
LEFT JOIN menu
ON sales.product_id= menu.product_id
GROUP BY product_name
ORDER BY COUNT(product_name) DESC
LIMIT 1;

-- Which item was purchased first by the customer after they became a member?
WITH cte AS
(SELECT sales.customer_id ,product_name ,DATEDIFF(order_date,join_date) AS diff,
 RANK() OVER(PARTITION BY customer_id ORDER BY DATEDIFF(order_date,join_date)) AS rnk
FROM sales
LEFT JOIN menu
ON sales.product_id= menu.product_id
LEFT JOIN members
ON members.customer_id= sales.customer_id
WHERE DATEDIFF(order_date,join_date)>0)

SELECT customer_id, product_name
FROM cte
WHERE rnk = 1;

-- Which item was purchased just before the customer became a member?
WITH cte AS(
SELECT sales.customer_id, product_name, DATEDIFF(order_date, join_date) AS diff,
 RANK() OVER(PARTITION BY sales.customer_id ORDER BY DATEDIFF(order_date, join_date)) AS rnk
FROM sales
LEFT JOIN menu
ON sales.product_id = menu.product_id
LEFT JOIN members
ON members.customer_id = sales.customer_id
WHERE DATEDIFF(order_date, join_date) < 0)

SELECT customer_id, product_name
FROM cte
WHERE rnk = 1;

-- What is the total items and amount spent for each member before they became a member?
SELECT sales.customer_id, SUM(price) AS total_cost, COUNT(price) AS total_orders
FROM sales
LEFT JOIN members
ON sales.customer_id= members.customer_id
LEFT JOIN menu
ON menu.product_id= sales.product_id
WHERE DATEDIFF(order_date,join_date) < 0
GROUP BY sales.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(CASE WHEN product_name = 'sushi'
                                THEN 2*price*10
                                ELSE price*10
                                END) AS new_price
FROM sales
LEFT JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 -- not just sushi - how many points do customer A and B have at the end of January?
 
 SELECT sales.customer_id, SUM(CASE WHEN product_name = 'sushi' OR (DATEDIFF(order_date, join_date)>=0 OR DATEDIFF(order_date, join_date)<7)
                              THEN price*2*10
                              ELSE price*10
                              END) AS points
 FROM sales
 LEFT JOIN members
 ON members.customer_id = sales.customer_id
 LEFT JOIN menu
 ON menu.product_id = sales.product_id
 WHERE MONTHNAME(order_date) = 'January'
 GROUP BY sales.customer_id;
 
 SELECT * 
 FROM sales
 LEFT JOIN members
 ON members.customer_id = sales.customer_id
 LEFT JOIN menu
 ON menu.product_id = sales.product_id
 
 









