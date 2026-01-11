-- ====================================================
-- User-Defined Functions
-- ====================================================

-- Function : get_fiscal_year_au
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
-- Finance Query: Sales for Customer Croma (FY 2021)
-- ====================================================

-- Business Question: 
-- Retrieve monthly sales records for customer Croma (using customer code) within fiscal year 2022

SELECT * FROM gdb0041.fact_sales_monthly
WHERE
customer_code = 90002002 AND
fiscal_year_au(date) = 2022
ORDER BY date DESC;