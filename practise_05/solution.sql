-- Завдання 1.3
SELECT 'sales' AS t, COUNT(*) FROM sales
UNION ALL
SELECT 'stock_prices', COUNT(*) FROM stock_prices;

-- Завдання 2.1
select 
	store_id,
	sum(total_amount) as total_amount
from sales
group by store_id

select 
	sale_id,
	store_id,
	total_amount,
	sum(total_amount) over()
from sales
order by sale_id;

-- Завдання 2.2
select
	sale_id,
	store_id,
	total_amount,
	round(avg(total_amount) over(), 2) as avg_all
from sales
order by sale_id;

-- Завдання 2.3
select
	sale_id,
	total_amount,
	count(*) over() as sales_count
from sales
order by sale_id;

-- Завдання 2.4
select
	sale_id,
	store_id,
	total_amount,
	round((total_amount / (sum(total_amount) over())) * 100, 2) as pct_of_total
from sales
order by sale_id;

-- Завдання 2.5
select
	sale_id,
	store_id,
	total_amount,
	dense_rank() over(order by total_amount desc) as overall_rank
from sales
order by overall_rank;

-- Завдання 3.1
select 
	sale_id,
	store_id,
	total_amount,
	round(avg(total_amount) over(partition by store_id), 2) as avg_store_sales
from sales
order by store_id, sale_id;

-- Завдання 3.2
select 
	sale_id,
	store_id,
	total_amount,
	sum(total_amount) over w as store_total,
	min(total_amount) over w as store_min,
	max(total_amount) over w as store_max,
	count(sale_id) over w as store_sales_cnt
from sales
window w as (partition by store_id)
order by store_id, sale_id;

-- Завдання 3.3
select 
	sale_id,
	store_id,
	total_amount,
	round(total_amount - avg(total_amount) over w, 2) as diff_from_avg
from sales
window w as (partition by store_id)
order by store_id, sale_id;

-- Завдання 3.4
select 
	sale_id,
	store_id,
	total_amount,
	round(total_amount / sum(total_amount) over w, 2) * 100 as pct_of_store 
from sales
window w as (partition by store_id)
order by store_id, sale_id;

-- Завдання 3.5
select
	sale_id,
	store_id,
	total_amount,
	s.avg_store_sales
from (
	select 
	sale_id,
	store_id,
	total_amount,
	round(avg(total_amount) over(partition by store_id), 2) as avg_store_sales
	from sales
	) s
where total_amount > s.avg_store_sales
order by store_id, sale_id;

-- Завдання 4.1
select 
	sales.*,
	row_number() over(partition by store_id order by sale_date, sale_id) as sale_rank	
from sales;

-- Завдання 4.2
select 
	sales.*,
	rank() over(partition by store_id order by total_amount desc) as amount_rank
from sales;

-- Завдання 4.3
select s.*
from (
	select 
		sales.*,
		rank() over(partition by store_id order by total_amount desc) as amount_rank,
		dense_rank() over(partition by store_id order by total_amount desc) as amount_dense
	from sales
	order by store_id, sale_id
	) s
where s.amount_rank != s.amount_dense; -- різниці немає, бо у магазинів немає однакових продажів у різнні дні

-- Завдання 4.4
select 
	sales.*,
	ntile(2) over(partition by store_id order by total_amount desc) as half
from sales;

-- Завдання 4.5
select 
	sales.*,
	dense_rank() over(partition by sale_date order by total_amount desc) as date_rank
from sales;

-- Завдання 4.6
select 
	sales.*,
	dense_rank() over(partition by product_id order by sale_date) as product_rank
from sales;

-- Завдання 5.1
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount)  over w as previous_sale_amount
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 5.2
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount)  over w as previous_sale_amount,
    lead(total_amount) over w as next_sale_amount
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 5.3
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount)  over w as previous_sale_amount,
    lead(total_amount) over w as next_sale_amount,
    (total_amount - lag(total_amount)  over w) as diff_prev
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 5.4
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount, 1, 0)  over w as previous_sale_amount,
    coalesce(lag(total_amount, 1, 0)  over w, 0) as previous_sale_amount_,
    lead(total_amount) over w as next_sale_amount,
    (total_amount - lag(total_amount)  over w) as diff_prev
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 5.5
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount)  over w as previous_sale_amount,
    lead(total_amount) over w as next_sale_amount,
    (total_amount - lag(total_amount)  over w) as diff_prev,
    lag(total_amount, 2)  over w as two_sales_ago
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 5.6
select 
	sale_id, 
	store_id,
	sale_date,
	total_amount,
    lag(total_amount)  over w as previous_sale_amount,
    (total_amount - lag(total_amount) over w) as diff_prev,
    case 
    	when lag(total_amount) over w is NULL then 'перший продаж'
    	when (total_amount - lag(total_amount) over w) < 0 then 'падіння' 
    	when (total_amount - lag(total_amount) over w) > 0 then 'зростання'
    	else 'без змін'
    end as trend 
