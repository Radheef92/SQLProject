-------------------------------------------------DATA CLEANING----------------------------------------------------------------------------------


SELECT *
FROM PortfolioTut.dbo.HousingProject 



------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioTut.dbo.HousingProject 

UPDATE HousingProject
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingProject
ADD SaleDateConverted Date;

UPDATE HousingProject
SET SaleDateConverted = CONVERT(Date,SaleDate)



--------------------------------------------------------------------------------------------------------------------------------------------------

--populate property Address

SELECT *
FROM PortfolioTut.dbo.HousingProject 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID




SELECT a.ParcelID, 
       a.PropertyAddress, 
	   b.ParcelID, 
	   b.PropertyAddress,
	   ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioTut.dbo.HousingProject a
JOIN PortfolioTut.dbo.HousingProject b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioTut.dbo.HousingProject a
JOIN PortfolioTut.dbo.HousingProject b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioTut.dbo.HousingProject 
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioTut.dbo.HousingProject 



ALTER TABLE HousingProject
ADD PropertyMainAddress Nvarchar(255);

UPDATE HousingProject
SET PropertyMainAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingProject
ADD PropertyCityAddress Nvarchar(255);

UPDATE HousingProject
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 



SELECT *
FROM PortfolioTut.dbo.HousingProject 




SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioTut.dbo.HousingProject 


ALTER TABLE HousingProject
ADD OwnerMainAddress Nvarchar(255);

UPDATE HousingProject
SET OwnerMainAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE HousingProject
ADD OwnerCityAddress Nvarchar(255); 

UPDATE HousingProject
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE HousingProject
ADD OwnerState Nvarchar(255); 

UPDATE HousingProject
SET OwnerState =PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



SELECT *
FROM PortfolioTut.dbo.HousingProject 



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioTut.dbo.HousingProject
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END
FROM PortfolioTut.dbo.HousingProject 

UPDATE HousingProject
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioTut.dbo.HousingProject
GROUP BY SoldAsVacant
ORDER BY 2




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
	  ORDER BY UniqueID) 
	  row_num
	               
FROM PortfolioTut.dbo.HousingProject 
--ORDER BY ParcelID
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num > 1









---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioTut.dbo.HousingProject 

ALTER TABLE PortfolioTut.dbo.HousingProject 
DROP COLUMN  OwnerAddress,TaxDistrict , PropertyAddress



-------------------------------------------------------------Thanks---------------------------------------------------------------------------------------------------------------------------------