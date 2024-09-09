local button, REVIVE_BATTLE_PETS = CreateFrame('Button', 'SmartRez',nil , 'SecureActionButtonTemplate'), C_Spell.GetSpellInfo(125439).name
button:RegisterForClicks("AnyUp","AnyDown")
button:SetAttribute("type","macro")
button:SetScript('PreClick', function(self)
    if InCombatLockdown() then return end

    local injured = false
    for i = 1, 3 do -- Determine whether any pet in our loadout is actually injured
        local guid = C_PetJournal.GetPetLoadOutInfo(i)
        if guid then
            local health, maxHealth = C_PetJournal.GetPetStats(guid)
            if health < maxHealth then
                injured = true
                break
            end
        end
    end
    if not injured then
        if (not C_PetBattles.IsInBattle()) then
            print('Pets are already at full health!')
        end
        self:SetAttribute('macrotext', nil)
        return
    end

    if C_Spell.GetSpellCooldown(125439).duration == 0 then -- "Revive Battle Pets" is off cooldown, cast that
        self:SetAttribute('macrotext', '/cast [nopetbattle] ' .. REVIVE_BATTLE_PETS)
    else
        self:SetAttribute('macrotext', '/use [nopetbattle] item:86143')
    end
end)

local function AutoSelectGossipOption(id)
	local gossipInfoTable = C_GossipInfo.GetOptions()
	if gossipInfoTable[id] then
		if gossipInfoTable[id].gossipOptionID then
			C_GossipInfo.SelectOption(gossipInfoTable[id].gossipOptionID)
		end
	end
end

local autoGossipFrame = CreateFrame("FRAME")
autoGossipFrame:RegisterEvent("GOSSIP_SHOW")
autoGossipFrame:SetScript("OnEvent",function()
    local targetid = tonumber(string.match(tostring(UnitGUID("target")), "-([^-]+)-[^-]+$"))
    if (targetid == 97804) then -- diffany nelson
        AutoSelectGossipOption(1)
    end
end)
