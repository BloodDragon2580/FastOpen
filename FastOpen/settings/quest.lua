local _
local assert = _G.assert
local LibStub = _G.LibStub; assert(LibStub ~= nil,'LibStub')
local CreateFrame = _G.CreateFrame; assert(CreateFrame ~= nil,'CreateFrame')
local floor = _G.floor; assert(floor ~= nil,'floor')
local GameTooltip = _G.GameTooltip; assert(GameTooltip ~= nil,'GameTooltip')
local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor; assert(GameTooltip_SetDefaultAnchor ~= nil,'GameTooltip_SetDefaultAnchor')
local GetCVar = _G.GetCVar; assert(GetCVar ~= nil,'GetCVar')
local GetItemCount = _G.GetItemCount or _G.C_Item.GetItemCount; assert(GetItemCount ~= nil,'GetItemCount')
local GetItemInfo = _G.GetItemInfo or _G.C_Item.GetItemInfo; assert(GetItemInfo ~= nil,'GetItemInfo')
local GetItemIcon = _G.GetItemIcon or function(itemId) return select(10, GetItemInfo(itemId)) end; assert(GetItemIcon ~= nil,'GetItemIcon')
local GetQuestLogIndexByID = C_QuestLog.GetLogIndexForQuestID; assert(GetQuestLogIndexByID ~= nil,'GetQuestLogIndexByID')
local GetScreenWidth = _G.GetScreenWidth; assert(GetScreenWidth ~= nil,'GetScreenWidth')
local hooksecurefunc = _G.hooksecurefunc; assert(hooksecurefunc ~= nil,'hooksecurefunc')
local ipairs = _G.ipairs; assert(ipairs ~= nil,'ipairs')
local IsControlKeyDown = _G.IsControlKeyDown; assert(IsControlKeyDown ~= nil,'IsControlKeyDown')
local math = _G.math; assert(math ~= nil,'math')
local pairs = _G.pairs; assert(pairs ~= nil,'pairs')
local SetBinding = _G.SetBinding; assert(SetBinding ~= nil,'SetBinding')
local SetBindingClick = _G.SetBindingClick; assert(SetBindingClick ~= nil,'SetBindingClick')
local ShowQuestComplete = _G.ShowQuestComplete; assert(ShowQuestComplete ~= nil,'ShowQuestComplete')
local ShowQuestOffer = _G.ShowQuestOffer; assert(ShowQuestOffer ~= nil,'ShowQuestOffer')
local string = _G.string; assert(string ~= nil,'string')
local type = _G.type; assert(type ~= nil,'type')
local UIParent = _G.UIParent; assert(UIParent ~= nil,'UIParent')
local ADDON, P = ...
local FastOpen = LibStub("AceAddon-3.0"):GetAddon(ADDON)

local LIB_QUESTITEM = P.LIB_QUESTITEM; assert(LIB_QUESTITEM ~= nil,'LIB_QUESTITEM')
local print = P.print; assert(print ~= nil,'print')
local T_BLACKLIST_Q = P.T_BLACKLIST_Q; assert(T_BLACKLIST_Q ~= nil,'T_BLACKLIST_Q')
local LIB_WAGO_ANALYTICS = P.LIB_WAGO_ANALYTICS; assert(LIB_WAGO_ANALYTICS ~= nil,'LIB_WAGO_ANALYTICS')

function FastOpen:QBAnchorMove()
  if not self.QB then return end
  self.QB:SetClampedToScreen(true)
  self.QB:ClearAllPoints()
  if FastOpen.AceDB.profile.qb_sticky then
    self.QB:SetAllPoints(P.BUTTON_FRAME)
  else
    local frame = FastOpen.AceDB.profile.qb[2] or "none"
    if _G[frame] then frame = _G[frame] else frame = nil end
    if not frame then
      if FastOpen.AceDB.profile.HideInCombat then frame = self.frameHiderQ else frame = UIParent end
    end
    if not FastOpen.AceDB.profile.HideInCombat and frame == self.frameHiderQ then frame = UIParent end
    self.QB:SetPoint(FastOpen.AceDB.profile.qb[1] or "CENTER", frame, FastOpen.AceDB.profile.qb[3] or "CENTER", FastOpen.AceDB.profile.qb[4] or 0, FastOpen.AceDB.profile.qb[5] or 0)
  end
