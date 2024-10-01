local name, smart_rez = ...

local cookingID = 445118
local prospectID = 434018
local thaumaID = 430315

local thaumaReg = {
	210796, --mycobloom r1
	210797, --mycobloom r2
	211802, --ominous transmutagen
	211804, --volatile transmutagen
	211803, --Mercurial transmutagen
	212667, --Gloom Chitin r1
	212668, --Gloom Chitin r2
	212665, --leather r2
	210937, --iron claw r2
	210806, -- blossom r2
}

local cookingReg = {
	223512, --beef
	225911, --bee
}
local prospectReg = {
	210934, -- aqr2
	210933, --aqr1
}

smart_rez.craftStackSize = {
	[thaumaID] = 20,
	[cookingID] = 5,
	[prospectID] = 5,
}

smart_rez.reagentCraftIDs = {}

function smart_rez:initReagentCraftIDs()
	for _, pair in ipairs({ { thaumaID, thaumaReg }, { prospectID, prospectReg }, { cookingID, cookingReg } }) do
		local craftID, regIDs = pair[1], pair[2]
		if C_TradeSkillUI.IsRecipeProfessionLearned(craftID) then
			for i = 1, #regIDs do
				smart_rez.reagentCraftIDs[regIDs[i]] = craftID
			end
		end
	end
end
