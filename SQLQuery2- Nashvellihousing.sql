
---------/* Cleaning Data in SQL Queries*/------

SELECT * FROM PortfolioProject.dbo.NashvelliHousing
--Changing Date Format

SELECT SaleDate,CONVERT(Date,SaleDate) 
FROM PortfolioProject.dbo.[NashvelliHousing]

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET SaleDate=CONVERT(Date,SaleDate)

SELECT SaleDate
FROM PortfolioProject.dbo.[NashvelliHousing]

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET SaleDateConverted=CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..[NashvelliHousing]



--Populating Property Adderss

SELECT A.parcelID,A.PropertyAddress,B.parcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.dbo.[NashvelliHousing] A
JOIN PortfolioProject.dbo.[NashvelliHousing] B
ON A.ParcelID=B.ParcelID AND
 A.UniqueID<>B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A 
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.dbo.[NashvelliHousing] A
JOIN PortfolioProject.dbo.[NashvelliHousing] B
ON A.ParcelID=B.ParcelID AND
 A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

SELECT PropertyAddress
FROM PortfolioProject.dbo.[NashvelliHousing]
WHERE PropertyAddress IS NULL

--Breaking Adderss

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.[NashvelliHousing]

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD PropertySplitAdderss nvarchar(255);

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET PropertySplitAdderss=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM PortfolioProject.dbo.[NashvelliHousing]


--Splitting Owner Address
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.[NashvelliHousing]

---Altering Table Accordint to data

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.[NashvelliHousing]
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.[NashvelliHousing]
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * FROM PortfolioProject.dbo.[NashvelliHousing]

--Change 'Y','N' to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.[NashvelliHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant='y' THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
 ELSE SoldAsVacant
 END
FROM PortfolioProject.dbo.[NashvelliHousing]

UPDATE [NashvelliHousing]
SET SoldAsVacant= CASE WHEN SoldAsVacant='y' THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
 ELSE SoldAsVacant
 END

 --Remove Duplicates
 --CTE-Common Table Expression(Temporary table	created by select statement which can be used in later 

 SELECT * FROM PortfolioProject.dbo.NashvelliHousing

;WITH RowcntCTE AS(
 SELECT *,
  ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY 
				  UniqueID
				  )row_num

	FROM PortfolioProject.dbo.NashvelliHousing 
)
DELETE * FROM RowcntCTE
WHERE row_num>1

SELECT * FROM PortfolioProject.dbo.NashvelliHousing

ALTER TABLE PortfolioProject.dbo.NashvelliHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvelliHousing
DROP COLUMN SaleDate