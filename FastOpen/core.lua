local _
local assert = _G.assert
local ARTIFACT_RELIC_TALENT_AVAILABLE = _G.ARTIFACT_RELIC_TALENT_AVAILABLE; assert(ARTIFACT_RELIC_TALENT_AVAILABLE ~= nil,'ARTIFACT_RELIC_TALENT_AVAILABLE')
local C_Garrison = _G.C_Garrison; assert(C_Garrison ~= nil,'C_Garrison')
local C_Reputation = _G.C_Reputation; assert(C_Reputation ~= nil,'C_Reputation')
local C_TooltipInfo = _G.C_TooltipInfo; assert(C_TooltipInfo ~= nil,'C_TooltipInfo')
local CreateFrame = _G.CreateFrame; assert(CreateFrame ~= nil,'CreateFrame')
local date = _G.date; assert(date ~= nil,'date')
local debugprofilestop = _G.debugprofilestop; assert(debugprofilestop ~= nil,'debugprofilestop')
local ERR_SPELL_FAILED_REAGENTS_GENERIC = _G.ERR_SPELL_FAILED_REAGENTS_GENERIC; assert(ERR_SPELL_FAILED_REAGENTS_GENERIC ~= nil,'ERR_SPELL_FAILED_REAGENTS_GENERIC')
local ExpandAllFactionHeaders = _G.ExpandAllFactionHeaders or _G.C_Reputation.ExpandAllFactionHeaders; assert(ExpandAllFactionHeaders ~= nil,'ExpandAllFactionHeaders')
local format = _G.format; assert(format ~= nil,'format')
local GetArchaeologyRaceInfo = _G.GetArchaeologyRaceInfo; assert(GetArchaeologyRaceInfo ~= nil,'GetArchaeologyRaceInfo')
local GetCVar = _G.GetCVar; assert(GetCVar ~= nil,'GetCVar')
local GetFactionInfo = _G.GetFactionInfo or _G.C_CreatureInfo.GetFactionInfo; assert(GetFactionInfo ~= nil,'GetFactionInfo')
local GetFactionInfoByID = _G.GetFactionInfoByID or _G.C_CreatureInfo.GetFactionInfo; assert(GetFactionInfoByID ~= nil,'GetFactionInfoByID')
local GetChatWindowInfo = _G.GetChatWindowInfo; assert(GetChatWindowInfo ~= nil,'GetChatWindowInfo')
local GetItemCount = _G.GetItemCount or _G.C_Item.GetItemCount; assert(GetItemCount ~= nil,'GetItemCount')
local GetItemInfo = _G.GetItemInfo or _G.C_Item.GetItemInfo; assert(GetItemInfo ~= nil,'GetItemInfo')
local GetItemSpell = _G.GetItemSpell or _G.C_Item.GetItemSpell; assert(GetItemSpell ~= nil,'GetItemSpell')
local GetMinimapZoneText = _G.GetMinimapZoneText; assert(GetMinimapZoneText ~= nil,'GetMinimapZoneText')
local GetNumArchaeologyRaces = _G.GetNumArchaeologyRaces; assert(GetNumArchaeologyRaces ~= nil,'GetNumArchaeologyRaces')
local GetNumFactions = _G.GetNumFactions or _G.C_Reputation.GetNumFactions; assert(GetNumFactions ~= nil,'GetNumFactions')
local GetSpellCooldown = _G.GetSpellCooldown or _G.C_Spell.GetSpellCooldown; assert(GetSpellCooldown ~= nil,'GetSpellCooldown')
local GetSpellInfo = _G.GetSpellInfo or _G.C_Spell.GetSpellName; assert(GetSpellInfo ~= nil,'GetSpellInfo')
local GetTime = _G.GetTime; assert(GetTime ~= nil,'GetTime')
local gsub = _G.gsub; assert(gsub ~= nil,'gsub')
local InCombatLockdown = _G.InCombatLockdown; assert(InCombatLockdown ~= nil,'InCombatLockdown')
local ipairs = _G.ipairs; assert(ipairs ~= nil,'ipairs')
local IsPlayerSpell = _G.IsPlayerSpell; assert(IsPlayerSpell ~= nil,'IsPlayerSpell')
local ITEM_OPENABLE = _G.ITEM_OPENABLE; assert(ITEM_OPENABLE ~= nil,'ITEM_OPENABLE')
local ITEM_SPELL_TRIGGER_ONUSE = _G.ITEM_SPELL_TRIGGER_ONUSE; assert(ITEM_SPELL_TRIGGER_ONUSE ~= nil,'ITEM_SPELL_TRIGGER_ONUSE')
local LE_FOLLOWER_TYPE_SHIPYARD_6_2 = Enum.GarrisonFollowerType.FollowerType_6_0_Boat; assert(LE_FOLLOWER_TYPE_SHIPYARD_6_2 ~= nil,'LE_FOLLOWER_TYPE_SHIPYARD_6_2')
local LE_GARRISON_TYPE_6_0 = Enum.GarrisonType.Type_6_0_Garrison or Enum.GarrisonType.Type_6_0; assert(LE_GARRISON_TYPE_6_0 ~= nil,'LE_GARRISON_TYPE_6_0')
local LE_GARRISON_TYPE_7_0 = Enum.GarrisonType.Type_7_0_Garrison or Enum.GarrisonType.Type_7_0; assert(LE_GARRISON_TYPE_7_0 ~= nil,'LE_GARRISON_TYPE_7_0')
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local math = _G.math; assert(math ~= nil,'math')
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS; assert(NUM_CHAT_WINDOWS ~= nil,'NUM_CHAT_WINDOWS')
local pairs = _G.pairs; assert(pairs ~= nil,'pairs')
local select = _G.select; assert(select ~= nil,'select')
local string = _G.string; assert(string ~= nil,'string')
local tonumber = _G.tonumber; assert(tonumber ~= nil,'tonumber')
local type = _G.type; assert(type ~= nil,'type')
local UIParent = _G.UIParent; assert(UIParent ~= nil,'UIParent')
local UnitClass = _G.UnitClass; assert(UnitClass ~= nil,'UnitClass')
local unpack = _G.unpack; assert(unpack ~= nil,'unpack')
local wipe = _G.wipe; assert(wipe ~= nil,'wipe')
local PLAYER_LIST_DELIMITER = _G.PLAYER_LIST_DELIMITER; assert(PLAYER_LIST_DELIMITER ~= nil,'PLAYER_LIST_DELIMITER')
local table = _G.table; assert(table ~= nil,'table')

local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)

local ARCHAELOGY_ANNOUNCE = P.ARCHAELOGY_ANNOUNCE; assert(ARCHAELOGY_ANNOUNCE ~= nil,'ARCHAELOGY_ANNOUNCE')
local ARTIFACT_ANNOUNCE = P.ARTIFACT_ANNOUNCE; assert(ARTIFACT_ANNOUNCE ~= nil,'ARTIFACT_ANNOUNCE')
local CB_CVAR = P.CB_CVAR; assert(CB_CVAR ~= nil,'CB_CVAR')
local L = P.L
local PRI_REP = P.PRI_REP; assert(PRI_REP ~= nil,'PRI_REP')
local REWARD_ANNOUNCE = P.REWARD_ANNOUNCE; assert(REWARD_ANNOUNCE ~= nil,'REWARD_ANNOUNCE')
local RGB_RED = P.RGB_RED; assert(RGB_RED ~= nil,'RGB_RED')
local RGB_YELLOW = P.RGB_YELLOW; assert(RGB_YELLOW ~= nil,'RGB_YELLOW')
local SHIPYARD_ANNOUNCE = P.SHIPYARD_ANNOUNCE; assert(SHIPYARD_ANNOUNCE ~= nil,'SHIPYARD_ANNOUNCE')
local SPELL_PICKLOCK = P.SPELL_PICKLOCK; assert(SPELL_PICKLOCK ~= nil,'SPELL_PICKLOCK')
local TALENT_ANNOUNCE = P.TALENT_ANNOUNCE; assert(TALENT_ANNOUNCE ~= nil,'TALENT_ANNOUNCE')
local TOGO_ANNOUNCE = P.TOGO_ANNOUNCE; assert(TOGO_ANNOUNCE ~= nil,'TOGO_ANNOUNCE')
local whoCalls = P.whoCalls; assert(whoCalls ~= nil,'whoCalls')
local WORK_ANNOUNCE = P.WORK_ANNOUNCE; assert(WORK_ANNOUNCE ~= nil,'WORK_ANNOUNCE')
local LIB_MASQUE = P.LIB_MASQUE;
local LIB_QUESTITEM = P.LIB_QUESTITEM; assert(LIB_QUESTITEM ~= nil,'LIB_QUESTITEM')
local print = P.print; assert(print ~= nil,'print')
local T_BLACKLIST = P.T_BLACKLIST; assert(T_BLACKLIST ~= nil,'T_BLACKLIST')
local T_CHECK = P.T_CHECK; assert(T_CHECK ~= nil,'T_CHECK')
local T_OPEN = P.T_OPEN; assert(T_OPEN ~= nil,'T_OPEN')
local T_RECIPES_FIND = P.T_RECIPES_FIND; assert(T_RECIPES_FIND ~= nil,'T_RECIPES_FIND')
local T_REPS = P.T_REPS; assert(T_REPS ~= nil,'T_REPS')
local T_SPELL_FIND = P.T_SPELL_FIND; assert(T_SPELL_FIND ~= nil,'T_SPELL_FIND')
local T_USE = P.T_USE; assert(T_USE ~= nil,'T_USE')
local VALIDATE = P.VALIDATE
local TIMER_IDLE = P.TIMER_IDLE; assert(TIMER_IDLE ~= nil,'TIMER_IDLE')
local LIB_WAGO_ANALYTICS = P.LIB_WAGO_ANALYTICS; assert(LIB_WAGO_ANALYTICS ~= nil,'LIB_WAGO_ANALYTICS')

