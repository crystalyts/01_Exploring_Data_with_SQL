-- Answering business questions

use magist;

-- Part One:
-- 1. How many orders are there in the dataset? 

SELECT 
    COUNT(order_id)
FROM
    orders;


-- 2. Are orders actually delivered?

SELECT 
    order_status, 
    COUNT(*) AS orders
FROM
    orders
GROUP BY order_status;


-- 3. Is Magist having user growth? 

SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;


-- 4. How many products are there on the products table?

SELECT 
    COUNT(DISTINCT product_id) AS products_count
FROM
    products;


-- 5. Which are the categories with the most products?

SELECT 
    product_category_name, 
    COUNT(DISTINCT product_id) AS n_products
FROM
    products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;


-- 6. How many products were present in actual transactions?

SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;


-- 7. What’s the price for the most expensive and cheapest products? 

SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;


-- 8.1 What are the highest and lowest payment values? 

SELECT 
	MAX(payment_value) as highest,
    MIN(payment_value) as lowest
FROM
	order_payments;


-- 8.2 What are the highest and lowest order values?

select 
	MAX(payment_value) as highest, 
    MIN(payment_value) as lowest
from 
	order_payments
where 
	payment_value 
    in
	(select sum(payment_value) from order_payments group by order_id);
    
    
-- 8.3 questions regarding order values

-- avg order value:
select 
	avg(payment_value)
from 
	order_payments
where 
	payment_value 
    in
	(select sum(payment_value) from order_payments group by order_id);
    
    
-- avg order value excl. shipping:
select 
	avg(price)
from 
	order_items
where 
	price 
    in
	(select sum(price) from order_items group by order_id);


-- find the total order value incl shipping of all orders:
select order_id, sum(payment_value)
from order_payments
group by order_id;


-- find the max order value of an order incl shipping:
select sum(payment_value)
from order_payments
group by order_id
order by sum(payment_value) desc
limit 1;


-- find the min order value of an order incl shipping:
select order_id, sum(payment_value)
from order_payments
group by order_id
order by sum(payment_value) asc
limit 1;


-- or excl shipping

-- find the max order value of an order excl shipping:
select order_id, sum(price)
from order_items
group by order_id
order by sum(price) desc
limit 1;


-- find the min order value of an order excl shipping:
select order_id, sum(price)
from order_items
group by order_id
order by sum(price) asc
limit 1;


-- Part Two:

-- Questions in relation to the sales:

-- 1. What categories of tech products does Magist have?   
--     --> tech products: 'computers_accessories' , 'telephony', 'consoles_games', 'computers'
   
select product_category_name_english, 
    COUNT(DISTINCT product_id)
FROM
    products
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
GROUP BY product_category_name_english
ORDER BY COUNT(product_id) DESC;


-- 2.1 How many products are actually sold by category?

SELECT 
    product_category_name_english, COUNT(order_items.product_id)
FROM
    order_items
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
group by product_category_name_english;


-- 2.2 How many products of these tech categories have been sold (within the time window of the database snapshot)? 

SELECT 
    product_category_name_english, COUNT(order_items.product_id) as QTY_sold
FROM
    order_items
        LEFT JOIN
    products ON order_items.product_id = products.product_id
        LEFT JOIN
    product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
WHERE
    product_category_name_english IN ('computers_accessories' , 'telephony', 'consoles_games', 'computers')
GROUP BY product_category_name_english;


-- 3.1 What’s the average price of the products being sold?
-- --> €120

SELECT 
    AVG(price)
FROM
    order_items;


-- 3.2 What’s the average price of the high-tech product being sold?

select 
	product_category_name_english, avg(order_items.price)
from 
	order_items
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english
in ("computers_accessories", "telephony", "consoles_games", "computers")
group by product_category_name_english;


-- 4. Are expensive tech products popular?
--   --> Expensive products are not popular

select 
	product_category_name_english, order_items.product_id, order_items.price
from 
	order_items
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english
in ("computers_accessories", "telephony", "consoles_games", "computers");


-- Consider price above 500 as expensive

select 
	order_items.product_id, order_items.price, case
    when price >= 500 then 'expensive'
    when price >= 200 then 'medium'
    else 'not expensive'
    end as price_level
from 
	order_items
left join products
on order_items.product_id = products.product_id
left join product_category_name_translation
on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english
in ("computers_accessories", "telephony", "consoles_games", "computers");


-- 5. How did numbers of tech accessorie customers develope over time? 
select 
    year(o.order_purchase_timestamp) as year, 
    month(o.order_purchase_timestamp) as month, 
    count(distinct customer_id) as unique_customer 
from orders as o
left join order_items as oi
on o.order_id = oi.order_id
left join products as p
on oi.product_id = p.product_id 
where p.product_category_name
in ('pcs', 'informatica_acessorios', 'consoles_games', 'telefonia') 
group by year(order_purchase_timestamp), month(order_purchase_timestamp)
order by year(order_purchase_timestamp), month(order_purchase_timestamp);


-- 6.  How did numbers of tech accessorie sales develope over time? 
select 
    year(o.order_purchase_timestamp) as year, 
    month(o.order_purchase_timestamp) as month, 
    count(distinct o.order_id) as unique_orders
