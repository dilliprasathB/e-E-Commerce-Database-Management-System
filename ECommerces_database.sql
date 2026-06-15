-- E-commerce Database management system;

create database ECommerceDB;
use ECommerceDB;

-- customer table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    registration_date DATE
);

-- addresses
CREATE TABLE Addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    address_line VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)
);

-- products
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- supplies 
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100),
    contact_number VARCHAR(15),
    email VARCHAR(100)
);

-- Product_Suppliers
CREATE TABLE Product_Suppliers (
    product_id INT,
    supplier_id INT,
    PRIMARY KEY(product_id, supplier_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id),
    FOREIGN KEY(supplier_id) REFERENCES Suppliers(supplier_id)
);

-- Shopping_Cart
CREATE TABLE Shopping_Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    created_date DATE,
    FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);

-- Cart_Items
CREATE TABLE Cart_Items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY(cart_id) REFERENCES Shopping_Cart(cart_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id)
);

-- orders 
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    order_status VARCHAR(30),
    FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);

-- order items
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY(order_id) REFERENCES Orders(order_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id)
);

-- payments
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    FOREIGN KEY(order_id) REFERENCES Orders(order_id)
);

-- Reviews
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    rating INT CHECK(rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY(customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id)
);

-- Deliveries
CREATE TABLE Deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    delivery_date DATE,
    delivery_status VARCHAR(50),
    tracking_number VARCHAR(100),
    FOREIGN KEY(order_id) REFERENCES Orders(order_id)
);

-- Wishlist
CREATE TABLE Wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    FOREIGN KEY(customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id)
);

-- Coupons
CREATE TABLE Coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code VARCHAR(20) UNIQUE,
    discount_percent DECIMAL(5,2),
    expiry_date DATE
);

-- Order_Coupons
CREATE TABLE Order_Coupons (
    order_id INT,
    coupon_id INT,
    PRIMARY KEY(order_id, coupon_id),
    FOREIGN KEY(order_id) REFERENCES Orders(order_id),
    FOREIGN KEY(coupon_id) REFERENCES Coupons(coupon_id)
);
-----------------------------------------------------------------------------------------------
-- 1. Find Top 10 Selling Products

select * from payments;

select pr.product_name,p.amount 
from order_items as o
join payments as p on p.order_id=o.order_id
join products as pr on pr.product_id=o.product_id
order by p.amount desc limit 10;

-- Calculate Monthly Revenue
select month(payment_date) as payment , sum(amount) as monthly_revenue
from payments 
group by payment;

-- Identify Highest Spending Customers
select c.customer_id,c.first_name , c.last_name , sum(p.amount) as amt
from orders as o
join customers as c on c.customer_id=o.customer_id
join payments as p on p.order_id=o.order_id
group by c.customer_id
order by amt desc limit 1;

-- Find Customers Who Never Placed an Order
select c.first_name , c.last_name , o.order_status
from orders as o
join customers as c on c.customer_id = o.customer_id
where o.order_status = 'shipped';

-- Show Products with Low Stock
select product_id,product_name,stock_quantity from products 
where stock_quantity <20;

-- Find Most Used Coupon Codes
select  c.coupon_code,count(o.coupon_id) as codes
from order_coupons as o
join coupons as c on o.coupon_id = c.coupon_id
group by c.coupon_code 
having codes=3;

-- Calculate Revenue After Discounts
select sum(amount) from payments;

-- Find Products with Highest Ratings
select p.product_name , r.rating , r.review_text
from products as p
join reviews as r on p.product_id = r.product_id
where rating >=4 order by rating asc;
 
 -- Identify Customers with Multiple Addresses
 SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(a.address_id) AS address_count
FROM customers c
JOIN addresses a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.address_id) > 1;
 
-- Find Cancelled Orders
select p.product_id , p.product_name , d.delivery_status
from order_items as o
join products as p on p.product_id = o.product_id
join deliveries as d on d.order_id = o.order_id
where d.delivery_status = 'Cancelled';

-- Show Orders Still in Transit
select p.product_id , p.product_name , d.delivery_status
from order_items as o
join products as p on p.product_id = o.product_id
join deliveries as d on d.order_id = o.order_id
where d.delivery_status = 'In Transit';

-- Find Customers Who Added Products to Wishlist but Never Purchased
select w.wishlist_id ,p.product_id,c.first_name, c.last_name, p.product_name 
from wishlist as w
join products as p on p.product_id= w.product_id
join customers as c on c.customer_id =w.customer_id;

-- Calculate Average Order Value
select avg(total_amount) as average from orders;

 -- Find Best Performing Product Category
 
 SELECT c.category_id,
       c.category_name,
       COUNT(*) AS five_star_reviews
FROM Products p
JOIN Categories c
    ON c.category_id = p.category_id
JOIN Reviews r
    ON r.product_id = p.product_id
WHERE r.rating = 5
GROUP BY c.category_id, c.category_name
ORDER BY five_star_reviews DESC
LIMIT 1;

 -- Identify Repeat Customers
 select c.first_name,c.last_name,count(o.order_id) as total_order
 from orders as o
 join customers as c on c.customer_id=o.customer_id
 group by c.first_name,c.last_name
 having total_order=2;
 
 -- Sub query
 
 -- Find customers whose total spending is greater than the average customer spending.
 select c.first_name,c.last_name,o.total_amount
 from orders as o
 join customers as c on c.customer_id=o.customer_id 
 WHERE o.total_amount <
 (select avg(total_amount) from orders);
 
 -- Find products whose price is higher than the average product price in their category.
select  product_id,product_name,price from products
where price >
( select avg(price) as avg_price from products) ;

-- Find the second highest spending customer.
select c.first_name,c.last_name,c.customer_id,sum(o.total_amount)as sec_high
from orders as o 
join customers as c on c.customer_id=o.customer_id
group by customer_id
order by sec_high desc 
limit 1 offset 1;
 
 -- Find products that have never been ordered
 select p.product_name,p.product_id, o.order_id
 from order_items as oi
 right join products as p on p.product_id=oi.product_id
 right join orders as o on o.order_id=oi.order_id
 where o.order_id is null;
 
 -- Find categories whose average product rating is above the overall average rating.
 select c.first_name,c.last_name,c.customer_id,avg(r.rating) as rate
 from reviews as r
 join customers as c on c.customer_id=r.customer_id
 group by c.first_name,c.last_name,c.customer_id
 having rate >(
 select avg(rating) as over_all_average from reviews);
 
 -- Windows Function
 
 -- Rank products based on total sales revenue within each category.
 select c.category_name,c.category_id,p.price as price,
 rank() over(partition by c.category_id order by p.price desc) as total_price
 from categories as c 
 join products as p on c.category_id=p.category_id;
 
 -- Find the top 3 customers by spending using DENSE_RANK().
 select c.first_name, c.last_name,c.customer_id,o.total_amount,
 dense_rank() over(order by o.total_amount desc) as top_3_customer
 from customers as c
 join orders as o on c.customer_id=o.customer_id
 limit 3;
 
 -- Calculate a running total of monthly revenue.
 select month(order_date),sum(total_amount),
 rank() over(order by month(order_date) asc)
 from orders
 group by month(order_date);
 
 -- Find the highest-priced product in each category using ROW_NUMBER().
 select * from
 (select c.category_name,p.product_name,p.product_id,p.price,
 row_number() over(partition by c.category_id order by p.price desc) as r_n
 from categories as c
 join products as p on p.category_id=c.category_id)t
 where r_n=1;
 
 
 -- Display each customer's order amount along with the previous order amount using LAG().
 
 
 