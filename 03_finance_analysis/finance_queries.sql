-- ====================================================
-- User-Defined Functions
-- ====================================================
-- Function: get_fiscal_year_au
-- Purpose:
-- Calculates fiscal year based on Australian Financial Year (1 July - 30 June)

CREATE FUNCTION `get_fiscal_year_au` (
	calendar_date DATE
) RETURNS INTEGER

DETERMINISTIC
BEGIN
	DECLARE fiscal_year_au INT;
	SET fiscal_year_au = YEAR(DATE_ADD(calendar_date, INTERVAL 6 MONTH)); 
	RETURN fiscal_year_au;
END;

-- ====================================================
-- Finance Query: Sales for Customer Croma (FY 2022)
-- ====================================================
-- Business Question: 
-- Retrieve monthly sales records for customer Croma (using customer code) within fiscal year 2022

SELECT 
	date, 
	product_code,
	sold_quantity
FROM fact_sales_monthly
WHERE
customer_code = 90002002 AND
get_fiscal_year_au(date) = 2022
ORDER BY date DESC;

-- ====================================================
-- User-Defined Functions
-- ====================================================
-- Function: get_fiscal_quarter_au
-- Purpose:
-- Calculates fiscal quarter based on Australian Financial Year (1 July - 30 June)

CREATE FUNCTION `get_fiscal_quarter_au` (
	calendar_date DATE
) RETURNS INTEGER

DETERMINISTIC
BEGIN
	DECLARE fiscal_quarter_au INT;
	SET fiscal_quarter_au= QUARTER(DATE_ADD(calendar_date, INTERVAL 6 MONTH)); -- Quarter instead of year()
	RETURN fiscal_quarter_au;
END

-- ====================================================
-- Finance Query: Sales for Customer Croma (FY 2022)
-- ====================================================
-- Business Question: 
-- Retrieve monthly sales records for customer Croma (using customer code) within fiscal year 2022 AND within Quarter 4 (Q4 refers to April - June)
	
SELECT * FROM fact_sales_monthly
WHERE
	customer_code = 90002002 
	AND fiscal_year_au(date) = 2022
	AND get_fiscal_quarter_au(date) = 4
ORDER BY date DESC;

-- ====================================================
-- Gross Sales Detail for Customer Croma
-- ====================================================
-- Business Question: 
-- Retrieve product-level gross sales details, including qty, unit gross price, and total gross sales amount, for a customer within a fiscal year (Australian FY)

SELECT
sm.date, sm.product_code,
p.product, p.variant, sm.sold_quantity,
gp.gross_price,
(gp.gross_price * sm.sold_quantity) AS monthly_sales

FROM fact_sales_monthly sm
JOIN dim_product p
ON sm.product_code = p.product_code

JOIN fact_gross_price gp
ON 
	gp.product_code = p.product_code AND
    gp.fiscal_year = get_fiscal_year_au(sm.date)
WHERE
	customer_code = 90002002
	AND	get_fiscal_year_au(sm.date) = 2021

ORDER BY date ASC

-- ====================================================
-- Gross Monthly Sales for Customer Croma
-- ====================================================
-- Business Question: 
-- Calculate total monthly gross sales for customer Croma using Australian fiscal year pricing

SELECT 
	sm.date, 
    SUM(gp.gross_price*sm.sold_quantity) AS monthly_sales
FROM fact_sales_monthly sm
JOIN fact_gross_price gp
ON 
	gp.product_code = sm.product_code AND
	gp.fiscal_year = get_fiscal_year_au(sm.date)
    
WHERE sm.customer_code = 90002002
GROUP BY sm.date
ORDER BY sm.date ASC

-- ====================================================
-- Yearly Report on Croma Sales
-- ====================================================
-- Business Question: 
-- Generate a yearly report for Croma, where the fiscal year and total gross sales in that year are displayed

SELECT 
	gp.fiscal_year,
	ROUND(SUM(gp.gross_price * sm.sold_quantity),2) AS yearly_sales
FROM fact_sales_monthly sm
JOIN fact_gross_price gp
	ON gp.product_code = sm.product_code   -- primary key 
	AND gp.fiscal_year = get_fiscal_year_au(sm.date) -- sm table did not have fiscal_year to link the two, while gp table did, so the previous get_fiscal_year_au function was used to match sales in each year

WHERE sm.customer_code = 90002002 -- croma customer key
GROUP BY gp.fiscal_year -- group by fiscal year as an aggregated column exists in SELECT statement
ORDER BY gp.fiscal_year

-- ====================================================
-- Stored Procedure: Monthly Gross Sales for Customers
-- ====================================================
-- Purpose: 
-- Return monthly gross sales for one or more customers using Australian fiscal year pricing logic.
-- 
-- Input:
-- in_customer_codes: comma-separated list of customer codes
-- Example: '90002002, 90002003'

CREATE PROCEDURE get_monthly_gross_sales_for_customer (
    IN in_customer_codes VARCHAR(255)
)
BEGIN
	SELECT 
		sm.date, 
		SUM(gp.gross_price*sm.sold_quantity) AS monthly_sales
	FROM fact_sales_monthly sm
	JOIN fact_gross_price gp
	ON gp.product_code = sm.product_code 
	AND gp.fiscal_year = get_fiscal_year_au(sm.date)
		
	WHERE
		FIND_IN_SET(sm.customer_code, in_customer_codes) >0 -- FIND_IN_SET() is a MySQL-specific function that checks whether the value exists inside the comma-separated list
	GROUP BY sm.date										-- In this case, keep only rows where sm.customer_code is present in the list of customer codes that is taken as input
	ORDER BY sm.date ASC;									-- FIND_IN_SET() is used to support passing multiple customer IDs/codes into the procedure for reporting flexibility, it's viable for small databases/systems and analytics use cases.
END

CALL get_monthly_gross_sales_for_customer(90002002);


-- ====================================================
-- Finance Query: Gross Sales with Pre-Invoice Discounts
-- ====================================================
-- Business Question: 
-- Retrieve product-level gross sales and applicable pre-invoice discount percentages for FY2021

SELECT
	sm.date, sm.product_code,
	p.product, p.variant, sm.sold_quantity,
	gp.gross_price,
	(gp.gross_price * sm.sold_quantity) AS monthly_sales,
	pre.pre_invoice_discount_pct
FROM fact_sales_monthly sm
JOIN dim_product p
ON sm.product_code = p.product_code

JOIN fact_gross_price gp
ON 
	gp.product_code = p.product_code AND
    gp.fiscal_year = get_fiscal_year_au(sm.date)
JOIN fact_pre_invoice_deductions pre
ON
	sm.customer_code = pre.customer_code AND
	pre.fiscal_year = get_fiscal_year_au(sm.date)
WHERE
	get_fiscal_year_au(sm.date) = 2021

ORDER BY date ASC

-- ====================================================
-- Finance Query: Gross Sales with Pre-Invoice Discounts
-- ====================================================
-- This query uses a date dimension (dim_date) to derive FY logic, avoiding row-level function calls and improving performance
--
-- Joins:
-- fact_sales_monthly -> dim_product -> dim_date -> fact_gross_price

EXPLAIN ANALYZE              -- Used to identify query run and fetch times
SELECT
	sm.date, sm.product_code,
	p.product, p.variant, sm.sold_quantity,
	gp.gross_price,
	(gp.gross_price * sm.sold_quantity) AS monthly_sales,
	pre.pre_invoice_discount_pct
FROM fact_sales_monthly sm
JOIN dim_product p
ON sm.product_code = p.product_code
JOIN dim_date dt
	ON dt.calendar_date = sm.date
JOIN fact_gross_price gp
ON 
	gp.product_code = p.product_code AND
    gp.fiscal_year = dt.fiscal_year
JOIN fact_pre_invoice_deductions pre
ON
	sm.customer_code = pre.customer_code AND
	pre.fiscal_year = dt.fiscal_year
WHERE
	dt.fiscal_year = 2021

-- ====================================================
-- VIEW 1: sales_preinv_discount
-- ====================================================
-- Purpose: Show sales with pricing and pre-invoice discounts
-- Product x Customer x Date

 CREATE VIEW `sales_preinv_discount` AS
SELECT
	sm.date,
	dt.fiscal_year,
	sm.customer_code,
	c.market,
	sm.product_code,
	p.product, p.variant, sm.sold_quantity,
	gp.gross_price,
	(gp.gross_price * sm.sold_quantity) AS monthly_sales,
	pre.pre_invoice_discount_pct
FROM fact_sales_monthly sm
JOIN dim_customer c ON sm.customer_code = c.customer_code
JOIN dim_product p
	ON sm.product_code = p.product_code
JOIN dim_date dt
	ON dt.calendar_date = sm.date
JOIN fact_gross_price gp
	ON 
	gp.product_code = p.product_code AND
	gp.fiscal_year = dt.fiscal_year
JOIN fact_pre_invoice_deductions pre
	ON
	sm.customer_code = pre.customer_code AND
	pre.fiscal_year = dt.fiscal_year

-- ====================================================
-- Finance Query: Obtaining Net Invoice Sales
-- ====================================================
-- Business Question: Return Net Invoice Sales alongside customers and the related purchased products using view
-- Product x Customer x Date

SELECT *,
	(monthly_sales - monthly_sales*pre_invoice_discount_pct) AS net_invoice_sales
FROM sales_preinv_discount

-- ====================================================
-- VIEW 2: sales_postinv_discount
-- ====================================================
-- Purpose: Show sales with pricing and post-invoice discounts
-- Product x Customer x Date

CREATE VIEW `sales_postinv_discount` AS
SELECT
	s.date, s.fiscal_year,
    s.customer_code, s.market,
    s.product_code, s.product, s.variant,
    s.sold_quantity, s.monthly_sales,
    s.pre_invoice_discount_pct,
    (1-pre_invoice_discount_pct) * monthly_sales AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_preinv_discount s 
JOIN fact_post_invoice_deductions po
ON po.customer_code = s.customer_code AND
	po.product_code = s.product_code AND
	po.date = s.date

-- ====================================================
-- Finance Query: Obtaining Net Sales
-- ====================================================
-- Business Question: Return Net Sales from previously created views

SELECT *,
	(1-post_invoice_discount_pct)*net_invoice_sales AS net_sales
FROM sales_postinv_discount

-- ====================================================
-- VIEW 3: Net Sales
-- ====================================================
-- Purpose: Show net sales after both pre-invoice and post-invoice discount deductions in a table for aggregation purposes

CREATE VIEW `net_sales` AS
SELECT *,
	(1-post_invoice_discount_pct)*net_invoice_sales AS net_sales
FROM sales_postinv_discount
