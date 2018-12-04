-- Use sakila DB
USE sakila;

-- 1a. Display first and last name of actor
SELECT first_name, last_name
FROM actor;

-- 1b. Display first and last name in one column in upper case
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. Display ID number and last name of actor with name of Joe
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Display actors with last name containing gen
SELECT *
FROM actor
WHERE last_name LIKE '%gen%';

-- 2c. Display actors with last nam containg li ordered by last name then first name
SELECT *
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

-- 2d. Display country id and country of Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create column in actor named description
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Delete the description column
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List last names and the number of each
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b. List last names and counts of each where at least 2
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. Change HARPO WILLIAMS to GROUCHO WILLIAMS
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name LIKE 'HARPO' AND last_name LIKE 'WILLIAMS';

-- 4d. Change GROUCHO back to HARPO
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- 5a. Show schema for address table
SHOW CREATE TABLE address;

-- 6a. Display first name, last name, address from staff and address
SELECT staff.first_name AS 'First Name', 
               staff.last_name AS 'Last Name',
               address.address AS 'Address'
FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b. Show total amount rung up by each staff member using staff and payment
SELECT staff.first_name AS 'First Name', 
               staff.last_name AS 'Last Name',
               SUM(payment.amount) AS 'Total Exchanges'
FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY 1, 2;

-- 6c. List each film and number of actors on the film using film_actor and film
SELECT film.title AS 'Title' , COUNT(film_actor.actor_id) AS '# of Actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. Display number of copies of Hunchback Impossible are in inventory
SELECT COUNT(*) AS 'Hunchback Impossible in Inventory'
FROM inventory
WHERE film_id = (
	SELECT film_id
	FROM film
	WHERE title LIKE 'Hunchback Impossible'
);

-- 6e. List total paid by customer (listed alphebetically) using payment and customer
SELECT customer.first_name AS 'First Name',
               customer.last_name AS 'Last Name',
               SUM(payment.amount) AS 'Total Amount Paid'
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name;

-- 7a. Display english films whose titles start with k or q
SELECT title
FROM film
WHERE title LIKE 'K%' 
		OR title LIKE 'Q%'
        AND language_id = (
			     SELECT language_id
                 FROM language
                 WHERE name LIKE 'English'
);

-- 7b. Display all actors who appear in Alone Trip
SELECT 	first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
	FROM film_actor
	WHERE film_id = (
        SELECT film_id
        FROM film
        WHERE title LIKE 'Alone Trip'
));

-- 7c. Display all Canadian customers names and emails
SELECT customer.first_name AS 'First Name', 
               customer.last_name AS 'Last Name',
               customer.email AS 'Email'
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country LIKE 'Canada';

-- 7d. Display all films categorized as family
SELECT film.title AS 'Family Film'
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name LIKE 'Family';

-- 7e. Display most frequently rented movies in descending order
SELECT film.title AS 'Title', 
               COUNT(rental.inventory_id) AS 'Number of Rentals'
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY 2 DESC;

-- 7f. Display income by store
SELECT store.store_id AS 'Store ID',
               SUM(payment.amount) AS 'Income'
FROM store
JOIN inventory ON store.store_id = inventory.store_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY 1;

-- 7g. Display Store ID, City and Country of each store
SELECT store.store_id AS 'Store ID',
               city.city AS 'City',
               country.country AS 'Country'
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

-- 7h. Display top 5 genres by revenue in descending order
SELECT category.name AS 'Genre',
               SUM(payment.amount) AS 'Revenue'
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; 

-- 8a. Create a view of 7h
CREATE VIEW top_five_genre
AS
SELECT category.name AS 'Genre',
               SUM(payment.amount) AS 'Revenue'
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; 

-- 8b. Display view
SELECT *
from top_five_genre;

-- 8c. Delete view
DROP VIEW top_five_genre;