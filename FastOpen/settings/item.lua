local _
local assert = _G.assert
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER; assert(BACKPACK_CONTAINER ~= nil,'BACKPACK_CONTAINER')
local C_PetJournal = _G.C_PetJournal; assert(C_PetJournal ~= nil,'C_PetJournal')
local format = _G.format; assert(format ~= nil,'format')
local GetContainerItemID = _G.GetContainerItemID or C_Container.GetContainerItemID; assert(GetContainerItemID ~= nil,'GetContainerItemID')
local GetContainerItemInfo = _G.GetContainerItemInfo or C_Container.GetContainerItemInfo; assert(GetContainerItemInfo ~= nil,'GetContainerItemInfo')
local GetContainerItemLink = _G.GetContainerItemLink or C_Container.GetContainerItemLink; assert(GetContainerItemLink ~= nil,'GetContainerItemLink')
local GetContainerNumSlots = _G.GetContainerNumSlots or C_Container.GetContainerNumSlots; assert(GetContainerNumSlots ~= nil,'GetContainerNumSlots')
local GetItemCount = _G.GetItemCount or _G.C_Item.GetItemCount; assert(GetItemCount ~= nil,'GetItemCount')
local GetItemInfo = _G.GetItemInfo or _G.C_Item.GetItemInfo; assert(GetItemInfo ~= nil,'GetItemInfo')
local GetItemSpell = _G.GetItemSpell or _G.C_Item.GetItemSpell; assert(GetItemSpell ~= nil,'GetItemSpell')
local GetTime = _G.GetTime; assert(GetTime ~= nil,'GetTime')
local LOCKED = _G.LOCKED; assert(LOCKED ~= nil,'LOCKED')
local math = _G.math; assert(math ~= nil,'math')
local NUM_TOTAL_EQUIPPED_BAG_SLOTS = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS; assert(NUM_TOTAL_EQUIPPED_BAG_SLOTS ~= nil,'NUM_TOTAL_EQUIPPED_BAG_SLOTS')
local pairs = _G.pairs; assert(pairs ~= nil,'pairs')
local strfind = _G.strfind; assert(strfind ~= nil,'strfind')
local string = _G.string; assert(string ~= nil,'string')
local tonumber = _G.tonumber; assert(tonumber ~= nil,'tonumber')
local type = _G.type; assert(type ~= nil,'type')
local unpack = _G.unpack; assert(unpack ~= nil,'unpack')
local wipe = _G.wipe; assert(wipe ~= nil,'wipe')
local GetItemCooldown = _G.GetItemCooldown or _G.C_Item.GetItemCooldown; assert(GetItemCooldown ~= nil,'GetItemCooldown')
local UnpackAuraData = AuraUtil.UnpackAuraData; assert(UnpackAuraData ~= nil,'UnpackAuraData')
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID; assert(GetPlayerAuraBySpellID ~= nil,'GetPlayerAuraBySpellID')
local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)
local T_BAGS = P.T_BAGS; assert(T_BAGS ~= nil,'T_BAGS')
local T_PICK = P.T_PICK; assert(T_PICK ~= nil,'T_PICK')
local T_BLACKLIST = P.T_BLACKLIST; assert(T_BLACKLIST ~= nil,'T_BLACKLIST')
local T_CHECK = P.T_CHECK; assert(T_CHECK ~= nil,'T_CHECK')
local T_OPEN = P.T_OPEN; assert(T_OPEN ~= nil,'T_OPEN')
local T_RECIPES_FIND = P.T_RECIPES_FIND; assert(T_RECIPES_FIND ~= nil,'T_RECIPES_FIND')
local T_SPELL_FIND = P.T_SPELL_FIND; assert(T_SPELL_FIND ~= nil,'T_SPELL_FIND')
local T_ITEM_REQUIRE_QUEST_NOT_COMPLETED = FastOpen.T_ITEM_REQUIRE_QUEST_NOT_COMPLETED; assert(T_ITEM_REQUIRE_QUEST_NOT_COMPLETED ~= nil,'T_ITEM_REQUIRE_QUEST_NOT_COMPLETED')
local T_USE = P.T_USE; assert(T_USE ~= nil,'T_USE')
local print = P.print; assert(print ~= nil,'print')
local TIMER_IDLE = P.TIMER_IDLE; assert(TIMER_IDLE ~= nil,'TIMER_IDLE')

