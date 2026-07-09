# atliq-sql-analytics
SQL-based finance, sales and supply chain analytics for AtliQ Hardware, a fictional computer hardware manufacturer. Built as part of the Codebasics Data Engineering course.

## Project Overview
AtliQ Hardware's management lacked sufficient data-driven insights to make fast, informed decisions. This project addresses these weaknesses through the implementation of structured queries across 3 domains; finance, market performance, and supply chains

## Tech Stack
- MySQL - querying and analysis
- MYSQL Workbench - query development and data exploration

## Repository Structure 
atliq-sql-analytics/
├── 01_business_context/     # Background on AtliQ Hardware and business problem
├── 02_data_model/           # Entity-relationship diagrams and schema overview
├── 03_finance_analysis/     # Gross sales, net sales, P&L reporting queries
├── 04_market_analysis/      # Regional performance and customer segmentation
├── 05_supply_chain/         # Forecast accuracy and inventory analysis

## Key Analysis
### Finance Analysis
- Gross and Net Sales reporting by customer, product and region
- Pre and post-invoice deduction breakdowns
- Monthly and Yearly P&L Summaries

### Market Analysis
- Top performing markets and customers by revenue
- Regional net sales percentage share
- Customer-level discount and profitability analysis

### Supply Chain
- Forecast accuracy reporting
- Net Error and Absolute Net Error analysis across products and segments
- Identifying over and under-stocked items
