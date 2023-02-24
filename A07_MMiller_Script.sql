--*************************************************************************--
-- Title: Assignment07
-- User: MMiller
-- Desc: This file demonstrates how to use Functions
-- Change Log: 
-- 2023-02-22, MMiller, Altering file for assignment 07
-- 2017-01-01,RRoot,Created File
--**************************************************************************--


--********************************************************************--
--[ Create the Database ]--
--********************************************************************--


BEGIN TRY
   USE  MASTER
   ;
   IF EXISTS (
              SELECT *
		        FROM SYS.databases 
		       WHERE NAME='Assignment07DB_MMiller'
		     )
   BEGIN
	          ALTER DATABASE Assignment07DB_MMiller
	            SET SINGLE_USER
	            WITH ROLLBACK IMMEDIATE -- Kicks everyone out of the DB
			  ;
	          DROP DATABASE Assignment07DB_MMiller
	          ;
   END
              CREATE DATABASE Assignment07DB_MMiller
			  ;
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Database Not Created.'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

USE Assignment07DB_MMiller
;
GO


--********************************************************************--
--[ Create the Tables ]--
--********************************************************************--

CREATE TABLE t_CATEGORIES
    (CATEGORY_ID int IDENTITY (1,1) NOT NULL 
	             CONSTRAINT pkc_CATEGORY_ID 
				 PRIMARY KEY CLUSTERED (CATEGORY_ID) -- IDENTITY (starts using,interval)
   , CATEGORY_NAME nvarchar(100) NOT NULL
     );
GO

CREATE TABLE t_PRODUCTS
    (PRODUCT_ID int IDENTITY (1,1) NOT NULL 
	             CONSTRAINT pkc_PRODUCT_ID 
				 PRIMARY KEY CLUSTERED (PRODUCT_ID)
   , PRODUCT_NAME nvarchar(100) NOT NULL
   , CATEGORY_ID int NULL 
                 CONSTRAINT fk_PRODUCT_CATEGORY_ID 
                 FOREIGN KEY (CATEGORY_ID) REFERENCES t_CATEGORIES(CATEGORY_ID) --ON DELETE CASCADE
   , UNIT_PRICE money NOT NULL
    );
GO
 
