local thauma = {
    [224828] = true, --weavercloth r1
    [228231] = true, --weavercloth r2
    [228232] = true, --weavercloth r3
    [210796] = true, --mycobloom r1
    [210797] = true, --mycobloom r2
    [211802] = true, --ominous transmutagen
    [211804] = true, --volatile transmutagen
    [211803] = true, --Mercurial transmutagen
    -- [210930] = true, --bismuth r1
 }
local function findItem()
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
       for slot = 1, C_Container.GetContainerNumSlots(bag) do
          local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
          if itemInfo then
             if thauma[itemInfo.itemID] and itemInfo.stackCount >= 20 then
                return ItemLocation:CreateFromBagAndSlot(bag, slot), math.floor(itemInfo.stackCount / 20)
             end
          end
       end
    end
end

local lastSortTime = 0
local btn = CreateFrame("Button", "thaumaButton", UIParent, "SecureActionButtonTemplate")
btn:RegisterForClicks("AnyUp","AnyDown")
btn:SetScript("OnClick", function()

		local castEndTime = select(5, UnitCastingInfo("player"))
		if castEndTime then
			if castEndTime > GetTime() * 1000 then
				-- print("Remaining cast time: " .. castEndTime - GetTime() * 1000 .. "ms")
				return
			end
		end
      local currentTime = GetTime()
      if currentTime - lastSortTime >= 10 then
         C_Container.SortBags()
         print("Sorting bags")
         lastSortTime = currentTime
      end
      local itemLoc, casts = findItem()
      if itemLoc and itemLoc:IsValid() then
            C_TradeSkillUI.CraftSalvage(430315, casts, itemLoc)
      else
            print("No valid items in bags")
      end
end)