function FastOpen:Verbose(...)
  if FastOpen.AceDB.profile.verbose then print(...) end
end
function FastOpen:OnInitialize()
  self:InitEvents()
  self:ProfileLoad()
  self:OptionsLoad()
end
function FastOpen:OnEnable()
  self.masque = LIB_MASQUE and LIB_MASQUE:Group(ADDON)
  LIB_QUESTITEM.RegisterCallback(self, "LibQuestItem_Update","QBUpdate")
end
function FastOpen:TooltipCreate(name)
  local frame
  if _G[name] and _G[name].SetOwner then
    frame = _G[name]
  else
    frame = CreateFrame("GameTooltip",name,nil,"GameTooltipTemplate")
  end
  frame:SetOwner(UIParent,"ANCHOR_NONE")
  return frame
end
function FastOpen:GetLinesFromTooltipData(tooltipData)
  if not tooltipData then return {} end
  local lines = {}
  for i, line in ipairs(tooltipData.lines) do
    lines[i] = line
  end
  return lines
end
function FastOpen:GetTooltipLinesByID(itemID)
  local tooltipData = C_TooltipInfo.GetItemByID(itemID)
  return FastOpen:GetLinesFromTooltipData(tooltipData)
end
function FastOpen:GetTooltipLinesByBagItem(bag, slot)
  local tooltipData = C_TooltipInfo.GetBagItem(bag, slot)
  return FastOpen:GetLinesFromTooltipData(tooltipData)
end
function FastOpen:GetTooltipLinesBySpellID(spellID)
  local tooltipData = C_TooltipInfo.GetSpellByID(spellID)
  return FastOpen:GetLinesFromTooltipData(tooltipData)
