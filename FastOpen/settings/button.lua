local _
local assert = _G.assert
local BROWSE_NO_RESULTS = _G.BROWSE_NO_RESULTS; assert(BROWSE_NO_RESULTS ~= nil,'BROWSE_NO_RESULTS')
local CreateFrame = _G.CreateFrame; assert(CreateFrame ~= nil,'CreateFrame')
local GameTooltip = _G.GameTooltip; assert(GameTooltip ~= nil,'GameTooltip')
local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor; assert(GameTooltip_SetDefaultAnchor ~= nil,'GameTooltip_SetDefaultAnchor')
local GetCVar = _G.GetCVar; assert(GetCVar ~= nil,'GetCVar')
local GetItemCooldown = _G.GetItemCooldown or _G.C_Item.GetItemCooldown; assert(GetItemCooldown ~= nil,'GetItemCooldown')
local GetItemInfo = _G.GetItemInfo or _G.C_Item.GetItemInfo; assert(GetItemInfo ~= nil,'GetItemInfo')
local GetScreenWidth = _G.GetScreenWidth; assert(GetScreenWidth ~= nil,'GetScreenWidth')
local GetTime = _G.GetTime; assert(GetTime ~= nil,'GetTime')
local IsAltKeyDown = _G.IsAltKeyDown; assert(IsAltKeyDown ~= nil,'IsAltKeyDown')
local IsControlKeyDown = _G.IsControlKeyDown; assert(IsControlKeyDown ~= nil,'IsControlKeyDown')
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local math = _G.math; assert(math ~= nil,'math')
local string = _G.string; assert(string ~= nil,'string')
local STRING_SCHOOL_UNKNOWN = _G.STRING_SCHOOL_UNKNOWN; assert(STRING_SCHOOL_UNKNOWN ~= nil,'STRING_SCHOOL_UNKNOWN')
local tinsert = _G.tinsert; assert(tinsert ~= nil,'tinsert')
local tremove = _G.tremove; assert(tremove ~= nil,'tremove')
local type = _G.type; assert(type ~= nil,'type')
local UIParent = _G.UIParent; assert(UIParent ~= nil,'UIParent')
local unpack = _G.unpack; assert(unpack ~= nil,'unpack')
local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)
local BUTTON_FRAME = P.BUTTON_FRAME; assert(BUTTON_FRAME ~= nil,'BUTTON_FRAME')
local CLICK_BLACKLIST_MSG = P.CLICK_BLACKLIST_MSG; assert(CLICK_BLACKLIST_MSG ~= nil,'CLICK_BLACKLIST_MSG')
local CLICK_DRAG_MSG = P.CLICK_DRAG_MSG; assert(CLICK_DRAG_MSG ~= nil,'CLICK_DRAG_MSG')
local CLICK_OPEN_MSG = P.CLICK_OPEN_MSG; assert(CLICK_OPEN_MSG ~= nil,'CLICK_OPEN_MSG')
local CLICK_SKIP_MSG = P.CLICK_SKIP_MSG; assert(CLICK_SKIP_MSG ~= nil,'CLICK_SKIP_MSG')
local DEFAULT_ICON = P.DEFAULT_ICON; assert(DEFAULT_ICON ~= nil,'DEFAULT_ICON')
local DEFAULT_ICON_SIZE = P.DEFAULT_ICON_SIZE; assert(DEFAULT_ICON_SIZE ~= nil,'DEFAULT_ICON_SIZE')
local L = P.L
local MACRO_INACTIVE = P.MACRO_INACTIVE; assert(MACRO_INACTIVE ~= nil,'MACRO_INACTIVE')
local MOUSE_LB = P.MOUSE_LB; assert(MOUSE_LB ~= nil,'MOUSE_LB')
local MOUSE_RB = P.MOUSE_RB; assert(MOUSE_RB ~= nil,'MOUSE_RB')
local TIMER_IDLE = P.TIMER_IDLE; assert(TIMER_IDLE ~= nil,'TIMER_IDLE')
local print = P.print; assert(print ~= nil,'print')
local function SetOutside(obj, anchor, xOffset, yOffset)
  xOffset = xOffset or 1
  yOffset = yOffset or 1
  anchor = anchor or obj:GetParent()
  if obj:GetPoint() then
    obj:ClearAllPoints()
  end
  obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
  obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end
