use miniprojectsql2;
show tables;
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;
#1. Join all the tables and create a new table called combined_table.
#(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
create table combined_table as
select Customer_Name,Province,Region,Customer_Segment, m.Cust_id,m.Ord_id,m.Prod_id,m.Ship_id,Sales,Discount,
Order_Quantity,Profit,Shipping_Cost,Product_Base_Margin,o.Order_ID,order_date,Order_Priority,Product_Category,
Product_Sub_Category,Ship_Mode,ship_date from cust_dimen c 
left join market_fact m on m.Cust_id=c.Cust_id left join orders_dimen o on m.Ord_id=o.Ord_id 
left join prod_dimen p on p.Prod_id=m.Prod_id left join shipping_dimen s on s.Ship_id=m.Ship_id; 
##2. Find the top 3 customers who have the maximum number of orders
 with t as
 (select *,row_number()over(partition by cust_id order by order_quantity desc)  roww  from combined_table)
 select cust_id ,customer_name,region,customer_segment, order_quantity from t where roww=1 order by order_quantity desc limit 3;
 #3. Create a new column DaysTakenForDelivery that contains the date difference 
#of Order_Date and Ship_Date.
select *,datediff(ship_date,order_date) daytakenfordelivery from combined_table;
#4. Find the customer whose order took the maximum time to get delivered.
select cust_id,customer_name,region,customer_segment,datediff(ship_date,order_date) daytakenfordelivery from combined_table order by daytakenfordelivery desc limit 1;
#5. Retrieve total sales made by each product from the data (use Windows 
#function)
select distinct * from
(select prod_id,product_category,product_sub_category,sum(sales)over(partition by prod_id ) totalsales from combined_table  order by totalsales desc)t;
#6. Retrieve total profit made from each product from the data (use windows 
#function)
select distinct * from
(select prod_id,product_category,product_sub_category,sum(profit)over(partition by prod_id ) totalprofit from combined_table  order by totalprofit desc)t;
#7. Count the total number of unique customers in January and how many of them
#came back every month over the entire year in 2011 
#unique customer in jan
(select distinct cust_id,customer_name , count(order_date)over(partition by cust_id) jancustomerno from 
combined_table where date_format(order_date,"%M")='january' order by jancustomerno desc );
# number of customer come back in every month of 2011
with nt as
(select distinct cust_id,customer_name , count(order_date)over(partition by cust_id) jancustomerno from 
combined_table where date_format(order_date,"%M")='january' order by jancustomerno desc )
select * from nt where cust_id in (select cust_id from combined_table where date_format(order_date ,"%Y")=2011)
and cust_id in ( select  cust_id from combined_table where date_format(order_date,"%m") in (1 and 2 and 3 and 4 and 5 and 6and 7and 8and 9 and 10and 11and 12));
select cust_id,count(cust_id) from combined_table 
where date_format(order_date,"%m") =all (1,2, 3 ,4 , 5 ,6,7,8,9,10,11,12) ;
 select  cust_id from combined_table where  ( date_format(order_date,"%m")=1 and  date_format(order_date,"%m")=2) and  date_format(order_date,"%m")=3;# and  date_format(order_date,"%m")=4 and date_format(order_date,"%m")= 5 and  date_format(order_date,"%m")= 6and  date_format(order_date,"%m")=7and  date_format(order_date,"%m")= 8 and  date_format(order_date,"%m")=9 and  date_format(order_date,"%m")=10 and  date_format(order_date,"%m")=11 and  date_format(order_date,"%m")= 12);

#8. Retrieve month-by-month customer retention rate since the start of the 
#business.(using views)
create view  v1 as
select *  from 
(select Customer_Name,cust_id,order_date,lead(order_date)over(partition by cust_id order by cust_id) t ,monthname(order_date) mn ,
count(cust_id)over(partition by cust_id)from combined_table)a where month(t)-month(order_date )=1 order by mn;
select * from v;