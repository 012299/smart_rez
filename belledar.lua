local steakID = 222738
local pepperID = 222696
local coreID = 222697

-- could do this with recipe info too
local steakReq = 15
local pepperReq = 5
local coreReq = 40

local pepper = "Crunchy Peppers"
local coredust = "Coreway Dust"

local function getReq(reqID, reqAmt, crafts)
	local totalReq = reqAmt * crafts
	local invAmount = GetItemCount(reqID, true, nil, true)
	if invAmount < totalReq then
		return totalReq - invAmount
	else
		return 0
	end
end

local function setupMerch()
	local ixPepper = nil
	local ixCore = nil

	for ix = 1, GetMerchantNumItems() do
		local itemInfo = GetMerchantItemInfo(ix)
		if itemInfo == pepper then
			ixPepper = ix
		elseif itemInfo == coredust then
			ixCore = ix
		end
	end
	return ixPepper, ixCore
end

local function buyIngr(amount, ix)
	if amount > 1000 then
		local purchases = math.floor(amount / 1000)
		leftover = amount - purchases * 1000
		for i = 1, purchases do
			BuyMerchantItem(ix, 1000)
		end
		amount = amount - purchases * 100
	end
	BuyMerchantItem(ix, amount)
end

local btn = CreateFrame("Button", "BelledarCountBtn", UIParent, "SecureActionButtonTemplate")
-- sort bags before we create the button
btn:RegisterForClicks("AnyUp", "AnyDown")
btn:SetScript("OnClick", function()
	local totalCrafts = math.floor(GetItemCount(steakID, true, nil, true) / steakReq)
	if totalCrafts < 1 then
		return
	end
	local pepperBuy = getReq(pepperID, pepperReq, totalCrafts)
	local coreBuy = getReq(coreID, coreReq, totalCrafts)
	if pepperBuy >= 1 or coreBuy >= 1 then
		local ixPepper, ixCore = setupMerch()
		buyIngr(pepperBuy, ixPepper)
		buyIngr(coreBuy, ixCore)
		--BuyMerchantItem(ixPepper, pepperBuy)
		--BuyMerchantItem(ixCore, coreBuy)
	end
end)
