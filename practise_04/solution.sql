-- Завдання 1.3
SELECT 'products' AS t, COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'customer_data', COUNT(*) FROM customer_data
UNION ALL SELECT 'product_catalog', COUNT(*) FROM product_catalog
UNION ALL SELECT 'products_with_categories', COUNT(*) FROM products_with_categories;

-- Завдання 2.1
select name,
	price,
	ceil(price) as price_ceil,
	round(cast(sqrt(price) as numeric), 2) as price_sqrt
from products 
order by id;

-- Завдання 2.2
select name,
	price,
	mod(price, 1000) as price_rest
from products
order by id;

-- Завдання 2.3
select name,
	coalesce(discount, 0) as discount,
	case 
		when coalesce(discount, 0) < 0.07 then 'Мінімальна'
		when coalesce(discount, 0) between 0.07 and 0.12 then 'Середня'
		else 'Висока' 
	end as discount_level
from products
order by id;

-- Завдання 2.4
select name,
	(price * coalesce(discount, 0)) as money_discount,
	greatest((price * coalesce(discount, 0)), 1000) as max_discount
from products
order by id;

-- Завдання 2.5
select name,
	price,
	least(price, 18000) as capped_price
from products
order by id;

-- Завдання 3.1
select count(id) as orders_count,
	sum(total_amount) as total_sales,
	round(avg(total_amount), 2) as avg_amount,
	min(total_amount) as min_amount,
	max(total_amount) as max_amount 
from orders;

-- Завдання 3.2
select region,
	count(id) as orders_count,
	sum(total_amount) as total_sales,
	round(avg(total_amount), 2) as avg_amount
from orders
group by region
order by total_sales desc;

-- Завдання 3.3
select customer_id,
	count(id) as orders_count,
	sum(total_amount) as total_spent
from orders
group by customer_id
having count(id) > 1
order by customer_id;

-- Завдання 3.4
select customer_id,
	count(distinct region) as regions_count,
	string_agg(distinct region, ',' order by region) as regions
from orders
group by customer_id
having count(distinct region) > 1;

-- Завдання 3.5
select region,
	round(avg(total_amount), 2) as avg_amount,
	round(stddev(total_amount), 2) as stddev_amount,
	round(variance(total_amount), 2) as variance_amount
from orders
group by region
order by region;

-- Завдання 4.1
select id,
	first_name,
	last_name,
	lower(concat(left(last_name, 3), left(first_name, 3), id::text)) as login
from employees
order by id;

-- Завдання 4.2
select id,
	first_name,
	last_name,
	length(bio) as bio_length,
	concat(left(bio, 50), '...') as bio_short
from employees
where length(bio) > 50
order by id;

-- Завдання 4.3
select id,
	department,
	case 
		when (left(department, 1) = ' ' or right(department, 1) = ' ') then trim(department)
		else ''
	end as department_trimmed,	
	bio,
	case 
		when (left(bio, 1) = ' ' or right(bio, 1) = ' ') then trim(bio)
		else ''
	end as bio_trimmed
from employees
where (left(department, 1) = ' ' or right(department, 1) = ' ' or left(bio, 1) = ' ' or right(bio, 1) = ' ')
order by id;

-- Завдання 4.4
select split_part(email, '@', 2) as domain
from employees
order by id;

-- Завдання 4.5
INSERT INTO employees (first_name, last_name, email, bio, department)
VALUES ('Софія', 'Кравчук Мельник', 'sofiia.kravchuk@example.com',
        'Аналітик даних', 'IT');
select id,
	first_name,
	last_name
from employees
where position(' ' in last_name ) != 0
order by id;

-- Завдання 4.6
select department,
	string_agg(bio, ';') as bios
from employees
group by department
order by department;

-- Завдання 4.7
select case 
		 when length(id::text) < 5 then lpad(id::text, (5 - length(id::text)), '*')
		 else id::text
	   end as padded_id,
	first_name,
	last_name
from employees
order by id;

-- Завдання 5.1
select event_name,
	round(extract (epoch from end_date - start_date) / 3600, 1) as duration_hours,
	round(extract (epoch from end_date - start_date) / 86400, 2) as duration_days
from events
order by id;

-- Завдання 5.2
select 
	event_name,
	to_char(start_date, 'FMDD.MM.YYYY HH24:MI') as start_formatted,
	to_char(end_date, 'FMMonth DD, YYYY') as end_formatted
from events
order by id;

-- Завдання 5.3
select event_name,
	start_date,
	case 
		when start_date < now() then 'Минуле'
		else 'Майбутнє'
	end as status	
from events
order by id;

-- Завдання 5.4
select event_name,
	registration_deadline,
	start_date,
	extract (epoch from start_date - registration_deadline) / 86400 as days_before_start
from events
where extract (epoch from start_date - registration_deadline) / 86400 < 7
order by id;

