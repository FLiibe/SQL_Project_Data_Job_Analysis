/* This query aim to identify all the remote job postings published 
in 2023 for the data analyst role*/

SELECT
company_dim.name AS company_name,
job_postings_fact.job_id AS id,
job_postings_fact.job_title_short AS title,
job_postings_fact.job_location AS location,
job_postings_fact.salary_year_avg AS yearly_salary,
job_postings_fact.job_work_from_home AS remote,
job_postings_fact.job_schedule_type AS type
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_title_short = 'Data Analyst' AND job_postings_fact.job_location IN ('Anywhere') AND job_postings_fact.salary_year_avg IS NOT NULL AND job_work_from_home = TRUE
GROUP BY title, location, yearly_salary, company_name, type, id
ORDER BY yearly_salary DESC

