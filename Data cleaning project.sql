-- Data Cleaning

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data (spellings or related like that)
-- 3. Null values or blank values
-- 4. Remove any columns

-- creating a staging from raw data to staging 
create table layoffs_staging
like layoffs;

select * from layoffs_staging;

insert  layoffs_staging
select * from layoffs;

-- to identify duplicates
select *, 
ROW_NUMBER() OVER(
Partition by company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging;


with  duplicate_cte as 
(
select *, 
ROW_NUMBER() OVER(
Partition by company, location,
industry, total_laid_off, percentage_laid_off, 'date',stage,
country, funds_raised_millions) as row_num
from layoffs_staging
)
select* 
from duplicate_cte
where row_num > 1;
;

select*
from layoffs_staging
where company = 'Cazoo';

with  duplicate_cte as 
(
select *, 
ROW_NUMBER() OVER(
Partition by company, location,
industry, total_laid_off, percentage_laid_off, 'date',stage,
country, funds_raised_millions) as row_num
from layoffs_staging
)
DELETE
from duplicate_cte
where row_num > 1;


-- creating a staging - 2
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2
select *, 
ROW_NUMBER() OVER(
Partition by company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) as row_num
from layoffs_staging;

-- here, deleting the duplicate rows
DELETE
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;

-- Standarizing data
-- triming and updating the company name
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- updating the cryptograph names to few are in crypto 
select distinct industry
from layoffs_staging2;

UPDATE layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- updating the country - united state. name to united state 
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United states%';

-- changing the date to text to date format
select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

select *
from layoffs_staging2;

-- Null and blank values
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_staging2
set industry = NULL
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging
where company like 'Bally%';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

ALTER table layoffs_staging2
drop column row_num;