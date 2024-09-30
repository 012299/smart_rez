local _C_GetContainerNumSlots = _G["C_Container"]["GetContainerNumSlots"]
local _C_GetContainerItemInfo = _G["C_Container"]["GetContainerItemInfo"]
local _C_SortBags = _G["C_Container"]["SortBags"]
local _C_TradeSkillUI_CraftSalvage = _G["C_TradeSkillUI"]["CraftSalvage"]
local _ItemLocation = _G["ItemLocation"]
local _GetTime = _G["GetTime"]
local _UnitCastingInfo = _G["UnitCastingInfo"]

local salvageItem = ItemLocation:CreateEmpty()
ThaumaFrame = CreateFrame("Frame")

local cookingID = 445118
local prospectID = 434018
local thaumaID = 430315

local itemToCast = {
	-- thauma
	[210796] = thaumaID, --mycobloom r1
	[210797] = thaumaID, --mycobloom r2
	[211802] = thaumaID, --ominous transmutagen
	[211804] = thaumaID, --volatile transmutagen
	[211803] = thaumaID, --Mercurial transmutagen
	[212667] = thaumaID, --Gloom Chitin r1
	[212668] = thaumaID, --Gloom Chitin r2
	[212665] = thaumaID, --leather r2
	[210937] = thaumaID, --iron claw r2
	[210806] = thaumaID, -- blossom r2
	-- cooking
	[223512] = cookingID, --beef
	[225911] = cookingID, --bee
	-- prospect
	[210934] = prospectID, -- aqr2
	[210933] = prospectID, --aqr1
}

local castToStack = {
	[thaumaID] = 20,
	[cookingID] = 5,
	[prospectID] = 5,
}

local function findItem()
	for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for slot = 1, _C_GetContainerNumSlots(bag) do
			local itemInfo = _C_GetContainerItemInfo(bag, slot)
			if itemInfo then
				local castID = itemToCast[itemInfo.itemID]
				if castID then
					local castStack = castToStack[castID]
					if itemInfo.stackCount >= castStack then
						salvageItem:SetBagAndSlot(bag, slot)
						return castID, math.floor(itemInfo.stackCount / castStack)
					end
				end
			end
		end
	end
end

local lastSortTime = 0
local currentTime = _GetTime()
local castStartTime, castEndTime = nil, nil
ThaumaFrame.unBlockButton = _GetTime()

ThaumaFrame.btn = CreateFrame("Button", "thaumaButton", UIParent, "SecureActionButtonTemplate")
-- sort bags before we create the button
_C_SortBags()
ThaumaFrame.btn:RegisterForClicks("AnyUp", "AnyDown")
ThaumaFrame.btn:SetScript("OnClick", function()
	print(ThaumaFrame.unBlockButton - _GetTime())
	if ThaumaFrame.unBlockButton > _GetTime() then
		return
	end
	local castID, casts = findItem()
	casts = 1
	if castID then
		ThaumaFrame:RegisterEvents()
		currentTime = _GetTime()
		_C_TradeSkillUI_CraftSalvage(castID, casts, salvageItem)
		castStartTime, castEndTime = select(4, _UnitCastingInfo("player"))
		if castStartTime and castEndTime then
			ThaumaFrame.unBlockButton = _GetTime() + ((castEndTime - castStartTime) / 1000) * casts
		end
	else
		currentTime = _GetTime()
		ThaumaFrame:UnregisterAllEvents()
		if currentTime - lastSortTime >= 10 then
			_C_SortBags()
			lastSortTime = currentTime
		end
	end
end)

function ThaumaFrame:RegisterEvents()
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:SetScript("OnEvent", function(_, eventName, eventData)
        if eventName == "UNIT_SPELLCAST_INTERRUPTED" then
			local target = eventData
			if target == "player" then
				ThaumaFrame.unBlockButton = _GetTime()
				print("INTERRUPTED")
				ThaumaFrame:UnregisterAllEvents()
			end
    	end
    end)
end
