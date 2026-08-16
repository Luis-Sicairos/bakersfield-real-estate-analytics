CREATE DATABASE bakersfield_real_estate;
USE bakersfield_real_estate;

CREATE TABLE weekly_market 
(
    Metro VARCHAR(100),
    State VARCHAR(10),
    Date DATE,
    Inventory DOUBLE,
    New_Listings DOUBLE,
    Median_List_Price DOUBLE,
    Sales_Count DOUBLE,
    Median_Sale_Price DOUBLE,
    Sale_to_List_Ratio DOUBLE,
    Pct_Sold_Above_List DOUBLE,
    Days_to_Pending DOUBLE,
    Pct_Listings_Price_Cut DOUBLE,
    Price_Cut_Amount DOUBLE
);

CREATE TABLE home_values (
    City VARCHAR(100),
    State VARCHAR(10),
    County VARCHAR(100),
    Date DATE,
    Home_Value DOUBLE
);

SELECT *
FROM weekly_market
ORDER BY Date DESC
LIMIT 5;

SELECT
    Date,
    Median_Sale_Price,
    Inventory,
    Days_to_Pending,
    Sale_to_List_Ratio,
    Pct_Listings_Price_Cut
FROM weekly_market
ORDER BY Date DESC
LIMIT 1;

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY Date DESC)  AS rn
    FROM weekly_market
)

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY Date DESC) AS rn
    FROM weekly_market
)
SELECT
    current.Date,
    current.Median_Sale_Price,
    ROUND(
        (current.Median_Sale_Price - prior.Median_Sale_Price)
        / prior.Median_Sale_Price * 100,
        2
    ) AS Median_Sale_Price_4W_Change_Pct,

    current.Inventory,
    ROUND(
        (current.Inventory - prior.Inventory)
        / prior.Inventory * 100,
        2
    ) AS Inventory_4W_Change_Pct,

    current.Days_to_Pending,
    ROUND(
        current.Days_to_Pending - prior.Days_to_Pending,
        1
    ) AS Days_to_Pending_4Week_Change

FROM ranked current
JOIN ranked prior
    ON prior.rn = current.rn + 4
WHERE current.rn = 1;

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY Date DESC) AS rn
    FROM weekly_market
)
SELECT
    current.Date,

    current.Median_Sale_Price,
    ROUND(
        (current.Median_Sale_Price - prior.Median_Sale_Price)
        / prior.Median_Sale_Price * 100,
        2
    ) AS Median_Sale_Price_YoY_Pct,

    current.Inventory,
    ROUND(
        (current.Inventory - prior.Inventory)
        / prior.Inventory * 100,
        2
    ) AS Inventory_YoY_Pct,

    current.Median_List_Price,
    ROUND(
        (current.Median_List_Price - prior.Median_List_Price)
        / prior.Median_List_Price * 100,
        2
    ) AS Median_List_Price_YoY_Pct,

    current.Days_to_Pending,
    ROUND(
        current.Days_to_Pending - prior.Days_to_Pending,
        1
    ) AS Days_to_Pending_YoY_Change

FROM ranked current
JOIN ranked prior
    ON prior.rn = current.rn + 52
WHERE current.rn = 1;

CREATE OR REPLACE VIEW market_kpi_snapshot AS

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY Date DESC) AS rn
    FROM weekly_market
)

SELECT
    current.Date AS Latest_Date,

    current.Median_Sale_Price,
    ROUND(
        (current.Median_Sale_Price - four_week.Median_Sale_Price)
        / four_week.Median_Sale_Price * 100,
        2
    ) AS Median_Sale_Price_4W_Change_Pct,
    ROUND(
        (current.Median_Sale_Price - year_ago.Median_Sale_Price)
        / year_ago.Median_Sale_Price * 100,
        2
    ) AS Median_Sale_Price_YoY_Pct,

    current.Inventory,
    ROUND(
        (current.Inventory - four_week.Inventory)
        / four_week.Inventory * 100,
        2
    ) AS Inventory_4W_Change_Pct,
    ROUND(
        (current.Inventory - year_ago.Inventory)
        / year_ago.Inventory * 100,
        2
    ) AS Inventory_YoY_Pct,

    current.Median_List_Price,

    current.Days_to_Pending,
    ROUND(
        current.Days_to_Pending - four_week.Days_to_Pending,
        1
    ) AS Days_to_Pending_4W_Change,
    ROUND(
        current.Days_to_Pending - year_ago.Days_to_Pending,
        1
    ) AS Days_to_Pending_YoY_Change,

    current.Sale_to_List_Ratio,
    current.Pct_Sold_Above_List,
    current.Pct_Listings_Price_Cut,
    current.Price_Cut_Amount,
    current.New_Listings,
    current.Sales_Count

FROM ranked current
JOIN ranked four_week
    ON four_week.rn = current.rn + 4
JOIN ranked year_ago
    ON year_ago.rn = current.rn + 52

WHERE current.rn = 1;

SELECT *
FROM market_kpi_snapshot;

CREATE OR REPLACE VIEW latest_home_value AS

SELECT
    City,
    State,
    County,
    Date AS Latest_Home_Value_Date,
    Home_Value
FROM home_values
WHERE Date = (
    SELECT MAX(Date)
    FROM home_values
);

SELECT *
FROM latest_home_value;