from sales
window w as (partition by store_id order by sale_date, sale_id);

-- Завдання 6.1
select 
	sales.*,
	sum(total_amount) over (partition by store_id order by sale_date, sale_id) as cumulative_store_sales
from sales;

-- Завдання 6.2
select 
	sales.*,
	sum(quantity_sold) over (partition by store_id order by sale_date, sale_id) as cumulative_qty
from sales;

-- Завдання 6.3
select 
	sales.*,
	avg(total_amount) over (partition by store_id order by sale_date, sale_id
							rows between 2 preceding and current row) as moving_avg_3rows
from sales;

-- Завдання 6.4
select 
	s.*
from (
	select 
		sales.*,
		avg(total_amount) over (partition by store_id order by sale_date, sale_id
								rows between 2 preceding and current row) as moving_avg_3rows,
		avg(total_amount) over (partition by store_id order by sale_date
								range between interval '2 days'  preceding and current row) as moving_avg_3days
	from sales
	) s
where s.moving_avg_3days != s.moving_avg_3rows;

-- Завдання 6.5
select 
	sales.*,
	max(total_amount) over (partition by store_id order by sale_date, sale_id
							rows between unbounded preceding and current row) as running_max
from sales;

-- Завдання 7.1
select 
	stock_prices.*,
	lag(closing_price) over(partition by stock_symbol order by price_date
						range between interval '1 day' preceding and current row) as yesterday_price,
	lead(closing_price) over(partition by stock_symbol order by price_date
						range between interval '1 day' preceding and current row) as tomorrow_price				
from stock_prices;

-- Завдання 7.2
select 
	stock_prices.*,
	closing_price - lag(closing_price) over(partition by stock_symbol order by price_date
						range between interval '1 day' preceding and current row) as price_delta			
from stock_prices;

-- Завдання 7.3
select 
	stock_prices.*,
	round((closing_price - lag(closing_price) over(partition by stock_symbol order by price_date
						range between interval '1 day' preceding and current row)) / closing_price * 100, 2) as price_delta			
from stock_prices;

-- Завдання 7.4
select 
	stock_prices.*,
	first_value(closing_price) over(partition by stock_symbol order by price_date
						range between unbounded preceding and current row) as first_price,
	(closing_price - first_value(closing_price) over(partition by stock_symbol order by price_date
						range between unbounded preceding and current row)) / closing_price * 100 as growth_from_start_pct
from stock_prices;

-- Завдання 7.5
select 
	stock_prices.*,
	max(closing_price) over(partition by stock_symbol 
						range between unbounded preceding and current row) as max_price,
	(closing_price - max(closing_price) over(partition by stock_symbol 
						range between unbounded preceding and current row)) as diff_from_max
from stock_prices;

-- Завдання 7.6
with d as (
    select stock_symbol, price_date, closing_price,
           closing_price - lag(closing_price)
               over (partition by stock_symbol order by price_date) as price_delta
    from stock_prices
)
select stock_symbol, price_date, closing_price, price_delta,
       sum(coalesce(price_delta, 0))
           over (partition by stock_symbol order by price_date) as cumulative_change
from d;

-- Завдання 7.7
with d as (
    select stock_symbol, price_date, closing_price,
           closing_price - lag(closing_price)
               over (partition by stock_symbol order by price_date) as price_delta
    from stock_prices
)
select stock_symbol, price_date, closing_price, price_delta,
        case when price_delta > 0
        	 	and lag(price_delta)
               over (partition by stock_symbol order by price_date) > 0
             	and  lag(price_delta, 2)
               over (partition by stock_symbol order by price_date) > 0
             then 'так'
             else 'ні'
			 end as three_day_growth       
from d;

-- Завдання 8.1
select 
	store_id,
	sale_id,
	sale_date,
	total_amount
from (
    select sales.*,
           row_number() over (partition by store_id
                              order by total_amount desc, sale_id) as rn
    from sales
) t
where rn = 1;

-- Завдання 8.2
with cte_1 as (
select distinct
	store_id,
	first_value(sale_date) over (partition by store_id order by sale_date, sale_id) as first_sale_date,                         
    last_value(sale_date) over (partition by store_id  order by sale_date, sale_id
                             rows between unbounded preceding and unbounded following) as last_sale_date                        
from sales
),
cte_2 as (
select
	cte_1.*,
	s.total_amount
from cte_1
left join sales s on s.store_id = cte_1.store_id and s.sale_date  = cte_1.first_sale_date
union all
select
	cte_1.*,
	s.total_amount
from cte_1
left join sales s on s.store_id = cte_1.store_id and s.sale_date  = cte_1.last_sale_date
)
select 
	store_id,
	first_sale_date,
	last_sale_date,
	sum(total_amount) as days_between
from cte_2
group by 
	store_id,
	first_sale_date,
	last_sale_date
order by store_id;

-- Завдання 8.3
select 
	product_id,
	sum(total_amount) as product_total,
	dense_rank() over(order by sum(total_amount) desc) as product_rank
from sales
group by product_id;

