/*

Cleaning Data in SQL Queires

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Standardize date format

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


-- Change Y and N to Yes and No in 'Sold As Vacant' Field

Select Distinct(SoldAsVacant), COunt(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
When SoldAsVacant = 'Y' Then 'YES'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case
When SoldAsVacant = 'Y' Then 'YES'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END


-- Remove Duplicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
