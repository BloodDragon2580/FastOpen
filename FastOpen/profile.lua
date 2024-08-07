-- LUA variables in WTF
local _
-- global functions and variebles to locals to keep LINT happy
local assert = _G.assert
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local pairs = _G.pairs; assert(pairs ~= nil,'pairs')
local RegisterStateDriver = _G.RegisterStateDriver; assert(RegisterStateDriver ~= nil,'RegisterStateDriver')
local string = _G.string; assert(string ~= nil,'string')
local wipe = _G.wipe; assert(wipe ~= nil,'wipe')
-- local AddOn
local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)
--
local T_CHECK = P.T_CHECK; assert(T_CHECK ~= nil,'T_CHECK')
local T_USE = P.T_USE; assert(T_USE ~= nil,'T_USE')
--
function FastOpen:ProfileChanged() -- LUA stored variables changed
  self:ButtonLoad()
  self:QBUpdate()
  self:QBSkin()
  wipe(T_CHECK)
  wipe(T_USE)
  self:BAG_UPDATE()
end
function FastOpen:ProfileLoad() -- LUA stored variables load and init
  local defaults = {
    profile = {
      ["iconSize"] = P.DEFAULT_ICON_SIZE, -- default size
      ["lockButton"] = false, -- unlock
      ["skinButton"] = false, -- buttons are skinned
      ["masque"] = true, -- if Masque addon is loaded then hand skinning to addon
      ["button"] = {"CENTER", nil, "CENTER", 0, 0}, -- Item Button anchor and location
      ["qb"] = {"CENTER", nil, "CENTER", 0, 0}, -- Quest Bar location if not qb_sticky
      ["qb_sticky"] = true, -- Quest Bar is anchored to Item Button
      ["T_BLACKLIST"] = {}, -- Permanent blacklist for items button
      ["T_BLACKLIST_Q"] = {}, -- Permanent blacklist for quest items
      ["Skip"] = false,
      ["zoneUnlock"] = true,
      ["glowButton"] = true,
      ["backdrop"] = true,
      ["profession"] = true,
      ["verbose"] = false,
      ["cofeeStacks"] = 1,
      ["quest"] = false,
      ["visible"] = false,
      ["swap"] = false,
      ["autoquest"] = false,
      ["slots"] = 10,
      ["direction"] = "RIGHT",
      ["keyBind"] = "ALT-Q",
      ["expand"] = 1,
      ["spacing"] = 1,
      ["hiSTRATA"] = false,
      ["herald"] = true,
      ["SkipOnError"] = true,
      ["HideInCombat"] = false,
      ["ShowReputation"] = true,
      ["SkipExalted"] = false,
      ["SkipMaxPower"] = true,
    },
  }
  self.AceDB = LibStub("AceDB-3.0"):New("FastOpenProfile",defaults,true)
  self.AceDB.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
  self.AceDB.RegisterCallback(self, "OnProfileCopied",  "ProfileChanged")
  self.AceDB.RegisterCallback(self, "OnProfileReset",   "ProfileChanged")
  self.profileOn = self.AceDB.profile.profiling
