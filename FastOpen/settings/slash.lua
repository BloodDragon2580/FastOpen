-- Slash handler and key-binding header
local _
-- global functions and variebles to locals to keep LINT happy
local assert = _G.assert
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER; assert(BACKPACK_CONTAINER ~= nil,'BACKPACK_CONTAINER')
local format = _G.format; assert(format ~= nil,'format')
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage; assert(GetAddOnMemoryUsage ~= nil,'GetAddOnMemoryUsage')
local GetContainerItemID = _G.GetContainerItemID or C_Container.GetContainerItemID; assert(GetContainerItemID ~= nil,'GetContainerItemID')
local GetContainerItemLink = _G.GetContainerItemLink or C_Container.GetContainerItemLink; assert(GetContainerItemLink ~= nil,'GetContainerItemLink')
local GetContainerNumSlots = _G.GetContainerNumSlots or C_Container.GetContainerNumSlots; assert(GetContainerNumSlots ~= nil,'GetContainerNumSlots')
local GetItemInfo = _G.GetItemInfo or _G.C_Item.GetItemInfo; assert(GetItemInfo ~= nil,'GetItemInfo')
local GetSpellInfo = _G.GetSpellInfo or _G.C_Spell.GetSpellName; assert(GetSpellInfo ~= nil,'GetSpellInfo') -- intentionally use GetSpellName here, as that is what we use later
local GetTime = _G.GetTime; assert(GetTime ~= nil,'GetTime')
local issecurevariable = _G.issecurevariable; assert(issecurevariable ~= nil,'issecurevariable')
local math = _G.math; assert(math ~= nil,'math')
local NUM_TOTAL_EQUIPPED_BAG_SLOTS = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS; assert(NUM_TOTAL_EQUIPPED_BAG_SLOTS ~= nil,'NUM_TOTAL_EQUIPPED_BAG_SLOTS')
local pairs = _G.pairs; assert(pairs ~= nil,'pairs')
local string = _G.string; assert(string ~= nil,'string')
local tonumber = _G.tonumber; assert(tonumber ~= nil,'tonumber')
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage; assert(UpdateAddOnMemoryUsage ~= nil,'UpdateAddOnMemoryUsage')
-- local AddOn
local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)
--
local T_CHECK = P.T_CHECK; assert(T_CHECK ~= nil,'T_CHECK')
local print = P.print; assert(print ~= nil,'print')
local PRI_OPEN = P.PRI_OPEN; assert(PRI_OPEN ~= nil,'PRI_OPEN')

