-- select database
use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
use sakila;
select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor;

-- 2a. Fidning the ID Number, first and last name of actors wherein the first name is "Joe"
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor_id, first_name, last_name
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
select actor_id, first_name, last_name
from actor
where last_name like '%LI%';
-- order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor.
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB(150) NULL AFTER `Actor_Name`;

-- 3b. Delete the 'description' column
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'LastNameCount'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as 'LastNameCount'
from actor
group by last_name
having LastNameCount >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
update actor
set first_name = 'HARPO'
where first_name='GROUCHO' and last_name='WILLIAMS';

-- 4d. In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name='WILLIAMS';

-- 5d. create the 'address' table 
describe address;
show create table sakila.address;

-- count the number of staff
select count(*) from staff;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select staff.first_name, staff.last_name, address.address
from staff left join address on staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'TOTAL'
FROM staff LEFT JOIN payment ON staff.staff_id = payment.staff_id and payment_date like '2005-08%'
GROUP BY staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select film.title, count(film_actor.actor_id) as 'Number of actors'
from film left join film_actor on film.film_id = film_actor.film_id
group by film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, COUNT(inventory_id)
FROM film 
INNER JOIN inventory 
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:

select last_name, first_name, SUM(amount)
from payment
inner join customer
on payment.customer_id = customer.customer_id
group by payment.customer_id
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title
from film
where (title like 'K%' or title like 'Q%')
and language_id=(select language_id from language where name='English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor 
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id from film where title='ALONE TRIP'));
        
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select first_name, last_name, email, active
from customer
join address on (customer.address_id = address.address_id)
join city on (address.city_id=city.city_id)
join country on (city.country_id = country.country_id) where (`country`.`country`='CANADA');

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT title, category
FROM film_list
WHERE category = 'Family';
 
 -- 7e. Display the most frequently rented movies in descending order.
 -- this query doesn't seem to recognize film.title but it is there so i'm not sure what is wrong
select `film`.`title`, inventory.film_id, count(rental.inventory_id)
from inventory
inner join rental
on inventory.inventory_id = rental.inventory_id
inner join film_text
on inventory.film_id=film.film_id
group by rental.inventory_id
order by count(rental.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(amount)
from store
inner join staff
on store.store_id = staff.store_id
inner join payment
on payment.staff_id = staff.staff_id
group by store_id
order by sum(amount);

use sakila;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
join address
on (store.address_id = address.address_id)
join city
on (city.city_id = address.city_id)
join country 
on (country.country_id = city.country_id);

-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name as 'GENRE', sum(payment.amount) as 'GROSS'
from category
join film_category
on (category.category_id = film_category.category_id)
join inventory
on (film_category.film_id = inventory.film_id)
join rental
on (inventory.inventory_id = rental.inventory_id)
join payment
on (rental.rental_id = payment.rental_id)
group by category.name order by Gross desc
limit 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view Genre_Gross as
select category.name as 'GENRE', sum(payment.amount) as 'GROSS'
from category
join film_category
on (category.category_id = film_category.category_id)
join inventory
on (film_category.film_id = inventory.film_id)
join rental
on (inventory.inventory_id = rental.inventory_id)
join payment
on (rental.rental_id = payment.rental_id)
group by category.name order by Gross desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * 
from genre_gross;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view `sakila`.`genre_gross`;