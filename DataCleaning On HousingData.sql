--Data Cleaning in SQL
Select *
from HousingData..Nashville
--------------------------------------------------------------------------------------------------------------

--Standardize Date Format
Update Nashville
Set SaleDate = Convert(Date, SaleDate)

select SaleDateConverted, Convert(Date, SaleDate)
from HousingData..Nashville

--If above query doesnt update properly
Alter Table Nashville
add SaleDateConverted Date;

Update Nashville
Set SaleDateConverted = Convert(Date, SaleDate)
--------------------------------------------------------------------------------------------------------------------

--Populate Property Address
select *
from HousingData..Nashville
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from HousingData..Nashville a
join HousingData..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from HousingData..Nashville a
join HousingData..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns(Address, City, State)
Select PropertyAddress
from HousingData..Nashville
where PropertyAddress is null
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from HousingData..Nashville

Alter Table Nashville
add PropertSplitAddress nvarchar(255);

Update Nashville
Set PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table Nashville
add PropertySplitCity nvarchar(255);

Update Nashville
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
from HousingData..Nashville
--The Address and city columns are added to the end of the table as PropertySplitAddress and PropertSplitCity
-------------------------------------------------------------------------------------------------------------------

-- Splitting the OWnerAddress into individual Columns (Address, City, State) Using Parsenames

Select OwnerAddress
from HousingData..Nashville

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from HousingData..Nashville

Alter Table Nashville
add OwnerSplitAddress nvarchar(255);

Update Nashville
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Nashville
add OwnerSplitCity nvarchar(255);

Update Nashville
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Nashville
add OwnerSplitState nvarchar(255);

Update Nashville
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from HousingData..Nashville
-- OwnerSplitAddress, OwnerSplitCity and OwnerSplitState Columns are added at the end of the table
-------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'SoldAsVacant' Field
Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from HousingData..Nashville
group by SoldAsVacant
order by 2

select SoldAsVacant
,Case when SoldAsVacant = 'Y' Then 'YES'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END
from HousingData..Nashville

update Nashville
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'YES'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END
-------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingData..Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

select * 
from HousingData..Nashville
--------------------------------------------------------------------------------------------------------------------

--delete Unused Columns
Select *
from HousingData..Nashville

Alter Table HousingData..Nashville
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate