# E-Commerce Profit Optimization Analysis
### Olist Brazilian E-Commerce | MySQL · Power BI

## Project Overview

This project analyzes 96,478 delivered orders from Olist, Brazil's largest e-commerce marketplace, covering the period 2016 to 2018. The objective is to identify profit optimization opportunities by analyzing product margins, customer behavior, seasonal trends and payment patterns using advanced SQL and interactive Power BI dashboards.

## Project Objective

Most e-commerce analyses stop at revenue reporting. This project goes deeper by answering:
- Why is profit low despite high sales in certain categories?
- Which products and customers are actually valuable?
- How can the business increase profit — not just revenue?

## Tools & Technologies
MySQL - Database design, data cleaning, analysis 
Power BI - Interactive dashboard and visualization 
Kaggle - Dataset source

## Dataset

**Source:** Olist Brazilian E-Commerce Dataset
**Link:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

**Tables used:**

olist_orders - Order header information 
olist_order_items - Products per order 
olist_order_payments - Payment details 
olist_order_reviews - Customer reviews 
olist_customers - Customer information 
olist_products - Product catalog 
olist_sellers - Seller information 
product_category_translation - Portuguese to English 

**Analysis scope:** Delivered orders only (96,478 orders)

## Business Questions Answered

### Profitability Analysis
- Which categories generate high revenue but low profit?
- Which categories have the best profit margins?
- What is the overall business margin trend year over year?

### Product Strategy
- Which categories should be scaled up?
- Which categories need pricing or logistics review?
- How do categories rank differently on revenue vs profit?

### Customer Behavior
- What is the customer retention rate?
- Which customer segments drive the most revenue?
- Which states show the highest average order value?

### Advanced Analysis
- What seasonal patterns affect monthly revenue?
- How do payment methods influence order value?
- What is the month over month revenue growth trend?

---

## SQL Analysis

### Techniques Used
- Multi-table JOINs across 8 relational tables
- Window functions: RANK, LAG, PARTITION BY
- CTEs for clean modular query structure
- HAVING filters for segment-level analysis
- Calculated columns: profit, margin_pct, revenue

## Key Business Insights

### 1. Customer Retention Crisis
97% of customers never return after their first purchase.
Only 2,801 out of 93,358 customers placed more than one order.
Repeat rate: 3.00%

**Recommendation:**
- Launch post-purchase email campaigns
- Introduce loyalty rewards program
- Personalized product recommendations
- Even 5% retention improvement = ~4,600 new repeat customers

### 2. Electronics Margin Crisis
Electronics category shows only 32.27% margin vs 67.79%
business average. Telephony at 49.31% also underperforming.
Root cause: High freight costs for heavy and bulky items.

**Recommendation:**
- Negotiate logistics rates for heavy item categories
- Add minimum order value threshold for free shipping
- Review pricing strategy on low margin SKUs

### 3. Watches & Gifts — Star Category
Ranks 2nd in revenue (Rs. 1.21M) AND 1st in profit margin
(82.65%). Only top-5 category above average margin.
Revenue grew from rank 3 in 2017 to rank 2 in 2018 —
fastest growing category in the dataset.

**Recommendation:**
- Increase marketing budget for this category by 20%
- Expand product range within this category
- Priority restocking before peak demand months

### 4. Black Friday Drives 51.6% Revenue Spike
November 2017 showed the largest single month revenue jump
in the entire dataset. October to November: +51.6% growth.
This seasonal pattern will repeat every year.

**Recommendation:**
- Begin inventory planning in September
- Run targeted campaigns from October 15
- Increase seller capacity before November
- Target high AOV states with November promotions

### 5. Northeastern States — High Value Market
States PB (234), AC (213), AL (206) show average order
values 40-60% above the overall average of Rs. 143.83.
These smaller markets have high-spend customers with
less retail competition.

**Recommendation:**
- Run targeted digital campaigns in PB, AC, AL, AP
- Higher AOV = better return on marketing spend
- Partner with local sellers in these regions
- Offer region-specific product bundles

## Power BI Dashboard

### Dashboard Pages

**Page 1 — Executive Summary**
Overall KPIs, order fulfillment rate and yearly revenue vs profit comparison

**Page 2 — Product & Profit Analysis**
Category revenue vs profit, margin analysis with conditional formatting and revenue vs margin scatter plot

**Page 3 — Customer Insights**
Retention rate, repeat vs one-time customers, customer segmentation and AOV by state

**Page 4 — Revenue Trends & Payment Patterns**
Monthly revenue 2017 vs 2018, payment method revenue share and average payment value analysis

**Page 5 — Strategic Recommendations**
5 data-backed business findings with specific actionable recommendations for each

### Key Metrics

Total Revenue: Rs. 13.88M 
Total Profit: Rs. 11.56M 
Avg Profit Margin: 67.79% 
Total Orders: 96,478 
Unique Customers: 93,358 
Avg Order Value: Rs. 143.83 
Customer Retention Rate: 3.00% 
Repeat Customers: 2,801 
Best Margin Category: Computers (94.44%) 
Highest Revenue Category: Health Beauty (Rs. 1.27M) 
Star Category: Watches & Gifts (82.65% margin) 

## Statistical Highlights

- Revenue grew 19.3% from 2017 to 2018
- 97.02% of all orders were successfully delivered
- Top 3 categories contribute ~30% of total revenue
- Credit card accounts for 77.22% of total payment revenue
- Northeastern states show 40-60% higher AOV than average
- November Black Friday spike: +51.6% month over month

## Future Enhancements

- Build customer churn prediction model using machine learning
- Perform product affinity and basket analysis
- Add seller performance scoring model
- Implement dynamic pricing recommendation engine
- Build return rate analysis by category

## Author Note

This project was built as a portfolio case study for Data Analyst roles, demonstrating practical skills in MySQL database design, advanced SQL analysis, business insight generation and Power BI dashboard development. The project highlights how data analytics can drive decisions around profit optimization, customer retention,product strategy and marketing investment allocation.

## Dashboard Preview
<img width="1057" height="590" alt="img 1" src="https://github.com/user-attachments/assets/f34f08fa-2c56-44d7-b55e-51089ab2b3f4" />

<img width="1050" height="593" alt="img 2" src="https://github.com/user-attachments/assets/71bef228-65b1-4988-beef-b8dbab1580ef" />

<img width="1052" height="588" alt="img 3" src="https://github.com/user-attachments/assets/49c627b0-4198-4bf4-b1ed-abb5fa616d9d" />

<img width="1056" height="588" alt="img 4" src="https://github.com/user-attachments/assets/e3b7755d-449d-4c0f-9912-b2641d8e0392" />

<img width="1052" height="587" alt="img 5" src="https://github.com/user-attachments/assets/ef9e2a00-aa80-454f-adb4-98cfc87a071c" />

**Author:** Shreya Ranjan
**Role:** Data Analyst
**Tools:** MySQL, Power BI
**Dataset:** Olist Brazilian E-Commerce (Kaggle)
