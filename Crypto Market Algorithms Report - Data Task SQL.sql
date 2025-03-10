SET NOCOUNT ON;

-- Common Table Expression (CTE) to calculate quarterly volumes for 2020
WITH quarter_volume as (
    SELECT 
        c.algorithm ,
        SUM(t.volume) as Volume,                 -- Total volume per algorithm per quarter
        DATEPART(quarter, dt) as quarters        -- Extract quarter (1-4) from date
    FROM coins AS c
    JOIN transactions as t ON t.coin_code = c.code
    WHERE DATEPART(year, dt) = 2020              -- Filter transactions for 2020 only
    GROUP BY c.algorithm, DATEPART(quarter, dt)   -- Group by algorithm and quarter
)

-- Main query to pivot quarterly data into columns (Q1-Q4)
SELECT 
    c.algorithm as AlgorithmName,
    COALESCE(ROUND(qv1.Volume, 6), 0) AS Q1,      -- Q1: Round to 6 decimals, replace NULL with 0
    COALESCE(ROUND(qv2.Volume, 6), 0) AS Q2,      -- Q2: Same as above
    COALESCE(ROUND(qv3.Volume, 6), 0) AS Q3,      -- Q3: Same as above
    COALESCE(ROUND(qv4.Volume, 6), 0) AS Q4       -- Q4: Same as above
FROM coins as c
-- Left join ensures all algorithms are included, even with no transactions in a quarter
LEFT JOIN quarter_volume as qv1 
    ON c.algorithm = qv1.algorithm AND qv1.quarters = 1
LEFT JOIN quarter_volume as qv2 
    ON c.algorithm = qv2.algorithm AND qv2.quarters = 2
LEFT JOIN quarter_volume as qv3 
    ON c.algorithm = qv3.algorithm AND qv3.quarters = 3
LEFT JOIN quarter_volume as qv4 
    ON c.algorithm = qv4.algorithm AND qv4.quarters = 4
-- WHERE clause excludes LTC (if required; verify if this is intended)
WHERE c.code NOT LIKE 'LTC'                       -- Exclude LTC (may need validation)
ORDER BY AlgorithmName ASC;                         -- Sort results by algorithm name


