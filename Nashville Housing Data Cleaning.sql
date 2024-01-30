-- Nashville Housing Data - SQL Data Cleaning

Select *
From SQLDataCleaning.dbo.Nashville

-- Standardizing the date format

Alter table SQLDataCleaning.dbo.Nashville
Add SaleDateConverted Date;

Update SQLDataCleaning.dbo.Nashville
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted, Convert(Date, SaleDate)
From SQLDataCleaning.dbo.Nashville


-- Populating the property address data

Select a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLDataCleaning.dbo.Nashville a
Join SQLDataCleaning.dbo.Nashville b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLDataCleaning.dbo.Nashville a
Join SQLDataCleaning.dbo.Nashville b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Property Address into Individual Columns - Using a Substring

Alter table SQLDataCleaning.dbo.Nashville 
Add PropertySplitAddress Nvarchar(255);

Update SQLDataCleaning.dbo.Nashville
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)

Alter table SQLDataCleaning.dbo.Nashville 
Add PropertySplitCity Nvarchar(255);

Update SQLDataCleaning.dbo.Nashville
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(propertyAddress))


-- Breaking out Owner Address into Individual Columns - Using Parsname 

Alter table SQLDataCleaning.dbo.Nashville 
Add OwnerSplitAddress Nvarchar(255);

Update SQLDataCleaning.dbo.Nashville
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'), 3)

Alter table SQLDataCleaning.dbo.Nashville 
Add OwnerSplitCity Nvarchar(255);

Update SQLDataCleaning.dbo.Nashville
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'), 2)

Alter table SQLDataCleaning.dbo.Nashville 
Add OwnerSplitState Nvarchar(255);

Update SQLDataCleaning.dbo.Nashville
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'), 1)


-- Changing Y and N to Yes and No in "Sold as Vacant" Column

Select Distinct(SoldasVacant), Count(SoldasVacant)
From SQLDataCleaning.dbo.Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
From SQLDataCleaning.dbo.Nashville

Update SQLDataCleaning.dbo.Nashville
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
	                    end


-- Removing Duplicates

With RownumCTE as(
Select *,
   row_number() over (
     partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by 
				      UniqueID
					  ) row_num

From SQLDataCleaning.dbo.Nashville 
)
Select *
From RownumCTE
Where row_num > 1
Order by PropertyAddress


-- Deleting Unused Columns

Alter table SQLDataCleaning.dbo.Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Alter table SQLDataCleaning.dbo.Nashville
Drop Column SaleDate

Select *
From SQLDataCleaning.dbo.Nashville
