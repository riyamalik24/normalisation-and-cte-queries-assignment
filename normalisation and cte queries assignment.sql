use mavenmovies;
 --In the sakila database, there is no table that directly violates the first normal form. However if a table might violoate 1NF and to normalize 
it nad achieve 1NF we need to ensure that each column holds atomic values. This can be done by splitting the numbers into seperate table and
establishing a one to many relationship between the different tables.






--Table rental is in 2NF
the rental table from sakila contains following key columns : rental_id, rental_date, inventory_id, customer_id, staff_id and return_date
to determine whether the table is in 2NF:
1) first normal form
* the table has a primary key and all values are atomic
* the rental table meets first normal form since each column holds atomic values, and rental id is the primary key
2) second normal form
* to be in 2NF, the table must be in 1NF and all non-key attributes must depend on whole primary key
* in the rental table, columns like rental_date, inventory_id and customer_id directly depend on rental_id, whcih is the orimary key

 Normalization (if it violates 2NF):
If there were partial dependencies (e.g., if rental_date depended only on inventory_id), we would:

Identify the partially dependent columns.
Create a new table for those columns, ensuring each functional dependency is represented correctly.
Since the rental table does not have partial dependencies, it is already in 2NF.

This is how we would verify and normalize the table if needed








--Table: film is in 3NF
the film table contains columns such as film_id, title, description, release_year, language_id, rental_duration, rental_date, length,
replacement_cost, rating, and speciall features

Violation of 3NF: 
In 3NF, a table must be in 2NF, and all non-key attributes should depend only on the primary key, with no transitive dependencies 
The film table violates 3NF due to transcriptive dependency between language_id and other language-related attributes like language.name.
Here, language_id is a foreign key but language.name depends on language_id, not directly on primary key film_id.

Steps to normalize to 3NF:
1) identify the transitive dependencies:
  language_id --> language.name (because language.name depends on language_id not film_id)
2) create an new table
 * move language_id and language.name to a new table named language.
 * the new language table would include:
   language_id (primary key)
   name
3) update film table
   retain language_id as a foreign key in the film table, but remove language.name
   This normalization removes the transitive dependency, ensuring the table is in 3NF.
   
   
   
   
   
   
   
   
   
--we will take table "payment" and normalize it from unormalized form to 2NF
table : payment 
the actual payment table contains columns: payment_id, customer_id, staff_id, rental_id, amount and payment_date.
step 1: unormalized form(UNF)
--In an unnormalized form, the data might look like this;
use mavenmovies;
select * from payment;
In this, The payment_date column contains multiple values, which violates the rule of atomicity.
Step 2: Convert to 1NF (First Normal Form)
To bring the table into 1NF, we ensure each column has only atomic values:
for this, we have to split payment_date row into seprate rows to ensure atomic values.
Step 3: Second Normal Form (2NF)
To achieve 2NF, the table must:
Be in 1NF.
Have no partial dependencies, meaning all non-key attributes should depend on the whole primary key.
n this case, payment_id is the primary key. Since all the non-key columns depend only on payment_id and not on part of a composite key,
 there are no partial dependencies in the current structure.

Final Outcome:
The payment table is already in 2NF because:
It is in 1NF (atomic values, no repeating groups).
All non-key attributes fully depend on the primary key payment_id.

Therefore, the payment table does not violate 2NF, and no further normalization is needed for 2NF.
This is how we would normalize the payment table from unnormalized form to at least 2NF;








WITH ActorFilmCount AS (
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name )

SELECT DISTINCT first_name, last_name, film_count FROM ActorFilmCount ORDER BY film_count DESC;








   
   In the Sakila database, there is no explicit hierarchy in the category table, that is there are no subcategories within categories;
   
   

   
   
   
   
   
   
 WITH FilmLanguageInfo AS (
SELECT 
	f.title, 
	l.name AS language_name, 
	f.rental_rate FROM film f
    JOIN language l ON f.language_id = l.language_id
)
-- Final selection from the CTE
SELECT title, language_name, rental_rate FROM FilmLanguageInfo ORDER BY title;








WITH CustomerRevenue AS (
SELECT 
    c.customer_id, 
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
	SUM(p.amount) AS total_revenue
FROM customer c JOIN payment p ON c.customer_id = p.customer_id GROUP BY c.customer_id, customer_name
)
-- Final selection from the CTE
SELECT customer_id, customer_name, total_revenue FROM CustomerRevenue ORDER BY total_revenue DESC;








WITH FilmRanked AS (
SELECT film_id, title, rental_duration,
RANK() OVER (ORDER BY rental_duration DESC) AS rental_duration_rank FROM film
)
-- Final selection from the CTE
SELECT film_id, title, rental_duration, rental_duration_rank FROM FilmRanked ORDER BY rental_duration_rank;








WITH FrequentRenters AS (
SELECT r.customer_id, COUNT(r.rental_id) AS rental_count
FROM rental r GROUP BY r.customer_id HAVING COUNT(r.rental_id) > 2
)
-- Joining the CTE with the customer table to get additional details
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email, c.active, c.create_date, fr.rental_count
FROM FrequentRenters fr JOIN customer c ON fr.customer_id = c.customer_id
ORDER BY fr.rental_count DESC;







WITH MonthlyRentals AS (
    SELECT 
	DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, -- Extract year and month
	COUNT(rental_id) AS total_rentals
    FROM rental GROUP BY rental_month )
-- Final selection from the CTE
SELECT rental_month, total_rentals FROM MonthlyRentals ORDER BY rental_month;







WITH CustomerPayments AS (SELECT customer_id, SUM(amount) AS total_amount
FROM payment GROUP BY customer_id )
-- Display the total payments made by each customer
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
COALESCE(cp.total_amount, 0) AS total_payments FROM customer c
LEFT JOIN CustomerPayments cp ON c.customer_id = cp.customer_id
ORDER BY c.customer_id;








WITH ActorPairs AS (SELECT  fa1.actor_id AS actor1_id, fa2.actor_id AS actor2_id, fa1.film_id
FROM film_actor fa1 JOIN film_actor fa2 ON fa1.film_id = fa2.film_id
 AND fa1.actor_id < fa2.actor_id )
-- Final selection from the CTE
SELECT 
a1.first_name AS actor1_first_name,
a1.last_name AS actor1_last_name,
a2.first_name AS actor2_first_name,
a2.last_name AS actor2_last_name,
COUNT(ap.film_id) AS shared_films
FROM ActorPairs ap JOIN actor a1 ON ap.actor1_id = a1.actor_id
JOIN actor a2 ON ap.actor2_id = a2.actor_id
GROUP BY a1.first_name, a1.last_name, a2.first_name, a2.last_name ORDER BY shared_films DESC;

























  
   
   
   
   


