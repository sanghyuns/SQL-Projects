/*
-- Cleaning Data in SQL Queries

*/

SELECT * 
FROM NashvilleHousing.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------



-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-------------------------------------------------------------------------------------------------


-- Populate Property Address Data using ParcelID

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


---------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Splitting Address Using PARSENAME-----------------------------------------

SELECT OwnerAddress 
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

----------------------------------------------------------------------------------------------------------------------

--Change Y and N to 'Yes' and 'No' in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM NashvilleHousing.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



---------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing.dbo.NashvilleHousing
DROP COLUMN SaleDate