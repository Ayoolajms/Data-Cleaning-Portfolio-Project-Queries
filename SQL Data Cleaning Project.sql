Select * 
From dbo.NashvilleHousing

------------------------------------------------------------------------------------

--Standardize Date/Time Format

Select SaleDate, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing 
Alter COLUMN SaleDate DATE


-----------------------------------------------------------------------------------------------


-- Populate Property Address Data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, States)

Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add PropertySpiltAddress Nvarchar(255)

Update NashvilleHousing
Set PropertySpiltAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing 
Add PropertySpiltCity Nvarchar(255)

Update NashvilleHousing
Set PropertySpiltCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select * 
From dbo.NashvilleHousing


Select OwnerAddress 
From dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add OwnerSpiltAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSpiltAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing 
Add OwnerSpiltCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSpiltCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2) 

Alter Table NashvilleHousing 
Add OwnerSpiltState Nvarchar(255)

Update NashvilleHousing
Set OwnerSpiltState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 

Select * 
From dbo.NashvilleHousing

----------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
From dbo.NashvilleHousing


Update NashvilleHousing
   SET SoldAsVacant =  Case when SoldAsVacant = 'Y' Then 'Yes'
    when SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
END

----------------------------------------------------------------------

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
From dbo.NashvilleHousing
--Order by ParcelID
)

Select *
--Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress




----------------------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS
Select * 
From dbo.NashvilleHousing

ALTER Table dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress