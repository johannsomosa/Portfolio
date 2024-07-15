-- Create staging table
Create table layoffs_staging
Like layoffs;

Select * from layoffs_staging

Insert layoffs_staging
Select * from layoffs

-- Identify duplicates

With duplicate_cte AS 
(Select *,
Row_number() over
(partition by company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
From layoffs_staging
)
Select * 
from duplicate_cte
where row_num > 1

-- Identify and confirm duplicates

Select * from layoffs_staging
where company = 'Casper'
-- 2
Select * from layoffs_staging
where company = 'Cazoo'
-- 2

Select * from layoffs_staging
where company = 'Hibob'
-- 1


Select * from layoffs_staging
where company = 'Wildlife Studios'
-- 1

Select * from layoffs_staging
where company = 'Yahoo'
-- 1

-- DELETE DUPLICATES

Create `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_number` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE `world_layoffs`.`layoffs_staging2` 
CHANGE COLUMN `row_number` `row_num` INT NULL DEFAULT NULL ;

Select *
From layoffs_staging2;

Insert layoffs_staging2
Select *,
Row_number() over
(partition by company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
From layoffs_staging;

Delete
From layoffs_staging2
where row_num > 1;

-- STANDARDIZE DATA

Select distinct(company),
TRIM(company)
FROM layoffs_staging2;

Update layoffs_staging2
SET company = TRIM(company);

Select distinct(industry)
FROM layoffs_staging2
ORDER BY 1;
-- 2 NULL
-- Merge Crypto industries

Select *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

Update layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

Select distinct(date)
FROM layoffs_staging2
ORDER BY 1;

Select distinct(country), TRIM(Trailing '.' FROM COUNTRY)
FROM layoffs_staging2
ORDER BY 1;

Update layoffs_staging2
SET country = TRIM(Trailing '.' FROM COUNTRY)
WHERE country LIKE 'United States%';

-- Change DATE from text into standard date format

Select `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

Update layoffs_staging2
SET date = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE `world_layoffs`.`layoffs_staging2` 
MODIFY COLUMN `date` DATE;

Select *
FROM layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

Select *
FROM layoffs_staging2
where company LIKE 'Bally%';

UPDATE layoffs_staging2
set industry = NULL
Where industry = '';

Select t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE t1.industry is NULL
AND t2.industry is NOT NULL;
    
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry is NOT NULL;

Select *
FROM layoffs_staging2;

DELETE
FROM layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
