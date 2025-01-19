/* This query aim to identify all the remote job postings published 
in 2023 for the data analyst role*/

SELECT company_dim.name AS name, 
job_title_short AS title,
job_title AS role,
job_location AS location,
job_posted_date AS date,
salary_year_avg AS salary
FROM job_postings_fact_staging
INNER JOIN company_dim ON company_dim.company_id = job_postings_fact_staging.company_id
WHERE job_work_from_home = TRUE AND job_title_short = 'Data Analyst' AND 
EXTRACT(YEAR FROM job_posted_date) = 2023 AND salary_year_avg IS NOT NULL
ORDER BY salary DESC
LIMIT 10 