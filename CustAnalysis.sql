-- creating "goldusers_signup" table and inserting values

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'), (3,'2017-04-21');

-- creating "users" table and inserting values

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'), 
(2,'2015-01-15'), 
(3,'2014-04-11'); 


-- creating "sales" table and inserting values

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-18',2),
(3,'2019-12-18',1), 
(2,' 2019-12-18',3), 
(1,'2019-10-23',2), 
(1,'2018-03-19',3), 
(3,'2016-12-20',2), 
(1,'2016-11-09',1), 
(1,'2016-05-20',3), 
(2,'2017-09-24',1), 
(1,'2017-03-11',2), 
(1,'2016-03-11',1), 
(3,'2016-11-10',1), 
(3,'2017-12-07',2), 
(3,'2016-12-15',2), 
(2,'2017-11-08',2), 
(2,'2018-09-10',3); 


-- creating "product" table and inserting values

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

-- Reviewing tables

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1 ---- what is total amount each customer spent on zomato ?

select s.userid, sum(price)
from sales as s
inner join product as p
on p.product_id = s.product_id
group by s.userid
order by userid


2 ---- How many days has each customer visited zomato?

select userid, count(distinct created_date) as num_of_days
from sales
group by userid


3 --- what was the first product purchased by each customer?

select userid, product_name
from (select *, rank() over(partition by userid order by created_date) as rankk
from sales as s
inner join product as p
on s.product_id = p.product_id) as a
where a.rankk = 1


4 -- what is most purchased item on menu & how many times was it purchased by all customers ?

select userid, count(product_id)
from sales
where product_id = (select product_id
from sales
group by product_id
order by count(product_id) DESC
limit 1)
group by userid


5 ---- which item was most popular for each customer?


with tb as (select userid,product_id,  count(product_id) as cnt,
dense_rank() over(partition by userid order by count(product_id) desc) as dr
from sales
group by userid, product_id
order by userid)
select userid, product_id
from tb
where dr = 1


6 --- which item was purchased first by customer after they become a member ?

with tb as (select *, dense_rank() over(partition by s.userid order by created_date) as rk
from sales as s
inner join goldusers_signup as g
on s.userid = g.userid
where created_date>=gold_signup_date
)
select * 
from tb
where rk = 1


7 --- which item was purchased just before customer became a member?


with tb as (select *, rank() over(partition by s.userid order by created_date desc) as rk
from sales as s
inner join goldusers_signup as g
on s.userid = g.userid and created_date < gold_signup_date
)
select *
from tb
where rk = 1


8 ---- what is total orders and amount spent for each member before they become a member ?

select s.userid, count(s.product_id) as orders_purchased, sum(price) as total_amt
from sales as s
inner join goldusers_signup as g
on s.userid = g.userid and created_date < gold_signup_date
inner join product as p
on s.product_id = p.product_id
group by s.userid


9 --- rnk all transaction of the customers

select *, rank() over(partition by userid order by created_date) as transction
from sales


10 --- rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na

select *, 
case
when g.userid is null then null
else rank() over(partition by g.userid order by created_date desc)
end as transction
from sales as s
left join goldusers_signup as g
on s.userid = g.userid
