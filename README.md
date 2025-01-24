# Introduction
Motivated by the goal of better understanding the data analyst job market, this project aims to identify the most lucrative and sought-after skills, simplifying the process for others to discover ideal job opportunities. Before proceeding with the analysis, I performed data cleaning to ensure the dataset was accurate, consistent, and ready for meaningful insights.
# Data Cleaning
1. **Remove duplicates**
2. **Standardize data**
3. **Null values or blank values**
4. **Remove columns and rows**

### *Let's create a new table (duplicate of our dataset).*

```sql
CREATE TABLE 
    job_postings_fact_staging
AS
TABLE 
    job_postings_fact;
```
### *Now, let's proceed to verify if we have duplicate with this query.*

```sql
SELECT 
    job_id, COUNT(*)
FROM 
    job_postings_fact_staging
GROUP BY 
    job_id
HAVING 
    COUNT(*) > 1
ORDER BY 
    job_id;
```
*Looks like we don't have duplicates*

### *Let's standardize checking every columns.*

```sql

SELECT 
    job_title, TRIM(job_title)
FROM 
    job_postings_fact_staging
WHERE 
    job_title <> TRIM(job_title)
ORDER by 
    job_title;
```
*Seem we have some rows to trim, let'so do it.*

```sql
UPDATE 
    job_postings_fact_staging
SET 
    job_title = TRIM(job_title);
```
*Done, let's move on with the following columns.*

```sql
SELECT 
    job_location, TRIM(job_location)
FROM 
    job_postings_fact_staging
WHERE 
    job_location <> TRIM(job_location);
```
*Here is all good, let's continue and eliminate 'via' from job_via column.*

```sql
UPDATE 
    job_postings_fact_staging
SET 
    job_via = REPLACE(job_via, 'via','')
WHERE 
    job_via LIKE 'via%';
```
*Now let's group job type. For example, 'contractor%' in 'contractor' and then trim.*
```sql
UPDATE 
    job_postings_fact_staging
SET 
    job_schedule_type = 
CASE
    WHEN job_schedule_type LIKE '%and%'THEN split_part(job_schedule_type,'and', 1)
    WHEN job_schedule_type LIKE '%,%' THEN split_part(job_schedule_type,',', 1)
    ELSE job_schedule_type
END;

UPDATE 
    job_postings_fact_staging
SET 
    job_schedule_type = TRIM(job_schedule_type);

SELECT DISTINCT 
    job_schedule_type
FROM 
    job_postings_fact_staging;
```
*Now we have grouped and modified the columns.*

```sql
UPDATE 
    job_postings_fact_staging
SET 
    job_posted_date= job_posted_date::DATE;

ALTER TABLE 
    job_postings_fact_staging
ALTER COLUMN 
    job_posted_date TYPE DATE 
USING 
    job_posted_date::DATE;
```
*Above, we changed the date from timestamp to date as we don't really need the time.*

### *Now, let's eliminate null values or blank values.*

```sql
DELETE FROM 
    job_postings_fact_staging
WHERE 
    salary_rate IS NULL;
```
*We have just deleted column with no salary as they give no usefull information.*

### * And lastly, let's verify if we have to remove any columns and/or rows.*

```sql
ALTER TABLE 
    job_postings_fact_staging
ADD COLUMN 
    salary_year_adjusted NUMERIC;
```
 *We insert a column to proportionate the rows with the hour salary with the rows with year salary.*

```sql
UPDATE 
    job_postings_fact_staging
SET 
    salary_year_adjusted = ROUND(
    CASE
        WHEN salary_year_avg IS NULL THEN salary_hour_avg*2080
        ELSE salary_year_avg
    END);
```
*Above, the calculation to round the column.*
```sql
SELECT 
    *
FROM 
    job_postings_fact_staging
```
### *And the data cleaning is complete!!!*

# Background
*Explore the landscape of data analytics careers.* Centered on the role of a data analyst, this project examines the highest-paying positions, most in-demand skills, and the intersection of high demand and competitive salaries in the field.

### The questions I wanted to answer through my SQL queries were:
1. What are the top-paying data analyst jobs? 
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

# Tool i used
In my exploration of the data analyst job market, I utilized several essential tools:

- **SQL:** The core of my analysis, enabling me to query databases and extract key insights.
- **PostgreSQL:** The preferred database management system, perfectly suited for managing job posting data.
- **Visual Studio Code:** My primary tool for managing databases and running SQL queries.
- **Git & GitHub:** Crucial for version control, sharing SQL scripts, and tracking the progress of my analysis.

# The Analysis
Each query in this project was designed to explore specific facets of the data analyst job market. Here's my approach to each question:

### 1. **Top Paying Data Analyst Jobs**
To uncover the highest-paying roles, I filtered data analyst positions by average annual salary and location, with a particular focus on remote opportunities. This analysis highlights the most lucrative positions in the field.
```sql
SELECT 
    company_dim.name AS name, 
    job_title_short AS title,
    job_title AS role,
    job_location AS location,
    job_posted_date AS date,
    salary_year_avg AS salary
FROM 
    job_postings_fact_staging
INNER JOIN 
    company_dim ON company_dim.company_id = job_postings_fact_staging.company_id
WHERE 
    job_work_from_home = TRUE AND job_title_short = 'Data Analyst' AND EXTRACT(YEAR FROM job_posted_date) = 2023 AND salary_year_avg IS NOT NULL
ORDER BY 
    salary DESC
LIMIT 10 
```
Here’s an overview of the top data analyst jobs in 2023:

- **Wide Salary Range:** The top 10 highest-paying roles range from $184,000 to $650,000, showcasing the field's substantial earning potential.
- **Diverse Employers:** Companies such as SmartAsset, Meta, and AT&T are leading the way with high salaries, reflecting demand across various industries.
- **Varied Job Titles:** The field offers a wide range of roles, from Data Analyst to Director of Analytics, emphasizing the diversity and specialization opportunities within data analytics


  ![Top Paying Roles](project_sql\data_job_analysis\asset\1.project_sql.png)

### 2. **Skills for Top Paying Jobs**
To identify the skills demanded for the highest-paying jobs, I combined job posting data with skills information. This analysis offers valuable insights into the qualifications employers prioritize for high-salary roles.
```sql
WITH top_paying_role AS 
(
    SELECT
        company_dim.name AS company_name,
        job_postings_fact_staging.job_id AS id,
        job_postings_fact_staging.job_title_short AS title,
        job_postings_fact_staging.job_location AS location,
        job_postings_fact_staging.salary_year_avg AS yearly_salary,
        job_postings_fact_staging.job_schedule_type AS type,
        job_postings_fact_staging.job_work_from_home AS remote
FROM 
        job_postings_fact_staging
LEFT JOIN 
        company_dim ON job_postings_fact_staging.company_id = company_dim.company_id
WHERE 
        job_postings_fact_staging.job_title_short = 'Data Analyst' AND job_postings_fact_staging.job_location ILIKE ('Anywhere') AND job_postings_fact_staging.salary_year_avg IS NOT NULL AND job_postings_fact_staging.job_work_from_home = TRUE
GROUP BY 
        title, location, yearly_salary, company_name, type, id, remote
ORDER BY 
        yearly_salary DESC
)

SELECT
        skills_dim.skills AS skill_name,
        top_paying_role.id,
        top_paying_role.title,
        top_paying_role.location,
        top_paying_role.yearly_salary,
        top_paying_role.type,
        top_paying_role.company_name
FROM 
        top_paying_role
INNER JOIN 
        skills_job_dim ON skills_job_dim.job_id = top_paying_role.id
INNER JOIN 
        skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY 
        skill_name, id, title, location, yearly_salary, top_paying_role.type, company_name
ORDER BY 
        yearly_salary DESC
```

Based on the analysis of the job postings, here are the key insights about required skills for data analyst roles:

- **SQL** is the most demanded skill, appearing in 8 out of 10 job postings, highlighting its crucial importance in data analysis roles.
- **Python** follows closely as the second most required skill, mentioned in 7 job listings.
- **Tableau** ranks third with 6 mentions, showing the importance of data visualization tools.

  ![Top Skills Requirred](project_sql\data_job_analysis\asset\2.skills_freq.PNG)

### 3. **In-Demand Skills for Data Analysts**
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

```sql
SELECT
    skills_dim.skills AS skill_name,
    COUNT(skills_dim.skills)
FROM 
    job_postings_fact_staging
INNER JOIN 
    skills_job_dim ON skills_job_dim.job_id = job_postings_fact_staging.job_id
INNER JOIN 
    skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE 
    job_postings_fact_staging.job_title_short = 'Data Analyst' AND job_postings_fact_staging.job_location IN ('Anywhere') AND job_postings_fact_staging.salary_year_avg IS NOT NULL AND job_postings_fact_staging.job_work_from_home = TRUE
GROUP BY 
    skill_name
ORDER BY 
    COUNT(skills_dim.skills) DESC
LIMIT 10
```


| Skill Name | Count |
|------------|-------|
| SQL        | 398   |
| Excel      | 256   |
| Python     | 236   |
| Tableau    | 230   |
| R          | 148   |