end
local tItemRetry = {}
function FastOpen:ItemLoad()
  local itemRetry = nil
  self:Profile(true)
  local nCB = tonumber(GetCVar(CB_CVAR))
  for itemID, data in pairs(FastOpen.T_RECIPES) do
    if not T_RECIPES_FIND[itemID] then
      local name = GetItemInfo(itemID)
      if type(name) ~= 'string' or name == '' then
        if VALIDATE then
          local retry = tItemRetry[itemID] or 0
          retry = retry + 1
          tItemRetry[itemID] = retry
          if retry > 1 then print("ItemLoad:GetItemInfo() empty for",itemID, retry) end
        end
        itemRetry = itemID
      else
        local c,pattern,zone,map,faction = unpack(data,1,5)
        if (c[2] == PRI_REP) and faction then T_REPS[name] = faction end
        local lines = FastOpen:GetTooltipLinesByID(itemID)
        local count = #lines
        if count > 1 then
          if type(pattern) == "number" then
            if count >= (pattern + nCB) then
              local i = pattern + ((pattern == 1) and 0 or nCB)
              local text = lines[i] and lines[i].leftText or "none"
              if text and (text ~= "none") and (text ~= "") and not string.find(text,'100') then
                T_RECIPES_FIND[itemID] = {c,text,zone,map,faction}
              else
                if VALIDATE then
                  local retry = tItemRetry[itemID] or 0
                  retry = retry + 1
                  tItemRetry[itemID] = retry
                  if retry > 1 then print("ItemLoad:SetItemByID()",itemID,"Line:",i,"Contains:",text,retry) end
                end
                itemRetry = itemID
              end
            else
              if VALIDATE then
                local retry = tItemRetry[itemID] or 0
                retry = retry + 1
                tItemRetry[itemID] = retry
                if retry > 1 then print("ItemLoad:SetItemByID()",itemID,"Have lines:",count,"Looking for:",pattern,"1st line:",lines[1] and lines[1].leftText,retry) end
              end
              itemRetry = itemID
            end
          elseif type(pattern) == "string" then
            local heading = lines[1] and lines[1].leftText
            if heading then
              local compare = gsub(heading,pattern,"%1")
              if compare and (compare ~= heading) and (compare ~= "") then
                T_RECIPES_FIND[itemID] = {c,compare,zone,map,faction}
              else
                if VALIDATE then
                  local retry = tItemRetry[itemID] or 0
                  retry = retry + 1
                  tItemRetry[itemID] = retry
                  if retry > 1 then print("ItemLoad:SetItemByID() 1st line",itemID,"Looking for:",pattern,"Have:",heading,retry) end
                end
                itemRetry = itemID
              end
            end
          end
        else
          if VALIDATE then
            local retry = tItemRetry[itemID] or 0
            retry = retry + 1
            tItemRetry[itemID] = retry
            if retry > 1 then print("ItemLoad() empty tooltip for",itemID,tItemRetry[itemID]) end
          end
          itemRetry = itemID
        end
      end
    end
  end
  self:Profile(false)
  if itemRetry then self:TimerFire("ItemLoad", P.TIMER_IDLE) end
  self.itemLoad = true
end
local spellLoaded = {}
local tSpellRetry = {}
local T_SPELL_BY_NAME = FastOpen.T_SPELL_BY_NAME; assert(T_SPELL_BY_NAME ~= nil,'T_SPELL_BY_NAME')
function FastOpen:SpellLoad()
  local spellRetry = nil
  self:Profile(true)
  for itemID,data in pairs(T_SPELL_BY_NAME) do
    if not spellLoaded[itemID] then
      local name = GetItemInfo(itemID)
      if type(name) ~= 'string' or name == '' then
        if VALIDATE then
          local retry = tSpellRetry[itemID] or 0
          retry = retry + 1
          tSpellRetry[itemID] = retry
          if retry > 1 then print("SpellLoad:GetItemInfo() empty for ",itemID,retry) end
        end
        spellRetry = itemID
      else 
        local spell = GetItemSpell(itemID)
        if type(spell) == 'string' and spell ~= "" then
          T_SPELL_FIND[spell] = data
          spellLoaded[itemID] = spell
        else
          if VALIDATE then print("GetItemSpell() no spell for",itemID, name, GetItemInfo(itemID)) end
          spellRetry = itemID
        end
      end
    else
      local spell = spellLoaded[itemID]
      T_SPELL_FIND[spell] = T_SPELL_BY_NAME[itemID]
    end
  end
  self:Profile(false)
  if spellRetry then self:TimerFire("SpellLoad", TIMER_IDLE) end
  self.spellLoad = true
end
function FastOpen:PickLockUpdate()
  if IsPlayerSpell(SPELL_PICKLOCK) then
    local lines = FastOpen:GetTooltipLinesBySpellID(SPELL_PICKLOCK)
    local count = #lines
    if count > 3 then
      local text = lines[4] and lines[4].leftText
      if text and text ~= "" then
        self.pickLockLevel = tonumber(string.match(text,"%d+"))
        if self.pickLockLevel then
          self.pickLockSpell = GetSpellInfo(SPELL_PICKLOCK)
        else
          print("Can't determine level of",GetSpellInfo(SPELL_PICKLOCK),"unexpected formating of tooltip!",text)
        end
      end
    else
      self:Verbose("Tooltip has less lines than expected, has", count, "instead more than 3.")
    end
  end
end
function FastOpen:PrintTooltip(tooltipLines)
  if not tooltipLines then return end
  for i=1,#tooltipLines do
    local line = tooltipLines[i]
    if tooltipLines[i].leftText then
      local r,g,b,a = tooltipLines[i].leftColor:GetRGBAAsBytes()
      local line = tooltipLines[i].leftText
      if line and line ~= "" then print(format("L %2d RGBA %3.3d %3.3d %3.3d %3.3d T %s",i,r,g,b,a, line)) end
    end
    if tooltipLines[i].rightText then
      local r,g,b,a = tooltipLines[i].rightColor:GetRGBAAsBytes()
      local line = tooltipLines[i].rightText
      if line and line ~= "" then print(format("R %2d RGBA %3.3d %3.3d %3.3d %3.3d T %s",i,r,g,b,a, line)) end
    end
  end
end
function FastOpen:BlacklistClear()
  if not FastOpen.AceDB.profile.Skip and T_BLACKLIST and T_BLACKLIST[0] then
    wipe(T_BLACKLIST)
    wipe(T_CHECK)
    return true
  end
end
function FastOpen:BlacklistReset()
  if (type(FastOpen.AceDB.profile.T_BLACKLIST) == "table") then
    wipe(FastOpen.AceDB.profile.T_BLACKLIST)
  else
    FastOpen.AceDB.profile.T_BLACKLIST = {} 
  end
  if (type(FastOpen.AceDB.profile.T_BLACKLIST_Q) == "table") then
    wipe(FastOpen.AceDB.profile.T_BLACKLIST_Q)
  else
    FastOpen.AceDB.profile.T_BLACKLIST_Q = {} 
  end
  wipe(T_CHECK)
  self:BAG_UPDATE()
end
function FastOpen:BlacklistItem(isPermanent,itemID)
  if itemID then
    local name = GetItemInfo(itemID)
    if isPermanent then
      if not (type(FastOpen.AceDB.profile.T_BLACKLIST) == "table") then FastOpen.AceDB.profile.T_BLACKLIST = {} end
      FastOpen.AceDB.profile.T_BLACKLIST[0] = true
      FastOpen.AceDB.profile.T_BLACKLIST[itemID] = true
      LIB_WAGO_ANALYTICS:IncrementCounter("SessionBlacklistItem")
      print(L["PERMA_BLACKLIST"],name or itemID)
    else
      if not (type(T_BLACKLIST) == "table") then T_BLACKLIST = {} end
      T_BLACKLIST[0] = true
      T_BLACKLIST[itemID] = true
      LIB_WAGO_ANALYTICS:IncrementCounter("PermanentBlacklistItem")
      if FastOpen.AceDB.profile.Skip then
        print(L["SESSION_BLACKLIST"],name or itemID)
      else
        print(L["TEMP_BLACKLIST"],name or itemID)
      end
    end
    T_USE[itemID] = nil; T_CHECK[itemID] = nil
  end
end
function FastOpen:Profile(onStart)
  if not self.profileOn then return end
  if not self.profileSession then self.profileSession = GetTime() end
  if onStart then
    self.profileCount = (self.profileCount or 0) + 1
    self.profileTP = debugprofilestop()
    return
  end
  local elapsed = (debugprofilestop() - self.profileTP)
  if self.profileMaxRun == nil or self.profileMaxRun < elapsed then self.profileMaxRun = elapsed end
  self.profileTotal = (self.profileTotal or 0) + elapsed
end
function FastOpen:inCombat()
  return InCombatLockdown()
