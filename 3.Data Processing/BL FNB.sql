---Viewing the table
select * from `blsales`.`fnb`.`bl_fnb_sales_case_study` limit 100;

---Cleaning the table
SELECT 
    -- 1. Convert Timestamp to clean ISO Date (YYYY-MM-DD)
    CAST(`Date` AS DATE) AS clean_date,
    
    -- 2. Round Rand monetary values to 2 decimal places
    ROUND(CAST(`Sales` AS DOUBLE), 2) AS clean_sales_rand,
    ROUND(CAST(`Cost Of Sales` AS DOUBLE), 2) AS clean_cost_of_sales_rand,
    
    -- 3. Keep Quantity Sold as integer
    CAST(`Quantity Sold` AS INT) AS quantity_sold

FROM `blsales`.`fnb`.`bl_fnb_sales_case_study`

-- 4. Filter out any potential NULL dates and sort chronologically
WHERE `Date` IS NOT NULL
ORDER BY clean_date ASC;

---Check for Duplicate Dates
SELECT 
    CAST(`Date` AS DATE) AS clean_date,
    COUNT(*) AS row_count
FROM `blsales`.`fnb`.`bl_fnb_sales_case_study`
GROUP BY CAST(`Date` AS DATE)
HAVING COUNT(*) > 1;

---Check for Missing / NULL Values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN `Date` IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN `Sales` IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN `Cost Of Sales` IS NULL THEN 1 ELSE 0 END) AS null_cost,
    SUM(CASE WHEN `Quantity Sold` IS NULL THEN 1 ELSE 0 END) AS null_quantity
FROM `blsales`.`fnb`.`bl_fnb_sales_case_study`;

---Check for Zero or Negative Quantities
SELECT *
FROM `blsales`.`fnb`.`bl_fnb_sales_case_study`
WHERE `Quantity Sold` <= 0 OR `Sales` < 0 OR `Cost Of Sales` < 0;


---Update cleaned table
CREATE OR REPLACE TABLE `blsales`.`fnb`.`bl_fnb_sales_case_study` AS
SELECT 
    CAST(`Date` AS DATE) AS clean_date,
    ROUND(CAST(`Sales` AS DOUBLE), 2) AS sales_rand,
    ROUND(CAST(`Cost Of Sales` AS DOUBLE), 2) AS cost_of_sales_rand,
    CAST(`Quantity Sold` AS INT) AS quantity_sold
FROM `blsales`.`fnb`.`bl_fnb_sales_case_study`
WHERE `Date` IS NOT NULL
ORDER BY clean_date ASC;

SELECT * FROM blsales.fnb.bl_fnb_sales_case_study;

---What is the daily sales price per unit?
---Answer: It varies by day based on pricing strategies and promotions, visible in your daily_unit_price column (e.g., R32.80, R32.41, R32.42).
SELECT 
    clean_date,
    sales_rand,
    cost_of_sales_rand,
    quantity_sold,
    
    -- Daily Sales Price per Unit
    ROUND(sales_rand / quantity_sold, 2) AS daily_unit_price,
    
    -- Daily Cost per Unit
    ROUND(cost_of_sales_rand / quantity_sold, 2) AS daily_unit_cost

    FROM blsales.fnb.bl_fnb_sales_case_study
    ORDER BY clean_date ASC;

---Overall Average Unit Sales Price (overall_avg_unit_price): R35.40
SELECT 
ROUND(SUM(sales_rand)/SUM(quantity_sold),2) AS overall_avg_unit_price
FROM blsales.fnb.bl_fnb_sales_case_study;


SELECT 
    clean_date,
    sales_rand,
    cost_of_sales_rand,
    
    -- Daily Gross Profit in Rand
    ROUND(sales_rand - cost_of_sales_rand, 2) AS daily_gross_profit_rand,
    
    -- Q3 & Q4: Daily Gross Profit %
    ROUND(((sales_rand - cost_of_sales_rand) / sales_rand) * 100, 2) AS daily_gross_profit_pct

