CREATE DATABASE Foodpanda;
USE Foodpanda;

DROP TABLE Orders1;

CREATE TABLE Orders(rdbms_id INT(3),
					country_name VARCHAR(100),
                    date_local DATETIME,
                    vendor_id INT(10),
                    customer_id INT(10),
                    gmv_local Double,
                    is_voucher_used CHAR(10),
                    is_successful_order CHAR(10)
                    );
SELECT * FROM Orders;

#table orders2
CREATE TABLE Orders1(rdbms_id INT(3),
					country_name VARCHAR(100),
                    date_local timestamp,
                    vendor_id INT(10),
                    customer_id INT(10),
                    gmv_local Double,
                    is_voucher_used CHAR(10),
                    is_successful_order CHAR(10)
                    );



# DROP TABLE Vendors;

CREATE TABLE Vendors( vendor_id INT(10),
					  rdbms_id INT(3),
                      country_name VARCHAR(100),
                      is_active CHAR(10),
                      vendor_name VARCHAR(100),
                      budget INT(3),
                      chain_id CHAR(10) DEFAULT NULL
                      );

SELECT * FROM Vendors;

# Query 1 : List all the orders that were made in Taiwan

select * from Orders where country_name = 'Taiwan';

# Query 2 : Find the Total GMV by country

select country_name, round(SUM(gmv_local),2) as total_gmv from Orders group by country_name;

# Query 3 : Find the top active vendor by GMV in each country
#step-1:
select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id;

select country_name, vendor_id, max(gmv_local) from Orders group by country_name;

#step-2:
select country_name, vendor_id, max(A.total_gmv) as total_gmv from 
		(select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id) as A
					 group by country_name;
                     
-- new one
select country_name, max(A.total_gmv) as total_gmv from 
		(select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id) as A
					 group by country_name;
                     
-- next step
select D.country_name, E.vendor_id, D.total_gmv from
					(
                    select country_name, max(A.total_gmv) as total_gmv from 
		(select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id) as A
					 group by country_name
                    ) as D, 
                    (
                    select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id
                    ) as E
                    where E.total_gmv = D.total_gmv;

                     
#step-3
#Final Query
select B.country_name, ven.vendor_name, B.total_gmv from
				(
                select D.country_name, E.vendor_id, D.total_gmv from
					(
                    select country_name, max(A.total_gmv) as total_gmv from 
		(select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id) as A
					 group by country_name
                    ) as D, 
                    (
                    select country_name, vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders group by vendor_id
                    ) as E
                    where E.total_gmv = D.total_gmv
                ) as B, Vendors ven
                where B.vendor_id = ven.vendor_id
                order by B.country_name;
                
                
#Query 4: Find the top 2 vendors per country, in each year available in the dataset

select * from Orders;
select * from Orders1;

# how to select only year:
select makedate(YEAR(date_local),1) from Orders;

#insert into new table
Insert into Orders1
select rdbms_id, country_name, makedate(YEAR(date_local),1), vendor_id, customer_id, gmv_local, is_voucher_used, is_successful_order
										from Orders;
                                        
#query
select * from Orders1 group by country_name order by gmv_local;

select country_name, date_local,vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders1 group by vendor_id,date_local;

-- my code


select Ft.date_local as year, Ft.country_name, Ft.vendor_name, Ft.total_gmv 
from
(
select A.country_name, A.date_local, vn.vendor_name, A.total_gmv ,
								ROW_NUMBER() OVER (PARTITION BY A.country_name, A.date_local
                              ORDER BY total_gmv DESC) max_count
			from 
			(
				select country_name, date_local,vendor_id, round(SUM(gmv_local),2) as total_gmv from Orders1 group by vendor_id,date_local
			) as A left join Vendors as vn ON A.vendor_id = vn.vendor_id
            group by A.date_local, A.vendor_id
            order by A.date_local asc, A.country_name asc,A.total_gmv desc
            
) as Ft
where Ft.max_count <= 2;
            
            
            
-- Join
SELECT Ord.date_local, Ord.country_name, vn.vendor_name, round(sum(Ord.gmv_local),2) as total_gmv FROM ORDERS as Ord
left join Vendors as vn
ON Ord.vendor_id = vn.vendor_id
GROUP BY Ord.country_name, vn.vendor_name
ORDER BY Ord.country_name, total_gmv desc;







