-- ====================================================
-- Table Creation
-- ====================================================
-- Purpose:
-- Created for performance optimisation, instead of calling get_fiscal_year_au function each time to reference fiscal_year

CREATE TABLE `dim_date` (
  `calendar_date` date NOT NULL,
  `fiscal_year` year GENERATED ALWAYS AS (YEAR(`calendar_date` + INTERVAL 6 MONTH)) VIRTUAL,
  PRIMARY KEY (`calendar_date`)
);