function FastOpen:ItemIsBlacklisted(itemID)
  if not itemID then return true end
  if T_BLACKLIST and T_BLACKLIST[itemID] then
    self:Verbose("ItemIsBlacklisted:","itemID",itemID,"is temporary blacklisted")
    return true
  elseif FastOpen.AceDB.profile["T_BLACKLIST"] and FastOpen.AceDB.profile.T_BLACKLIST[itemID] then
    self:Verbose("ItemIsBlacklisted:","itemID",itemID,"is permanently blacklisted")
    return true
  elseif P.BLACKLIST[itemID] then
    self:Verbose("ItemIsBlacklisted:","itemID",itemID,"build-in blacklisted")
    return true
  end
end
function FastOpen:ItemGetSpell(itemID)
  local spell = GetItemSpell(itemID)
  if spell and T_SPELL_FIND[spell] then
    local c, z, m = unpack(T_SPELL_FIND[spell],1,3)
    self:Verbose("ItemGetSpell:","itemID",itemID,"spell",spell)
    return c[1], c[2], z, m
  end
end
function FastOpen:ItemGetItem(itemID)
  local ref = FastOpen.T_ITEMS[itemID] or FastOpen.T_DISENCHANT_ITEMS[itemID] or FastOpen.AceDB.profile["T_TRACKLIST"][itemID]
  if not ref then return end
  local c,z,m,a = unpack(ref,1,4)
  if m and not m[self.mapID] then
    self:Verbose("ItemGetItem:","itemID",itemID,"rejected by map use")
    return 0
  end
  if a then
    local hasAura = false
    local name, icon, countAura, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnpackAuraData(GetPlayerAuraBySpellID(a))
    if spellID and (spellID == math.abs(a)) then
      if (spellID == P.AURA_MINERS_COFFEE) then
        if (countAura >= FastOpen.AceDB.profile.cofeeStacks) then
          self:Verbose("ItemGetItem:","itemID",itemID,"rejected already have aura",name,"with",countAura,"stacks")
          return 0
        end
      else
        hasAura = true
      end
    end
    if a > 0 and hasAura then
      self:Verbose("ItemGetItem:","itemID",itemID,"rejected already have aura",name)
      return 0
    elseif a < 0 and not hasAura then
      self:Verbose("ItemGetItem:","itemID",itemID,"rejected missing aura",name)
      return 0
    end
  end
  self:Verbose("ItemGetItem:","itemID",itemID,"will be shown",name,"count",c[1],"prio",c[2])
  return c[1], c[2], z, m, a
end
function FastOpen:ItemGetLockPattern(itemID, lines)
  if FastOpen.AceDB.profile.profession and self.pickLockLevel and (#lines > 2) then
    local locked = -1 
    if string.match(lines[2].leftText,"^" .. LOCKED .. "$") then locked = 3 end
    if string.match(lines[3].leftText,"^" .. LOCKED .. "$") then locked = 4 end
    if locked > 0 then 
      local lockLevel = tonumber(string.match(lines[locked].leftText,"%d+"))
      if lockLevel and (self.pickLockLevel >= lockLevel) then
        self:Verbose("ItemGetLockPattern:",itemID,"LockeLevel",lockLevel)
        T_PICK[itemID] = true
        return 1, P.PRI_OPEN
      end
    end
  end
end
function FastOpen:ItemGetPattern(itemID,bag,slot)
  local lines = FastOpen:GetTooltipLinesByBagItem(bag, slot)
  if (#lines < 1) then
    print(format("|cFFFF0000Error|r broken tooltip for |cFFFF0000%s|r itemID(%d)",GetItemInfo(itemID) or "unknown",itemID))
    return
  end
  local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, GetItemInfo(itemID))
  if classID == Enum.ItemClass.Miscellaneous and subclassID == Enum.ItemMiscellaneousSubclass.Mount then
    self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as MOUNT")
    return 1, P.PRI_OPEN
  end
  if classID == Enum.ItemClass.Housing and subclassID == Enum.ItemHousingSubclass.Decor then
    self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as DECOR")
    return 1, P.PRI_OPEN --fallback for housing decor
  end
  if classID == Enum.ItemClass.Consumable and subclassID == Enum.ItemConsumableSubclass.Other then
    local tMogSet = C_Item.GetItemLearnTransmogSet(itemID)
    if tMogSet then
      for _, appearance in pairs(C_Transmog.GetAllSetAppearancesByID(tMogSet)) do
        if appearance and appearance.itemModifiedAppearanceID and not C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearance.itemModifiedAppearanceID) then
          self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as TRANSMOG")
          return 1, P.PRI_OPEN
        end
      end
    end
  end
  if classID == Enum.ItemClass.Consumable and (subclassID == Enum.ItemConsumableSubclass.UtilityCurio or subclassID == Enum.ItemConsumableSubclass.CombatCurio) then
    self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as CURIO")
    return 1, P.PRI_OPEN --fallback for curios
  end
  local n, p = self:ItemGetLockPattern(itemID, lines)
  if n and n > 0 then return n, p end
  for i=1,#lines do
    local heading = lines[i] and lines[i].leftText
    if heading and heading ~= "" then
      if heading == ITEM_COSMETIC then
        if not FastOpen:ItemIsAppearanceCollected(lines) then
          self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as COSMETIC")
          return 1, P.PRI_OPEN
        else
          return 0
        end
      end
      if heading == TOY then
        if not FastOpen:ItemIsToyCollected(lines) then
          self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as TOY")
          return 1, P.PRI_OPEN
        else
          return 0
        end
      end
      if not self:IsTransmogColor(lines[i].leftColor:GetRGBAAsBytes()) then
        for key, data in pairs(T_RECIPES_FIND) do
          local c, pattern, z, m, faction = unpack(data,1,5)
          if strfind(heading,pattern,1,true) then
            if faction then
              local level, top, value, reward = self:GetReputation(heading)
              if (level and (level > 7) and FastOpen.AceDB.profile.SkipExalted) or reward then return end
            end
            self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as RECIPE because of heading and pattern:",heading,pattern)
            return c[1], c[2], z, m
          end
        end
      end
      for key, data in pairs(T_OPEN) do
        if strfind(heading,key,1,true) then
          local c, z, m = unpack(data,1,3)
          self:Verbose("ItemGetPattern:","itemID",itemID,"will be shown as OPEN")
          return c[1], c[2], z, m
        end
      end
    end
  end
  return 0