CREATE TABLE t_EMPLOYEES
    (EMPLOYEE_ID int IDENTITY(1,1) NOT NULL 
                 CONSTRAINT pkc_EMPLOYEE_ID 
                 PRIMARY KEY CLUSTERED (EMPLOYEE_ID) 
   , EMPLOYEE_FIRST_NAME NVARCHAR(100) NOT NULL 
   , EMPLOYEE_LAST_NAME NVARCHAR(100) NOT NULL
   , MANAGER_ID int NULL 
                 CONSTRAINT fk_MANAGER_ID 
                 FOREIGN KEY (MANAGER_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
     );
GO
  
CREATE TABLE t_INVENTORY
    (INVENTORY_ID int IDENTITY(1,1) NOT NULL 
               CONSTRAINT pk_INVENTORY_ID 
               PRIMARY KEY CLUSTERED (INVENTORY_ID)
   , INVENTORY_DATE date NOT NULL
   , EMPLOYEE_ID int NOT NULL 
               CONSTRAINT fk_INVENTORY_TO_EMPLOYEES 
               FOREIGN KEY (EMPLOYEE_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID) 
   , PRODUCT_ID int NOT NULL 
               CONSTRAINT fk_INVENTORY_PRODUCT_ID 
               FOREIGN KEY (PRODUCT_ID) REFERENCES t_PRODUCTS(PRODUCT_ID) --ON DELETE CASCADE
   , INVENTORY_COUNT int NOT NULL
    );
GO

 --********************************************************************--
--[ Add Addtional Constaints ]--
--********************************************************************--

-- Table Constraints: Categories (Table 1 of 4)
BEGIN
/*   ALTER TABLE dbo.t_CATEGORIES -- moved action to table creation avoid script run error
       ADD CONSTRAINT pkc_CATEGORY_ID 
       PRIMARY KEY CLUSTERED (CATEGORY_ID)
     ;
*/
	 ALTER TABLE dbo.t_CATEGORIES
	   ADD CONSTRAINT uq_CATEGORY_NAME
	   UNIQUE NONCLUSTERED (CATEGORY_NAME) -- Non-clustered is not ordered, is slower, requires a lookup, and is not stored with table.
     ;
END
GO

-- Table Constraints: Products (Table 2 of 4)
BEGIN
/*   ALTER TABLE dbo.t_PRODUCTS -- moved action to table creation avoid script run error
       ADD CONSTRAINT pkc_PRODUCT_ID
       PRIMARY KEY CLUSTERED (PRODUCT_ID)
	 ;
*/
     ALTER TABLE dbo.t_PRODUCTS
       ADD CONSTRAINT uq_PRODUCT_NAME
       UNIQUE (PRODUCT_NAME)
	 ;

/*   ALTER TABLE dbo.t_PRODUCTS -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_PRODUCT_CATEGORY_ID
	   FOREIGN KEY (CATEGORY_ID) REFERENCES t_CATEGORIES(CATEGORY_ID)
	 ;
*/
     ALTER TABLE dbo.t_PRODUCTS
       ADD CONSTRAINT ck_UNIT_PRICE_EqGt0
       CHECK (Unit_Price >= 0)
	 ;
END
GO

-- Table Constraints: Employees (Table 3 of 4)
/*
BEGIN
     ALTER TABLE dbo.t_Employees -- moved action to table creation avoid script run error
       ADD CONSTRAINT pkc_EMPLOYEE_ID
       PRIMARY KEY CLUSTERED (EMPLOYEE_ID)
     ;
     ALTER TABLE dbo.t_Employees -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_MANAGER_ID
       FOREIGN KEY (MANAGER_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
     ;
END
GO
*/

-- Table Constraints: Inventory (Table 4 of 4)
BEGIN
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT pk_INVENTORY_ID
       PRIMARY KEY (INVENTORY_ID)
     ;
*/
     ALTER TABLE dbo.t_INVENTORY
       ADD CONSTRAINT df_INVENTORY_DATE
       DEFAULT GETDATE() FOR INVENTORY_DATE
     ;
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_INVENTORY_PRODUCT_ID
       FOREIGN KEY (PRODUCT_ID) REFERENCES t_PRODUCTS(PRODUCT_ID)
     ;
*/
     ALTER TABLE dbo.t_INVENTORY
       ADD CONSTRAINT ck_INVENTORY_COUNT_EqGt0
       CHECK ([INVENTORY_COUNT] >= 0)
     ; 
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_INVENTORY_TO_EMPLOYEES
       FOREIGN KEY (EMPLOYEE_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
     ;
*/
END
GO


--********************************************************************--
--[ Adding Data ]--
--********************************************************************--

-- Categories Data (Table 1 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment07DB_MMiller.dbo.t_CATEGORIES
                  (CATEGORY_NAME)
            SELECT CATEGORYNAME
              FROM NORTHWIND.dbo.CATEGORIES
          ORDER BY CategoryID
	 COMMIT TRANSACTION
	 ;
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Categories not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Products Data (Table 2 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment07DB_MMiller.dbo.t_PRODUCTS 
                  (PRODUCT_NAME
				 , CATEGORY_ID
				 , UNIT_PRICE)
            SELECT PRODUCTNAME AS PRODUCT_NAME
			     , CATEGORYID AS CATEGORY_ID
				 , UNITPRICE AS UNIT_PRICE
		      FROM NORTHWIND.dbo.PRODUCTS
		  ORDER BY ProductID
	 COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Products not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Employees Data (Table 3 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment07DB_MMiller.dbo.t_EMPLOYEES
                  (EMPLOYEE_FIRST_NAME
				 , EMPLOYEE_LAST_NAME
				 , MANAGER_ID)
            SELECT e.FIRSTNAME as EMPLOYEE_FIRST_NAME
		         , e.LASTNAME as EMPLOYEE_LAST_NAME
			     , IsNULL (e.ReportsTo, e.EmployeeID)
		      FROM NORTHWIND.dbo.EMPLOYEES e
		  ORDER BY e.EmployeeID
	 COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Employees not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Inventory Data (Table 4 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment07DB_MMiller.dbo.t_INVENTORY
                  (INVENTORY_DATE
				 , EMPLOYEE_ID
				 , PRODUCT_ID
				 , INVENTORY_COUNT)
         SELECT '20170101' AS INVENTORY_DATE
		       , 5 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock AS INVENTORY_COUNT
           FROM NORTHWIND.dbo.PRODUCTS
          UNION
         SELECT '20170201' AS INVENTORYDATE
		       , 7 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock + 10 AS INVENTORY_COUNT -- Using this is to create a made up value
           FROM NORTHWIND.dbo.PRODUCTS
          UNION
         SELECT '20170301' AS INVENTORYDATE
		       , 9 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock + 20 AS INVENTORY_COUNT -- Using this is to create a made up value
		   FROM NORTHWIND.dbo.PRODUCTS 
		  ORDER BY 1, 2
	  COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Inventory not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

--********************************************************************--
--[ Show Data Tables ]--
--********************************************************************--
--SELECT * FROM ASSIGNMENT07DB_MMiller.dbo.t_CATEGORIES;
--SELECT * FROM ASSIGNMENT07DB_MMiller.dbo.t_PRODUCTS;
--SELECT * FROM ASSIGNMENT07DB_MMiller.dbo.t_EMPLOYEES;
--SELECT * FROM ASSIGNMENT07DB_MMiller.dbo.t_INVENTORY;



--********************************************************************--
--[ CREATE VIEWS ]--
--********************************************************************--

CREATE VIEW dbo.v_CATEGORIES WITH SCHEMABINDING
       AS
       SELECT 
         c.CATEGORY_ID
	   , c.CATEGORY_NAME
	   FROM dbo.t_CATEGORIES c
;
GO
				-- Testing Order By DESC vs ASC 
				-- SELECT * FROM Assignment07DB_MMiller.dbo.CATEGORIES ORDER BY Category_name ASC
				-- SELECT * FROM Assignment07DB_MMiller.dbo.CATEGORIES ORDER BY Category_name DESC

CREATE VIEW dbo.v_PRODUCTS WITH SCHEMABINDING
       AS
       SELECT
         p.PRODUCT_ID
	   , p.PRODUCT_NAME 
	   , p.CATEGORY_ID
	   , p.UNIT_PRICE 
	     FROM dbo.t_PRODUCTS p
; 
GO
CREATE VIEW dbo.v_EMPLOYEES WITH SCHEMABINDING
       AS
       SELECT
         e.EMPLOYEE_ID
	   , e.EMPLOYEE_FIRST_NAME 
	   , e.EMPLOYEE_LAST_NAME
	   , e.MANAGER_ID 
	     FROM dbo.t_EMPLOYEES e
; 
GO

CREATE VIEW dbo.v_INVENTORY WITH SCHEMABINDING
       AS
       SELECT
         i.INVENTORY_ID
	   , i.INVENTORY_DATE 
	   , i.EMPLOYEE_ID
	   , i.PRODUCT_ID
	   , i.INVENTORY_COUNT
	     FROM dbo.t_INVENTORY i
; 
GO

CREATE VIEW dbo.x_PRODUCT_INVENTORIES WITH SCHEMABINDING
       AS
SELECT TOP 100000
        P.PRODUCT_NAME
      , I.INVENTORY_DATE AS [INVENTORY_DATE]
      , CONCAT((FORMAT(I.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(I.INVENTORY_DATE))) AS [INVENTORY_DATES]
	  , I.INVENTORY_COUNT
  FROM dbo.v_PRODUCTS P
  JOIN dbo.v_INVENTORY I
    ON P.PRODUCT_ID  = I.PRODUCT_ID
 ORDER BY
       P.PRODUCT_NAME
	 , I.INVENTORY_DATE
;
GO

			     /*--[ Show Views Created ]--
			     SELECT * FROM dbo.v_CATEGORIES;
			     SELECT * FROM dbo.v_PRODUCTS;
			     SELECT * FROM dbo.v_EMPLOYEES;
			     SELECT * FROM dbo.v_INVENTORY;
				 */
--********************************************************************--
--[ CREATE TEMPORAL ]--
--********************************************************************--
/*
SELECT
        P.PRODUCT_NAME
      , I.INVENTORY_DATE
      , CONCAT((FORMAT(I.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(I.INVENTORY_DATE))) AS [INVENTORY_MONTH]
	  , I.INVENTORY_COUNT
  INTO #_PRODUCT_INVENTORIES 
  FROM dbo.v_PRODUCTS P
  JOIN dbo.v_INVENTORY I
    ON P.PRODUCT_ID  = I.PRODUCT_ID
 ORDER BY
       P.PRODUCT_NAME
	 , I.INVENTORY_DATE
;
GO
*/



--********************************************************************--
--[ QUESTIONS & ANSWERS]--
--********************************************************************--

Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts - 2.5 pts out of 50 pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

             --HINTS:
             --https:// database.guide/how-to-format-numbers-as-currency-in-sql-server-t-sql 

SELECT 
       P.PRODUCT_NAME            AS [PRODUCT_NAME]
     , FORMAT(P.UNIT_PRICE, 'C') AS [UNIT_PRICE]
  FROM dbo.v_PRODUCTS P
  ORDER BY
       P.PRODUCT_NAME
;
GO


-- Question 2 (10% of pts - 5 pts out of 50 pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.


SELECT
       C.CATEGORY_NAME AS [CATEGORY_NAME]
     , P.PRODUCT_NAME  AS [PRODUCT_NAME]
--     , C.CATEGORY_NAME + ' ' + '-' + ' ' + P.PRODUCT_NAME AS [CATEGORY_AND_PRODUCT]
     , FORMAT(P.UNIT_PRICE, 'C') AS [UNIT_PRICE]
  FROM dbo.v_CATEGORIES C
  JOIN dbo.v_PRODUCTS P
    ON P.CATEGORY_ID = C.CATEGORY_ID
 ORDER BY
       C.CATEGORY_NAME
     , P.PRODUCT_NAME
;
GO
             -- Questions:
             -- Does he mean just one column with Category and Product Names, like together?


-- Question 3 (10% of pts - 5 pts out of 50 pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

             --HINTS:
             --https:// www.w3schools.com/sql/func_sqlserver_month.asp
             --https:// www.w3schools.com/sql/func_sqlserver_year.asp

SELECT
        P.PRODUCT_NAME
      , I.INVENTORY_DATE
      , CONCAT((FORMAT(I.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(I.INVENTORY_DATE))) AS [INVENTORY_DATE]
--	  , I.INVENTORY_COUNT
  FROM dbo.v_PRODUCTS P
  JOIN dbo.v_INVENTORY I
    ON P.PRODUCT_ID  = I.PRODUCT_ID
 ORDER BY
       P.PRODUCT_NAME
	 , I.INVENTORY_DATE
;
GO

-- Question 4 (10% of pts - 5 pts out of 50 pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

CREATE VIEW dbo.v_PRODUCT_INVENTORIES WITH SCHEMABINDING
       AS
SELECT TOP 100000
        P.PRODUCT_NAME
--    , I.INVENTORY_DATE
      , CONCAT((FORMAT(I.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(I.INVENTORY_DATE))) AS [INVENTORY_DATE]
	  , I.INVENTORY_COUNT
  FROM dbo.v_PRODUCTS P
  JOIN dbo.v_INVENTORY I
    ON P.PRODUCT_ID  = I.PRODUCT_ID
 ORDER BY
       P.PRODUCT_NAME
	 , I.INVENTORY_DATE
;
GO
			     --[ SHOW VIEWS CREATED ]--
			     -- SELECT * FROM dbo.v_PRODUCT_INVENTORIES
				 

-- Question 5 (10% of pts - 5 pts out of 50 pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

CREATE VIEW v_CATEGORY_INVENTORIES 
       AS
SELECT TOP 10000
        C.CATEGORY_NAME        AS [CATEGORY_NAME]
--    , I.INVENTORY_DATE       AS [INVENTORY_DATE]
      , CONCAT((FORMAT(I.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(I.INVENTORY_DATE))) AS [INVENTORY_DATES]
	  , SUM(I.INVENTORY_COUNT) AS [COUNT]
  FROM dbo.v_CATEGORIES C
  JOIN dbo.v_PRODUCTS   P
    ON P.CATEGORY_ID = C.CATEGORY_ID
  JOIN dbo.v_INVENTORY  I
    ON I.PRODUCT_ID = P.PRODUCT_ID
 GROUP BY
       C.CATEGORY_NAME
     , I.INVENTORY_DATE
 ORDER BY
       C.CATEGORY_NAME
     , I.INVENTORY_DATE
;
GO
			     --[ SHOW VIEWS CREATED ]--
			     -- SELECT * FROM dbo.v_CATEGORY_INVENTORIES

-- Question 6 (10% of pts - 5 pts out of 50 pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

CREATE VIEW v_PRODUCT_INVENTORIES_WITH_PREVIOUS_MONTH_COUNTS
       AS
SELECT TOP 10000
	   v_PI.PRODUCT_NAME
     , CONCAT((FORMAT(v_PI.INVENTORY_DATE, 'MMMM')), ',',' ',(YEAR(v_PI.INVENTORY_DATE))) AS [INVENTORY_DATES]
	 , v_PI.INVENTORY_COUNT
	 , IIF(v_PI.INVENTORY_DATES LIKE '%JANUARY%'   
	       , 0
--         , LEAD(SUM(v_PI.INVENTORY_COUNT)) OVER(ORDER BY v_PI.PRODUCT_NAME)
		   , LAG(SUM(v_PI.INVENTORY_COUNT)) OVER(ORDER BY v_PI.PRODUCT_NAME)
		  ) AS [PRIOR_MONTH_INVENTORY]
  FROM dbo.x_PRODUCT_INVENTORIES v_PI
   GROUP BY
  	   v_PI.PRODUCT_NAME
     , v_PI.INVENTORY_DATE
	 , v_PI.INVENTORY_DATES
	 , v_PI.INVENTORY_COUNT
  ORDER BY
       v_PI.PRODUCT_NAME
	 , v_PI.INVENTORY_DATE
;
GO
  			     --[ SHOW VIEWS CREATED ]--
			     -- SELECT * FROM dbo.v_PRODUCT_INVENTORIES_WITH_PREVIOUS_MONTH_COUNTS

-- Question 7 (15% of pts - 7.5 pts out of 50 pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

CREATE VIEW v_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs
       AS
SELECT 
       v_PIwPMC.PRODUCT_NAME
	 , v_PIwPMC.INVENTORY_DATES
	 , v_PIwPMC.INVENTORY_COUNT
	 , v_PIwPMC.PRIOR_MONTH_INVENTORY
	 ,CAST((CASE 
	       WHEN v_PIwPMC.INVENTORY_COUNT < v_PIwPMC.PRIOR_MONTH_INVENTORY THEN -1
	       WHEN v_PIwPMC.INVENTORY_COUNT = v_PIwPMC.PRIOR_MONTH_INVENTORY THEN 0
	       WHEN v_PIwPMC.INVENTORY_COUNT > v_PIwPMC.PRIOR_MONTH_INVENTORY THEN 1
	       END) AS int)
	        AS CURRENT_vs_PREVIOUS_MONTH_KPI
  FROM v_PRODUCT_INVENTORIES_WITH_PREVIOUS_MONTH_COUNTS AS v_PIwPMC
;
GO
  			     --[ SHOW VIEWS CREATED ]--
			     -- SELECT * FROM dbo.v_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs

				 --[ INSTRUCTOR NOTES ]--
			     -- Important: This new view must use your v_PRODUCT_INVENTORIES_WITH_PREVIOUS_MONTH_COUNTS view!
				 -- Check that it works: Select * From v_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs;
go

-- Question 8 (25% of pts - 12.5 pts out of 50 pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

CREATE FUNCTION dbo.f_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs (@KPI int)
       RETURNS TABLE AS
	   RETURN
		   SELECT *
	         FROM dbo.v_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs v
	        WHERE v.CURRENT_vs_PREVIOUS_MONTH_KPI = (@KPI)
	   ;
GO

 			     --[ SHOW VIEWS CREATED ]--
                 -- Check that it works:
                    Select * From f_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs(1);
                    Select * From f_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs(0);
                    Select * From f_PRODUCT_INVENTORIES_with_PREVIOUS_MONTH_COUNTS_with_KPIs(-1);


/***************************************************************************************/
