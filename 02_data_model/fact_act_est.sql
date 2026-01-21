-- ====================================================
-- Fact Table: fact_act_est
-- ====================================================
-- Grain : 
-- Month x Product x Customer
-- Purpose:
-- Stores actual sales and forecasted quantities for supply chain analysis
CREATE TABLE fact_act_est
(
-- Actuals with forecast
SELECT
	sm.date AS date,
	get_fiscal_year_au(sm.date) AS fiscal_year,
	sm.product_code AS product_code,
	sm.customer_code AS customer_code,
	sm.sold_quantity AS sold_quantity,
	f.forecast_quantity AS forecast_quantity
FROM
	fact_sales_monthly sm
LEFT JOIN fact_forecast_monthly f 
USING (date, customer_code, product_code)

UNION 

SELECT
	f.date AS date,
	f.fiscal_year AS fiscal_year,
	f.product_code AS product_code,
	f.customer_code AS customer_code,
	f.forecast_quantity AS forecast_quantity ,
	sm.sold_quantity AS sold_quantity
FROM
	fact_forecast_monthly f  
LEFT JOIN fact_sales_monthly sm
USING (date, customer_code, product_code)
)