SQL leads with 398 mentions, suggesting it's highly valued, especially in data-related roles. Excel and Python follow closely, reflecting their broad applicability. Tableau's strong presence emphasizes the importance of data visualization, while R indicates demand for statistical analysis.

### 4. **Skills Based On Salary**
The exploration of average salaries linked to various skills uncovered which professional abilities command the highest compensation.
```SQL
SELECT
    skills_dim.skills AS skill_name,
    ROUND(AVG(job_postings_fact_staging.salary_year_avg),0) AS salary
FROM 
    job_postings_fact_staging
INNER JOIN 
    skills_job_dim ON skills_job_dim.job_id = job_postings_fact_staging.job_id
INNER JOIN 
    skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE 
    job_postings_fact_staging.job_title_short = 'Data Analyst' AND job_postings_fact_staging.job_location IN ('Anywhere') AND job_postings_fact_staging.salary_year_avg IS NOT NULL AND job_postings_fact_staging.job_work_from_home = TRUE
GROUP BY 
    skills_dim.skills
ORDER BY 
    salary DESC
LIMIT 
    25
```
Top-paying skills for Data Analysts highlight the high demand for expertise in big data (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas). Proficiency in development tools like GitLab and Kubernetes, as well as cloud platforms such as GCP and Databricks, reflects the industry's emphasis on automation, cloud-based analytics, and predictive modeling, which significantly boost earning potential.

| Skills    | Average Salary ($) |
|------------   |------------ |
| PySpark       | 208,172     |
| Bitbucket     | 189,155     |
| Couchbase     | 160,515     |
| Watson        | 160,515     |
| Dataroboot    | 155,486     |
| Gitlab        | 154,500     |
| Swift         | 153,750     |
| Jupyter       | 152,777     |
| Pandas        | 151,821     |
| Elasticsearch | 145,000     |

### 5. **Most Optimal Skills To Learn**
This analysis sought to identify skills that are both highly demanded and well-paid, providing valuable guidance for prioritizing skill development strategically.
```sql
SELECT
    skills_dim.skills AS skill_name,
    COUNT(skills_dim.skills) AS skills_count,
    ROUND(AVG(job_postings_fact_staging.salary_year_avg),0) AS salary
FROM 
    job_postings_fact_staging
INNER JOIN 
    skills_job_dim ON skills_job_dim.job_id = job_postings_fact_staging.job_id
INNER JOIN 
    skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE 
    job_postings_fact_staging.job_title_short = 'Data Analyst' AND job_postings_fact_staging.job_location IN ('Anywhere') AND job_postings_fact_staging.salary_year_avg IS NOT NULL AND job_postings_fact_staging.job_work_from_home = TRUE
GROUP BY 
    skills_dim.skills
ORDER BY 
    skills_count DESC, salary DESC
LIMIT 
    10
```

| Skills | Demand Count | Average Salary ($)
|------------|----------|------------------
| SQL        |  398     |97,237          
| Excel        |256     |87,288             
| Python        | 236   |101,397              
| Tableau        | 230  |99,288             
| r        |   230      |100,499              
| Sas        |   148    |98,902               
| Power BI    |126      |97,431              
| PowerPoint   |110     |88,701               
| Looker        |58     |103,795               
| Word        |  49     |82,576         

Programming languages like Python and R are in high demand (236 and 230 mentions), with average salaries around $101K, showing their value despite their widespread availability. Tableau and Looker underscore the critical role of data visualization, with salaries near $100K. Database technologies, including SQL and NoSQL, remain essential, offering average earnings between $98K and $104K.
# Conclusions

### **Insights**
The analysis revealed key takeaways:

- **Top-Paying Data Analyst Jobs:** Remote roles offer significant salary ranges, with the highest reaching $650,000.
- **Skills for High Salaries:** Advanced SQL proficiency is crucial for securing top-paying positions.
- **Most In-Demand Skill:** SQL is the most sought-after skill in the data analyst job market, making it essential for job seekers.
- **Specialized Skills and Salaries:** Niche skills like SVN and Solidity command the highest average salaries, highlighting their premium value.
- **Key Skill for Market Value:** SQL stands out as both high in demand and well-paid, making it an optimal choice for analysts aiming to maximize their career potential.
## *Closing Thoughts*
This project strengthened my SQL expertise and provided valuable insights into the data analyst job market. The findings offer a clear roadmap for skill development and job search strategies. By focusing on high-demand and well-paid skills, aspiring analysts can stand out in a competitive market. This study emphasizes the need for continuous learning and staying ahead of trends in the evolving field of data analytics.
