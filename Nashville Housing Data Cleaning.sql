
--Project : Cleaning Data using Sql Queries

select * from [NashvilleHousing]

-- (1) Standarize Date format

alter table NashvilleHousing 
add [Sale Date Converted] date;

update NashvilleHousing 
set [Sale Date Converted] = CONVERT(date, Saledate)



-- (2) Populate Property address data

select * from NashvilleHousing
where PropertyAddress is null


select PropertyAddress from [NashvilleHousing] 
where 
  PropertyAddress is not null 
group by 
  PropertyAddress


select 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress, 
  isnull(a.PropertyAddress, b.PropertyAddress) 
from 
  [NashvilleHousing] a 
  join [NashvilleHousing] b on a.ParcelID = b.ParcelID 
  and a.[UniqueID ] <> b.[UniqueID ] 
where 
  a.PropertyAddress is null

update a 
set propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress) 
from 
  [NashvilleHousing] a 
  join [NashvilleHousing] b on a.ParcelID = b.ParcelID 
  and a.[UniqueID ] <> b.[UniqueID ] 
where 
  a.PropertyAddress is null


select * from NashvilleHousing


--(3) Breaking out address into individual Columns (Address,City ,state)

--Breaking out Property Address using string,Charindex function

select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1), 
  SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress)+ 1, LEN(PropertyAddress)) 
from 
  [NashvilleHousing]

alter table NashvilleHousing
add [PropertySplitAddress] nvarchar(255);

update NashvilleHousing
set [PropertySplitAddress] = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)


alter table NashvilleHousing
add [PropertySplitCity] nvarchar(255);

update NashvilleHousing
set [PropertySplitCity] = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(PropertyAddress))


--Breaking out Owner Address using parsename function 

select 
  PARSENAME(replace(OwnerAddress, ',', '.'),3), 
  PARSENAME(replace(OwnerAddress, ',', '.'), 2), 
  PARSENAME(replace(OwnerAddress, ',', '.'), 1) 
from 
  NashvilleHousing


alter table NashvilleHousing 
add [ownerSplitAddress] nvarchar(255);

update NashvilleHousing
set [OwnerSplitAddress] = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing 
add [OwnerSplitCity] nvarchar(255);

update NashvilleHousing
set [OwnerSplitCity] = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add [ownerSplitState] nvarchar(255);

update NashvilleHousing
set [OwnerSplitState] = PARSENAME(replace(OwnerAddress,',','.'),1)


-- (4) Change Y and N to Yes and No in 'Sold as Vacant' field


select 
  distinct(SoldAsVacant), 
  count(SoldAsVacant) 
from 
  NashvilleHousing 
group by 
  SoldAsVacant 
order by 
  2


select 
  SoldAsVacant, 
  case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' else SoldAsVacant end as New 
from 
  NashvilleHousing

update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' else SoldAsVacant end



--(5) Remove Duplicates


select * from NashvilleHousing

with DuplicateRow as (
  select *, ROW_NUMBER() over (partition by ParcelID, 
      PropertyAddress, 
      SaleDate, 
      SalePrice, 
      LegalReference 
      order by 
        UniqueId
    ) as Row_num 
  from 
    NashvilleHousing
)

select * from DuplicateRow 
where Row_num >1
order by UniqueId


Delete from DuplicateRow 
where Row_num >1



--(6) Remove Unused Columns

select * from NashvilleHousing

alter table 
  NashvilleHousing 
drop column 
  OwnerAddress, 
  PropertyAddress, 
  TaxDistrict
  SaleDate


--(7) Renaming Column Name

select * from NashvilleHousing

sp_rename  'NashvilleHousing.PropertySplitAddress', 'PropertyAddress', 'Column'

sp_rename  'NashvilleHousing.PropertySplitCity', 'PropertyCity', 'Column'


sp_rename  'NashvilleHousing.ownerSplitAddress', 'OwnerAddress', 'Column'

sp_rename  'NashvilleHousing.ownerSplitCity', 'OwnerCity', 'Column'

sp_rename  'NashvilleHousing.OwnerSplitState', 'OwnerState', 'Column'

sp_rename  'NashvilleHousing.Sale Date Converted', 'Sale Date', 'Column'