end
function FastOpen:QBAnchorSave()
  if not self.QB then return end
  local point, relativeTo, relativePoint, xOfs, yOfs = self.QB:GetPoint()
  FastOpen.AceDB.profile.qb = {point or "CENTER", relativeTo and relativeTo.GetName and relativeTo:GetName() or "UIParent", relativePoint or "CENTER", xOfs or 0, yOfs or 0}
end
function FastOpen:QBAnchorSize()
  if not self.QB then return end
  self.QB:SetClampedToScreen(true)
  local iconSize = FastOpen.AceDB.profile.iconSize or P.DEFAULT_ICON_SIZE
  if not (GetScreenWidth() > 1500) then iconSize = math.floor(iconSize * 0.75) end
  self.QB:SetWidth(iconSize)
  self.QB:SetHeight(iconSize)
  if not self.QB.buttons then return end
  for i = 1, #self.QB.buttons do 
    local bt = self.QB.buttons[i]
    self:QBButtonSize(bt)
    self:QBButtonAnchor(i)
  end
end
function FastOpen:QBAnchor()
  self.QB = CreateFrame("Frame",P.QB_NAME.."Anchor",self.frameHiderQ)
  self:QBAnchorSize()
  self:QBAnchorMove()
  self.QB.buttons = {}
  if FastOpen.AceDB.profile.quest then 
    if not (self.QB:IsShown() or self.QB:IsVisible()) then self.QB:Show() end
  else
    if self.QB:IsShown() or self.QB:IsVisible() then self.QB:Hide() end
  end
end
function FastOpen:QBButtonSize(bt)
  local iconSize = FastOpen.AceDB.profile.iconSize or P.DEFAULT_ICON_SIZE
  if not (GetScreenWidth() > 1500) then iconSize = math.floor(iconSize * 0.75) end
  bt:SetWidth(iconSize)
  bt:SetHeight(iconSize)
end
function FastOpen:QBButton(i, p)
  if p.buttons and p.buttons[i] then
    local bt = p.buttons[i]
    return bt
  end
  local name = P.QB_NAME..i
  local bt = CreateFrame("Button", name, p, "ActionButtonTemplate,SecureActionButtonTemplate")
  self:QBButtonSize(bt)
  self:ButtonBackdrop(bt)
  bt:RegisterForClicks("AnyUp", "AnyDown") 
  bt:SetScript("OnEnter",  function(self) FastOpen:QBOnEnter(self) end)
  bt:SetScript("OnLeave",  function(self) FastOpen:QBOnLeave(self) end)
  bt:SetScript("PostClick",function(self,mouse) FastOpen:QBPostClick(self,mouse) end)
  bt.questMark = bt:CreateTexture(name.."Quest", "OVERLAY")
  bt.questMark:SetTexture(P.QUEST_ICON);
  bt.questMark:SetTexCoord(0.125, 0.250, 0.125, 0.250);
  bt.questMark:SetAllPoints()
  bt.questMark:Hide()
  self:ButtonStore(bt)
  bt.timer = bt:CreateFontString(nil,"OVERLAY","GameFontWhite")
  local timer = bt.timer
  local font, size = bt.count:GetFont()
  timer:SetFont(font, size-2,"OUTLINE")
  self:ButtonSwap(bt,FastOpen.AceDB.profile.swap)
  self:ButtonSkin(bt,FastOpen.AceDB.profile.skinButton)
  p.buttons[i] = bt
  return bt
end
function FastOpen:QBOnEnter(bt)
  if self:inCombat() then return end
  if not _G.ElvUI then
    if GetCVar("UberTooltips") == "1" then
      GameTooltip_SetDefaultAnchor(GameTooltip, bt)
    else
      GameTooltip:SetOwner(bt, "ANCHOR_RIGHT")
    end
  else
    local gto = GameTooltip:GetOwner()
    if not gto then GameTooltip_SetDefaultAnchor(GameTooltip,  UIParent) end
  end
  GameTooltip:SetHyperlink(bt:GetAttribute("item1"))
  local text = LIB_QUESTITEM.questItemText[bt.itemID]
  if text then
    text = P.L["Quest"] .. ": " .. LIB_QUESTITEM.questItemText[bt.itemID]
  else
    text = P.L["Quest not found for this item."]
  end
  GameTooltip:AddLine(text, 0, 1, 0)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(P.MOUSE_RB .. P.CLICK_SKIP_MSG,0,1,0)
  GameTooltip:AddLine(P.MOUSE_RB .. P.CLICK_BLACKLIST_MSG)
  GameTooltip:Show()
