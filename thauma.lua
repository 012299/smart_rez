local name, smart_rez = ...

local _C_GetContainerNumSlots = _G["C_Container"]["GetContainerNumSlots"]
local _C_GetContainerItemInfo = _G["C_Container"]["GetContainerItemInfo"]
local _C_SortBags = _G["C_Container"]["SortBags"]
local _C_TradeSkillUI_CraftSalvage = _G["C_TradeSkillUI"]["CraftSalvage"]
local _ItemLocation = _G["ItemLocation"]
local _C_Item_GetItemCount = _G["C_Item"]["GetItemCount"]
local _GetTime = _G["GetTime"]
local _C_Timer_NewTimer = _G["C_Timer"]["NewTimer"]

local _UnitCastingInfo = _G["UnitCastingInfo"]

local salvageItem = ItemLocation:CreateEmpty()

local regToCraft = smart_rez.reagentCraftIDs
local craftStackSize = smart_rez.craftStackSize

local function findItem()
	_C_SortBags()
	for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for slot = 1, _C_GetContainerNumSlots(bag) do
			local itemInfo = _C_GetContainerItemInfo(bag, slot)
			if itemInfo then
				local castID = regToCraft[itemInfo.itemID]
				if castID then
					local castStack = craftStackSize[castID]
					if itemInfo.stackCount >= castStack then
						salvageItem:SetBagAndSlot(bag, slot)
						return castID, math.floor(itemInfo.stackCount / castStack)
					end
				end
			end
		end
	end
end

local ThaumaFrame = CreateFrame("FRAME", "ThaumaFrame")

ThaumaFrame.unBlockTime = _GetTime()
ThaumaFrame.longBlock = false

function ThaumaFrame:blockBtn(casts, doTimer)
	local castStartTime, castEndTime = select(4, _UnitCastingInfo("player"))
	if castStartTime then
		local craftTime = ((castEndTime - castStartTime) / 1000) * casts
		self.unBlockTime = _GetTime() + craftTime
		_C_Timer_NewTimer(craftTime, function()
			ThaumaFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		end)
	elseif doTimer then
		_C_Timer_NewTimer(0.3, function()
			ThaumaFrame:blockBtn(casts, false)
		end)
	end
end

local function handleClick()
	if ThaumaFrame.longBlock or ThaumaFrame.unBlockTime > _GetTime() then
		return
	end

	ThaumaFrame.unBlockTime = _GetTime() + 0.3
	local castID, casts = findItem()

	if castID then
		ThaumaFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		_C_TradeSkillUI_CraftSalvage(castID, casts, salvageItem)
		ThaumaFrame:blockBtn(casts, true)
	else
		ThaumaFrame:RegisterEvent("BAG_UPDATE")
		ThaumaFrame.longBlock = true
	end
end

ThaumaFrame.btn = CreateFrame("Button", "thaumaButton", UIParent, "SecureActionButtonTemplate")
ThaumaFrame.btn:RegisterForClicks("AnyUp", "AnyDown")
ThaumaFrame.btn:SetScript("OnClick", handleClick)

local ThaumaEvents = {}
function ThaumaEvents:PLAYER_LOGIN(...)
	smart_rez:initReagentCraftIDs()
end

function ThaumaEvents:BAG_UPDATE(...)
	ThaumaFrame.longBlock = false
	ThaumaFrame:UnregisterEvent("BAG_UPDATE")
end

function ThaumaEvents:UNIT_SPELLCAST_INTERRUPTED(target, ...)
	if target == "player" then
		ThaumaFrame.unBlockButton = _GetTime()

		ThaumaFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		print("unregister spellcast")
	end
end

ThaumaFrame:SetScript("OnEvent", function(self, event, ...)
	ThaumaEvents[event](self, ...)
end)
ThaumaFrame:RegisterEvent("PLAYER_LOGIN")

--[[
function ThaumaFrame:RegisterEvents()
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:SetScript("OnEvent", function(_, eventName, eventData)
		if eventName == "UNIT_SPELLCAST_INTERRUPTED" then
			local target = eventData
			if target == "player" then
				ThaumaFrame.unBlockButton = _GetTime()
                ThaumaFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			end
		end
	end)
end
]]
