create schema e_commerce;
use e_commerce;
drop table ecommercechurn;

-- Creating a table
CREATE TABLE ecommercechurn 
(
    CustomerID	int,
    Churn	int,
    Tenure	int,
	PreferredLoginDevice	VARCHAR(40),
    CityTier	int,
    WarehouseToHome	int,
    PreferredPaymentMode	VARCHAR(40),
    Gender	VARCHAR(30),
    HourSpendOnApp	int,
    NumberOfDeviceRegistered	int,
    PreferedOrderCat	VARCHAR(100),
    SatisfactionScore	int,
    MaritalStatus	VARCHAR(50),
    NumberOfAddress	int,
    Complain	int,
    OrderAmountHikeFromlastYear	Text,
    CouponUsed	int,
    OrderCount	int,
    DaySinceLastOrder	double,
    CashbackAmount int
);

-- Loading the data file

LOAD DATA INFILE 
"E:/ECommerce_Churn.csv"
into table  ecommercechurn
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
lines terminated by '\n'
IGNORE 1 ROWS
(CustomerID, 
Churn,  @Tenure, PreferredLoginDevice, CityTier, @WarehouseToHome,  PreferredPaymentMode , Gender ,
@HourSpendOnApp , NumberOfDeviceRegistered , PreferedOrderCat , SatisfactionScore , MaritalStatus ,  NumberOfAddress , 
Complain ,@OrderAmountHikeFromlastYear , @CouponUsed , @OrderCount , @DaySinceLastOrder ,  CashbackAmount 
)    
SET Tenure  = NULLIF(@Tenure, ''),
	WarehouseToHome = nullif(@WarehouseToHome ,''),
    HourSpendOnApp = nullif(@HourSpendOnApp , ''),
    OrderAmountHikeFromlastYear  = nullif(@OrderAmountHikeFromlastYear, ''),
    CouponUsed = nullif(@CouponUsed , ''),
    OrderCount = nullif(@OrderCount ,''),
    DaySinceLastOrder = nullif(@DaySinceLastOrder, '');
    
    
SELECT 
    COUNT(CustomerID)
FROM
    ecommercechurn;
SELECT 
    *
FROM
    ecommercechurn;


SHOW VARIABLES LIKE 'secure_file_priv';


-- -------------- Data Cleaning  -------------

-- Total number of customers
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM ecommercechurn;

-- Checking for duplicate rows
SELECT CustomerID, COUNT(CustomerID) as Count
FROM ecommercechurn
GROUP BY CustomerID
Having COUNT(CustomerID) > 1;

-- Checking for NULL values

SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE daysincelastorder IS NULL;

-- Handling NULL values
-- we can get rid of the NULL values if we replace them with the mean value of the column

-- Step 1: Calculate the average tenure
SET @avg_tenure = (SELECT AVG(tenure) FROM ecommercechurn WHERE tenure IS NOT NULL);

-- Step 2: Update the table using the calculated average
UPDATE ecommercechurn
SET tenure = COALESCE(tenure, @avg_tenure);

SET @avg_Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM ecommercechurn WHERE Hourspendonapp IS NOT NULL);
UPDATE ecommercechurn
SET Hourspendonapp = coalesce(Hourspendonapp, @avg_Hourspendonapp);

SET @avg_orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM ecommercechurn WHERE orderamounthikefromlastyear IS NOT NULL);
UPDATE ecommercechurn
SET orderamounthikefromlastyear = coalesce(orderamounthikefromlastyear, @avg_orderamounthikefromlastyear);

SET @avg_WarehouseToHome = (SELECT AVG(WarehouseToHome) FROM ecommercechurn WHERE WarehouseToHome IS NOT NULL);
UPDATE ecommercechurn
SET WarehouseToHome = coalesce(WarehouseToHome, @avg_WarehouseToHome);

SET @avg_couponused = (SELECT AVG(couponused) FROM ecommercechurn WHERE couponused IS NOT NULL);
UPDATE ecommercechurn
SET couponused = coalesce(couponused, @avg_couponused);

SET @avg_ordercount = (SELECT AVG(ordercount) FROM ecommercechurn WHERE ordercount IS NOT NULL);
UPDATE ecommercechurn
SET ordercount = coalesce(ordercount, @avg_ordercount);

SET @avg_daysincelastorder = (SELECT AVG(daysincelastorder) FROM ecommercechurn WHERE daysincelastorder IS NOT NULL);
UPDATE ecommercechurn
SET daysincelastorder = coalesce(daysincelastorder, @avg_daysincelastorder);


-- Creating a new column from an already existing “churn” column
ALTER TABLE ecommercechurn
ADD CustomerStatus NVARCHAR(50);

UPDATE ecommercechurn
SET CustomerStatus = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END ;

select churn, CustomerStatus from ecommercechurn;

--  Creating a new column from an already existing “complain” column
ALTER TABLE ecommercechurn
ADD ComplainRecieved NVARCHAR(10);

UPDATE ecommercechurn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END;

select distinct complainrecieved from ecommercechurn;

-- Checking values in each column for correctness and accuracy

select * from ecommercechurn;

-- Fixing redundancy in “PreferedLoginDevice” Column

select distinct preferredlogindevice 
from ecommercechurn;

UPDATE ecommercechurn
SET preferredlogindevice = 'phone'
WHERE preferredlogindevice = 'mobile phone';


