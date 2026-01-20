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

-- ====================================================
-- Stored Procedure: get_top_markets_by_net_sales
-- ====================================================
-- Purpose: 
-- Return top markets by inputting parameters of fiscal_year and number to limit by
	
CREATE PROCEDURE `get_top_n_markets_by_net_sales` (
	in_fiscal_year INT,
    in_top_n INT)
BEGIN
	SELECT 
		market,
		ROUND(SUM(net_sales)/1000000,2) AS net_sales_millions
	FROM net_sales
	WHERE fiscal_year = in_fiscal_year
	GROUP BY market
	ORDER BY net_sales_millions DESC
LIMIT in_top_n;
END

-- ====================================================
-- Stored Procedure: get_top_n_customers_by_net_sales
-- ====================================================
-- Purpose: 
-- Returns top N customers by net sales for a given fiscal year and market

CREATE PROCEDURE `get_top_n_customers_by_net_sales` (
	in_fiscal_year INT,
    in_top_n INT,
	in_market VARCHAR(45))
BEGIN
	SELECT 
		c.customer,
		ROUND(SUM(n.net_sales)/1000000,2) AS net_sales_millions
	FROM net_sales n
	JOIN dim_customer c
	ON c.customer_code = n.customer_code 
	WHERE 
		n.fiscal_year = in_fiscal_year AND
        n.market = in_market
	GROUP BY c.customer
	ORDER BY net_sales_millions DESC
    LIMIT in_top_n;
END

