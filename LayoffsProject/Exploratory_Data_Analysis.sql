select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
Where percentage_laid_off = 1;

-- Company with largest total layoffs
select company, sum(total_laid_off)
from layoffs_staging2
GROUP by company
ORDER BY 2 DESC;

-- When did these layoffs occur?
select company, MIN IN(`date`), MAX(`date`)
from layoffs_staging2
GROUP by company
ORDER BY 2 DESC;

-- Which industries and companies experienced the largest layoffs?
select country, industry, sum(total_laid_off)
from layoffs_staging2
GROUP by industry, country
ORDER BY 3 DESC;

-- What was Total Laid-off for each year?
select YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
GROUP by YEAR(`date`)
ORDER BY 2 DESC;

-- # of lay-offs in each stage.
select stage, SUM(total_laid_off)
from layoffs_staging2
GROUP by stage
ORDER BY 2 DESC;

select stage, SUM(total_laid_off)
from layoffs_staging2
GROUP by stage
ORDER BY 2 DESC;

-- Rolling Totals for layoffs by each month
SELECT SUBSTRING(`date`,1,7) AS	`Month`, SUM(total_laid_off) AS `Total Laid Off`
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
Group BY `Month`
Order by `Month` ASC;

WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS `Total Laid Off`
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
Group BY `Month`
Order by 1 ASC
)
Select `Month`, `Total Laid Off` , SUM(`Total Laid Off`) OVER(Order by `Month`) as rolling_total
FROM Rolling_Total;

-- Create Ranking system for the yearly lay offs of each company
-- 1. Lay offs of each company for every year
select company, year(`DATE`) AS `YEAR` , SUM(total_laid_off)
from layoffs_staging2
GROUP by company, `YEAR` 
ORDER BY 3 DESC;

WITH Company_Year (Company, `Company Year`, `Total Laid Off`) AS
(
select company, year(`DATE`) AS `YEAR` , SUM(total_laid_off)
from layoffs_staging2
GROUP by company, `YEAR` 
ORDER BY 3 DESC
)
Select *
FROM Company_Year;

-- 2. Create Ranking System of each year according to the Top 5 total laid off.
WITH Company_Year (Company, `Company Year`, `Total Laid Off`) AS
(
select company, year(`DATE`) AS `YEAR` , SUM(total_laid_off)
from layoffs_staging2
GROUP by company, `YEAR` 
ORDER BY 3 DESC
),
Company_Year_Rank AS
(
Select *, dense_rank() OVER (Partition by `Company Year` ORDER BY  `Total Laid Off` DESC) AS Ranking
FROM Company_Year
WHERE `Company Year` is not null
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