end
function FastOpen:SecondsToString(s)
  local nH = math.floor(s/3600)
  local nM = math.floor(s/60 - nH*60)
  local nS = math.floor(s - nH*3600 - nM*60)
  if nH > 0  then return 30,string.format("%d",nH) .. ":" .. string.format("%02d",nM); end
  if nM > 0  then return  5,string.format("%d",nM) .. ":" .. string.format("%02d",nS); end
  if s > 9.9 then return  1,string.format("%.0f",s); end
  return 0.1, string.format("%.1f",s)
end
function FastOpen:removekey(t, key)
  if t and key and (type(t) == "table") and (t[key] ~= nil) then
    local element = t[key]
    t[key] = nil
    return element
  end
  return nil
end
local HERALD_ANNOUNCED = {}
function FastOpen:CheckBuilding(toCheck)
  if not FastOpen.AceDB.profile.herald then return end
  if toCheck then C_Garrison.RequestLandingPageShipmentInfo(); return; end
  if C_Garrison.HasGarrison(LE_GARRISON_TYPE_6_0) then
    local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)
    local numBuildings = #buildings
    if(numBuildings > 0) then
      for i = 1, numBuildings do
        local buildingID = buildings[i].buildingID;
        if buildingID and not HERALD_ANNOUNCED[buildingID] then
          local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfo(buildingID)
          if name and shipmentsReady and shipmentsTotal and (shipmentsReady / shipmentsTotal) > WORK_ANNOUNCE then
            self:PrintToActive((TOGO_ANNOUNCE):format(name,shipmentsReady,shipmentsTotal-shipmentsReady))
            HERALD_ANNOUNCED[buildingID] = true
          end
        end
      end
    end
  end
  if C_Garrison.HasGarrison(LE_GARRISON_TYPE_7_0) then
    local followerShipments = C_Garrison.GetFollowerShipments(LE_GARRISON_TYPE_7_0)
    if followerShipments then
      for i = 1, #followerShipments do
        if not HERALD_ANNOUNCED[followerShipments[i]] then
          local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipments[i])
          if name and shipmentsReady and shipmentsTotal and (shipmentsReady / shipmentsTotal) > WORK_ANNOUNCE then
            self:PrintToActive((TOGO_ANNOUNCE):format(name,shipmentsReady,shipmentsTotal-shipmentsReady))
            HERALD_ANNOUNCED[followerShipments[i]] = true
          end
        end
      end
    end
    local looseShipments = C_Garrison.GetLooseShipments(LE_GARRISON_TYPE_7_0)
    if looseShipments then
      for i = 1, #looseShipments do
        if not HERALD_ANNOUNCED[looseShipments[i]] then
          local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfoByContainerID(looseShipments[i])
          if name and shipmentsReady and shipmentsTotal and (shipmentsReady / shipmentsTotal) > WORK_ANNOUNCE then
            self:PrintToActive((TOGO_ANNOUNCE):format(name,shipmentsReady,shipmentsTotal-shipmentsReady))
            HERALD_ANNOUNCED[looseShipments[i]] = true
          end
        end
      end
    end
    local talentTrees = C_Garrison.GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_7_0, select(3, UnitClass("player")))
    if talentTrees then
      local completeTalentID = C_Garrison.GetCompleteTalent(LE_GARRISON_TYPE_7_0)
      if completeTalentID and not HERALD_ANNOUNCED[completeTalentID] then
        for treeIndex, treeID in ipairs(talentTrees) do
          local treeInfo = C_Garrison.GetTalentTreeInfo(treeID)
          for talentIndex, talent in ipairs(treeInfo.talents) do
            if (talent.id == completeTalentID) then
              self:PrintToActive((TALENT_ANNOUNCE):format(talent.name))
              HERALD_ANNOUNCED[completeTalentID] = true
            end
          end
        end
      end
      for treeIndex, treeID in ipairs(talentTrees) do
        local treeInfo = C_Garrison.GetTalentTreeInfo(treeID)
        for talentIndex, talent in ipairs(treeInfo.talents) do
          if talent.selected and not HERALD_ANNOUNCED[talent.perkSpellID] and FastOpen.T_INSTA_WQ[talent.perkSpellID] then
            local ability = GetSpellInfo(talent.perkSpellID)
            local _, duration = GetSpellCooldown(talent.perkSpellID)
            local count = GetItemCount(FastOpen.T_INSTA_WQ[talent.perkSpellID])
            local name = GetItemInfo(FastOpen.T_INSTA_WQ[talent.perkSpellID])
            if duration == 0 and name then
              local txt = " " .. RGB_RED .. ERR_SPELL_FAILED_REAGENTS_GENERIC .. " " .. RGB_YELLOW .. name
              self:PrintToActive((TALENT_ANNOUNCE):format(ability) .. ((count == 0) and txt or ""))
              HERALD_ANNOUNCED[talent.perkSpellID] = true
            end
          end
        end
      end
    end    
  end
  for i = 1, GetNumArchaeologyRaces() do
    local raceName, _, _, have, required = GetArchaeologyRaceInfo(i)
    if raceName and (required > 0) and (have >= required) and not HERALD_ANNOUNCED[raceName] then
      self:PrintToActive((ARCHAELOGY_ANNOUNCE):format(raceName))
      HERALD_ANNOUNCED[raceName] = true
    end
  end
  if not HERALD_ANNOUNCED["shipyard"] then
    local activeShips, maxShips = C_Garrison.GetNumFollowers(LE_FOLLOWER_TYPE_SHIPYARD_6_2), 0
    local _,_,_,_,_,shipyardRank = C_Garrison.GetOwnedBuildingInfo(98)
    if shipyardRank == 1 then 
      maxShips = 6
    elseif shipyardRank == 2 then
      maxShips = 8
    elseif shipyardRank == 3 then
      maxShips = 10 
    end
    if maxShips > 0 then
      if activeShips < maxShips then
        self:PrintToActive((SHIPYARD_ANNOUNCE):format(activeShips,maxShips))
        HERALD_ANNOUNCED["shipyard"] = true
      end
    end
  end
  ExpandAllFactionHeaders()
  local nF = GetNumFactions()
  local paragon = {}
  for i=1, nF do
    local name, _, _, _, _, value, _, _, header, _, _, _, _, id = GetFactionInfo(i)
    if name and not header and id then
      if C_Reputation.IsFactionParagon(id) then
        local reward = false
        local top
        value, top, _, reward = C_Reputation.GetFactionParagonInfo(id)
        while (value and top and (value > top)) do value = value - top end
        if reward and not HERALD_ANNOUNCED[id] then
          table.insert(paragon,name)
          HERALD_ANNOUNCED[id] = true
        end
      end
    end
  end
  if #paragon > 0 then self:PrintToActive((REWARD_ANNOUNCE):format(table.concat(paragon,PLAYER_LIST_DELIMITER))) end
