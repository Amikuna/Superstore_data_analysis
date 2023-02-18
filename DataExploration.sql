USE db

SELECT * FROM SampleSuperstore

--remove duplicates
WITH dp AS(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY City,
			 ShipMode,
			 Segment,
			 State,
			 Subcategory,
			 PostalCode,
			 Sales,
			 Quantity,
			 Profit
			 ORDER BY Sales
) AS Row_num
FROM SampleSuperstore
)
DELETE FROM dp
WHERE Row_num>1

--Which is the least profitable state?
SELECT State, ROUND(SUM(Profit), 2) AS Total_Profit FROM SampleSuperstore
GROUP BY State ORDER BY Total_Profit


--The most profitable City
SELECT City, ROUND(SUM(Profit)/(SELECT SUM(Profit) FROM SampleSuperstore)*100,2) as perct FROM SampleSuperstore
GROUP BY City ORDER BY perct DESC
--As we can see New York City takes 21.7 percent of the total profit

--Which Segment is the least profitable?
SELECT Segment, ROUND(SUM(Profit),2) AS Total_Profit FROM SampleSuperstore
GROUP BY Segment ORDER BY Total_Profit

--The least profitable category and subcategory
SELECT Category, SubCategory, ROUND(SUM(Profit),2) AS Total_Profit FROM SampleSuperstore
GROUP BY Category, SubCategory ORDER BY Total_Profit

--As we can see tables, bookcases and supplies are not profitable for a company

-- let's see product sales
SELECT Category, SubCategory, ROUND(SUM(Sales),2) AS Total_Sales FROM SampleSuperstore
GROUP BY Category, SubCategory ORDER BY Total_Sales DESC

--Even though company makes a big loss selling tables it is the 4th best selling product and bookcases are also in top 9
--Do they sell these product for cheap price

SELECT SubCategory, ROUND(AVG(Discount)*100,2) AS Avg_discount FROM SampleSuperstore
GROUP BY SubCategory ORDER BY Avg_discount DESC

--Tables and bookcases have relatively high discounts on average than other products

--Calculate average cost of the product in each subcategory
SELECT SubCategory, ROUND(AVG((Sales-Profit)/Quantity),2) AS Cost FROM SampleSuperstore
WHERE Discount=0
GROUP BY SubCategory ORDER BY Cost DESC


--Does ship mode has any effect on profit
SELECT ShipMode, ROUND(SUM(Profit),2) as Total_Profit FROM SampleSuperstore
GROUP BY ShipMode ORDER BY Total_Profit

--Ship mode for poor performing products
SELECT ShipMode, SubCategory,  AVG(Profit) AS Avg_Profit FROM SampleSuperstore
WHERE SubCategory='Tables' or SubCategory='Bookcases' or SubCategory='Supplies'
GROUP BY ShipMode, SubCategory ORDER BY Avg_Profit DESC

--If shipping mode is "Same Day" company can still make profit with Bookcases and Supplies

--To sum up company should stop making discounts on tables, bookcases or stop selling them because it causes negative profit
--and if company stops selling them it will increase total profit

--compare total profit to profit without "Tables", "Bookcases" and "Supplies" 

WITH diff AS(
SELECT ROUND(SUM(Profit),2) AS Total_profit,
(SELECT ROUND(SUM(Profit),2) FROM SampleSuperstore
WHERE SubCategory != 'Tables' and SubCategory != 'Bookcases' and SubCategory != 'Supplies'
) AS Profit_after
FROM SampleSuperstore
)
SELECT Total_profit, Profit_after, Profit_after-Total_profit as Difference FROM diff
--So if company stops selling poor performing products it will have $22387.14 more profit

SELECT * FROM SampleSuperstore
WHERE Sales=7.056

DROP TABLE SampleSuperstore