end
function FastOpen:QBOnLeave(bt)
  if self:inCombat() then return end
  GameTooltip:Hide() 
end
function FastOpen:QBBlacklist(isPermanent,itemID)
  if itemID then
    local name = GetItemInfo(itemID)
    if isPermanent then
      if not FastOpen.AceDB.profile["T_BLACKLIST_Q"] then FastOpen.AceDB.profile.T_BLACKLIST_Q = {} end
      FastOpen.AceDB.profile.T_BLACKLIST_Q[0] = true
      FastOpen.AceDB.profile.T_BLACKLIST_Q[itemID] = true
      LIB_WAGO_ANALYTICS:IncrementCounter("SessionBlacklistQuest")
      print(P.L["PERMA_BLACKLIST"],name or itemID)
    else
      T_BLACKLIST_Q[0] = true
      T_BLACKLIST_Q[itemID] = true
      LIB_WAGO_ANALYTICS:IncrementCounter("PermanentBlacklistQuest")
      print(P.L["SESSION_BLACKLIST"],name or itemID)
    end
    self:QBUpdate()
  end
end
function FastOpen:QBPostClick(bt,mouse)
  if mouse and (mouse == 'RightButton') then self:QBBlacklist(IsControlKeyDown(),bt.itemID) end
  if not mouse then 
    LIB_WAGO_ANALYTICS:IncrementCounter("QuestItemKeybindUsed")
  end
  if FastOpen.AceDB.profile.keyBind and (bt.itemID ~= self.AceDB.char.questBarID) then
    self.AceDB.char.questBarID = bt.itemID
    self:QBKeyBind(bt)
    if mouse then
      LIB_WAGO_ANALYTICS:IncrementCounter("QuestItemClickedKeybindUpdated")
    end
  elseif mouse and FastOpen.AceDB.profile.keyBind then
    LIB_WAGO_ANALYTICS:IncrementCounter("QuestItemClickedKeybindNotUpdated")
  end
end
function FastOpen:QBKeyBind(bt,i)
  if not (bt and FastOpen.AceDB.profile.keyBind and string.len(FastOpen.AceDB.profile.keyBind) > 0) then return end
  if self:inCombat() then self:TimerFire("QBKeyBind", P.TIMER_IDLE, bt, i); return end
  if bt and bt.GetName and string.len(bt:GetName()) > 0 then 
    self:QBClearBind()
    SetBindingClick(FastOpen.AceDB.profile.keyBind, bt:GetName(), 'LeftButton')
    if bt.hotkey then bt.hotkey:SetText(self:ButtonHotKey(FastOpen.AceDB.profile.keyBind)) end
    self.qbKBIndex = i
  end
end
function FastOpen:QBClearBind()
  if not (self.QB and self.QB.buttons) then return end
  for _,bt in ipairs(self.QB.buttons) do
    if bt and bt.hotkey and bt.hotkey.SetText then bt.hotkey:SetText("") end
  end
  SetBinding(FastOpen.AceDB.profile.keyBind)
  self.qbKBIndex = nil
end
function FastOpen:QBButtonAnchor(i)
  local button = self.QB.buttons[i]
  local parent = (i == 1 or (i-1) % FastOpen.AceDB.profile.slots == 0) and (P.QB_NAME.."Anchor") or (P.QB_NAME..(i-1))
  local rowspace = 0
  if (i > 1) and ((i-1) % FastOpen.AceDB.profile.slots == 0) then rowspace = -FastOpen.AceDB.profile.expand * (FastOpen.AceDB.profile.iconSize + FastOpen.AceDB.profile.spacing) * floor(i/FastOpen.AceDB.profile.slots) end
  button:ClearAllPoints()
  if FastOpen.AceDB.profile.direction == "RIGHT" then
    button:SetPoint("LEFT", parent, "RIGHT", FastOpen.AceDB.profile.spacing, -rowspace)
  elseif FastOpen.AceDB.profile.direction == "LEFT" then
    button:SetPoint("RIGHT", parent, "LEFT", -FastOpen.AceDB.profile.spacing, rowspace)
  elseif FastOpen.AceDB.profile.direction == "UP" then
    button:SetPoint("BOTTOM", parent, "TOP", rowspace, FastOpen.AceDB.profile.spacing)
  elseif FastOpen.AceDB.profile.direction == "DOWN" then
    button:SetPoint("TOP", parent, "BOTTOM", -rowspace, -FastOpen.AceDB.profile.spacing)
  end
