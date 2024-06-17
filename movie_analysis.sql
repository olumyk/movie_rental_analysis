#                               SQL Movie Analysis

# Manage a chain of Movie Rental Stores
# Introduction
# -Data: see attached
    # In this project, you will write more advanced queries on a database designed to resemble a real-world database system - MySQL’s Sakila Sample Database.
    # The development of the Sakila sample database began in early 2005. Early designs were based on the database used in the Dell whitepaper (Three Approaches to MySQL Applications on Dell PowerEdge Servers).
    # The Sakila sample database is designed to represent a DVD rental store. The Sakila sample database still borrows film and actor names from the Dell sample database.

# Problem Description
# You will be writing queries in SQL to manage a chain of movie rental stores, for example,
    # -Track the inventory level and determine whether the rental can happen
    # -Manage customer information and identify loyalty customers
    # -Monitor customers’ owing balance and find overdue DVDs

# This project can be considered as a typical retail-related business case, because it has the main metrics you can find in any retailer’s real database, such as Walmart, Shoppers, Loblaws, Amazon...

# Key Metrics:
    # -Production information (in this project, it is the film)
    # -Sales information
    # -Inventory information
    # -Customer behavior information

########################################################################################################################

SHOW DATABASES;
USE sakila;
SHOW TABLES;

#                                    Exercise 1

# 1.Before doing any exercise, you should explore the data first.
    # -For Exercise 1, we will focus on the product, which is the film (DVD) in this project.
    # -Please explore the product-related tables (actor, film_actor, film, language, film_category, category) by using SELECT * – Do not forget to limit the number of records
SELECT * FROM actor LIMIT 5;
SELECT * FROM film_actor LIMIT 5;
SELECT * FROM film LIMIT 5;
SELECT * FROM language LIMIT 5;
SELECT * FROM film_category LIMIT 5;
SELECT * FROM category LIMIT 5;

## Use table FILM to solve the questions below:
# 2.What is the largest `rental_rate` for each rating?
SELECT
    rating,
    MAX(rental_rate) AS largestRentalRate
FROM film
GROUP BY rating;


# 3.How many films are in each rating category?
SELECT
    rating,
    COUNT(*) AS filmCount
FROM film
GROUP BY rating;


# 4.Create a new column `film_length` to segment different films by length:
# `length < 60 then ‘short’; length < 120 then standard’; length >=120 then ‘long’, then count the number of films in each segment.`
SELECT
    film_length,
    COUNT(*) AS filmCount
FROM
    (
    SELECT
        COALESCE(
                CASE WHEN length < 60 THEN 'short'
                    WHEN length < 120 THEN 'standard'
                    ELSE 'long'
                    END,
                'unknown'
        ) AS film_length
    FROM film) Sub1
GROUP BY film_length;


## Use table ACTOR to solve questions as below:
SELECT * FROM actor LIMIT 5;

# 5.Which actors have the last name ‘Johansson’?
SELECT *
FROM actor
WHERE last_name = 'Johansson';


# 6.How many distinct actors’ last names are there? -- ANS: 121
SELECT COUNT(DISTINCT last_name)
FROM actor;

# 7.Which last names are not repeated? Hint: use COUNT() and GROUP BY and HAVING
SELECT
    last_name AS uniqueLastNames
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) = 1;

# 8.Which last names appear more than once?
SELECT
    last_name,
    count(last_name) AS lastNameCount
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;


## Use table FILM_ACTOR to solve questions as below:
SELECT * FROM film_actor LIMIT 5;

# 9.Count the number of actors in each film, order the result by the number of actors in descending order
SELECT
    film_id,
    COUNT(DISTINCT actor_id) actorCount
FROM film_actor
GROUP BY 1
ORDER BY 2 DESC;


# 10.How many films do each actor play in?
SELECT
    actor_id,
    COUNT(film_id) AS filmCount
FROM film_actor
GROUP BY 1;


########################################################################################################################
#                        Exercise 2 (for after Day 4 Lecture):

# 1.Before doing any exercise, you should explore the data first.
    # -For Exercise 1, we will focus on the product, which is the film (DVD) in this project.
    # -Please explore the product-related tables (`actor, film_actor, film, language, film_category, category`) by using `SELECT *`
    # –Do not forget to limit the number of records;
SHOW TABLES;
SELECT * FROM actor LIMIT 5;
SELECT * FROM film_actor LIMIT 5;
SELECT * FROM film LIMIT 5;
SELECT * FROM language LIMIT 5;
SELECT * FROM film_category LIMIT 5;
SELECT * FROM category LIMIT 5;

