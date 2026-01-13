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

SELECT * FROM gdb0041.fact_sales_monthly
WHERE
customer_code = 90002002 AND
fiscal_year_au(date) = 2022
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
	DECLARE get_fiscal_quarter_au INT;
	SET get_fiscal_quarter_au= QUARTER(DATE_ADD(calendar_date, INTERVAL 6 MONTH)); -- Quarter instead of year()
	RETURN get_fiscal_quarter_au;
END

-- ====================================================
-- Finance Query: Sales for Customer Croma (FY 2022)
-- ====================================================
-- Business Question: 
-- Retrieve monthly sales records for customer Croma (using customer code) within fiscal year 2022 AND within Quarter 4 (Q4 refers to April - June)
	
SELECT * FROM gdb0041.fact_sales_monthly
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
(gp.gross_price * sm.sold_quantity) AS gross_sales_total

FROM fact_sales_monthly sm
JOIN dim_product p
ON sm.product_code = p.product_code

JOIN fact_gross_price gp

ON 
	gp.product_code = p.product_code AND
    gp.get_fiscal_year_au= get_fiscal_year_au(sm.date)
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
    SUM(gp.gross_price*sm.sold_quantity) AS gross_sales_total
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