local function SetInside(obj, anchor, xOffset, yOffset)
  xOffset = xOffset or 1
  yOffset = yOffset or 1
  anchor = anchor or obj:GetParent()
  if obj:GetPoint() then
    obj:ClearAllPoints()
  end
  obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
  obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end
function FastOpen:ButtonSkin(button,skin)
  if not button then return end
  if self.masque and FastOpen.AceDB.profile.masque then
    if button.isSkinned == nil then self.masque:AddButton(button); self.masque:ReSkin() end
    button.isSkinned = true
    return
  end
  if skin then
    if button.isSkinned then return end
    local ht = button:CreateTexture(nil,"OVERLAY")
    if ht.SetTexture then ht:SetColorTexture(0.3, 0.3, 0.3, 0.5) end
    if ht.SetInside then ht:SetInside() else SetInside(ht) end
    button.ht = ht
    if button.SetHighlightTexture then button:SetHighlightTexture(ht) end
    local pt = button:CreateTexture(nil,"OVERLAY")
    if pt.SetTexture then pt:SetColorTexture(0, 0, 0, 0) end
    if pt.SetInside then pt:SetInside() else SetInside(pt) end
    button.pt = pt
    button:SetPushedTexture(pt)
    if button.cooldown then
      if button.cooldown.SetDrawEdge then button.cooldown:SetDrawEdge(false) end
      if button.cooldown.SetDrawBling then button.cooldown:SetDrawBling(false) end
      if button.cooldown.SetDrawSwipe then button.cooldown:SetDrawSwipe(false) end
      if button.cooldown.SetSwipeColor then button.cooldown:SetSwipeColor(0, 0, 0, 0) end
    end
    if not _G.WWM then button.icon:SetTexCoord(0.08,0.92,0.08,0.92) end
    if button.icon.SetInside then button.icon:SetInside() else SetInside(button.icon) end
    button.normal:SetTexture(nil)
    button.normal:Hide()
    button.normal:SetAlpha(0)
    button.hotkey:ClearAllPoints()
    button.hotkey:SetPoint("TOPRIGHT", 1, -2)
    button.isSkinned = true
  else
    if (button.isSkinned == nil) then return end
    if button.b_icon then button.icon:SetTexCoord(unpack(button.b_icon)) end
    if button.b_texture then button.normal:SetTexture(button.b_texture) end
    if button.b_alpha then button.normal:SetAlpha(button.b_alpha) end
    button.normal:Show()
    button.count:ClearAllPoints()
    if button.b_count then button.count:SetPoint(unpack(button.b_count)) end
    button.hotkey:ClearAllPoints()
    if button.b_hotkey then button.hotkey:SetPoint(unpack(button.b_hotkey)) end
    if button.b_htexture then button:SetHighlightTexture(button.b_htexture) end
    if button.b_ptexture then button:SetPushedTexture(button.b_ptexture) end
    if button.cooldown and button.cooldown.SetDrawEdge then 
      if button.b_draw then 
        button.cooldown:SetDrawEdge(button.b_draw)
        button.cooldown:SetDrawBling(button.b_draw)
        button.cooldown:SetDrawSwipe(button.b_draw)
      end
      button.cooldown:SetSwipeColor(0.1, 0.1, 0.1, .8)
    end
    button.isSkinned = nil
  end
end
function FastOpen:ButtonReputation(tooltip,func)
  if not (tooltip and tooltip.GetItem) then return end
  local OHC = _G.OHC
  local OrderHallMissionFrame = _G.OrderHallMissionFrame
  if (func == "SetItemByID") and (OHC ~= nil) and OrderHallMissionFrame and OrderHallMissionFrame:IsVisible() then return end
  local name = tooltip:GetItem(); if not name then return end
  local level, top, value, reward = self:GetReputation(name); if not level then return end
  if level < 8 then
    tooltip:AddLine(_G['FACTION_STANDING_LABEL' .. level] .. (" |cffca3c3c%.2f%%|r"):format((value/top) * 100.0))
  else
    tooltip:AddLine(_G['FACTION_STANDING_LABEL' .. level] .. (reward and "+" or ''))
  end
  tooltip:Show()