end
function FastOpen:OptionsLoad() -- load options for UI config
  local FastOpeFastOpentions = {
    type = "group",
    args = {
      ver = {
        name = P.FastOpen_VERSION,
        type = "header",
        order = 0,
        width = "full",    
      },
      toggle = {
        order = 1,
        name = P.L["TOGGLE"],
        type = "group",
        args = {
          blacklist = {
            name = P.L["Clear Blacklist"],
            order = 1,
            desc = P.L["Reset Permanent blacklist."],
            type = "execute",
            width = "full",    
            func = function() FastOpen:BlacklistReset() end,
          },
          header1 = {
            type = "header",
            name = "",
            order = 2,
          },
          skin = {
            name = P.L["Skin Button"],
            order = 3,
            type = "toggle",
            -- width = "full",    
            set = function(info,val) FastOpen.AceDB.profile["skinButton"] = val; FastOpen:ButtonLoad(); FastOpen:QBSkin(); end,
            get = function(info) return FastOpen.AceDB.profile.skinButton end,
          },
          masque = {
            name = P.L["Masque Enable"],
            order = 4,
            desc = P.L["Need UI reload or relogin to activate."],
            type = "toggle",
            -- width = "full",    
            set = function(info,val) FastOpen.AceDB.profile["masque"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.masque end,
          },
          backdrop = {
            name = P.L["Backdrop Button"],
            order = 5,
            desc = P.L["Create or remove backdrop around button, need reload UI."],
            type = "toggle",
            -- width = "full",    
            set = function(info,val) FastOpen.AceDB.profile["backdrop"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.backdrop end,
          },
          lock = {
            name = P.L["Lock Button"],
            order = 6,
            desc = P.L["Lock button in place to disbale drag."],
            type = "toggle",
            -- width = "full",    
            set = function(info,val) FastOpen.AceDB.profile["lockButton"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.lockButton end,
          },
          glow = {
            name = P.L["Glow Button"],
            order = 7,
            desc = P.L["When item is placed by zone change, button will have glow effect."],
            type = "toggle",
            -- width = "full",    
            set = function(info,val) FastOpen.AceDB.profile["glowButton"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.glowButton end,
          },
          skip = {
            name = P.L["Session skip"],
            order = 8,
            desc = P.L["Skipping item last until relog."],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["Skip"] = val; if FastOpen:BlacklistClear() then FastOpen:BAG_UPDATE() end; end,
            get = function(info) return FastOpen.AceDB.profile.Skip end,
          },
          zoneUnlock = {
            name = P.L["Zone unlock"],
            order = 9,
            desc = P.L["Don't zone restrict openable items"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["zoneUnlock"] = val; FastOpen:BAG_UPDATE(); end,
            get = function(info) return FastOpen.AceDB.profile.zoneUnlock end,
          },
          profession = {
            name = P.L["Profession"],
            order = 10,
            desc = P.L["Place items usable by lockpicking"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["profession"] = val; FastOpen:BAG_UPDATE(); end,
            get = function(info) return FastOpen.AceDB.profile.profession end,
          },
          quest = {
            name = P.L["Quest bar"],
            order = 11,
            desc = P.L["Quest items placed on bar"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["quest"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.quest end,
          },
          visible = {
            name = P.L["Visible"],
            order = 12,
            desc = P.L["Make button visible by placing fake item on it"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["visible"] = val; FastOpen:BAG_UPDATE(); FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.visible end,
          },
          swap = {
            name = P.L["Swap"],
            order = 13,
            desc = P.L["Swap location of numbers for count and cooldown timer"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["swap"] = val; FastOpen:ButtonSwap(FastOpen.BF,FastOpen.AceDB.profile.swap) end,
            get = function(info) return FastOpen.AceDB.profile.swap end,
          },
          autoquest = {
            name = P.L["AutoQuest"],
            order = 14,
            desc = P.L["Auto accept or hand out quests from AutoQuestPopupTracker!"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["autoquest"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.autoquest end,
          },
          strata = {
            name = P.L["Strata"],
            order = 15,
            desc = P.L["Set strata for items button to HIGH, place it over normal windows."],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["strata"] = val; FastOpen.BF:SetFrameStrata(FastOpen.AceDB.profile.strata and "HIGH" or "MEDIUM")  end,
            get = function(info) return FastOpen.AceDB.profile.strata end,
          },
          herald = {
            name = P.L["Herald"],
            order = 16,
            desc = P.L["Announce completed work orders, artifact points etc.."],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["herald"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.herald end,
          },
          SkipOnError = {
            name = P.L["Skip on Error"],
            order = 17,
            desc = P.L["Temporary blacklist item when click produce error message"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["SkipOnError"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.SkipOnError end,
          },
          HideInCombat = {
            name = P.L["HIDE_IN_COMBAT"],
            order = 18,
            desc = P.L["HIDE_IN_COMBAT_HELP"],
            type = "toggle",
            -- width = "full",
            set = function(info,val)
              FastOpen.AceDB.profile["HideInCombat"] = val; 
              RegisterStateDriver(self.frameHiderB, "visibility", string.format( "[petbattle] [vehicleui] %shide; show", FastOpen.AceDB.profile.HideInCombat and "[combat] " or ""))
            end,
            get = function(info) return FastOpen.AceDB.profile.HideInCombat end,
          },
          ShowReputation = {
            name = P.L["SHOW_REPUTATION"],
            order = 19,
            desc = P.L["SHOW_REPUTATION_HELP"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["ShowReputation"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.ShowReputation end,
          },
          SkipExalted = {
            name = P.L["SKIP_EXALTED"],
            order = 20,
            desc = P.L["SKIP_EXALTED_HELP"],
            type = "toggle",
            -- width = "full",
            set = function(info,val) FastOpen.AceDB.profile["SkipExalted"] = val; wipe(T_CHECK); wipe(T_USE) end,
            get = function(info) return FastOpen.AceDB.profile.SkipExalted end,
          },
        },
      },
      pos = {
        name = P.L["Button"],
        type = "group",
        order = 2,
        args = {
          header1 = {
            name = P.L["Button location"],
            type = "header",
            order = 1,
          },
          GMFx = {
            name = "X",
            type = "range",
            -- width = "full",
            order = 2,
            min = -1000,
            max = 1000,
            step = 1,
            bigStep = 10,
            set = function(info,val) FastOpen.AceDB.profile.button[4] = val; FastOpen:ButtonMove(); end,
            get = function(info) return FastOpen.AceDB.profile.button[4] end,
          },
          GMFy = {
            name = "Y",
            type = "range",
            -- width = "full",
            order = 3,
            min = -500,
            max = 500,
            step = 1,
            bigStep = 10,
            set = function(info,val) FastOpen.AceDB.profile.button[5] = val; FastOpen:ButtonMove(); end,
            get = function(info) return FastOpen.AceDB.profile.button[5] end,
          },
          header2 = {
            name = P.L["Button size"],
            type = "header",
            order = 4,
          },
          iconSize = {
            name = P.L["Width and Height"],
            desc = P.L["Button size in pixels"],
            width = "full",
            type = "range",
            order = 5,
            min = 16,
            max = 64,
            step = 1,
            set = function(info,val) FastOpen.AceDB.profile["iconSize"] = val; FastOpen:ButtonSize(); FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.iconSize end,
          },
          header3 = {
            name = "",
            type = "header",
            order = 6,
          },
          cofeeStacks = {
            name = P.L["Miner's Coffee stacks"],
            desc = P.L["Allow buff up to this number of stacks"],
            type = "range",
            width = "full",
            order = 7,
            min = 1,
            max = 5,
            step = 1,
            set = function(info,val) FastOpen.AceDB.profile["cofeeStacks"] = val; end,
            get = function(info) return FastOpen.AceDB.profile.cofeeStacks end,
          },
        },
      },
      quest = {
        order = 3,
        name = P.L["Quest bar"],
        type = "group",
        args = {
          sticky = {
            order = 1,
            name = P.L["Sticky"],
            desc = P.L["Anchor to Item button"],
            type = "toggle",
            width = "full",
            set = function(info,val) FastOpen.AceDB.profile["qb_sticky"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.qb_sticky end,
          },
          slots = {
            name = P.L["Buttons per row"],
            desc = P.L["Number of buttons placed in one row"],
            type = "range",
            order = 2,
            min = 5,
            max = 20,
            step = 1,
            set = function(info,val) FastOpen.AceDB.profile["slots"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.slots end,
          },
          spacing = {
            name = P.L["Spacing"],
            desc = P.L["Space between buttons"],
            type = "range",
            order = 3,
            min = -10,
            max = 10,
            step = 1,
            set = function(info,val) FastOpen.AceDB.profile["spacing"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.spacing end,
          },
          header1 = {
            name = "",
            type = "header",
            order = 4,
          },
          direction = {
            name = P.L["Direction"],
            desc = P.L["Expand bar to"],
            order = 5,
            type = "select",
            values = { UP = P.L["Up"], DOWN = P.L["Down"], LEFT = P.L["Left"], RIGHT = P.L["Right"] },
            set = function(info,val) FastOpen.AceDB.profile["direction"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.direction end,
          },
          expand = {
            order = 6,
            type = "select",
            name = P.L["Add new row"],
            desc = P.L["Above or below last one"],
            values = { [1] = P.L["Up"], [-1] = P.L["Down"] },
            set = function(info,val) FastOpen.AceDB.profile["expand"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.expand end,
          },
          header2 = {
            name = "",
            type = "header",
            order = 7,
          },
          keyBind = {
            order = 8,
            name = P.L["Hot-Key"],
            desc = P.L["Key to use for automatic key binding."],
            type = "keybinding",
            width = "full",
            set = function(info,val) FastOpen.AceDB.profile["keyBind"] = val; FastOpen:QBUpdate(); end,
            get = function(info) return FastOpen.AceDB.profile.keyBind end,
          }
        },
      },
    },
  }
  FastOpeFastOpentions.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.AceDB)
  LibStub("AceConfig-3.0"):RegisterOptionsTable(P.FastOpen_TITLE, FastOpeFastOpentions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(P.FastOpen_TITLE,ADDON,nil)
end
