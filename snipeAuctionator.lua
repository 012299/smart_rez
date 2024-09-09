local _, SnipeAuctionator = ...

-- Initialize main frame and state variables
SnipeAuctionator.frame = CreateFrame("Frame")
SnipeAuctionator.isInitialized = false
SnipeAuctionator.hooksInitialized = false

-- Initialize item data
local function InitializeItemData()
    SnipeAuctionator.itemMaxPrices = {
        [210796] = 270000, -- Mycobloom
        [224828] = 270000, -- Weavercloth r1
    }
    SnipeAuctionator.itemSnipeQuantities = {
        [210796] = 200, -- Mycobloom
        [224828] = 200, -- Weavercloth r1
    }
end

-- Initialize the addon
function SnipeAuctionator:Initialize()
    if self.isInitialized then return end
    self.isInitialized = true

    print("SnipeAuctionator: Initializing...")
    InitializeItemData()
    print("SnipeAuctionator: Initialization complete. Ready to snipe!")
end

-- Create the Snipe UI
function SnipeAuctionator:CreateSnipeUI(parent)
    print("SnipeAuctionator: Creating snipe UI")
    local snipeFrame = CreateFrame("Frame", nil, parent)
    snipeFrame:SetSize(200, 50)
    snipeFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 60, -200)

    -- Create label
    snipeFrame.label = snipeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    snipeFrame.label:SetText("Snipe price")
    snipeFrame.label:SetPoint("TOPLEFT", snipeFrame, "TOPLEFT", -25, 0)

    -- Create price input
    snipeFrame.price = CreateFrame("Frame", nil, snipeFrame, "AuctionatorConfigurationMoneyInputAlternate")
    snipeFrame.price:SetPoint("TOPLEFT", snipeFrame, "TOPLEFT", -150, -20)
    snipeFrame.price.lastSnipePrice = 0
    snipeFrame.price:SetAmount(0)

    -- Update price on change
    snipeFrame.price:SetScript("OnUpdate", function()
        local currentSnipePrice = snipeFrame.price:GetAmount()
        if currentSnipePrice ~= snipeFrame.price.lastSnipePrice then
            snipeFrame.price.lastSnipePrice = currentSnipePrice
            self.itemMaxPrices[snipeFrame.itemID] = currentSnipePrice
        end
    end)

    return snipeFrame
end

-- Hook into Auctionator's Buy Commodity Frame
function SnipeAuctionator:HookAuctionatorBuyCommodityFrame()
    if self.hooksInitialized then return true end

    local AucMix = AuctionatorBuyCommodityFrameTemplateMixin
    if not AucMix then
        print("SnipeAuctionator: AuctionatorBuyCommodityFrameTemplateMixin not found. Retrying...")
        return false
    end

    -- Prevent list update on purchase
    local originalOnEvent = AucMix.OnEvent
    AucMix.OnEvent = function(self, event, ...)
        if event == "COMMODITY_PURCHASE_SUCCEEDED" then
            -- print("SnipeAuctionator: COMMODITY_PURCHASE_SUCCEEDED event received")
            return
        end
        originalOnEvent(self, event, ...)
    end

    -- Hook into OnLoad and create the snipe UI
    hooksecurefunc(AucMix, "OnLoad", function(frame)
        print("SnipeAuctionator: Hooked into AuctionatorBuyCommodityFrameTemplateMixin.OnLoad")
        frame.SnipeFrame = self:CreateSnipeUI(frame.DetailsContainer)

        -- Hook into BuyClicked
        hooksecurefunc(frame, "BuyClicked", function()
            print("SnipeAuctionator: Buy buwtton clicked")
            frame.DetailsContainer.BuyButton:SetText("Buying...")
            frame.DetailsContainer.BuyButton:Disable()
            if frame.WidePriceRangeWarningDialog then
                frame.WidePriceRangeWarningDialog:StartPurchase()
            end
        end)

        -- Hook into CheckPurchase
        hooksecurefunc(frame, "CheckPurchase", function(aucFrame, newUnitPrice, newTotalPrice)
            print("SnipeAuctionator: CheckPurchase called")
            local itemName, itemLink = C_Item.GetItemInfo(aucFrame.expectedItemID)
            local maxPrice = frame.SnipeFrame.price:GetAmount()

            -- Display item information
            DEFAULT_CHAT_FRAME:AddMessage(
                string.format("%s\nID: %d\nPrice: %s\nMax: %s",
                    itemLink or "Unknown Item",
                    aucFrame.expectedItemID,
                    GetMoneyString(newUnitPrice),
                    maxPrice and GetMoneyString(maxPrice) or "Not Set"
                ),
                1, 1, 0
            )

            -- Check if price is within range and confirm purchase
            if maxPrice and maxPrice > 0 then
                if newUnitPrice <= maxPrice then
                    aucFrame.FinalConfirmationDialog:ConfirmPurchase()
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("Purchasing %s x%d\n", itemLink, aucFrame.selectedQuantity), 1, 1, 0)
                else
                    aucFrame.FinalConfirmationDialog:Hide()
                    DEFAULT_CHAT_FRAME:AddMessage("Too rich, try again\n", 1, 1, 0)
                end
            end
        end)
    end)

    print("SnipeAuctionator: Successfully hooked into AuctionatorBuyCommodityFrameTemplateMixin")
    self.hooksInitialized = true
    return true
end

-- Register and handle events
function SnipeAuctionator:RegisterEvents()
    self.frame:RegisterEvent("AUCTION_HOUSE_THROTTLED_SYSTEM_READY")
    self.frame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
    self.frame:RegisterEvent("AUCTION_HOUSE_SHOW")
    self.frame:SetScript("OnEvent", function(_, eventName, eventData)
        if eventName == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
            -- print("SnipeAuctionator: AUCTION_HOUSE_THROTTLED_SYSTEM_READY event received")
            local buyButton = AuctionatorBuyCommodityFrame.DetailsContainer.BuyButton
            if buyButton then
                buyButton:SetText(AUCTIONATOR_L_BUY_NOW)
                buyButton:Enable()
            end
        elseif eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
            AuctionatorBuyCommodityFrame.SnipeFrame.itemID = eventData
            AuctionatorBuyCommodityFrame.SnipeFrame.price:SetAmount(self.itemMaxPrices[eventData] or 0)
            AuctionatorBuyCommodityFrame.selectedQuantity = self.itemSnipeQuantities[eventData] or 0
        elseif eventName == "AUCTION_HOUSE_SHOW" then
            SnipeAuctionator:HookAuctionatorBuyCommodityFrame()
        end
    end)
end

-- Set up hooks
function SnipeAuctionator:SetupHooks()
    self:Initialize()
    self:RegisterEvents()
end

-- Set up hooks as soon as SnipeAuctionator loads
SnipeAuctionator:SetupHooks()

print("SnipeAuctionator: Addon loaded and attempting to hook into Auctionator...")