# 2.Find language name for each film by using table Film and Language;
SELECT * FROM film LIMIT 10;
SELECT * FROM language LIMIT 10;
SELECT DISTINCT language_id FROM language;
SELECT DISTINCT language_id FROM film;

-- solution
SELECT
    f.film_id, f.title, f.language_id,
    l.name
FROM film f
INNER JOIN language l ON f.language_id = l.language_id;


# 3.In table `Film_actor`, there are `actor_id` and `film_id` columns. I want to know the actor name for each `actor_id`, and the film tile for each `film_id`.
# Hint: Use multiple table Inner Join
SELECT * FROM film_actor LIMIT 5;
SELECT * FROM actor LIMIT 5;
SELECT * FROM film LIMIT 5;

-- solution
SELECT
    fa.actor_id, a.first_name, a.last_name,
    fa.film_id, f.title
FROM film_actor fa
INNER JOIN actor a ON fa.actor_id = a.actor_id
INNER JOIN film f ON fa.film_id = f.film_id;


# 4.In table Film, there is no category information. I want to know which category each film belongs to.
# Hint: use table `film_category` to find the category id for each film and then use table category to get the category name
SELECT * FROM film LIMIT 5;
SELECT * FROM film_category LIMIT 5;
SELECT * FROM category LIMIT 5;

-- solution
SELECT
    f.film_id, f.title,
    fc.category_id,
    c.name AS categoryInfo
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id;


# 5.Select films with `rental_rate` > 2 and then combine the results with films with ratings G, PG-13, or PG.
SELECT * FROM film LIMIT 10;
SELECT DISTINCT rental_rate FROM film;
SELECT DISTINCT rating FROM film;

-- solution
SELECT * FROM film WHERE rental_rate > 2
UNION
SELECT * FROM film WHERE rating IN ('G', 'PG-13', 'PG');


########################################################################################################################
#                                    Exercise 3:

# Let’s look at sales first:
# The rental table contains one row for each rental of each inventory item with information about who rented what item when it was rented, and when it was returned
# The rental table refers to the inventory, customer, and staff tables and is referred to by the payment table
# `Rental_id`: A surrogate primary key that uniquely identifies the rental

SHOW TABLES;
DESCRIBE rental;
SELECT * FROM rental LIMIT 10;
SELECT COUNT(DISTINCT rental_id) FROM rental;

# 1.How many rentals (basically, the sales volume) happened from 2005-05 to 2005-08? Hint: use date between '2005-05-01' and '2005-08-31';
SELECT
    COUNT(*) AS rentalCount
FROM
    rental
WHERE
    rental_date BETWEEN '2005-05-01' AND '2005-08-31';


# 2.I want to see the rental volume by month. Hint: you need to use the substring function to create a month column, e.g.
-- rental volume by month of all time
SELECT
    SUBSTRING(rental_date FROM 1 FOR 7) AS monthlyRentalVol,
    COUNT(*) AS rentalCount
FROM rental
GROUP BY monthlyRentalVol
ORDER BY rentalCount DESC;

-- rental volume by month for time between 2005-05 to 2005-08
SELECT
    SUBSTRING(rental_date FROM 1 FOR 7) AS rental_month,
    COUNT(*) AS total_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-31'
GROUP BY rental_month;


# 3.Rank the staff by total rental volumes for all time periods. I need the staff’s names, so you have to join with the staff table
SELECT * FROM staff;
SELECT DISTINCT staff_id FROM rental;
SELECT * FROM rental LIMIT 10;

-- solution
SELECT
    s.staff_id, s.first_name, s.last_name,
    COUNT(r.rental_id) AS totalRentalVol
FROM staff s
INNER JOIN rental r ON s.staff_id = r.staff_id
GROUP BY
    s.staff_id
ORDER BY
    totalRentalVol DESC;


## How about inventory?
# 4.Create the current inventory level report for each film in each store.
    # -The inventory table has the inventory information for each film at each store
    # - `inventory_id` - A surrogate primary key used to uniquely identify each item in inventory, so each inventory id means each available film.
-- familiarizing with tables
SHOW tables; -- film, film_list, film_text, inventory, store
SELECT * FROM film LIMIT 10;
SELECT * FROM film_list LIMIT 10;
SELECT * FROM film_text LIMIT 10;
SELECT * FROM inventory LIMIT 10;
SELECT * FROM store LIMIT 10;
SELECT * FROM sales_by_store LIMIT 10;
SELECT COUNT(DISTINCT inventory_id) FROM rental;
SELECT COUNT(DISTINCT film_id) FROM film;

-- first
SELECT COUNT(f.film_id), i.store_id
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
GROUP BY store_id;