end
function FastOpen:ButtonOnEnter(button)
  if self:inCombat() then return; end
  if not _G.ElvUI then
    if GetCVar("UberTooltips") == "1" then
      GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    else
      GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    end
  else
    local gto = GameTooltip:GetOwner()
    if not gto then GameTooltip_SetDefaultAnchor(GameTooltip, UIParent) end
  end
  if button.bagID ~= nil and button.slotID ~= nil then
    GameTooltip:SetBagItem(button.bagID,button.slotID)
    if GameTooltip:NumLines() < 1 then
      local name = GetItemInfo(button.itemID)
      GameTooltip:SetText("|cFFFF00FF" .. (name or STRING_SCHOOL_UNKNOWN) .. "|r")
    end
  else
    GameTooltip:SetText(BROWSE_NO_RESULTS)
  end
  if button.itemTexture then
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(MOUSE_LB .. CLICK_OPEN_MSG,0,1,0)
    GameTooltip:AddLine(MOUSE_RB .. CLICK_SKIP_MSG,0,1,0)
    GameTooltip:AddLine(MOUSE_RB .. CLICK_BLACKLIST_MSG)
  end
  if not FastOpen.AceDB.profile.lockButton then 
    GameTooltip:AddLine(MOUSE_LB .. CLICK_DRAG_MSG)
  end
  GameTooltip:SetClampedToScreen(true)
  GameTooltip:Show()
end
function FastOpen:ButtonOnLeave(button)
  if self:inCombat() then return; end
  GameTooltip:Hide()
end
function FastOpen:ButtonPostClick(button)
  if button then
    self.BF.clickON = nil
    if (button == 'RightButton') then
      self:BlacklistItem(IsControlKeyDown(),self.BF.itemID)
      self.BF.itemID = nil
    end
    self:TimerFire("ItemShowNew", TIMER_IDLE / 3)
  end
end
function FastOpen:ButtonPreClick(bt, button)
  if button then
    if (button == 'RightButton') then
      bt:SetAttribute("type", nil)
      bt:SetAttribute("spell", nil)
      bt:SetAttribute("target-item", nil)
      bt:SetAttribute("item", nil)
    end
  end
end
function FastOpen:ButtonOnDragStart(button)
  if FastOpen.AceDB.profile.lockButton or self:inCombat() then return end
  if IsAltKeyDown() then button:StartMoving() end
end
function FastOpen:ButtonOnDragStop(button)
  button:StopMovingOrSizing()
  self:ButtonSave()
  self:QBAnchorSave()
end
function FastOpen:ButtonReset()
  if self:inCombat() then self:TimerFire("ButtonReset", TIMER_IDLE); return end
  self.AceDB.profile.iconSize = DEFAULT_ICON_SIZE
  self.AceDB.profile.lockButton = false
  self.AceDB.profile.button = {"CENTER", nil, "CENTER", 0, 0}
  self:ButtonSize()
  self:ButtonMove()
  self:QBUpdate()
  print(L["BUTTON_RESET"])
end
function FastOpen:ButtonSize()
  if self:inCombat() then self:TimerFire("ButtonSize", TIMER_IDLE); return end
  self.timerButtonSize = nil
  if not self.BF then return end
  local iconSize = FastOpen.AceDB.profile.iconSize or DEFAULT_ICON_SIZE
  if not (GetScreenWidth() > 1500) then iconSize = math.floor(iconSize * 0.75) end
  self.BF:SetWidth(iconSize)
  self.BF:SetHeight(iconSize)
  if FastOpen.AceDB.profile.qb_sticky then self:QBAnchorSize(); self:QBUpdate(); end
end
function FastOpen:ButtonSave()
  if not self.BF then return end
  local point, relativeTo, relativePoint, xOfs, yOfs = self.BF:GetPoint()
  FastOpen.AceDB.profile.button = {point or "CENTER", relativeTo and relativeTo.GetName and relativeTo:GetName() or "UIParent", relativePoint or "CENTER", xOfs, yOfs}
end
function FastOpen:ButtonMove()
  if self:inCombat() then self:TimerFire("ButtonMove", TIMER_IDLE); return end
  self.BF:SetClampedToScreen(true)
  self.BF:ClearAllPoints()
  local frame = FastOpen.AceDB.profile.button[2] or "none"
  if _G[frame] then frame = _G[frame] else frame = nil end
  if not frame then
    if FastOpen.AceDB.profile.HideInCombat then frame = self.frameHiderB else frame = UIParent end
  end
  if not FastOpen.AceDB.profile.HideInCombat and frame == self.frameHiderB then frame = UIParent end
  self.BF:SetPoint(FastOpen.AceDB.profile.button[1] or "CENTER", frame, FastOpen.AceDB.profile.button[3] or "CENTER", FastOpen.AceDB.profile.button[4] or 0, FastOpen.AceDB.profile.button[5] or 0)
  self:ButtonSave()
end
function FastOpen:ButtonStore(button)
  local name = button and button:GetName()
  if not name then return end
  button.icon   = _G[name .. "Icon"]
  button.hotkey = _G[name .. "HotKey"]
  button.count  = _G[name .. "Count"]
  button.normal = _G[name .. "NormalTexture"]
  if self.masque == nil then
    button.b_icon     = {button.icon:GetTexCoord()}
    button.b_texture  = button.normal:GetTexture()
    button.b_alpha    = button.normal:GetAlpha()
    button.b_count    = {button.count:GetPoint()}
    button.b_hotkey   = {button.hotkey:GetPoint()}
    button.b_htexture = button.GetHighlightTexture and button:GetHighlightTexture() or nil
    button.b_ptexture = button.GetPushedTexture and button:GetPushedTexture() or nil
    button.b_draw     = button.cooldown and button.cooldown.GetDrawEdge and button.cooldown:GetDrawEdge() or false
  end
end
function FastOpen:ButtonBackdrop(bt)
  if not FastOpen.AceDB.profile.backdrop then return end
  if self.masque and FastOpen.AceDB.profile.masque then return end
  local btex = bt:CreateTexture(nil, "BACKGROUND")
  btex:SetColorTexture(0, 0, 0, 1)
  btex:SetDrawLayer("BACKGROUND", -1)
  if btex.SetOutside then btex:SetOutside(bt) else SetOutside(btex,bt) end
  bt.backdropTexture = btex
end
function FastOpen:ButtonLoad()
  if self:inCombat() then self:TimerFire("ButtonLoad", TIMER_IDLE); return end
  if not self.BF then
    self.BF = CreateFrame("Button", BUTTON_FRAME, self.frameHiderB, "ActionButtonTemplate,SecureActionButtonTemplate")
    local bt = self.BF
    if bt:IsVisible() or bt:IsShown() then bt:Hide() end
    bt:SetFrameStrata(FastOpen.AceDB.profile.strata and "HIGH" or "MEDIUM")
    self:ButtonBackdrop(bt)
    bt:RegisterForDrag("LeftButton")
    bt:RegisterForClicks("AnyUp", "AnyDown")
    bt:SetScript("OnEnter",     function(self) FastOpen:ButtonOnEnter(self) end)
    bt:SetScript("OnLeave",     function(self) FastOpen:ButtonOnLeave(self) end)
    bt:SetScript("PreClick",    function(self,button) FastOpen:ButtonPreClick(self, button) FastOpen.preClick = true end)
    bt:SetScript("PostClick",   function(self,button) FastOpen:ButtonPostClick(button) end)
    bt:SetScript("OnDragStart", function(self) FastOpen:ButtonOnDragStart(self) end)
    bt:SetScript("OnDragStop",  function(self) FastOpen:ButtonOnDragStop(self) end)
    bt.icon:SetTexture(DEFAULT_ICON)
    self:ButtonStore(bt)
    bt.timer = bt:CreateFontString(nil,"OVERLAY","GameFontWhite")
    local timer = bt.timer
    local font, size = bt.count:GetFont()
    timer:SetFont(font,size-2,"OUTLINE")
    bt:EnableMouse(true)
    bt:SetMovable(true)
  end
  self:ButtonSize()
  self:ButtonMove()
  self:ButtonSkin(self.BF, FastOpen.AceDB.profile.skinButton)
  self:ButtonSwap(self.BF, FastOpen.AceDB.profile.swap)