from orders as o
left join order_items as oi
on o.order_id = oi.order_id
left join products as p
on oi.product_id = p.product_id 
where p.product_category_name
in ('pcs', 'informatica_acessorios', 'consoles_games', 'telefonia') 
group by year(order_purchase_timestamp), month(order_purchase_timestamp)
order by year(order_purchase_timestamp), month(order_purchase_timestamp);


-- ----------------------------------------------------------------------------------------------

-- Questions in relation to the sellers

-- 1. How many months of data are included in the magist database?
--    --> from sept 2016 to october 2018, that's 26 months

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM orders;


-- 2. How many sellers are there?

select count(distinct seller_id)
from sellers;


-- 3.  How many Tech sellers are there?

select count(DISTINCT s.seller_id)
from order_items as o_i
left join products as p on o_i.product_id = p.product_id 
right join product_category_name_translation as p_c_n_t on p.product_category_name = p_c_n_t.product_category_name
left join sellers as s on o_i.seller_id = s.seller_id
where product_category_name_english in ("computers_accessories", "telephony", "consoles_games", "computers");


-- 4. What percentage of overall sellers are Tech sellers?
--    -->(481 / 3095) * 100 --> 15,54%



-- 5. What is the total amount earned by all sellers? 

select 
    YEAR(o.order_purchase_timestamp) AS year
    , MONTH(o.order_purchase_timestamp) AS month
    , avg(op.payment_value) as total_earned
from 
    order_payments as op
left join
    orders as o
on op.order_id = o.order_id
group by
    YEAR(o.order_purchase_timestamp) 
    , MONTH(o.order_purchase_timestamp) 
order by
    YEAR(o.order_purchase_timestamp) 
    , MONTH(o.order_purchase_timestamp);
    

-- 6. What is the total amount earned by all Tech sellers?

select 
    YEAR(o.order_purchase_timestamp) AS year
    , MONTH(o.order_purchase_timestamp) AS month
    , avg(op.payment_value) as total_earned
from 
    order_payments as op
left join
    orders as o
on op.order_id = o.order_id
left join 
    order_items as oi
on op.order_id = oi.order_id
left join
    products as p
on oi.product_id = p.product_id
where 
    p.product_category_name
in ('pcs', 'informatica_acessorios', 'consoles_games', 'telefonia')
group by
    YEAR(o.order_purchase_timestamp) 
    , MONTH(o.order_purchase_timestamp) 
order by
    YEAR(o.order_purchase_timestamp) 
    , MONTH(o.order_purchase_timestamp);


-- 7. What's the average monthly income of all sellers?

SELECT 
    AVG(op.payment_value)
FROM
    order_payments AS op
        LEFT JOIN
    orders AS o ON op.order_id = o.order_id
GROUP BY YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp);


-- 8. What's the average monthly income of Tech sellers?

SELECT 
    AVG(o_p.payment_value) AS average_per_month
FROM
    order_payments AS op
        LEFT JOIN
    orders AS o ON op.order_id = o.order_id
        LEFT JOIN
    order_items AS oi ON op.order_id = oi.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
WHERE
    p.product_category_name IN ('pcs' , 'informatica_acessorios', 'consoles_games', 'telefonia')
GROUP BY YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp);


-- ----------------------------------------------------------------------------------------------

-- Questions in relation to the delivery time:

-- 1. What’s the average time between the order being placed and the product being delivered?

SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date))
FROM
    orders;


-- 2. How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    COUNT(order_id) AS delayed_order_number
FROM
    orders
WHERE
    (TIMESTAMPDIFF(DAY,
        order_estimated_delivery_date,
        order_delivered_customer_date)) > 0;

SELECT 
    COUNT(order_id) AS ontime_order_number
FROM
    orders
WHERE
    (TIMESTAMPDIFF(DAY,
        order_estimated_delivery_date,
        order_delivered_customer_date)) <= 0;

-- 3. Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT
    CASE 
		WHEN product_weight_g < 2000 AND product_length_cm < 60 AND product_width_cm < 30 AND product_height_cm < 15 THEN 'Packet 2kg'
        WHEN product_weight_g < 5000 AND product_length_cm < 120 AND product_width_cm < 60 AND product_height_cm < 60 THEN 'Packet 5kg'
        ELSE 'Packet big'
	END AS PacketSize, 
    Count(*), 
    AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS Delay
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
 JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered' 
-- AND product_category_name IN ('pcs' , 'informatica_acessorios', 'consoles_games', 'telefonia')
AND order_estimated_delivery_date < order_delivered_customer_date
GROUP BY PacketSize;

-- PAKET 2kg has most counts (1019). and a delay of 8 days (only for those who arrived later than estimated)
-- PAKET 5kg has 281 counts and a delay of 7.7 days
-- PAKET big has fewer counts 73 and a delay of 8 days

-- for all products:  (only delayed ones)
-- approximately 1 day more delay
-- the bigger the product the little later the delay (not significant for tech products)
-- a significant pattern could not be concluded */

-- ----------------------------------------------------------------------------------------------

-- Regarding Review Score:

select review_score, count(review_score) 
from order_reviews
group by review_score
order by review_score;

select avg(review_score) as average_Review
from order_reviews;
 
select year(o.order_purchase_timestamp) as year, 
    month(o.order_purchase_timestamp) as month, 
    count(review_id),
    avg(review_score)
from orders as o
left join order_reviews as ore
on o.order_id = ore.order_id
group by year(order_purchase_timestamp), month(order_purchase_timestamp)
order by year(order_purchase_timestamp), month(order_purchase_timestamp);