end
local offset = 0
function FastOpen:ItemToUse(itemID,count,prio,zone,map,aura,source)
  self:Verbose("ItemToUse:","itemID",itemID,"count",count,"prio",prio,"zone",zone,"map",map,"aura",aura,"source",source)
  local quest = T_ITEM_REQUIRE_QUEST_NOT_COMPLETED[itemID]
  if quest and C_QuestLog.IsQuestFlaggedCompleted(quest) then
    self:Verbose("ItemToUse:","not using item, because quest is flagged completed.","itemID",itemID)
    T_USE[itemID] = nil
    return
  end
  local pt = T_USE[itemID]
  if not pt then
    if (self.BF and self.BF.showID == nil) and (itemID == self.AceDB.char.itemID) then
      T_USE[itemID] = {count, prio, zone, map, aura, GetTime()+1.0, GetItemCount(itemID)}
    else
      T_USE[itemID] = {count, prio, zone, map, aura, GetTime()+offset, GetItemCount(itemID)}
      offset = offset + 0.001
    end
    pt = T_USE[itemID]
  else
    if pt[7] and count and (pt[7] < count) and (GetItemCount(itemID) >= count) then pt[6] = GetTime() end
    pt[1] = count
    pt[2] = prio
    if pt[3] == nil then pt[3] = zone end
    if pt[4] == nil then pt[4] = map end
    if pt[5] == nil then pt[5] = aura end
    pt[7] = GetItemCount(itemID)
  end
end
function FastOpen:ItemScan()
  wipe(T_BAGS)
  for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
    for slot = 1, GetContainerNumSlots(bag), 1 do
      local itemID = GetContainerItemID(bag,slot)
      if (itemID ~= nil) then
        local itemLink = GetContainerItemLink(bag,slot)
        T_BAGS[itemID] = {bag,slot,itemLink}
      end
    end
  end
  for key in pairs(T_CHECK) do if not T_BAGS[key] then T_CHECK[key] = nil end end
  for key in pairs(T_USE) do if not T_BAGS[key] then T_USE[key] = nil end end
  for itemID, data in pairs(T_BAGS) do
    if not T_CHECK[itemID] then
      T_CHECK[itemID] = true
      if not self:ItemIsBlacklisted(itemID) then
        local bag, slot, itemLink = unpack(data)
        if itemLink then
          local _, _, linkType, linkID = string.find(itemLink, "|?[^|]*|?H?([^:]*):?(%d+):")
          if linkType == P.ITEM_TYPE_BATTLE_PET then
            local numCollected, limit = C_PetJournal.GetNumCollectedInfo(linkID)
            if (numCollected < limit) then
              self:ItemToUse(itemID, 1, P.PRI_OPEN, nil, nil, "PET")
            else
              self:Verbose("ItemScan:","Pet",itemID,"have more than limit",limit)
              T_USE[itemID] = nil
            end
          elseif linkType == P.ITEM_TYPE_ITEM then
            local count, prio, zone, map, aura = self:ItemGetSpell(itemID)
            if count then 
              if (count > 0) then self:ItemToUse(itemID, count, prio, zone, map, aura, "SPELL") else T_USE[itemID] = nil end
            else
              count, prio, zone, map, aura = self:ItemGetItem(itemID)
              if count then 
                if (count > 0) then self:ItemToUse(itemID, count, prio, zone, map, aura, "ITEMID") else T_USE[itemID] = nil end
              else
                count, prio, zone, map, aura = self:ItemGetPattern(itemID,bag,slot)
                if count then
                  if (count > 0) then self:ItemToUse(itemID, count, prio, zone, map, aura, "TOOLTIP") else T_USE[itemID] = nil end
                else
                  T_CHECK[itemID] = nil
                  T_USE[itemID] = nil
                end
              end
            end
          end
        else
          self:Verbose("ItemScan:","itemID",itemID,"don't return itemLink")
          T_USE[itemID] = nil
        end
      else
        self:Verbose("ItemScan:","itemID",itemID,"is blacklisted")
        T_USE[itemID] = nil
      end
    end
  end
