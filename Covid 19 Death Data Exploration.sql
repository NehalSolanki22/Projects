-- Project : Data Exploration on Covid 19 Death Dataset using sql queries

use Project
go

select * from Covid19_Deaths
order by 3,4

select * from [Covid19 Vaccination]
order by 3,4

--(1) select data that we are going to be using

select 
  [location], 
  [date], 
  total_cases, 
  new_cases, 
  cast(total_deaths as int) as Deaths, 
  [population] 
from 
  Covid19_Deaths 
order by 
  1, 
  2 


select 
  [date], 
  [location], 
  [population], 
  total_cases, 
  new_cases, 
  cast(total_deaths as int) as [Total Deaths], 
  round((total_deaths / total_cases)* 100, 2) as [Death % ] 
from 
  Covid19_Deaths 
order by 
  2


--(2) Looking at total cases vs total deaths

select 
  [location], 
  max([date]) as [Date], 
  max(total_cases) as [Total Cases], 
  max(total_deaths) as [Total Deaths] 
from 
  Covid19_Deaths 
group by 
  [location] 
order by 
  1, 
  2


--Shows Likelihood of dying if you contract covid in your country

select 
  [location], 
  [date], 
  total_cases, 
  cast(total_deaths as int) as [Total Deaths], 
  round((total_deaths / total_cases)* 100, 2) as [Death % ] 
from 
  Covid19_Deaths 
where 
  [location] = 'India' and [continent] is not null 
order by 
  1, 
  2


--(3) Looking Total cases vs Population
--shows what % of population got covid

select 
  [location], 
  [date], 
  [population], 
  total_cases, 
  round((total_cases / [population])* 100,2) as [ % Infected Population] 
from 
  Covid19_Deaths 
where 
  [continent] is not null 
order by 
  1, 
  2

--looking at countries with highest infection rate compared to population

select 
  [location], 
  max([population]) as [Population], 
  max(total_cases) as [Highest infection count], 
  max(round((total_cases / [population])* 100,2)) as [ % Infected Population] 
from 
  Covid19_Deaths 
where 
  [continent] is not null 
group by 
  [location] 
order by 
  3 desc


--Showing countries highest death count per population 

select 
  [location], 
  max([population]) as [Population], 
  max(cast(total_deaths as int)) as [Highest death count], 
  max(round((total_deaths / [population])* 100, 2)) as [ % of Population Died] 
from 
  Covid19_Deaths 
where 
  [continent] is not null 
group by 
  [location] 
order by 
  3 desc

--(4) Lets break things down by continent
--showing continents with highest death count per population

select 
  [location], 
  max([population]) as [Population], 
  max(cast(total_deaths as int)) as [Highest death count], 
  max(round((total_deaths / [population])* 100,2)) as [ % of Population Died] 
from 
  Covid19_Deaths 
where 
  [continent] is null 
group by 
  [location] 
order by 
  3 desc

--(5) Global Numbers

with GlobalNumbers ([location], [Total cases], [Total Deaths]) as (
  select 
    [location], 
    max([total_cases]) as [Total cases], 
    max(cast([total_deaths] as int)) as [Total Deaths] 
  from 
    Covid19_Deaths 
  where 
    [continent] is not null 
  group by 
    [location]
) 
select 
  sum([Total cases]) as [Total cases], 
  sum([Total Deaths]) as [Total Deaths], 
  round((sum(cast([Total Deaths] as int))/ sum([Total cases]))* 100, 2) as [Death % ] 
from 
  GlobalNumbers


-- Looking at the Total Population vs Vaccination

select 
  d.continent, 
  d.[location], 
  d.[date], 
  d.[population], 
  v.new_vaccinations 
from 
  [Covid19_Deaths] as d 
  join [Covid19 Vaccination] as v on d.[location] = v.[location] 
  and d.[date] = v.[date] 
where 
  d.[continent] is not null 
order by 
  1, 
  2, 
  3 


select 
  d.continent, 
  d.[location], 
  d.[date], 
  d.[population], 
  v.new_vaccinations, 
  SUM(convert(int, v.new_vaccinations)) over (partition by d.[location] 
    order by 
      d.[location], 
      d.[date]
  ) as [Rolling People Vaccinated] 
from 
  [Covid19_Deaths] as d 
  join [Covid19 Vaccination] as v on d.[location] = v.[location] 
  and d.[date] = v.[date] 
where 
  d.[continent] is not null 
order by 
  1, 
  2, 
  3

--Use CTE(Common Table Expression) takes the result of an query as an reference

with PopvsVac (
  Continent, [Location], [Date], [Population], [New_vaccination], [Rolling People Vaccinated]) as(
  select 
    d.continent, 
    d.[location], 
    d.[date], 
    d.[population], 
    v.new_vaccinations, 
    SUM(convert(int, v.new_vaccinations)) over (partition by d.[location] 
      order by 
        d.[location], 
        d.[date]
    ) as [Rolling People Vaccinated] 
  from 
    [Covid19_Deaths] as d 
    join [Covid19 Vaccination] as v on d.[location] = v.[location] 
    and d.[date] = v.[date] 
  where 
    d.[continent] is not null
) 

select *, round(([Rolling People Vaccinated] / [Population])* 100,2) as [ % Rolling People Vaccinated] 
from 
  PopvsVac


--Use Temporary Table

drop table if exists PopsvsVac 
  
 create table PopsvsVac (
    Continent nvarchar(255), 
    [Location] nvarchar(255), 
    [Date] datetime, 
    [Population] numeric, 
    [New_vaccination] numeric, 
    [Rolling People Vaccinated] numeric
  ) 
  
insert into PopsvsVac 
select 
  d.continent, 
  d.[location], 
  d.[date], 
  d.[population], 
  v.new_vaccinations, 
  SUM(convert(int, v.new_vaccinations)) over (partition by d.[location] 
    order by 
      d.[location], 
      d.[date]
  ) as [Rolling People Vaccinated] 
from 
  [Covid19_Deaths] as d 
  join [Covid19 Vaccination] as v on d.[location] = v.[location] 
  and d.[date] = v.[date] 
where 
  d.[continent] is not null 


select *, round(([Rolling People Vaccinated] / [Population])* 100,1) as [ % Rolling People Vaccinated] 
from 
  PopsvsVac



--Creating View to store data for later visualization

create view vwPopvsVac as 
select 
  d.continent, 
  d.[location], 
  d.[date], 
  d.[population], 
  v.new_vaccinations, 
  SUM(convert(int, v.new_vaccinations)) over (partition by d.[location] 
    order by 
      d.[location], 
      d.[date]
  ) as [Rolling People Vaccinated] 
from 
  [Covid19_Deaths] as d 
  join [Covid19 Vaccination] as v on d.[location] = v.[location] 
  and d.[date] = v.[date] 
where 
  d.[continent] is not null

select * from vwPopvsVac


-- Calender with distinct dates use for making Visualization

select 
  [date] 
from 
  Covid19_Deaths 
group by 
  [date] 
order by 
  1


--continents and location

select 
  c.[continent], 
  l.[location] 
from 
  Covid19_Deaths c 
  join Covid19_Deaths l on c.continent = l.continent 
  and c.[location] = l.[location] 
group by 
  c.[continent], 
  l.[location] 
order by 
  1

