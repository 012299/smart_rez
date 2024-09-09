local function findGreenDe()
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
       for slot = 1, C_Container.GetContainerNumSlots(bag) do
          local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
          if itemInfo and itemInfo.quality == 2 then
			return itemInfo.itemID
          end
       end
    end
end

local button = CreateFrame('Button', 'greenDe',nil , 'SecureActionButtonTemplate')
button:RegisterForClicks("AnyUp","AnyDown")
button:SetAttribute("type","macro")
button:SetScript('PreClick', function(self)
	if InCombatLockdown() then return end

	local greenId = findGreenDe()
	if greenId then
		self:SetAttribute('macrotext', '/cast Disenchant\n/use item:' .. greenId)
	else
		self:SetAttribute('macrotext', nil)
	end
end)
