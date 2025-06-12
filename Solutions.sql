-- Week 2 SQL Challenge - https://8weeksqlchallenge.com/case-study-2/ 

-- A. Pizza Metrics

-- 1) How many pizzas were ordered?

select
    count (pizza_id) as total_orders
from customer_orders ;

-- 2) How many unique customer orders were made?

select
    count (distinct order_id) as unique_orders
from customer_orders ;

-- 3) How many successful orders were delivered by each runner?

select
    runner_id ,
    count (distinct order_id) as successfull_orders
from runner_orders
where pickup_time <> 'null'
group by runner_id ;

-- 4) How many of each type of pizza was delivered?

select 
    pizza_name ,
    count (*) as pizzas_delivered
from customer_orders as co
inner join runner_orders as ro
    on co.order_id = ro.order_id
inner join pizza_names as pn
    on co.pizza_id = pn.pizza_id
where pickup_time <> 'null'
group by pizza_name ;

-- 5) How many Vegetarian and Meatlovers were ordered by each customer?

select 
    customer_id ,
    pizza_name ,
    count (*) as pizzas_delivered
from customer_orders as co
inner join runner_orders as ro
    on co.order_id = ro.order_id
inner join pizza_names as pn
    on co.pizza_id = pn.pizza_id
group by customer_id, pizza_name 
order by customer_id ;

-- 6) What was the maximum number of pizzas delivered in a single order?

select
    c.order_id ,
    count (c.order_id) as number_of_pizzas
from customer_orders as c
inner join runner_orders as r
    on c.order_id = r.order_id
where pickup_time <> 'null'
group by c.order_id
order by count (c.order_id) desc
limit 1 ;

-- 7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select
    customer_id ,
    sum (case when 
                (
                (exclusions is not null and exclusions <> 'null' and length(exclusions) > 0) 
                and (extras is not null and extras <> 'null' and length(extras) > 0)
                ) = true
                then 1 else 0 end) as pizzas_with_change ,
    sum (case when 
                (
                (exclusions is not null and exclusions <> 'null' and length(exclusions) > 0) 
                and (extras is not null and extras <> 'null' and length(extras) > 0)
                ) = true
                then 0 else 1 end) as pizzas_without_change
from customer_orders as c
inner join runner_orders as r
    on c.order_id = r.order_id
where pickup_time <> 'null'
group by customer_id ;

-- 8) How many pizzas were delivered that had both exclusions and extras?

select
    count (*) as pizzas
from customer_orders as c
inner join runner_orders as r
    on c.order_id = r.order_id
where pickup_time <> 'null'
    and (exclusions is not null and exclusions <> 'null' and length(exclusions) > 0) 
    and (extras is not null and extras <> 'null' and length(extras) > 0) ;

-- 9) What was the total volume of pizzas ordered for each hour of the day?

select
    date_part('hour', order_time) as hour_of_the_day ,
    count (pizza_id) as total_pizzas_ordered
from customer_orders
group by date_part('hour', order_time) ;

-- 10) What was the volume of orders for each day of the week?

select
    dayname(order_time) as day ,
    count (pizza_id) as total_pizzas_ordered
from customer_orders
group by dayname(order_time) ;
