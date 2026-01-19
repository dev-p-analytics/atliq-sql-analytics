CREATE TABLE `dim_date` (
  `calendar_date` date NOT NULL,
  `fiscal_year` year GENERATED ALWAYS AS (YEAR(`calendar_date` + INTERVAL 6 MONTH)) VIRTUAL,
  PRIMARY KEY (`calendar_date`)
);