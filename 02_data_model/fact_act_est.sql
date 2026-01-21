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

-- ====================================================
-- Trigger: fact_sales_monthly_AFTER_INSERT & fact_forecast_monthly_AFTER_INSERT
-- ====================================================
-- Source: fact_act_est (Combination of actual and forecast table)
-- When a new record is inserted or updated in fact_act_est, the corresponding tables:
-- fact_sales_monthly and fact_forecast_monthly will also be updated due to this trigger, maintaining historical records 

CREATE DEFINER = CURRENT_USER TRIGGER `gdb0041`.`fact_sales_monthly_AFTER_INSERT` AFTER INSERT ON `fact_sales_monthly` FOR EACH ROW
BEGIN
	INSERT INTO fact_act_est
		(date, product_code, customer_code, sold_quantity)
	VALUES (
				NEW.date,
        NEW.product_code, -- Trigger specific, replaces 
        NEW.customer_code,
        NEW.sold_quantity
    )
    
    ON duplicate key update
		sold_quantity = values(sold_quantity);
    
END

------------------------------------------------------------------------------------------------------------------------------------------  

  CREATE DEFINER = CURRENT_USER TRIGGER `gdb0041`.`fact_forecast_monthly_AFTER_INSERT` AFTER INSERT ON `fact_forecast_monthly` FOR EACH ROW
BEGIN
	INSERT INTO fact_act_est
		(date, product_code, customer_code, forecast_quantity)
	VALUES (
				NEW.date,
        NEW.product_code, 
        NEW.customer_code,
        NEW.forecast_quantity
    )
    
    ON duplicate key update
		forecast_quantity = values(forecast_quantity);
END
