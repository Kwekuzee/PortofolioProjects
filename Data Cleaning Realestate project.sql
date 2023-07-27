/*

Cleaning Data in SQL Queries

*/

Select *
From DataCleaning.dbo.NashvilleHousing





--- Standardize Data format:
Select SaleDateConverted,CONVERT(Date,SaleDate)
From DataCleaning.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



-- Step 1
Alter TABLE NashvilleHousing
Add SaleDateConverted Date;

--step 2
Update NashvilleHousing
SET SaleDateConverted  = CONVERT(Date,SaleDate)


--call function-- done
Select SaleDateConverted,CONVERT(Date,SaleDate)
From DataCleaning.dbo.NashvilleHousing



--Populate Property address data
Select *
From DataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


Select  a.ParcelID  , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

    
UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns(Address,City,State)

Select PropertyAddress
From DataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityAndPostalCode
FROM DataCleaning.dbo.NashvilleHousing;


Alter TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(55);

Update NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


Alter TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From DataCleaning.dbo.NashvilleHousing




--OwnerAddress Cleaning
Select OwnerAddress
From DataCleaning.dbo.NashvilleHousing



SELECT
    LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) AS street_address,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2) AS city,
    RIGHT(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - 1) AS state
FROM DataCleaning.dbo.NashvilleHousing;
--AN EASIER WAY OF DOING SO IS --                           

Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
,PARSENAME(Replace(OwnerAddress, ',', '.'),2)
,PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From DataCleaning.dbo.NashvilleHousing

-- Street address session
Alter TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',', '.'),3)


--City session
Alter TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity  = PARSENAME(Replace(OwnerAddress, ',', '.'),2)


--State session
Alter TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',', '.'),1)

Select *
From DataCleaning.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From DataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldasVacant
, CASE When SoldasVacant = 'Y' THEN  'Yes'
       When SoldasVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END
From DataCleaning.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldasVacant = 'Y' THEN  'Yes'
       When SoldasVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END


--Remove Duplicates

WITH RowNumCTE AS(
SELECT  *,
        ROW_NUMBER() OVER (
		PARTITION BY PARCElID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					       UniqueID
						   )row_num
				     
From DataCleaning.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



-------------------------------------------------------
---- Delete Unused Columns



Select *
From DataCleaning.dbo.NashvilleHousing

ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate




