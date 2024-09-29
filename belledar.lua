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
    local totalReq = reqAmt*crafts
    local invAmount =  GetItemCount(reqID,true,nil,true)
    if invAmount < totalReq then
        return totalReq - invAmount
    else
        return 0
    end
end


local function setupMerch()
    local ixPepper = nil
    local ixCore = nil

    for ix=1, GetMerchantNumItems() do
        itemInfo = GetMerchantItemInfo(ix)
        if itemInfo == pepper then
            ixPepper = ix
        elseif itemInfo == coredust then
            ixCore = ix
        end
    end
    return ixPepper, ixCore
end



local btn = CreateFrame("Button", "BelledarCountBtn", UIParent, "SecureActionButtonTemplate")
-- sort bags before we create the button
btn:RegisterForClicks("AnyUp", "AnyDown")
btn:SetScript("OnClick", function()

    local totalCrafts = math.floor(GetItemCount(steakID,true,nil,true)/steakReq)
    if totalCrafts < 1 then
        return
    end
    local pepperBuy = getReq(pepperID, pepperReq, totalCrafts)
    local coreBuy = getReq(coreID, coreReq, totalCrafts)
    if pepperBuy >0 or coreBuy > 0 then
        local ixPepper, ixCore = setupMerch()
        BuyMerchantItem(ixPepper, pepperBuy)
        BuyMerchantItem(ixCore, coreBuy)

    end
end)
