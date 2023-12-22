/* 

Cleaning Data with SQL queries

*/


Select *
From PortfolioProject2..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfolioProject2..NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

-- above did not work so tried another method adding new column SaleDateConverted

Alter Table	NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)


-----------------------------------------------------------------------------------------------------

-- Populate property address data

Select *
From PortfolioProject2..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID

-- can update null propertyaddress based off of common ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject2..NashvilleHousing a
Join PortfolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject2..NashvilleHousing a
Join PortfolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, city, state)
-- start with PropertyAddress

Select PropertyAddress
From PortfolioProject2..NashvilleHousing


-- separate address and city and remove comma using Substring

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as PropertySplitAddress,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as PropertySplitCity
From PortfolioProject2..NashvilleHousing



Alter Table	NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


Alter Table	NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress))



-- update OwnerAddress next using Parsename

Select OwnerAddress
From PortfolioProject2..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject2..NashvilleHousing


Alter Table	NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table	NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table	NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



-----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field
-- Standardize Y, Yes, N, No in SoldAsVacant into just Yes or No


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From PortfolioProject2..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End


-----------------------------------------------------------------------------------------------------

-- Remove duplicates
-- Used row number, CTE and windows function partition by

With RowNumCTE As (
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID
	) as row_num
From PortfolioProject2..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1



-----------------------------------------------------------------------------------------------------

-- Delete unused columns
-- removed updated columns and tax district

Select *
From PortfolioProject2..NashvilleHousing;


Alter Table PortfolioProject2..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict