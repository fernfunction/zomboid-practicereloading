require "ISUI/ISFirearmRadialMenu"
require "PracticeReloading/ISPracticeReloadingAction"

local originalFillMenu = ISFirearmRadialMenu.fillMenu

function ISFirearmRadialMenu:fillMenu()
    originalFillMenu(self)
    local menu = getPlayerRadialMenu(self.playerNum)
    local weapon = self:getWeapon()
    if not weapon then return end

    local hasMagazine = weapon:getMagazineType()
    local hasAmmoLoaded = weapon:getCurrentAmmoCount() > 0 or weapon:isContainsClip()

    local canPractice = false
    if hasMagazine then
        if hasAmmoLoaded then
            canPractice = true
        else
            local magazine = weapon:getBestMagazine(self.character)
            canPractice = magazine ~= nil
        end
    else
        if hasAmmoLoaded then
            canPractice = true
        else
            local ammoType = weapon:getAmmoType()
            if ammoType then
                local itemKey = ammoType:getItemKey()
                canPractice = self.character:getInventory():getCountTypeRecurse(itemKey) > 0
            end
        end
    end

    if canPractice then
        local text = getText("IGUI_FirearmRadial_PracticeReloading")
        menu:addSlice(text, getTexture("media/ui/FirearmRadial_BulletsIntoFirearm.png"), PracticeReloadingRadialMenu.onPracticeReloading, self.character, weapon)
    end
end

PracticeReloadingRadialMenu = {}

function PracticeReloadingRadialMenu.onPracticeReloading(character, weapon)
    if not character or not weapon then return end
    if character:getPrimaryHandItem() ~= weapon then return end
    ISTimedActionQueue.add(ISPracticeReloadingAction:new(character, weapon))
end