end
function FastOpen:PrintToActive(msg)
  local ElvUI = _G.ElvUI
  if msg then
    local txt = ("|cff7f7f7f%s|r [|cff007f7f%s|r]" .. " %s"):format(ElvUI and "" or ("[" .. date("%H:%M") .. "]"),ADDON,msg)
    for i = 1, NUM_CHAT_WINDOWS do
      local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i)
      if shown and _G["ChatFrame"..i] then
        _G["ChatFrame"..i]:AddMessage(txt)
      end
    end
  end
end
function FastOpen:CompressText(text)
  text = string.gsub(text, "\n", "/n")
  text = string.gsub(text, "/n$", "")
  text = string.gsub(text, "||", "/124")
  return string.trim(text)
end
function FastOpen:GetReputation(name)
  local fID = T_REPS[name]; if not fID then return end
  local _, _, level, _, top, value = GetFactionInfoByID(fID)
  local reward
  if C_Reputation.IsFactionParagon(fID) then _, _, _, reward = C_Reputation.GetFactionParagonInfo(fID) end
  return level, top, value, reward
end
local T_timers = {}
function FastOpen:TimerFire(name,period,...)
  if not (type(period) == 'number' and period > 0) then whoCalls('Period must be a number greater than zero ' .. period); return; end
  if not (T_timers[name] and (self:TimeLeft(T_timers[name]) > 0)) then T_timers[name] = self:ScheduleTimer(name,period,...) end
end
function FastOpen:TimerCancel(name)
  local timer = T_timers[name]
  if (timer and (self:TimeLeft(timer) > 0)) then self:CancelTimer(timer) end
end
