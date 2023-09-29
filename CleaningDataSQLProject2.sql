/*  
Cleaning Data in SQL Queries

*/

Select *
from [PortfolioProject ]..NashvilleHousing



-- Standardize Data Format

Select SaleDate, Convert(Date,SaleDate)
from [PortfolioProject ]..NashvilleHousing

--updates temporarily
Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

--should update as a new column 
Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDAteConverted = convert(Date,SaleDate)

-- Populate Property Address Data


Select *
from [PortfolioProject ]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--Since ParcelID's have thesame address
-- Join the table to itself (selfjoin) and uniqueId's wont repeat themself but ParcelID's do

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [PortfolioProject ]..NashvilleHousing as a
join [PortfolioProject ]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [PortfolioProject ]..NashvilleHousing as a
join [PortfolioProject ]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into individual columns(address, City, Sate)

select PropertyAddress
from [PortfolioProject ]..NashvilleHousing

-- specifying what we are looking for until the comma (,)
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from [PortfolioProject ]..NashvilleHousing

-- taking off the specified index character 
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
from [PortfolioProject ]..NashvilleHousing

--selecting the two segments of the address 
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from [PortfolioProject ]..NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from [PortfolioProject ]..NashvilleHousing

-- using parsename to break down the address in owner address 

Select OwnerAddress
from [PortfolioProject ]..NashvilleHousing


-- parsename seperates but backwards so index will be backwards
-- replace(',', '.')
select 
PARSENAME(replace(OwnerAddress, ',','.'), 3)
,PARSENAME(replace(OwnerAddress, ',','.'), 2)
,PARSENAME(replace(OwnerAddress, ',','.'), 1)
from [PortfolioProject ]..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAdress nvarchar(255)

UPDATE NashvilleHousing
Set OwnerSplitAdress = PARSENAME(replace(OwnerAddress, ',','.'), 3)

Alter table NashvilleHousing
Add OwnerSPlitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'), 2)

Alter table NashvilleHousing
Add OwnerSpiltState nvarchar(255)

Update NashvilleHousing
set OwnerSpiltState = PARSENAME(replace(OwnerAddress, ',','.'), 1)

select OwnerAddress, OwnerSplitAddress, OwnerSpiltState, OwnerSPlitCity
from [PortfolioProject ]..NashvilleHousing

-- change Y and N to Yes and No in 'Sold as Vcant' field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from [PortfolioProject ]..NashvilleHousing
Group by SoldAsVacant
order by 2 desc

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [PortfolioProject ]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [PortfolioProject ]..NashvilleHousing


-- remove duplicates 
-- patition on things that should be unique to each row 

with RowNumCTE As (
select *, 
	ROW_NUMBER() Over (
	partition by ParcelID,
				 SalePrice,
				 LegalReference
				 order by
					UniqueID
					) row_num

from [PortfolioProject ]..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
--to find out if there are duplicates in the rows
where row_num > 1
order by PropertyAddress





-- now to delete the duplicates 

with RowNumCTE As (
select *, 
	ROW_NUMBER() Over (
	partition by ParcelID,
				 SalePrice,
				 LegalReference
				 order by
					UniqueID
					) row_num

from [PortfolioProject ]..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
--to find out if there are duplicates in the rows
where row_num > 1
--order by PropertyAddress




-- delete unused columns

Select *
from [PortfolioProject ]..NashvilleHousing


Alter table [PortfolioProject ]..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from [PortfolioProject ]..NashvilleHousing




