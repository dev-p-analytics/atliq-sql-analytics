# Data Model & Schema Design

## Overview
The AltiQ analytics data model is designed using a star schema to support efficient OLAP queries and analytical reporting. The schema separates transactional data from descriptive attributes, allowing for flexible and high-performance analysis. The model uses multiple fact tables, each representing a business process, which allows for flexibility and domain-specific analytics.

## Dimension Tables

### dim_customer
Stores customer-related attributes such as :
- customer code
- customer name
- platform
- channel
- market
- sub-zone
- region

  Used across multiple fact tables for customer-level analysis

### dim_product
Stores product-related attributes such as :
- product code
- division
- segment
- category
- product
- variant

Used across pricing, cost and sales-related fact tables

## Fact Tables

### facts_forecast_monthly
Stores monthly demand forecasts for products across 
Used for:
- Supply chain planning
- Forecast accuracy analysis

### facts_freight_cost
Stores freight-related costs across different markets
Used for:
- Transportation cost analysis

### facts_gross_price
Stores gross pricing information for products 
Used for:
- Gross sales calculation
- Trend analysis

### facts_manufacturing_cost
Stores product manufacturing costs across years
Used for:
- Cost analysis
- Profitability calculations

### facts_post_invoice_deductions
Stores discounts and deductions post-invoice
Used for:
- Net sales calculations
- Discount analysis

### facts_pre_invoice_deductions
Stores pre-invoice discounts
Used for:
- Discount analysis

### facts_sales_monthly
Stores the monthly sales of products across customers
Used for:
- Net sales calculations
- Trend analysis
- Profitability Calculations
  
## Schema Design Approach
Each fact table will connect to a shared dimension table, such as 'dim_customer' or 'dim_product', allowing the formation of multiple star schemas rather than a single consolidated star schema

The approach was chosen as:
- It aligns with real-world enterprise data warehousing
- Improves clarity and maintainability of analytical queries

  ## How This Model Supports Analytics
  This data model enables:
  - Finance analytics (gross sales, net sales, margins)
  - Market and customer performance analysis
  - Supply chain and forecasting insights
  - Efficient SQL-based OLAP reporting 
