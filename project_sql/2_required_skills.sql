/* With this query our focus is drifted on the skills associated
of every remote data analyst job posting to better understand 
what are the necessary skills to land a data analyst job*/

WITH top_paying_role AS (SELECT
company_dim.name AS company_name,
job_postings_fact.job_id AS id,
job_postings_fact.job_title_short AS title,
job_postings_fact.job_location AS location,
job_postings_fact.salary_year_avg AS yearly_salary,
job_postings_fact.job_schedule_type AS type,
job_postings_fact.job_work_from_home AS remote
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_title_short = 'Data Analyst' AND job_postings_fact.job_location ILIKE ('Anywhere') AND job_postings_fact.salary_year_avg IS NOT NULL AND job_postings_fact.job_work_from_home = TRUE
GROUP BY title, location, yearly_salary, company_name, type, id
ORDER BY yearly_salary DESC)

SELECT
skills_dim.skills AS skill_name,
top_paying_role.id,
top_paying_role.title,
top_paying_role.location,
top_paying_role.yearly_salary,
top_paying_role.type,
top_paying_role.company_name
FROM top_paying_role
INNER JOIN skills_job_dim ON skills_job_dim.job_id = top_paying_role.id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY skill_name, id, title, location, yearly_salary, top_paying_role.type, company_name
ORDER BY yearly_salary DESC


