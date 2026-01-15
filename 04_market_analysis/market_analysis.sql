-- ====================================================
-- Stored Procedure: Market Performance Badge
-- ====================================================
-- Purpose:
-- Assigns a performance badge (Gold/Silver) to a market based on total units sold within a specific fiscal year

CREATE PROCEDURE `get_market_badge` (
		IN in_market VARCHAR(45),         -- Arguments that are inputted and outputted
    IN in_fiscal_year year,
    OUT out_badge VARCHAR(45)
)
BEGIN
	declare qty INT DEFAULT 0             -- Initialise qty to 0 everytime procedure runs
	
 # retrieve total qty for a given market + fyear
	SELECT
		SUM(sold_quantity) INTO qty -- copies the data and places it within the newly created qty variable
  FROM fact_sales_monthly sm
  JOIN dim_customer c
  ON sm.customer_code = c.customer_code  -- Regular inner join that allows result set to have market and sold_qty as columns
  WHERE
		get_fiscal_year(sm.date) = in_fiscal_year AND -- Use previous function to match inputted year and sets market to inputted one
    c.market = in_market
   GROUP BY c.market;
    
 # determine market badge
  IF qty > 5000000 THEN
		SET out_badge = 'Gold';
	ELSE
		SET out_badge = 'Silver';
	END IF;
END
