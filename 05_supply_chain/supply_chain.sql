-- ====================================================
-- Supply Chain KPI: Forecast Accuracy & Bias by Customer
-- ====================================================
-- Business Purpose:
-- Evaluate forecast performance at the customer level for a
-- given fiscal year by measuring bias and accuracy.
-- 
--Metrics: 
-- Net Error -> SUM(forecast - actual)
--     >0 => over-forecasting
--     <0 => under-forecasting

-- Net Error% -> SUM(forecast-actual)/SUM(forecast)
-- measures forecast bias

-- Absolute Error -> SUM(ABS(forecast-actual))
-- measures total deviation regardless of direction

-- Absolute Error % -> SUM(ABS(forecast-actual))/ SUM(forecast)
-- scale noramlised accuracy 

-- Division of 0 is handled by NULLIF
-- Only records with both actual and forecast qty are shown

SELECT 
    s.customer_code,
    c.customer,
    c.market,
    SUM(s.forecast_quantity - s.sold_quantity) AS net_error,
    ROUND(SUM(s.forecast_quantity - s.sold_quantity) * 100.0 / 
          NULLIF(SUM(s.forecast_quantity), 0), 2) AS net_error_pct,
    SUM(ABS(s.forecast_quantity - s.sold_quantity)) AS abs_error,
    ROUND(SUM(ABS(s.forecast_quantity - s.sold_quantity)) * 100.0 / 
          NULLIF(SUM(s.forecast_quantity), 0), 2) AS abs_error_pct,
    SUM(s.forecast_quantity) AS total_forecast,
    SUM(s.sold_quantity) AS total_actual,
    COUNT(*) AS record_count
FROM fact_act_est s
JOIN dim_customer c ON s.customer_code = c.customer_code
WHERE s.fiscal_year = 2021
GROUP BY s.customer_code, c.customer, c.market
ORDER BY abs_error_pct DESC;