end
function FastOpen:ItemIsUnusable(Red, Green, Blue, Alpha)
  return (Red == 255 and Green == 32 and Blue == 32 and Alpha == 255)
end
function FastOpen:IsTransmogColor(Red, Green, Blue, Alpha)
  return (Red == 255 and Green == 128 and Blue == 255 and Alpha == 255)
end
function FastOpen:ItemIsAppearanceCollected(lines)
  if not lines then return false end
  local collected = true
  for i=1,#lines do
    if (lines[i] and lines[i].leftText) == TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN then
      collected = false
      break
    end
  end
  return collected
end
function FastOpen:ItemIsToyCollected(lines)
  if not lines then return false end
  local collected = false
  for i=1,#lines do
    if (lines[i] and lines[i].leftText) == ITEM_SPELL_KNOWN then
      break
    end
  end
  return collected
end
function FastOpen:ItemIsUsable(itemID)
  if not T_BAGS[itemID] then return end
  local bag,slot,itemLink = unpack(T_BAGS[itemID])
  if itemLink then
    local _, _, linkType, linkID = string.find(itemLink, "|?c[^|]*|?H?([^:]*):?(%d+):")
    if linkType == P.ITEM_TYPE_BATTLE_PET then return true end
  end
  local lines = FastOpen:GetTooltipLinesByBagItem(bag, slot)
  if (#lines < 1) then
    self:Verbose("ItemIsUsable:","itemID",itemID,"Empty tooltip!")
  end
  if #lines > 0 then
    for i=1,#lines do
      if lines[i] and lines[i].leftText then
        local text = lines[i].leftText
        if text and text ~= "" then
          if self:ItemIsUnusable(lines[i].leftColor:GetRGBAAsBytes()) then 
            self:Verbose("itemID",itemID,"has red text in tooltip!",text)
            return false
          end
          if i == 1 then
            local level, top, value, reward = self:GetReputation(text)
            if level then
              if ((level > 7) and FastOpen.AceDB.profile.SkipExalted) or reward then return false end
              if self:ItemCD(itemID) then return false end
            end
          end
        end
      end
      if lines[i] and lines[i].rightText then
        local text = lines[i].rightText
        if text and text ~= "" then
          if self:ItemIsUnusable(lines[i].rightColor:GetRGBAAsBytes()) then 
            self:Verbose("itemID",itemID,"has red text in tooltip!",text)
            return false
          end
        end
      end
    end
    return true
  end
  self:Verbose("ItemIsUsable:","itemID",itemID,"Empty tooltip!")
  return false
end
function FastOpen:ItemToPicklock(itemID)
  if not itemID then return end
  for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
    for slot = 1, GetContainerNumSlots(bag), 1 do
      local id = GetContainerItemID(bag,slot)
      if (id == itemID) then
        local lines = FastOpen:GetTooltipLinesByBagItem(bag, slot)
        if (#lines < 1) then
          self:Verbose("Broken tooltip on " .. id)
        end
        if self:ItemGetLockPattern(id, lines) then
          self:Verbose("ItemToPicklock:","Locked item",id,"bag",bag,"slot",slot)
          return bag, slot
        end
      end
    end
  end
end
function FastOpen:ItemShowRestart()
  if self:BlacklistClear() then
    print(P.L["RESTARTED_LOOKUP"])
    self:BAG_UPDATE()
  else 
    self.AceDB.char.itemID = nil
    self:ButtonHide()
  end
end
function FastOpen:ItemShow(itemID,prio)
  local bt = self.BF
  if not bt then return end
  if not itemID then self:ItemShowRestart(); return; end
  local bagID, slotID = unpack(T_BAGS[itemID])
  if not (bagID and slotID) then
    self:BlacklistItem(false,itemID)
    self:ItemShowRestart()
    return
  end
  local isGlow = (prio == P.PRI_POPUP) or nil
  local itemCount = GetItemCount(itemID)
  local itemTexture = GetContainerItemInfo(bagID, slotID)
  if not itemTexture then
    self:BlacklistItem(false,itemID)
    self:ItemShowRestart()
    return
  end
  if type(itemTexture) == "table" then
    itemTexture = itemTexture.iconFileID
  end
  local mtext = format(P.MACRO_ACTIVE,itemID)
  local mtarget = nil 
  local mtargetitem = nil
  local mtargetbag = nil
  local mtartgetslot = nil
  local mtype = "item"
  local mspell = nil
  if T_PICK[itemID] then
    local bag, slot = self:ItemToPicklock(itemID)
    if bag and slot then
      bagID = bag
      slotID = slot
      isGlow = true
      mtext = nil
      mtype = "spell"
      mspell = self.pickLockSpell
      mtarget = nil
      mtargetitem = nil
    else
      T_PICK[itemID] = nil
    end
  elseif FastOpen.T_DISENCHANT_ITEMS[itemID] then
    isGlow = true
    mtext = nil
    mtype = "spell"
    mspell = "Disenchant"
    mtarget = nil
    mtargetitem =  format("item:%d", itemID)
  elseif C_Item.IsDressableItemByID(itemID) then
    mtext = format(P.MACRO_ACTIVE,itemID)
  end
  if (bt.itemCount ~= itemCount) or (bt.itemID ~= itemID) or (bt.isGlow ~= isGlow) or (bt.mtext ~= mtext) or (bt.mtype ~= mtype) or (bt.mspell ~= mspell) or (bt.mtarget ~= mtarget) or (bt.mtargetitem ~= mtargetitem) or (bt.bagID ~= bagID) or (bt.slotID ~= slotID) then
    bt.prio = prio
    bt.showID = itemID
    bt.itemID = itemID
    bt.isGlow = isGlow
    bt.mtext = mtext
    bt.mtype = mtype
    bt.mspell = mspell
    bt.mtarget = mtarget
    bt.mtargetitem = mtargetitem
    bt.bagID = bagID
    bt.slotID = slotID
    bt.itemCount = itemCount
    bt.itemTexture = itemTexture
    self.AceDB.char.itemID = itemID
    self:ButtonShow()
  end
end
function FastOpen:ItemCD(itemID)
  local startTime, duration, enable = GetItemCooldown(itemID)
  return not (startTime == 0)
end
function FastOpen:ItemShowNew()
  self.preClick = nil
  if self:inCombat() or not (self.spellLoad and self.itemLoad) then self:TimerFire("ItemShowNew", P.TIMER_IDLE); return end
  self:Profile(true)
  self:ItemScan()
  local toShow, prio, stamp = nil, 0, 0
  for itemID, data in pairs(T_USE) do
    local c, p, z, m, a, t = unpack(data,1,6)
    local inZone = not z
    if z then
      if type(z) == "table" then
        for i = 1, #z do
          if type(z[i]) == "string" then
            if z[i] == self.Zone then
              inZone = true
            end
          end
        end
      end
      if inZone then
        p = P.PRI_POPUP
      else
        if FastOpen.AceDB.profile.zoneUnlock and not a then
          p = p + P.PRI_SKIP
          inZone = true
        else
          p = nil
        end
      end
    end
    if a and (not inZone or not self:ItemGetItem(itemID)) then p = nil end
    if z and (not inZone) then p = nil end
    if m and not m[self.mapID] then
      p = nil
    end
    self:Verbose("ItemShowNew:","itemID",itemID,"Zone",(inZone and "yes" or "no"),"Priority",((type(p) == "number") and p or "disabled"),"Stamp",t)
    if (type(p) == "number") and self:ItemIsUsable(itemID) and (GetItemCount(itemID) >= c) then
      if (prio == 0) then
        toShow = itemID; prio = p; stamp = t
      else 
        if (p < prio) then
          toShow = itemID; prio = p; stamp = t
        else 
          if (p == prio) and (t > stamp) then
            toShow = itemID; prio = p; stamp = t
          end
        end
      end
    end
  end
  self:ItemShow(toShow,prio)
  self:Profile(false)
end
function FastOpen:ItemTimer()
  if self:inCombat() or not (self.spellLoad and self.itemLoad) then return end
  wipe(T_CHECK)
  self:ZONE_CHANGED()
end
