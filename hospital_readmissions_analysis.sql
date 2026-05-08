SELECT 
    "State",
    COUNT(DISTINCT "Facility ID") AS num_hospitals,
    AVG(CAST("Excess Readmission Ratio" AS NUMERIC)) AS avg_excess_readmission
FROM hospital_readmissions
WHERE "Excess Readmission Ratio" != 'N/A'
GROUP BY "State"
ORDER BY avg_excess_readmission DESC;

SELECT 
    "Measure Name",
    COUNT(*) AS num_hospitals,
    AVG(CAST("Excess Readmission Ratio" AS NUMERIC)) AS avg_excess_ratio,
    MIN(CAST("Excess Readmission Ratio" AS NUMERIC)) AS min_ratio,
    MAX(CAST("Excess Readmission Ratio" AS NUMERIC)) AS max_ratio
FROM hospital_readmissions
WHERE "Excess Readmission Ratio" != 'N/A'
GROUP BY "Measure Name"
ORDER BY avg_excess_ratio DESC;

SELECT 
    "Facility Name",
    "State",
    COUNT("Measure Name") AS num_conditions,
    AVG(CAST("Excess Readmission Ratio" AS NUMERIC)) AS avg_excess_ratio,
    SUM(CAST("Number of Discharges" AS NUMERIC)) AS total_discharges
FROM hospital_readmissions
WHERE "Excess Readmission Ratio" != 'N/A'
AND "Number of Discharges" != 'N/A'
GROUP BY "Facility Name", "State"
HAVING COUNT("Measure Name") >= 3
ORDER BY avg_excess_ratio DESC
LIMIT 20;

SELECT 
    "Facility Name",
    "Facility ID",
    "State",
    "Measure Name",
    "Number of Discharges",
    "Excess Readmission Ratio",
    "Predicted Readmission Rate",
    "Expected Readmission Rate",
    "Number of Readmissions",
    "Start Date",
    "End Date"
FROM hospital_readmissions
WHERE "Excess Readmission Ratio" != 'N/A'
AND "Number of Discharges" != 'N/A'
AND "Number of Readmissions" != 'N/A';