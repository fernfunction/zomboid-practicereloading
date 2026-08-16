require "TimedActions/ISBaseTimedAction"

ISPracticeReloadingAction = ISBaseTimedAction:derive("ISPracticeReloadingAction")

function ISPracticeReloadingAction:isValid()
    return self.character:getPrimaryHandItem() == self.gun
end

function ISPracticeReloadingAction:start()
    self:beginAddingActions()
    self:queueNextCycle()
    if not self:endAddingActions() then
        self:forceStop()
    else
        self:forceComplete()
    end
end

function ISPracticeReloadingAction:queueNextCycle()
    if self.gun:getMagazineType() then
        self:queueMagazineCycle()
    else
        self:queueRoundsCycle()
    end
end

function ISPracticeReloadingAction:queueMagazineCycle()
    if self.gun:isContainsClip() then
        ISTimedActionQueue.add(ISEjectMagazine:new(self.character, self.gun))
        ISTimedActionQueue.add(ISPracticeReloadingAction:new(self.character, self.gun))
    else
        local magazine = self.gun:getBestMagazine(self.character)
        if not magazine then return end
        ISInventoryPaneContextMenu.transferIfNeeded(self.character, magazine)
        ISTimedActionQueue.add(ISInsertMagazine:new(self.character, self.gun, magazine))
        ISTimedActionQueue.add(ISPracticeReloadingAction:new(self.character, self.gun))
    end
end

function ISPracticeReloadingAction:queueRoundsCycle()
    if self.gun:isJammed() then return end
    if self.gun:getCurrentAmmoCount() > 0 then
        ISTimedActionQueue.add(ISUnloadBulletsFromFirearm:new(self.character, self.gun))
        ISTimedActionQueue.add(ISPracticeReloadingAction:new(self.character, self.gun))
    else
        local ammoType = self.gun:getAmmoType()
        if not ammoType then return end
        local itemKey = ammoType:getItemKey()
        local ammoCount = ISInventoryPaneContextMenu.transferBullets(self.character, itemKey, self.gun:getCurrentAmmoCount(), self.gun:getMaxAmmo())
        if ammoCount == 0 then return end
        ISTimedActionQueue.add(ISReloadWeaponAction:new(self.character, self.gun))
        ISTimedActionQueue.add(ISPracticeReloadingAction:new(self.character, self.gun))
    end
end

function ISPracticeReloadingAction:update()
    self:forceStop()
end

function ISPracticeReloadingAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISPracticeReloadingAction:perform()
    ISBaseTimedAction.perform(self)
end

function ISPracticeReloadingAction:getDuration()
    return -1
end

function ISPracticeReloadingAction:new(character, gun)
    local o = ISBaseTimedAction.new(self, character)
    o.stopOnAim = false
    o.stopOnWalk = false
    o.stopOnRun = true
    o.gun = gun
    o.maxTime = -1
    o.useProgressBar = false
    return o
end