end
function FastOpen:ButtonSwap(bt,swap)
  if not bt then return end
  if not bt.timer then return end
  if not bt.count then return end
  if swap then
    bt.count:ClearAllPoints()
    bt.count:SetPoint('BOTTOMLEFT',bt,'BOTTOMLEFT', 1, -1)
    bt.count:SetJustifyH("LEFT")
    bt.count:SetJustifyV("MIDDLE")
    bt.timer:ClearAllPoints()
    bt.timer:SetPoint("BOTTOMRIGHT",bt,"BOTTOMRIGHT", 1, -1)
    bt.timer:SetJustifyH("RIGHT")
    bt.timer:SetJustifyV("MIDDLE")
  else
    bt.count:ClearAllPoints()
    bt.count:SetPoint("BOTTOMRIGHT",bt,"BOTTOMRIGHT", 1, -1)
    bt.count:SetJustifyH("RIGHT")
    bt.count:SetJustifyV("MIDDLE")
    bt.timer:ClearAllPoints()
    bt.timer:SetPoint('BOTTOMLEFT',bt,'BOTTOMLEFT', 1, -1)
    bt.timer:SetJustifyH("LEFT")
    bt.timer:SetJustifyV("MIDDLE")
  end
end
function FastOpen:ButtonCount(count)
  if self.BF and self.BF.count then
    self.BF.count:SetText((type(count) == "number") and (count > 1) and count or "")
  end
end
function FastOpen:ButtonShow()
  if self:inCombat() then self:TimerFire("ButtonShow", TIMER_IDLE); return end
  local bt = self.BF
  self:ButtonCount(bt.itemCount)
  bt.icon:SetTexture(bt.itemTexture or DEFAULT_ICON)
  if (bt:IsMouseMotionFocus()) then self:ButtonOnEnter(bt) end

  bt:SetAttribute("type1", nil)
  bt:SetAttribute("macrotext1", nil)
  bt:SetAttribute("type", nil)
  bt:SetAttribute("spell", nil)
  bt:SetAttribute("target-item", nil)
  bt:SetAttribute("item", nil)
  bt:SetAttribute("target-bag", nil)
  bt:SetAttribute("target-slot", nil)

  if bt.itemTexture then
    if bt.mtext then
      bt:SetAttribute("type1", "macro")
      bt:SetAttribute("macrotext1", bt.mtext)
      self:Verbose("ButtonShow:","macro text",self:CompressText(bt.mtext))
    else
      bt:SetAttribute("type", bt.mtype)
      bt:SetAttribute("spell", bt.mspell)
      bt:SetAttribute("item", bt.mtarget)
      bt:SetAttribute("target-item", bt.mtargetitem)
      if bt.mspell then
        bt:SetAttribute("target-bag", bt.bagID)
        bt:SetAttribute("target-slot", bt.slotID)
      end
      self:Verbose("ButtonShow:",self:CompressText(bt.mtype),bt.mspell and self:CompressText(bt.mspell),bt.mtarget and self:CompressText("item: " .. bt.mtarget),bt.mtargetitem and self:CompressText("target-item: " .. bt.mtargetitem))
    end
  end
  if not (bt:IsVisible() or bt:IsShown()) then bt:Show() end
  if FastOpen.AceDB.profile.glowButton and bt.isGlow then
    self.ActionButton_ShowOverlayGlow(bt)
  else
    self.ActionButton_HideOverlayGlow(bt)
  end
  self.BF.clickON = true
