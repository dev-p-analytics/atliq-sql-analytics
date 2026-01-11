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

