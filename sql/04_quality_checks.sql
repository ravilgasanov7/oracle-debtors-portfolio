-- 04_quality_checks.sql
-- Data quality checks + example analytics queries

-- 1) Rows with negative debt (should be reviewed)
SELECT *
FROM debtors_clean
WHERE debt_amount < 0;

-- 2) Duplicates by apartment
SELECT apartment_no, COUNT(*) cnt
FROM debtors_clean
GROUP BY apartment_no
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- 3) Biggest debtors
SELECT *
FROM (
  SELECT client_code, location, apartment_no, debt_amount,
         DENSE_RANK() OVER (ORDER BY debt_amount DESC) AS rnk
  FROM debtors_clean
)
WHERE rnk <= 20
ORDER BY debt_amount DESC;

-- 4) Debt stats by location
SELECT location,
       COUNT(*)                 AS rows_cnt,
       SUM(debt_amount)         AS total_debt,
       AVG(debt_amount)         AS avg_debt,
       MAX(debt_amount)         AS max_debt
FROM debtors_clean
GROUP BY location
ORDER BY total_debt DESC;

-- 5) Missing important fields
SELECT *
FROM debtors_clean
WHERE apartment_no IS NULL
   OR total_amount IS NULL;