--
FastOpen.slash_handler = function(msg, editbox) -- /FastOpen handler
  local line = msg:lower()
  local cmd, arg = string.split(" ,",line)
  if cmd == "bdump" then
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
      for slot = 1, GetContainerNumSlots(bag), 1 do
        local link = GetContainerItemLink(bag, slot)
        if link then
          local _, _, itemType, itemID = string.find(link, "|?c[^|]*|?H?([^:]*):?(%d+):")
          print("Bag",bag,"Slot",slot,"Link",itemType or "unknow type",itemID or "unknown ID")
        end
      end
    end
    return
  end
  if cmd == "verbose" then
    FastOpen.AceDB.profile.verbose = not FastOpen.AceDB.profile.verbose
    print("Verbose mode", FastOpen.AceDB.profile.verbose and "on" or "off")
    return
  end
  if cmd == "titem" then
    local id = tonumber(arg)
    if id then
      for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
        for slot = 1, GetContainerNumSlots(bag), 1 do
          local itemID = GetContainerItemID(bag,slot)
          if itemID and itemID == id then -- when I own item just check true tooltip over bags
            print("Tooltip based on item in bag",bag,"slot",slot)
            FastOpen:PrintTooltip(FastOpen:GetTooltipLinesByBagItem(bag, slot))
            return
          end
        end
      end
      local name = GetItemInfo(id)
      if not name then
        print("Item ID",id,"is not in cache yet! Try same ID later")
        return
      end
      print("Tooltip based only on ID")
      FastOpen:PrintTooltip(FastOpen:GetTooltipLinesByID(id))
    end
    return
  end
  if cmd == "tspell" then
    local id = tonumber(arg)
    if id then
      local name = GetSpellInfo(id)
      if not name then
        print("Spell ID",id,"is not in cache yet! Try same ID later")
        return
      end
      FastOpen:PrintTooltip(FastOpen:GetTooltipLinesBySpellID(spellID))
    end
    return
  end
  if cmd == "profile" then
    if FastOpen.profileSession and FastOpen.profileCount and FastOpen.profileTotal and FastOpen.profileMaxRun and FastOpen.profileCount > 0 then
      local Elapsed = GetTime() - FastOpen.profileSession
      local textTime = (" %dh %02dm %02ds "):format(Elapsed / 3600, math.fmod(Elapsed / 60, 60), math.fmod(Elapsed, 60))
      print(format("%s session time %d [calls] spend %.2f [ms/call] max run %.2f [ms]", textTime, FastOpen.profileCount, FastOpen.profileTotal / FastOpen.profileCount, FastOpen.profileMaxRun))
    end
    UpdateAddOnMemoryUsage()
    print(format("Memory usage %.2f kB",GetAddOnMemoryUsage(ADDON)))
    if FastOpen.BF then
      local secure,addon = issecurevariable(FastOpen.BF,"Hide")
      if not secure then print("Tainted button Hide() by:",addon) end
      secure,addon = issecurevariable(FastOpen.BF,"Show")
      if not secure then print("Tainted button Show() by:",addon) end
      secure,addon = issecurevariable(FastOpen.BF,"SetAttribute")
      if not secure then print("Tainted button SetAttribute() by:",addon) end
    end
    if FastOpen.profileOn then -- toggle profiling
      FastOpen.profileOn = nil
      FastOpen.profileSession = nil
      FastOpen.profileCount = nil 
      FastOpen.profileTotal = nil
      print("Profiling OFF")
    else
      FastOpen.profileOn = true
      FastOpen.profileSession = nil
      FastOpen.profileCount = nil 
      FastOpen.profileTotal = nil
      print("Profiling ON")
    end
    FastOpen.AceDB.profile["profiling"] = FastOpen.profileOn
    return
  end
  if cmd == "reset" then
    if FastOpen.BF and not FastOpen:inCombat() then
      FastOpen:ButtonReset()
    end
    return
  end
  if cmd == "skin" then
    FastOpen.AceDB.profile["skinButton"] = (not FastOpen.AceDB.profile.skinButton)
    FastOpen:ButtonLoad()
    FastOpen:QBSkin()
    return
  end
  if cmd == "quest" then
    FastOpen.AceDB.profile["quest"] = not FastOpen.AceDB.profile.quest
    FastOpen:QBUpdate()
    return
  end
  if cmd == "show" then
    FastOpen.AceDB.profile["visible"] = not FastOpen.AceDB.profile.visible
    FastOpen:BAG_UPDATE()
    FastOpen:QBUpdate()
    return
  end
  if cmd == "lock" then
    FastOpen.AceDB.profile["lockButton"] = (not FastOpen.AceDB.profile.lockButton)
    return
  end
  if cmd == "glow" then
    FastOpen.AceDB.profile["glowButton"] = (not FastOpen.AceDB.profile.glowButton)
    return
  end
  if cmd == "skip" then
    FastOpen.AceDB.profile["Skip"] = (not FastOpen.AceDB.profile.Skip)
    if FastOpen:BlacklistClear() then FastOpen:BAG_UPDATE() end
    return
  end
  if cmd == "clear" then
    FastOpen:BlacklistReset()
    return
  end
  if cmd == "list" then
    if (FastOpen.AceDB.profile["T_BLACKLIST"] ~= nil and FastOpen.AceDB.profile.T_BLACKLIST[0]) or (FastOpen.AceDB.profile["T_BLACKLIST_Q"] ~= nil and FastOpen.AceDB.profile.T_BLACKLIST_Q[0])then
      print(P.L["BLACKLISTED_ITEMS"])
      print("--Button--")
      for itemID,count in pairs(FastOpen.AceDB.profile.T_BLACKLIST) do
        if itemID and itemID > 0 then
          local name = GetItemInfo(itemID)
          if not name then
            print("ItemID:",itemID,"Not in cache, try later same command to see name.")
          else
            print("ItemID:",itemID,"Name:",name)
          end
        end
      end
      print("--Quest--")
      for itemID,count in pairs(FastOpen.AceDB.profile.T_BLACKLIST_Q) do
        if itemID and itemID > 0 then
          local name = GetItemInfo(itemID)
          if not name then
            print("ItemID:",itemID,"Not in cache, try later same command to see name.")
          else
            print("ItemID:",itemID,"Name:",name)
          end
        end
      end
    else
      print(P.L["BLACKLIST_EMPTY"])
    end
    return
  end
  if cmd == "unlist" then
    local id = tonumber(arg)
    if id then
      if FastOpen.AceDB.profile["T_BLACKLIST"] ~= nil and FastOpen.AceDB.profile.T_BLACKLIST[id] then FastOpen.AceDB.profile.T_BLACKLIST[id] = nil; T_CHECK[id] = nil; FastOpen:BAG_UPDATE() end
      if FastOpen.AceDB.profile["T_BLACKLIST_Q"] ~= nil and FastOpen.AceDB.profile.T_BLACKLIST_Q[id] then FastOpen.AceDB.profile.T_BLACKLIST_Q[id] = nil; FastOpen:QBUpdate() end
    end
    return
  end
  if cmd == "zone" then
    FastOpen.AceDB.profile["zoneUnlock"] = not FastOpen.AceDB.profile.zoneUnlock
    FastOpen:BAG_UPDATE()
    return
  end
  if cmd == "add" then
    local id = tonumber(arg)
    local printed = false
    if id then
      if FastOpen.AceDB.profile["T_TRACKLIST"] ~= nil then FastOpen.AceDB.profile.T_TRACKLIST[id] = {{1,PRI_OPEN},nil,nil}; FastOpen:BAG_UPDATE() end
      print("Item ID",id,"added to the tracking list.")
    end
    return
  end
  local usage = {string.split("\n", P.L["FastOpen_USE"] .. P.CONSOLE_CMD .. P.CONSOLE_USAGE)}
  for _,line in pairs(usage) do 
    print(line)
  end
end
_G.SLASH_FastOpen_SWITCH1 = P.CONSOLE_CMD
_G.SlashCmdList["FastOpen_SWITCH"] = FastOpen.slash_handler
_G.BINDING_HEADER_FastOpen = ADDON -- add category to bindings to be able bind button to hotkey in default Blizzard interface
_G["BINDING_NAME_CLICK " .. P.BUTTON_FRAME .. ":LeftButton"] = _G.USABLE_ITEMS