end
function FastOpen:QBButtonAdd(i, itemID)
  local count = GetItemCount(itemID)
  local bt = self:QBButton(i, self.QB)
  bt.icon:SetTexture(GetItemIcon(itemID))
  bt.itemID = itemID
  bt.count:SetText((type(count) == "number") and (count > 1) and count or "")
  bt:SetAttribute("type1","item")
  bt:SetAttribute("item1", LIB_QUESTITEM:GetItemString(itemID))
  if (LIB_QUESTITEM.startsQuestItems[itemID] and not LIB_QUESTITEM.activeQuestItems[itemID]) or (itemID == P.DEFAULT_ITEMID and FastOpen.AceDB.profile.visible) then
    self.QB.refreshBar = true
    bt.questMark:Show()
  else
    bt.questMark:Hide()
  end
  self:QBButtonAnchor(i)
  if (itemID == self.AceDB.char.questBarID) then
    self:QBKeyBind(bt,i)
  end
  if not(bt:IsShown() or bt:IsVisible()) then bt:Show() end
end
function FastOpen:QBReset()
  self.QB.refreshBar = false
  if not (self.QB and self.QB.buttons) then return end
  for i = 1, #self.QB.buttons do 
    local bt = self.QB.buttons[i]
    if bt then
      bt.itemID = nil
      bt.count:SetText("")
      if bt:IsShown() or bt:IsVisible() then bt:Hide() end
    end
  end
end
function FastOpen:QBUpdate()
  if not self.QB or not self.QB.buttons then return end
  if self:inCombat() then self:TimerFire("QBUpdate", P.TIMER_IDLE); return end
  if not FastOpen.AceDB.profile.quest then 
    if self.QB:IsShown() or self.QB:IsVisible() then self.QB:Hide() end
    return
  end
  self:QBClearBind()
  self:QBReset()
  if not (self.QB:IsShown() or self.QB:IsVisible()) then self.QB:Show() end
  local i = 1
  for itemID, _ in pairs(LIB_QUESTITEM.startsQuestItems) do
    if not (LIB_QUESTITEM.activeQuestItems[itemID] or FastOpen.AceDB.profile.T_BLACKLIST_Q[itemID] or T_BLACKLIST_Q[itemID]) then self:QBButtonAdd(i, itemID); i = i + 1 end
  end
  for itemID, _ in pairs(LIB_QUESTITEM.usableQuestItems) do
    if not (LIB_QUESTITEM.startsQuestItems[itemID] or FastOpen.AceDB.profile.T_BLACKLIST_Q[itemID] or T_BLACKLIST_Q[itemID]) then self:QBButtonAdd(i, itemID); i = i + 1 end
  end
  if (i > 1) then
    if not self.qbKBIndex then
      self:QBKeyBind(self.QB.buttons[1])
      self.qbKBIndex = 1
    end
    return
  end
  if FastOpen.AceDB.profile.visible then
    for i = 1, FastOpen.AceDB.profile.slots * 2 do
      self:QBButtonAdd(i, P.DEFAULT_ITEMID)
    end
  end
end
function FastOpen:QBSkin()
  if not self.QB then return end
  for i = 1, #self.QB.buttons do self:ButtonSkin(self.QB.buttons[i],FastOpen.AceDB.profile.skinButton) end
end
function FastOpen:QBQuestAccept()
  if not (self.LQI and self.QB and self.QB.refreshBar) then return end
  if self:inCombat() then self:TimerFire("QBQuestAccept", P.TIMER_IDLE); return end
  self.LQI:Scan()
end
function FastOpen:QBAutoQuestTimer(ptype,qID)
  if self:inCombat() then self:TimerFire("QBAutoQuestTimer", P.TIMER_IDLE,ptype,qID); return end
  local index = GetQuestLogIndexByID(qID)
  if not index then return end
  if (ptype == "OFFER") then
    ShowQuestOffer(index)
  else
    ShowQuestComplete(index)
  end
end
function FastOpen:QBAutoQuest()
  hooksecurefunc("AutoQuestPopupTracker_AddPopUp", 
    function(questID, popUpType)
      if FastOpen.AceDB.profile.autoquest and (type(questID) == "number") and (type(popUpType) == "string") and questID then
        local index = GetQuestLogIndexByID(questID)
        if index then FastOpen:QBAutoQuestTimer(popUpType,questID) end
      end
    end
  )
end