FROM blsales.fnb.bl_fnb_sales_case_study
ORDER BY clean_date ASC;


---Promotional Periods & Price Elasticity of Demand (PED)
WITH promotional_periods AS (
    SELECT 
        clean_date,
        quantity_sold,
        sales_rand,
        ROUND(sales_rand / quantity_sold, 2) AS promo_price,
        ROUND(cost_of_sales_rand / quantity_sold, 2) AS promo_unit_cost,
        ROUND(((sales_rand - cost_of_sales_rand) / sales_rand) * 100, 2) AS promo_gp_pct
    FROM blsales.fnb.bl_fnb_sales_case_study
),
benchmark AS (
    SELECT 
        35.40 AS base_price,
        AVG(quantity_sold) AS base_qty
    FROM blsales.fnb.bl_fnb_sales_case_study
)
SELECT 
    p.clean_date,
    p.promo_price,
    b.base_price,
    p.quantity_sold AS promo_qty,
    ROUND(b.base_qty, 0) AS base_qty,
    p.promo_gp_pct,
    
    -- % Change in Price (% ΔP)
    ROUND(((p.promo_price - b.base_price) / b.base_price) * 100, 2) AS price_change_pct,
    
    -- % Change in Quantity (% ΔQ)
    ROUND(((p.quantity_sold - b.base_qty) / b.base_qty) * 100, 2) AS qty_change_pct,
    
    -- Price Elasticity of Demand (PED = % ΔQ / % ΔP)
    ROUND(
        (((p.quantity_sold - b.base_qty) / b.base_qty)) / 
        NULLIF(((p.promo_price - b.base_price) / b.base_price), 0), 
    2) AS price_elasticity_of_demand

FROM promotional_periods p
CROSS JOIN benchmark b
WHERE p.promo_price < 35.40  -- Filtering for discounted/promotional prices
ORDER BY p.promo_price ASC
LIMIT 10;

---Yearly Revenue Trends
SELECT 
    YEAR(clean_date) AS sales_year,
    ROUND(SUM(sales_rand), 2) AS total_revenue_rand,
    ROUND(SUM(cost_of_sales_rand), 2) AS total_cost_of_sales_rand,
    ROUND(SUM(sales_rand - cost_of_sales_rand), 2) AS total_gross_profit_rand,
    ROUND((SUM(sales_rand - cost_of_sales_rand) / SUM(sales_rand)) * 100, 2) AS yearly_gross_profit_pct
FROM blsales.fnb.bl_fnb_sales_case_study
GROUP BY YEAR(clean_date)
ORDER BY sales_year ASC;

---Best Sales Year
SELECT 
    YEAR(clean_date) AS sales_year,
    ROUND(SUM(sales_rand), 2) AS total_revenue_rand
    FROM blsales.fnb.bl_fnb_sales_case_study
    GROUP BY sales_year
    ORDER BY total_revenue_rand DESC
    LIMIT 1;

SELECT 
    YEAR(clean_date) AS sales_year,
    QUARTER(clean_date) AS sales_quarter,
    CONCAT(YEAR(clean_date), ' Q', QUARTER(clean_date)) AS year_quarter,
    SUM(quantity_sold) AS total_units_sold,
    ROUND(SUM(sales_rand), 2) AS quarterly_revenue_rand,
    ROUND(SUM(cost_of_sales_rand), 2) AS quarterly_cost_rand,
    ROUND(SUM(sales_rand - cost_of_sales_rand), 2) AS quarterly_gross_profit_rand,
    ROUND((SUM(sales_rand - cost_of_sales_rand) / SUM(sales_rand)) * 100, 2) AS quarterly_gp_pct
