USE PrescriptionsDB;
GO

ALTER TABLE Prescriptions
ADD FOREIGN KEY (PRACTICE_CODE) REFERENCES Medical_Practice (PRACTICE_CODE);

ALTER TABLE Prescriptions
ADD FOREIGN KEY (BNF_CODE) REFERENCES Drugs (BNF_CODE);

--Solution to Part (2) of Task 2
SELECT * FROM Drugs
WHERE [BNF_DESCRIPTION] LIKE '%tablet%' OR [BNF_DESCRIPTION] LIKE '%capsule%';

--Solution to Part (3) of Task 2

SELECT PRESCRIPTION_CODE, ROUND(ITEMS*QUANTITY, 0) AS Total_Quantity
FROM Prescriptions;

--Solution to Part (4) of Task 2

SELECT DISTINCT [CHEMICAL_SUBSTANCE_BNF_DESCR] FROM Drugs;

--Solution to Part (5) of Task 2
SELECT 
  Drugs.BNF_CHAPTER_PLUS_CODE, 
  COUNT(Prescriptions.PRESCRIPTION_CODE) AS Total_Prescriptions, 
  AVG(Prescriptions.ACTUAL_COST) AS Average_Cost, 
  MIN(Prescriptions.ACTUAL_COST) AS Minimum_Cost, 
  MAX(Prescriptions.ACTUAL_COST) AS Maximum_Cost
FROM Prescriptions
INNER JOIN Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
GROUP BY Drugs.BNF_CHAPTER_PLUS_CODE

--Solution to Part (6) of Task 2

SELECT 
  Medical_Practice.PRACTICE_NAME, 
  Prescriptions.PRESCRIPTION_CODE, 
  Prescriptions.ACTUAL_COST,
  Drugs.BNF_DESCRIPTION AS Most_Expensive_Prescriptions_Over_4000GBP
FROM 
  Medical_Practice 
INNER JOIN 
  Prescriptions ON Medical_Practice.PRACTICE_CODE = Prescriptions.PRACTICE_CODE
INNER JOIN
Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
WHERE 
  Prescriptions.ACTUAL_COST > 4000 AND
  Prescriptions.ACTUAL_COST = (
    SELECT MAX(ACTUAL_COST) 
    FROM Prescriptions 
    WHERE [dbo].[Prescriptions].PRACTICE_CODE = [dbo].[Medical_Practice].PRACTICE_CODE
  )
ORDER BY 
  Prescriptions.ACTUAL_COST DESC;



  --five other queries required in part (7) of Task 2

  --This query returns total prescriptions by category of drugs, and sorts from the most prescribed to the least prescribed category
  SELECT 
  Drugs.BNF_CHAPTER_PLUS_CODE, 
  COUNT(Prescriptions.PRESCRIPTION_CODE) AS Total_Prescriptions
  FROM Prescriptions
INNER JOIN Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
GROUP BY Drugs.BNF_CHAPTER_PLUS_CODE
ORDER BY Total_Prescriptions DESC;
  

  --This query returns the total number of prescriptions made by each medical practice in Bolton, 
--ordered by the practice with the highest number of prescriptions first.

SELECT Practice_Name, COUNT(*) AS [Total Prescriptions]
FROM Medical_Practice
JOIN Prescriptions ON Medical_Practice.Practice_Code = Prescriptions.Practice_Code
GROUP BY Practice_Name
ORDER BY [Total Prescriptions] DESC;


--The query below returns the total number of prescriptions made for each drug, 
--ordered by the drug with the highest number of prescriptions first.

SELECT BNF_Description, COUNT(*) AS [Total Prescriptions]
FROM Drugs
JOIN Prescriptions ON Drugs.BNF_Code = Prescriptions.BNF_Code
GROUP BY BNF_Description
ORDER BY [Total Prescriptions] DESC;

--This query returns the average medication prescribed by each medical practice in Bolton, 
--ordered by the practice with the highest average quantity first.

SELECT Practice_Name, AVG(QUANTITY * ITEMS) AS [Average Quantity]
FROM Medical_Practice
JOIN Prescriptions ON Medical_Practice.Practice_Code = Prescriptions.Practice_Code
GROUP BY Practice_Name
ORDER BY [Average Quantity] DESC;

--The fifth query returns the total number of prescriptions made by each medical practice in Bolton 
--that included the drug with BNF code '0404000M0AAAAAA'. 

SELECT Practice_Name, COUNT(*) AS [Total Prescriptions]
FROM Medical_Practice
WHERE EXISTS (
SELECT * FROM Prescriptions
WHERE Prescriptions.Practice_Code = Medical_Practice.Practice_Code
AND Prescriptions.BNF_Code = '0404000M0AAAAAA'
)
GROUP BY Practice_Name;

GO

--the stored procedure query below is used to find the number of times a drug has been prescribed by a medical practice

 CREATE PROCEDURE dbo.GetPrescriptionsByDrugAndPractice
    @drug_code NVARCHAR(50),
    @practice_code NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS Prescriptions
    FROM Prescriptions
    WHERE BNF_CODE = @drug_code
        AND PRACTICE_CODE = @practice_code;
END

EXEC dbo.GetPrescriptionsByDrugAndPractice @drug_code = '0407010F0BSAAAH', @practice_code = 'P82015';