-- Завдання 5.5
select event_name,
	case 
		when to_char(start_date, 'D') = '2' then 'Понеділок'
		when to_char(start_date, 'D') = '3' then 'Вівторок'
		when to_char(start_date, 'D') = '4' then 'Середа'
		when to_char(start_date, 'D') = '5' then 'Четвер'
		when to_char(start_date, 'D') = '6' then 'П`ятниця'
		when to_char(start_date, 'D') = '7' then 'Субота'
		else 'Неділя'
	end as weekday
from events
order by id;

-- Завдання 5.6
select event_name,
	start_date,
	start_date - interval '3 days' as reminder_date
from events
order by id;

-- Завдання 5.7
select event_name,
	extract(year from start_date) as event_year,
	extract(month from start_date) as event_month,
	extract(quarter from start_date) as event_quarter
from events
order by id;

-- Завдання 6.1
select 
	name,
	case 
		when (email is NULL and phone is NULL) then 'Контактні дані відсутні'
		when (email is not NULL and phone is NULL) then 'Є email'
		when (email is NULL and phone is not NULL) then 'Є телефон'
		else 'Є обидва'
	end as contact_status	
from customer_data
order by id;

-- Завдання 6.2
select name,
	coalesce(email, 'Немає email') as email,
	coalesce(phone, 'Немає телефону') as phone,
	coalesce(address, 'Адреса не вказана') as address,
	coalesce(total_purchases, 0) as total_purchases,
	coalesce(to_char(last_purchase_date, 'DD.MM.YYYY'), 'Немає покупок') as last_purchase_date
from customer_data
order by id;


-- Завдання 6.3
select id,
	name,
	total_purchases
from customer_data
where (total_purchases = 0 or total_purchases is NULL)
order by id;

-- Завдання 6.4
select id,
	name
from customer_data
where (email is NULL and phone is NULL)
order by id;

-- Завдання 6.5
select 
	count(id) as total,
	count(email) as with_email,
	count(phone) as with_phone,
	count(address) as with_address,
	sum(case when length(concat(email, phone, address)) > 0 then 0 else 1 end) as with_nothing
from customer_data;

-- Завдання 7.1
select name,
	attributes -> 'brand' as brand,
	coalesce(attributes -> 'specs' -> 'memory' ->> 'ram', 'Не вказано') as ram
from product_catalog
order by id;

-- Завдання 7.2
select name,
	attributes -> 'specs' ? 'battery' as battery
from product_catalog
where attributes -> 'specs' ? 'battery' = TRUE
order by id;

-- Завдання 7.3
select name,
	tags ?| array['gaming', 'wearables', 'audio'] as tags
from product_catalog
where tags ?| array['gaming', 'wearables', 'audio'] = TRUE
order by id;

-- Завдання 7.4
select sum(case when attributes -> 'specs' ? 'screen' = TRUE then 1 else 0 end) as with_screen,
	sum(case when attributes -> 'specs' ? 'battery' = TRUE then 1 else 0 end) as with_battery,
	sum(case when attributes -> 'specs' ? 'gps' = TRUE then 1 else 0 end) as with_gps,
	sum(case when attributes -> 'specs' ?| array['screen', 'battery', 'gps'] = TRUE then 1 else 0 end) as with_any
from product_catalog;

-- Завдання 7.5
select name,
	a.key as attr_key,
	a.value as attr_value
from product_catalog,
jsonb_each(attributes) as a
order by id;

-- Завдання 7.6
select jsonb_object_agg(
	t.brand,
	t.names)
from (
	 select attributes ->> 'brand' as brand, 
	 jsonb_agg(attributes ->> 'model' order by attributes ->> 'model') as names
	 from product_catalog
	 group by attributes->>'brand'
	) as t;

-- Завдання 7.7
update  product_catalog
set attributes = jsonb_set(
	attributes,
	'{specs, warranty}',
	'"1 рік"',
	TRUE
)
where attributes -> 'specs' -> 'warranty' is NULL
		
select name,
	attributes -> 'specs' -> 'warranty' as warranty 
from product_catalog;

-- Завдання 8.1
select array_to_string(
	(select array (
		select name
		from products_with_categories
		order by id)),
	','
);

-- Завдання 8.2
select 
	name,
	categories,
	array_length(categories, 1) as categories_count
from products_with_categories
where array_length(categories, 1) > 2
order by id;

-- Завдання 8.3
select name,
	categories
from products_with_categories
where categories && array['Гаджети', 'Ноутбуки', 'Аудіо'] 
order by id;

-- Завдання 8.4
select name,
	unnest(specifications) as specification
from products_with_categories
order by id;

-- Завдання 8.5
select s.name,
	count(s.specification) as numeric_specs_count
from (
	select name,
		unnest(specifications) specification
	from products_with_categories
	) s
where s.specification ~'[0-9]'
group by s.name;

-- Завдання 8.6
select 
	c.category,
	count(c.category) as products_count,
	sum(price) as total_price
from (
	select 
		unnest(categories) as category,
		price
	from products_with_categories
	) c
group by c.category
order by total_price  desc;

-- Завдання 8.7
update products_with_categories
set categories = array_append(categories, 'Топ-продаж')
where  not categories @> array['Топ-продаж']

select name,
	categories
from products_with_categories
where categories @> array['Топ-продаж'];

	