FROM blsales.fnb.bl_fnb_sales_case_study
GROUP BY YEAR(clean_date), QUARTER(clean_date)
ORDER BY sales_year ASC, sales_quarter ASC;
    

    ---Adding Columns for Insights
    SELECT 
    clean_date AS date,
    * EXCEPT (clean_date),
    
    -- 1. Unit Economics & Profitability Segment
    CASE 
        WHEN (sales_rand - cost_of_sales_rand) > 0 THEN '1. Profitable (+ Margin)'
        WHEN (sales_rand - cost_of_sales_rand) BETWEEN -1000 AND 0 THEN '2. Low Margin Deficit'
        ELSE '3. Structural Heavy Deficit'
    END AS profitability_segment,

    -- 2. Multi-Year & Volume Scale Tier
    CASE 
        WHEN YEAR(clean_date) = 2014 THEN 'Peak Volume Scale (2014)'
        WHEN YEAR(clean_date) = 2015 THEN 'Peak Monetary Deficit (2015)'
        WHEN YEAR(clean_date) = 2016 THEN 'Volume Contraction (2016)'
        ELSE 'Baseline Launch (2013)'
    END AS timeline_performance_tier,

    -- 3. Price Elasticity & Promotional Category
    CASE 
        WHEN (sales_rand / quantity_sold) < 33.00 THEN 'High Discount / Promo Spike (PED Sensitive)'
        WHEN (sales_rand / quantity_sold) BETWEEN 33.00 AND 36.75 THEN 'Below COGS Baseline (Structural Loss)'
        ELSE 'Target Price Floor (Above R36.75 COGS)'
    END AS promo_elasticity_category,

    -- 4. Quarterly Performance & Seasonality Segment
    CASE 
        WHEN YEAR(clean_date) = 2013 AND QUARTER(clean_date) = 4 THEN '2013-Q4 (Launch Phase)'
        WHEN YEAR(clean_date) = 2014 AND QUARTER(clean_date) IN (2, 3) THEN '2014 Peak Volume Period'
        WHEN YEAR(clean_date) = 2015 AND QUARTER(clean_date) = 4 THEN '2015-Q4 (Maximum Deficit Quarter)'
        WHEN YEAR(clean_date) = 2016 THEN CONCAT('2016-Q', QUARTER(clean_date), ' (Contraction Phase)')
        ELSE CONCAT(YEAR(clean_date), '-Q', QUARTER(clean_date))
    END AS quarterly_performance_period,

    CASE 
        WHEN QUARTER(clean_date) = 1 THEN 'Q1: Post-Holiday Recovery'
        WHEN QUARTER(clean_date) = 2 THEN 'Q2: Mid-Year Peak'
        WHEN QUARTER(clean_date) = 3 THEN 'Q3: Spring Push'
        WHEN QUARTER(clean_date) = 4 THEN 'Q4: Year-End Holiday Volume'
    END AS quarterly_seasonality_segment,

    -- 5. Strategic Action Recommendation Tag
    CASE 
        WHEN (sales_rand / quantity_sold) < 36.75 AND (sales_rand - cost_of_sales_rand) < 0 
            THEN 'Re-anchor Price Floor'
        WHEN (sales_rand / quantity_sold) < 33.00 
            THEN 'Terminate Deep Promo'
        ELSE 'Maintain & Monitor Margin'
    END AS strategic_recommendation_tag

FROM blsales.fnb.bl_fnb_sales_case_study;

========================================================================================
---QUESTION 5b: Does the product perform better or worse on promotion?
========================================================================================

---ANSWER: 
---It performs WORSE overall.

---STRATEGIC EXPLANATION:

---1. Volume vs. Profit Paradox:
   - While discounting price by ~13% drives huge demand spikes (over +200% volume increase), 
     the gross profit margin (promo_gp_pct) drops to -11.5% (worse than the baseline loss 
     of -3.81%).

---2. Why It Fails (Negative Unit Economics):
   - Because the average unit cost (~R36.75) is higher than even the regular retail price 
     (R35.40), lowering the price further to R30.70 means every unit sold loses even 
     more money on a per-unit basis (a loss of -R6.05 per unit during promotions vs -R1.35 
     at baseline).

---3. Business Conclusion:
   - Promotional discounts sell a massive amount of volume due to high price elasticity 
     (PED = -15.44), but because unit economics are fundamentally broken, running promotions 
     only accelerates total cash burn and deepens overall gross losses.


