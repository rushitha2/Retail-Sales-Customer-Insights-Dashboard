create database retail;
use retail;

create table dim_customer (customerid varchar(5) primary key,
    firstname varchar(50) not null,
    lastname varchar(50),
    gender varchar(10),
    region varchar(50),
    ssn varchar(11) unique not null);


create table dim_product ( productid int primary key,
    productname varchar(100) not null,
    category varchar(50) not null);


create table fact_sales ( saleid varchar(50) primary key,
    productid int,
    customerid varchar(5),
    salesamount decimal(10, 2) not null,
    quantity int not null,
    timestamp datetime not null,
    foreign key (productid) references dim_product(productid),
    foreign key (customerid) references dim_customer(customerid));
    
select * from dim_product;

select * from dim_customer;

select * from fact_sales;

select count(*) from fact_sales;

# Identify best-selling products

select p.productid, p.productname, sum(s.quantity) as total_quantity from fact_sales s
join dim_product p on s.productid = p.productid group by p.productid, p.productname order by total_quantity desc limit 5;

# Segment customers based on purchase patterns

select sales_category, count(customerid) as customer_count from (
select customerid, count(saleid) as total_sales,
case when count(saleid) >= 15 then 'frequent'
	when count(saleid) between 5 and 14 then 'regular'
	else 'infrequent'
	end as sales_category
from fact_sales group by customerid) as category group by sales_category order by customer_count desc;
 
# Analyze regional sales trends.

select c.region, sum(s.salesamount) as total_sales from fact_sales s join 
dim_customer c on s.customerid = c.customerid group by c.region order by total_sales desc;

# Total Sales Revenue

select sum(salesamount) as total_sales_revenue from fact_sales;

# Sales Growth Rate

select cur.sales_month, cur.total_sales as cur_month_sales, pre.total_sales as pre_month_sales,
(cur.total_sales - pre.total_sales) / pre.total_sales * 100 as sales_growth_rate from (
select month(timestamp) as sales_month, sum(salesamount) as total_sales from fact_sales 
where year(timestamp) = 2024 and month(timestamp) in (10, 11)  group by month(timestamp)) as cur
left join ( select month(timestamp) as sales_month, sum(salesamount) as total_sales from fact_sales
where year(timestamp) = 2024 and month(timestamp) in (09, 10) group by month(timestamp)) as pre
on  cur.sales_month = pre.sales_month + 1 order by cur.sales_month;

# Customer Lifetime Value (CLV)

select c.customerid, c.firstname, c.lastname, sum(s.salesamount) as clv
from fact_sales s join dim_customer c on s.customerid = c.customerid
group by c.customerid, c.firstname, c.lastname order by clv desc;

