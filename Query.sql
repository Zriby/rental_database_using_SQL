

/*
Question 1
We want to understand more about the movies that families are watching. 
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
EDIT:Create a query that lists the amount of movies rented for each film category it is classified in.
*/


/*Query 1 */
WITH t1 AS(
SELECT f.title title, c.name name_1, COUNT(r.rental_id) count_1
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r 
ON r.inventory_id = i.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY 2, 1
)

SELECT t1.name_1,SUM(count_1) Total_rented
FROM t1
GROUP BY 1
ORDER BY 1



/*
Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. 
EDIT:Find the rental duration of each movie category and its movie count.
*/

/*QUERY 2 */
WITH t1 AS
(
SELECT f.title title, c.name name1, f.rental_duration rental_duration,
NTILE(4) OVER (ORDER BY f.rental_duration) AS quartile
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 2
)
SELECT t1.name1 ,t1.rental_duration,COUNT(t1.title) movie_count
FROM t1
GROUP BY 1,2
ORDER BY 1,3 DESC

/*For presentation using excel go to:
Select your csv table > Insert > Pivot Table
Tick all the boxes under field name
Legend(series) has rental duration
axis has name1
values has SUM of number of movies rented (default)
*/



/*
Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, 
and the corresponding count of movies within each combination of film category for each corresponding rental duration category.
The resulting table should have three columns: Category, Rental length category,Count
*/

/* QUERY 3 */
WITH t1 AS 
(SELECT f.title, c.name AS name, f.rental_duration,
NTILE(4) OVER (ORDER BY f.rental_duration) AS quartile
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))
SELECT name,quartile,COUNT(quartile)
FROM t1
GROUP BY 1,2
ORDER BY 1,2





/*
Question 4
Edit:Show the top 10 paying customers and the highest differences across their monthly payment in 2017. 
The difference of payment will be in absoloute value! so negative sign differences are included as well.
So if a customer has a difference of 50 and -60, the highest difference is 60.
Order by name .
*/


/*QUERY 4 */
WITH t1 AS(
SELECT CONCAT(first_name,' ',last_name) fullname,DATE_TRUNC('month',p.payment_date) pay_month,p.amount pay_amount1
FROM customer c
JOIN payment p
ON p.customer_id=c.customer_id
),

t2 AS(
SELECT pay_month,fullname,COUNT(pay_month) pay_countpermon,SUM(pay_amount1) pay_amount /*COUNT(pay_month) is how much payment was done in that month*/
FROM t1
GROUP BY 1,2
ORDER BY 1
),

t3 AS(
SELECT t2.fullname fname10, SUM(t2.pay_amount) total
FROM t2
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
),

t4 AS(
SELECT DISTINCT t2.pay_month pay_mon,t3.fname10 fullname,t2.pay_countpermon,t2.pay_amount pay_amount
FROM t3
JOIN t2
ON t3.fname10 = t2.fullname 
/*
in case you want to join t1 with the rest
JOIN t1
ON t2.fullname=t1.fullname
*/
ORDER BY 2,1
),

t5 AS(
SELECT t4.*,
LEAD(t4.pay_amount) OVER(PARTITION BY t4.fullname ORDER BY t4.pay_mon) AS lead,
LEAD(t4.pay_amount) OVER(PARTITION BY t4.fullname ORDER BY t4.pay_mon) - t4.pay_amount AS difference,
ABS(LEAD(t4.pay_amount) OVER(PARTITION BY t4.fullname ORDER BY t4.pay_mon) - t4.pay_amount) AS abs_difference
FROM t4
)

SELECT t5.fullname,MAX(abs_difference) max_per_person
FROM t5
GROUP BY 1
ORDER BY 1




