
select sum(total_amount) as total_sales_revenue ,count(order_id) as total_orders,sum(quantity) as total_quantity_sold from fact_sales_data;

--How are sales trending Montly over time?

select monthname(order_date) as month_name,sum(total_amount) as total_amount from fact_sales_data
group by month_name
order by total_amount desc;


--Which products generate the highest and lowest sales revenue?


select p.product_name,sum(f.total_amount) as total_revenue from fact_sales_data f 
join product_details p on p.product_id = f.product_id
group by p.product_name
order by total_revenue desc;


--Which products have the highest and lowest quantities sold?


select p.product_name,sum(f.quantity) as total_quantities from fact_sales_data f 
join product_details p on p.product_id = f.product_id
group by p.product_name
order by total_quantities desc;


--Which product categories generate the highest revenue?


select p.product_category,sum(f.total_amount) as total_revenue from fact_sales_data f 
join product_details p on p.product_id = f.product_id
group by p.product_category
order by total_revenue desc;

--How does each product category perform in terms of revenue, orders, and quantity sold?

select p.product_category,sum(f.total_amount) as total_revenue,count(distinct f.order_id) as total_orders,sum(f.quantity) as total_quantity
from fact_sales_data f
join product_details p on p.product_id = f.product_id
group by p.product_category
order by total_revenue desc;

--Who are the top 10 customers based on total spending?

select c.customer_id, c.customer_name, sum(f.total_amount) as total_spent
from fact_sales_data f
join customer_details c on c.customer_id = f.customer_id
group by c.customer_id, c.customer_name
order by total_spent desc
limit 10;

--Which customers place the highest number of orders?

select c.customer_id, c.customer_name, count(distinct f.order_id) as total_orders
from fact_sales_data f
join customer_details c on c.customer_id = f.customer_id
group by c.customer_id, c.customer_name
order by total_orders desc;

--What percentage of total revenue comes from each customer?


select c.customer_id, c.customer_name,
       sum(f.total_amount) as customer_revenue,
       round(sum(f.total_amount) * 100.0 / sum(sum(f.total_amount)) over (), 2) as pct_of_total_revenue
from fact_sales_data f
join customer_details c on c.customer_id = f.customer_id
group by c.customer_id, c.customer_name
order by customer_revenue desc;

--How can customers be segmented into High, Medium, and Low-value customers based on their spending?

with customer_spend as (
    select c.customer_id, c.customer_name, sum(f.total_amount) as total_spent
    from fact_sales_data f
    join customer_details c on c.customer_id = f.customer_id
    group by c.customer_id, c.customer_name
)
select *,
    case
        when total_spent >= (select percentile_cont(0.75) within group (order by total_spent) from customer_spend) then 'High'
        when total_spent >= (select percentile_cont(0.25) within group (order by total_spent) from customer_spend) then 'Medium'
        else 'Low'
    end as customer_segment
from customer_spend
order by total_spent desc;


--Which products are most frequently purchased by customers?

select p.product_name,
       count(f.order_id) as times_purchased,
       sum(f.quantity) as total_quantity_sold
from fact_sales_data f
join product_details p on p.product_id = f.product_id
group by p.product_name
order by times_purchased desc;

--What is the year-over-year or month-over-month sales growth?


with monthly_sales as (
    select date_trunc('month', order_date) as sales_month, sum(total_amount) as total_revenue
    from fact_sales_data
    group by sales_month
)
select sales_month, total_revenue,
       lag(total_revenue) over (order by sales_month) as prev_month_revenue,
       round((total_revenue - lag(total_revenue) over (order by sales_month)) * 100.0
             / lag(total_revenue) over (order by sales_month), 2) as mom_growth_pct
from monthly_sales
order by sales_month;

--Which day, month, quarter, or year generates the highest sales?

with yearly_sales as (
    select year(order_date) as sales_year, sum(total_amount) as total_revenue
    from fact_sales_data
    group by sales_year
)
select sales_year, total_revenue,
       lag(total_revenue) over (order by sales_year) as prev_year_revenue,
       round((total_revenue - lag(total_revenue) over (order by sales_year)) * 100.0
             / lag(total_revenue) over (order by sales_year), 2) as yoy_growth_pct
from yearly_sales
order by sales_year;



select dayname(order_date) as day_of_week, sum(total_amount) as total_revenue
from fact_sales_data
group by day_of_week
order by total_revenue desc;

select quarter(order_date) as quarter_num, sum(total_amount) as total_revenue
from fact_sales_data
group by quarter_num
order by total_revenue desc;


--Which products and categories contribute the most to overall business revenue, and what is their percentage contribution?

-- product level
select p.product_name, p.product_category,
       sum(f.total_amount) as product_revenue,
       round(sum(f.total_amount) * 100.0 / sum(sum(f.total_amount)) over (), 2) as pct_contribution
from fact_sales_data f
join product_details p on p.product_id = f.product_id
group by p.product_name, p.product_category
order by product_revenue desc;

-- category level
select p.product_category,
       sum(f.total_amount) as category_revenue,
       round(sum(f.total_amount) * 100.0 / sum(sum(f.total_amount)) over (), 2) as pct_contribution
from fact_sales_data f
join product_details p on p.product_id = f.product_id
group by p.product_category
order by category_revenue desc;
