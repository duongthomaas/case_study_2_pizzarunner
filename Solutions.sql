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

-- B Runner and Customer Experience

-- 1) How many runners signed up for each 1 week period?

with cte as (
    select
        runner_id ,
        registration_date ,
        date_trunc('week', registration_date) + 4
    from runners
)
select
    date_trunc('week', registration_date) + 4 as week_starting ,
    count (distinct runner_id) as number_of_runners
from cte
group by date_trunc('week', registration_date) + 4
order by date_trunc('week', registration_date) + 4 ;

-- 2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with cte as (
    select
        distinct r.order_id ,
        runner_id ,
        order_time ,
        pickup_time
    from customer_orders as c
    inner join runner_orders as r
        on c.order_id = r.order_id
    where pickup_time <> 'null'
) , cte_2 as (
    select
        runner_id ,
        timestampdiff('seconds', to_timestamp(order_time), to_timestamp(pickup_time)) as time_difference_in_seconds
    from cte
)
select
    runner_id ,
    avg(time_difference_in_seconds) / 60
from cte_2
group by runner_id
;

-- 3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
  
with cte as (
    select
        r.order_id,
        pizza_id,
        order_time,
        pickup_time
    from customer_orders as c
    inner join runner_orders as r
        on c.order_id = r.order_id
    where pickup_time <> 'null'
),
cte_2 AS (
    SELECT
        order_id,
        COUNT(pizza_id) AS count_pizzas,
        max(TIMESTAMPDIFF(
            'second',
            TO_TIMESTAMP(order_time),
            TO_TIMESTAMP(pickup_time)
        )) AS time_difference_in_seconds
    FROM cte
    GROUP BY order_id
)
SELECT
    count_pizzas,
    round( AVG(time_difference_in_seconds) / 60, 1) AS avg_pickup_time_minutes
FROM cte_2
GROUP BY count_pizzas
ORDER BY count_pizzas;

-- 4) What was the average distance travelled for each customer?

select 
    customer_id ,
    round( avg(try_cast(regexp_substr(distance, '[0-9]+(\.[0-9]+)?') as float)), 1) as distance_km
from customer_orders as c
inner join runner_orders as r
    on c.order_id = r.order_id
where distance <> 'null'
group by customer_id
order by customer_id ;

-- 5) What was the difference between the longest and shortest delivery times for all orders?

select 
    max (regexp_replace(duration, '[^0-9]',''):: int) as longest_time ,
    min (regexp_replace(duration, '[^0-9]',''):: int) as shortest_time ,
    (max (regexp_replace(duration, '[^0-9]',''):: int)) - (min (regexp_replace(duration, '[^0-9]',''):: int)) as time_difference
from runner_orders
where duration <> 'null'
;

-- 6) What was the average speed for each runner for each delivery and do you notice any trend for these values?

select
    order_id ,
    runner_id ,
    replace(distance, 'km', '') :: numeric(3,1) / regexp_replace(duration, '[^0-9]', '') :: numeric(3,1) as km_per_minute
from runner_orders
where distance <> 'null'
order by runner_id
;

-- 7) What is the successful delivery percentage for each runner?

select 
    runner_id ,
    sum (
        case when
            duration = 'null'
            then 0
            else 1
            end
        ) / count(order_id) as successful_delivery_percentage
from runner_orders
group by runner_id 
;
