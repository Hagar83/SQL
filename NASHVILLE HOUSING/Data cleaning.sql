select * from Sheet1

--describe for sheet table
-- Using sp_help stored procedure
EXEC sp_help 'Sheet1';

-- Using system catalog views
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'Sheet1'

select SaleDate from Sheet1

--converting dates to standard format

select SaleDate , convert(Date,SaleDate) as 'Standard Date Formate' from Sheet1

Alter table Sheet1
Add New_Date Date

update Sheet1
set New_Date = convert(Date,SaleDate)

select New_Date from Sheet1

--deleting old one
Alter Table sheet1
Drop column SaleDate

--Deleting NULLs in property Address
select ParcelID, PropertyAddress from sheet1
where PropertyAddress IS NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Sheet1 a
JOIN sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Sheet1 a
JOIN sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


select ParcelID, PropertyAddress from sheet1

--splitting property address
SELECT 
    CASE
        WHEN PropertyAddress LIKE '%,%' THEN LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)
        ELSE NULL
    END AS 'House Address',
    CASE
        WHEN PropertyAddress LIKE '%,%' THEN RIGHT(PropertyAddress, CHARINDEX(',', REVERSE(PropertyAddress)) -1)
        ELSE NULL
    END AS 'City'
FROM Sheet1;

alter table sheet1
add PropertyAddressHouse Nvarchar(255)

update sheet1
set PropertyAddressHouse = (SELECT 
    CASE
        WHEN PropertyAddress LIKE '%,%' THEN LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)
        ELSE NULL
    END AS 'House Address')

alter table sheet1
add PropertyAddressCity Nvarchar(255)

update sheet1
set PropertyAddressCity = (SELECT 
    CASE
        WHEN PropertyAddress LIKE '%,%' THEN RIGHT(PropertyAddress, CHARINDEX(',', REVERSE(PropertyAddress)) -1)
        ELSE NULL
    END AS 'City')

Alter table sheet1
drop column PropertyAddress

--splitting owner address

select OwnerAddress
from sheet1

SELECT 
    CASE
        WHEN OwnerAddress LIKE '%,%' THEN LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)
        ELSE NULL
    END AS 'House Address',
    CASE
        WHEN OwnerAddress LIKE '%,%' THEN PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
        ELSE NULL
    END AS 'City',
	CASE
        WHEN OwnerAddress LIKE '%,%' THEN RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress)) -1)
        ELSE NULL
    END AS 'State'
FROM Sheet1;


Alter table sheet1
add OwnerAddressHouse Nvarchar(255)

update sheet1
set OwnerAddressHouse= (select CASE
        WHEN OwnerAddress LIKE '%,%' THEN LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)
        ELSE NULL
    END AS 'House Address')

Alter table sheet1
add OwnerAddressCity Nvarchar(255)

update sheet1
set OwnerAddressCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter table sheet1
add OwnerAddressState Nvarchar(255)

update sheet1
set OwnerAddressState=(SELECT 
   CASE
        WHEN OwnerAddress LIKE '%,%' THEN RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress)) -1)
        ELSE NULL
    END AS 'State')

alter table sheet1
drop column OwnerAddress

--remove duplicates 
WITH removeDuplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, New_Date,LegalReference,SalePrice,PropertyAddressHouse,PropertyAddressCity  ORDER BY UniqueID) AS RowNum
    FROM sheet1
)
SELECT *
FROM removeDuplicates
WHERE RowNum > 1;

--removing unused columns
--i already deleted most of them
Alter table sheet1
drop column TaxDistrict