end
function FastOpen:ButtonHide()
  if self:inCombat() then self:TimerFire("ButtonHide", TIMER_IDLE); return end
  local bt = self.BF
  bt.itemCount = 0
  bt.bagID = nil
  bt.itemID = nil
  bt.isGlow = nil
  bt.mtext = MACRO_INACTIVE
  bt.itemTexture = nil
  bt.icon:SetTexture(DEFAULT_ICON)
  bt:SetAttribute("type", nil)
  bt:SetAttribute("spell", nil)
  bt:SetAttribute("target-item", nil)
  bt:SetAttribute("item", nil)
  self:ButtonCount(bt.itemCount)
  self.ActionButton_HideOverlayGlow(bt)
  if FastOpen.AceDB.profile.visible then
    if not (bt:IsShown() or bt:IsVisible()) then bt:Show() end
  else
    if bt:IsShown() or bt:IsVisible() then bt:Hide() end
  end
end
function FastOpen:ButtonHotKey(key)
  if key and (string.len(key) > 0) then
    key = key:gsub('ALT%-', 'A')
    key = key:gsub('CTRL%-', 'C')
    key = key:gsub('SHIFT%-', 'S')
    key = key:gsub('BUTTON', 'M')
		key = key:gsub('MOUSEWHEELUP', 'MWUp');
		key = key:gsub('MOUSEWHEELDOWN', 'MWDn');
		key = key:gsub('NUMPAD', 'Np');
		key = key:gsub('PAGEUP', 'PgUp');
		key = key:gsub('PAGEDOWN', 'PgDn');
		key = key:gsub('INSERT', 'Ins');
		key = key:gsub('HOME', 'Hm');
		key = key:gsub('DELETE', 'Del');
		key = key:gsub('NMULTIPLY', "Np*");
		key = key:gsub('NMINUS', "Np-");
		key = key:gsub('NPLUS', "Np+");
		key = key:gsub('NEQUALS', "Np="); 
  else
    key = ""
  end
  return key
end
function FastOpen:ButtonOnUpdate(bt,start,duration)
  if not bt.timer then return end
  if (start > 0) and (duration > 0) then
    local expire = start + duration
    if bt.expire == nil or bt.expire < expire then
      bt.expire = expire
      bt:SetScript("OnUpdate",nil)
      bt:SetScript("OnUpdate", function(self,elapsed)
        if not self.update then self.update = 0 end
        self.update = self.update - elapsed
        if (self.update < 0) then
          if self.itemID and self:IsShown() then
            local start, duration, enable = GetItemCooldown(self.itemID)
            local cd = 0
            if (start > 0) and (duration > 0) then cd = (start - GetTime()) + duration end
            if (cd > 0) then
              local update,txt = FastOpen:SecondsToString(cd)
              self.update = update
              self.timer:SetText(txt)
            else
              self:SetScript("OnUpdate",nil)
              self.timer:SetText(nil)
              self.expire = nil
            end
          end
        end
      end)
    end
  end
end
local unusedOverlayGlows = {}
local numOverlays = 0
function FastOpen.ActionButton_GetOverlayGlow()
  local overlay = tremove(unusedOverlayGlows)
  if not overlay then
    numOverlays = numOverlays + 1
    overlay = CreateFrame("Frame", ADDON .. "ActionButtonOverlay"..numOverlays, FastOpen.frameHiderB, "ActionBarButtonSpellActivationAlert")
  end
  return overlay;
end
function FastOpen.ActionButton_ShowOverlayGlow(self)
  if not self.overlay then
    self.overlay = FastOpen.ActionButton_GetOverlayGlow()
    local frameWidth, frameHeight = self:GetSize()
    self.overlay:SetParent(self)
    SetOutside(self.overlay,self,frameWidth/3, frameHeight/3)
  end
  self.overlay:Show()
  self.overlay.ProcStartAnim:Stop()
  self.overlay.ProcStartAnim:Play()
end
function FastOpen.ActionButton_HideOverlayGlow(self)
  if self.overlay then
    if self.overlay.ProcStartAnim:IsPlaying() then
      self.overlay.ProcStartAnim:Stop()
    end
    FastOpen.ActionButton_OverlayGlowAnimOutFinished(self.overlay)
  end
end
function FastOpen.ActionButton_OverlayGlowAnimOutFinished(overlay)
  local actionButton = overlay:GetParent()
  overlay:Hide()
  tinsert(unusedOverlayGlows, overlay)
  actionButton.overlay = nil
end