-- solution
SELECT
    i.inventory_id,
    f.film_id,
    s.store_id
FROM
    inventory i
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN store s ON i.store_id = s.store_id
ORDER BY film_id;


# 5.When you show the inventory level to your manager, your manager definitely wants to know the film's name. Please add the film's name to the inventory report.
    # -Tile column in film table is the film name
    # -Should you use left join or inner join? – this depends on how you want to present your result to your manager, so there is no right or wrong answer
    # -Which table should be your base table if you want to use left join?
SELECT
    i.inventory_id,
    f.film_id,
    s.store_id,
    f.title AS filmName
FROM
    inventory i -- base table
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN store s ON i.store_id = s.store_id
ORDER BY film_id;


# 6.After you show the inventory level again to your manager, your manager still wants to know the category for each film. Please add the category for the inventory report.
    # -Name column in the category table is the category name
    # -You need to join film, category, inventory, and `film_category
SHOW tables;
SELECT * FROM category LIMIT 5;
SELECT * FROM film_category LIMIT 5;

-- solution
SELECT
    s.store_id,
    i.inventory_id,
    f.film_id, f.title AS filmName,
    c.name AS categoryName
FROM
    film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN store s ON i.store_id = s.store_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id;


# 7.Your manager is happy now, but you need to save the query result to a table, just in case your manager wants to check again, and you may need the table to do some analysis in the future.
    # Use the `CREATE` statement to create a table called `inventory_rep`

-- create inventory_rep table using CREATE
CREATE TABLE inventory_rep
(
    store_id INT,
    inventory_id INT,
    film_id INT,
    filmName VARCHAR(255),
    categoryName VARCHAR(255)
);

-- see that table is created and empty
SHOW tables;
SELECT * FROM inventory_rep;
truncate sakila.inventory_rep;

-- save the query result to inventory_rep table
INSERT INTO inventory_rep
SELECT
    s.store_id,
    i.inventory_id,
    f.film_id, f.title AS filmName,
    c.name AS categoryName
FROM
    film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN store s ON i.store_id = s.store_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id;

-- preview the populated table
SELECT * FROM inventory_rep LIMIT 5;


# 8.Use your report to identify the film which is not available in any store, and the next step will be to notice the supply chain team add the film to the store
SELECT
    s.store_id,
    i.inventory_id,
    f.film_id, f.title AS filmName,
    c.name AS categoryName
FROM
    film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN store s ON i.store_id = s.store_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE i.film_id IS NULL;


## Let’s look at Revenue:
    # -The payment table records each payment made by a customer, with information such as the amount and the rental paid for. Let us consider the payment amount as revenue and ignore the receivable revenue part
    # -`rental_id`: The rental that the payment is being applied. This is optional because some payments are for outstanding fees and may not be directly related to a rental – which means it can be null;

# 9.How much revenue was made from 2005-05 to 2005-08 by month?
SELECT
    SUBSTRING(p.payment_date FROM 1 FOR 7) AS payment_month,
    SUM(p.amount) AS sumRevenue
FROM
    payment p
        LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE
    p.payment_date BETWEEN '2005-05-01' AND '2005-08-31'
GROUP BY
    payment_month;


# 10.How much revenue was made from 2005-05 to 2005-08 by each store?
SELECT
    s.store_id,
    SUBSTRING(p.payment_date FROM 1 FOR 7) AS paymentMonth,
    SUM(p.amount) AS sumRevenue
FROM
    payment p
LEFT JOIN
    rental r ON p.rental_id = r.rental_id
INNER JOIN
    customer c ON p.customer_id = c.customer_id
INNER JOIN
    store s ON c.store_id = s.store_id
WHERE
    p.payment_date BETWEEN '2005-05-01' AND '2005-08-31'
GROUP BY
    s.store_id, paymentMonth
ORDER BY paymentMonth;


# 11.Say the movie rental store wants to offer unpopular movies for sale to free up shelf space for newer ones. Help the store to identify unpopular movies by counting the number of rental times for each film. Provide the film id, film name, and category name so the store can also know which categories are not popular.
    # Hint: count how many times each film was checked out and rank the result by ascending order.
SELECT
    f.film_id,
    f.title AS filmName,
    c.name AS categoryName,
    COUNT(r.rental_id) AS countRental
FROM
    film f
INNER JOIN
        film_category fc ON f.film_id = fc.film_id
INNER JOIN
        category c ON fc.category_id = c.category_id
LEFT JOIN
        inventory i ON f.film_id = i.film_id
LEFT JOIN
        rental r ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id, f.title, c.name
ORDER BY
    countRental ASC;