-- Fixing redundancy in “PreferedOrderCat” Column

select distinct preferedordercat 
from ecommercechurn;

UPDATE ecommercechurn
SET preferedordercat = 'Mobile Phone'
WHERE Preferedordercat = 'Mobile';

-- Fixing redundancy in “PreferredPaymentMode” Column

select distinct PreferredPaymentMode 
from ecommercechurn;

UPDATE ecommercechurn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD';

select* from ecommercechurn;

-- Fixing wrongly entered values in “WarehouseToHome” column

SELECT DISTINCT warehousetohome
FROM ecommercechurn;

UPDATE ecommercechurn
SET warehousetohome = '27'
WHERE warehousetohome = '127';

UPDATE ecommercechurn
SET warehousetohome = '26'
WHERE warehousetohome = '126';


-- -------------Data Analysis --------------------

-- 1. What is the overall customer churn rate?

SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ecommercechurn) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ecommercechurn
WHERE CustomerStatus = 'churned') AS Churned;

-- 2. How does the churn rate vary based on the preferred login device?

SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY preferredlogindevice;

-- 3. What is the distribution of customers across different city tiers?

SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY citytier
ORDER BY churnrate DESC;
select * from ecommercechurn;
-- 4. Is there any correlation between the warehouse-to-home distance and customer churn?

ALTER TABLE ecommercechurn
ADD warehousetohomerange NVARCHAR(50);

UPDATE ecommercechurn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;


SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC;

-- 5. Which is the most preferred payment mode among churned customers?

SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS decimal(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC;

-- 6. What is the typical tenure for churned customers?

ALTER TABLE ecommercechurn
ADD TenureRange NVARCHAR(50);

UPDATE ecommercechurn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END;

SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY Churnrate DESC;

-- 7. Is there any difference in churn rate between male and female customers?

SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY gender
ORDER BY Churnrate DESC;

-- 8. How does the average time spent on the app differ for churned and non-churned customers?

SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommercechurn
GROUP BY customerstatus;

-- 9. Does the number of registered devices impact the likelihood of churn?

SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC;

-- 10. Which order category is most preferred among churned customers?

SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferedordercat
ORDER BY Churnrate DESC;

-- 11. Is there any relationship between customer satisfaction scores and churn?

SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC;

-- 12. Does the marital status of customers influence churn behavior?

SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY maritalstatus
ORDER BY Churnrate DESC;

-- 13. How many addresses do churned customers have on average?

SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ecommercechurn
WHERE customerstatus = 'Churned';

-- 14. Do customer complaints influence churned behavior?

SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY complainrecieved
ORDER BY Churnrate DESC;

-- 15. How does the use of coupons differ between churned and non-churned customers?

SELECT customerstatus, SUM(couponused) AS SumofCouponUsed
FROM ecommercechurn
GROUP BY customerstatus;

-- 16. What is the average number of days since the last order for churned customers?

SELECT AVG(daysincelastorder) AS AverageNumofDaysSinceLastOrder
FROM ecommercechurn
WHERE customerstatus = 'churned';

-- 17. Is there any correlation between cashback amount and churn rate?

ALTER TABLE ecommercechurn
ADD cashbackamountrange NVARCHAR(50);

UPDATE ecommercechurn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END; 

SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC;

-- Insight Section
-- The dataset includes 5,630 customers, providing a substantial sample size for analysis.
-- The overall churn rate is 16.84%, indicating significant customer attrition.
-- Customers who prefer logging in with a computer have slightly higher churn rates compared to phone users, suggesting different usage patterns and preferences.
-- Tier 1 cities have lower churn rates than Tier 2 and Tier 3 cities, possibly due to competition and customer preferences.
-- Proximity to the warehouse affects churn rates, with closer customers showing lower churn, highlighting the importance of optimizing logistics and delivery strategies.
-- “Cash on Delivery” and “E-wallet” payment modes have higher churn rates, while “Credit Card” and “Debit Card” have lower churn rates, indicating the influence of payment preferences on churn.
-- Longer tenure is associated with lower churn rates, emphasizing the need for building customer loyalty early on.
-- Male customers have slightly higher churn rates than female customers, although the difference is minimal.
-- App usage time does not significantly differentiate between churned and non-churned customers.
-- More registered devices correlate with higher churn rates, suggesting the need for consistent experiences across multiple devices.
-- “Mobile Phone” order category has the highest churn rate, while “Grocery” has the lowest, indicating the importance of tailored retention strategies for specific categories.
-- Highly satisfied customers (rating 5) have a relatively higher churn rate, highlighting the need for proactive retention strategies at all satisfaction levels.
-- Single customers have the highest churn rate, while married customers have the lowest, indicating the influence of marital status on churn.
-- Churned customers have an average of four associated addresses, suggesting higher mobility.
-- Customer complaints are prevalent among churned customers, emphasizing the importance of addressing concerns to minimize churn.
-- Coupon usage is higher among non-churned customers, showcasing the effectiveness of loyalty rewards and personalized offers.
-- Churned customers have had a short time since their last order, indicating recent disengagement and the need for improved customer experience and retention initiatives.
-- Moderate cashback amounts correspond to higher churn rates, while higher amounts lead to lower churn, suggesting the positive impact of higher cashback on loyalty.