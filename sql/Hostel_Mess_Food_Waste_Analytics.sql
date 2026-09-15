
-- HOSTEL MESS FOOD WASTE & PROCUREMENT ANALYTICS
-- SQL PROJECT

-- 1. DATABASE SETUP

CREATE DATABASE hostel_mess_analytics;

USE hostel_mess_analytics;


-- 2. CREATE TABLES

CREATE TABLE meal_operations (
    date DATE,
    day VARCHAR(10),
    meal VARCHAR(20),
    menu_item VARCHAR(50),
    students_present INT,
    food_prepared_kg DECIMAL(10,2),
    food_consumed_kg DECIMAL(10,2),
    leftover_kg DECIMAL(10,2),
    waste_kg DECIMAL(10,2),
    waste_percent DECIMAL(5,2),
    estimated_food_cost DECIMAL(10,2),
    notes VARCHAR(100)
);


CREATE TABLE procurement (
    purchase_date DATE,
    supplier VARCHAR(50),
    ingredient VARCHAR(50),
    category VARCHAR(30),
    quantity_purchased_kg DECIMAL(10,2),
    unit_price_inr DECIMAL(10,2),
    procurement_cost_inr DECIMAL(10,2),
    payment_status VARCHAR(20),
    delivery_rating INT
);


CREATE TABLE menu_master (
    meal VARCHAR(20),
    menu_item VARCHAR(50),
    expected_consumption_per_student_kg DECIMAL(5,3),
    popularity_score INT
);


-- 3. DATA VALIDATION

SELECT COUNT(*) AS total_meal_records
FROM meal_operations;


SELECT COUNT(*) AS total_procurement_records
FROM procurement;


SELECT COUNT(*) AS total_menu_records
FROM menu_master;


-- 4. BASIC DATA EXPLORATION

SELECT *
FROM meal_operations
LIMIT 10;


SELECT
    date,
    meal,
    menu_item,
    waste_kg
FROM meal_operations
LIMIT 10;


-- 5. DINNER WASTE ANALYSIS

SELECT
    SUM(waste_kg) AS total_dinner_waste
FROM meal_operations
WHERE meal = 'Dinner';


-- 6. MEAL-WISE TOTAL WASTE

SELECT
    meal,
    SUM(waste_kg) AS total_waste
FROM meal_operations
GROUP BY meal
ORDER BY total_waste DESC;


-- 7. MEAL-WISE AVERAGE WASTE

SELECT
    meal,
    AVG(waste_kg) AS avg_waste
FROM meal_operations
GROUP BY meal
ORDER BY avg_waste DESC;


-- 8. MEAL-WISE RECORD COUNT

SELECT
    meal,
    COUNT(*) AS total_records
FROM meal_operations
GROUP BY meal
ORDER BY total_records DESC;


-- 9. DATA CLEANING - REMOVE BLANK MEAL RECORDS

SET SQL_SAFE_UPDATES = 0;

DELETE FROM meal_operations
WHERE meal IS NULL OR meal = '';


-- 10. VALIDATE CLEANED DATA

SELECT
    COUNT(*) AS total_records
FROM meal_operations;


SELECT
    meal,
    COUNT(*) AS total_records
FROM meal_operations
GROUP BY meal
ORDER BY total_records DESC;



-- 11. COMBINED MEAL-WISE ANALYSIS

SELECT
    meal,
    COUNT(*) AS total_records,
    SUM(waste_kg) AS total_waste,
    AVG(waste_kg) AS avg_waste
FROM meal_operations
GROUP BY meal
ORDER BY total_waste DESC;



-- 12. DINNER MENU-WISE WASTE


SELECT
    menu_item,
    SUM(waste_kg) AS total_waste
FROM meal_operations
WHERE meal = 'Dinner'
GROUP BY menu_item
ORDER BY total_waste DESC;


-- 13. HIGH-WASTE MENU ITEMS

SELECT
    menu_item,
    SUM(waste_kg) AS total_waste
FROM meal_operations
GROUP BY menu_item
HAVING SUM(waste_kg) > 150
ORDER BY total_waste DESC;


-- 14. WASTE CATEGORY USING CASE WHEN

SELECT
    date,
    meal,
    menu_item,
    waste_kg,
    CASE
        WHEN waste_kg < 5 THEN 'Low'
        WHEN waste_kg < 10 THEN 'Medium'
        ELSE 'High'
    END AS waste_category
FROM meal_operations
LIMIT 20;



-- 15. WASTE CATEGORY COUNT


SELECT
    CASE
        WHEN waste_kg < 5 THEN 'Low'
        WHEN waste_kg < 10 THEN 'Medium'
        ELSE 'High'
    END AS waste_category,
    COUNT(*) AS total_records
FROM meal_operations
GROUP BY
    CASE
        WHEN waste_kg < 5 THEN 'Low'
        WHEN waste_kg < 10 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY total_records DESC;


-- 16. HIGH-WASTE DINNER MENU ITEMS

SELECT
    menu_item,
    SUM(waste_kg) AS total_waste
FROM meal_operations
WHERE meal = 'Dinner'
GROUP BY menu_item
HAVING SUM(waste_kg) > 100
ORDER BY total_waste DESC;


-- 17. JOIN MEAL OPERATIONS WITH MENU MASTER

SELECT
    m.date,
    m.meal,
    m.menu_item,
    m.students_present,
    m.waste_kg,
    mm.expected_consumption_per_student_kg,
    mm.popularity_score
FROM meal_operations m
JOIN menu_master mm
    ON m.meal = mm.meal
    AND m.menu_item = mm.menu_item
LIMIT 20;



-- 18. MENU WASTE + POPULARITY ANALYSIS

SELECT
    m.menu_item,
    SUM(m.waste_kg) AS total_waste,
    AVG(m.waste_percent) AS avg_waste_percent,
    AVG(mm.popularity_score) AS popularity_score
FROM meal_operations m
JOIN menu_master mm
    ON m.meal = mm.meal
    AND m.menu_item = mm.menu_item
GROUP BY m.menu_item
ORDER BY total_waste DESC;



-- 19. INGREDIENT-WISE PROCUREMENT COST

SELECT
    ingredient,
    SUM(procurement_cost_inr) AS total_procurement_cost
FROM procurement
GROUP BY ingredient
ORDER BY total_procurement_cost DESC;



-- 20. SUPPLIER PERFORMANCE ANALYSIS


SELECT
    supplier,
    SUM(quantity_purchased_kg) AS total_quantity_purchased,
    SUM(procurement_cost_inr) AS total_cost,
    AVG(delivery_rating) AS avg_delivery_rating
FROM procurement
GROUP BY supplier
ORDER BY total_cost DESC;


-- 21. MONTHLY WASTE TREND

SELECT
    DATE_FORMAT(date, '%Y-%m') AS month,
    SUM(waste_kg) AS total_waste,
    SUM(estimated_food_cost) AS total_waste_cost
FROM meal_operations
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY month;


-- 22. TOP 10 WASTE-GENERATING MENU ITEMS

SELECT
    menu_item,
    SUM(waste_kg) AS total_waste,
    AVG(waste_percent) AS avg_waste_percent,
    SUM(estimated_food_cost) AS total_waste_cost
FROM meal_operations
GROUP BY menu_item
ORDER BY total_waste DESC
LIMIT 10;