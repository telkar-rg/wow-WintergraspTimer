--local ALLIANCE = "|TInterface\\WorldStateFrame\\AllianceIcon:32|t"
--local HORDE = "|TInterface\\WorldStateFrame\\HordeIcon:32|t"
--local DISPUTED = "|TInterface\\WorldStateFrame\\CombatSwords:32|t"

local ALLIANCE = "|TInterface\\Calendar\\UI-Calendar-Event-PVP02:16|t "
local HORDE = "|TInterface\\Calendar\\UI-Calendar-Event-PVP01:16|t "
local DISPUTED = "|TInterface\\Calendar\\UI-Calendar-Event-PVP:16|t "

WGT.WaitTimer = {
   LastTime = time(),
   LastBattleTime = nil
}

--------------
--  Locals  --
--------------
local waitTimer = WGT.WaitTimer
local frame
local createFrame
local onUpdate
local dropdownFrame
local initialize

---------------------
--  Dropdown Menu  --
---------------------
do
    function initialize(dropdownFrame, level)
	local info
	info = UIDropDownMenu_CreateInfo()
	info.text = "Enabled"
	info.notCheckable = false
	info.checked = WGT.Options.Enabled
	info.func = function() waitTimer:ToggleEnabled() end
	UIDropDownMenu_AddButton(info, 1)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Always Show"
	info.notCheckable = false
	info.checked = WGT.Options.AlwaysShow
	info.func = function() waitTimer:ToggleAlwaysShow() end
	UIDropDownMenu_AddButton(info, 1)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Hide In Instances"
	info.notCheckable = false
	info.checked = WGT.Options.HideInInstances
	info.func = function() waitTimer:ToggleHideInInstances() end
	UIDropDownMenu_AddButton(info, 1)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Hide In Wintergrasp"
	info.notCheckable = false
	info.checked = WGT.Options.HideInWintergrasp
	info.func = function() waitTimer:ToggleHideInWintergrasp() end
	UIDropDownMenu_AddButton(info, 1)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Show In All Zones"
	info.notCheckable = false
	info.checked = WGT.Options.ShowInAllZones
	info.func = function() waitTimer:ToggleShowInAllZones() end
	UIDropDownMenu_AddButton(info, 1)

	local zoneName = GetZoneText()
	if WGT:ShownInZone(zoneName) then
	   info = UIDropDownMenu_CreateInfo()
	   info.text = "Remove Zone: "..zoneName
	   info.notCheckable = true
	   info.func = function() waitTimer:RemoveZone(zoneName) end
	   UIDropDownMenu_AddButton(info, 1)
	else
	   info = UIDropDownMenu_CreateInfo()
	   info.text = "Add Zone: "..zoneName
	   info.notCheckable = true
	   info.func = function() waitTimer:AddZone(zoneName) end
	   UIDropDownMenu_AddButton(info, 1)
	end

	info = UIDropDownMenu_CreateInfo()
	info.text = "hide"
	info.notCheckable = true
	info.func = function() waitTimer:Hide() end
	UIDropDownMenu_AddButton(info, 1)
    end
end


------------------------
--  Create the frame  --
------------------------
function createFrame()
	local elapsed = 0
	local frame = CreateFrame("GameTooltip", "WGTWaitTimer", UIParent, "GameTooltipTemplate")
	dropdownFrame = CreateFrame("Frame", "WGTWaitTimerDropdown", frame, "UIDropDownMenuTemplate")
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint(WGT.Options.WaitTimerFramePoint, UIParent, WGT.Options.WaitTimerFramePoint, WGT.Options.WaitTimerFrameX, WGT.Options.WaitTimerFrameY)
	frame:SetHeight(64)
	frame:SetWidth(64)
	frame:SetScale(WGT.Options.ScaleFrame)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetMovable()
	GameTooltip_OnLoad(frame)
	frame:SetPadding(16)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ValidateFramePosition(self)
		local point, _, _, x, y = self:GetPoint(1)
		WGT.Options.WaitTimerFrameX = x
		WGT.Options.WaitTimerFrameY = y
		WGT.Options.WaitTimerFramePoint = point
	end)
	frame:SetScript("OnUpdate", function(self, e)
		elapsed = elapsed + e
		if elapsed >= 0.5 then
			onUpdate(self)
			elapsed = 0
		end
	end)
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			UIDropDownMenu_Initialize(dropdownFrame, initialize, "MENU")
			ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
		end
	end)
	return frame
end

----------------
--  OnUpdate  --
----------------
function onUpdate(self)
   local color
   local j = 0
   self:ClearLines()

   local text = waitTimer:GetWintergraspOwnerText()
   if text ~= nil then
      self:SetText(text)
      self:Show()
   else
      self:SetText("Can't get Wintergrasp information.")
      self:Hide()
   end
end

---------------
--  Methods  --
---------------
function waitTimer:Show()
   frame = frame or createFrame()
   frame:Show()
   frame:SetOwner(UIParent, "ANCHOR_PRESERVE")
   onUpdate(frame)
end

function waitTimer:Hide()
   if frame then frame:Hide() end
end

function waitTimer:IsShown()
   return frame and frame:IsShown()
end

function waitTimer:ToggleEnabled()
   WGT.Options.Enabled = not WGT.Options.Enabled
   WGT:ShowOrHideWaitTimer(true)
end

function waitTimer:ToggleAlwaysShow()
   WGT.Options.AlwaysShow = not WGT.Options.AlwaysShow
   WGT:ShowOrHideWaitTimer(true)
end

function waitTimer:ToggleHideInInstances()
   WGT.Options.HideInInstances = not WGT.Options.HideInInstances
   WGT:ShowOrHideWaitTimer(true)
end

function waitTimer:ToggleHideInWintergrasp()
   WGT.Options.HideInWintergrasp = not WGT.Options.HideInWintergrasp
   WGT:ShowOrHideWaitTimer(true)
end

function waitTimer:ToggleShowInAllZones()
   WGT.Options.ShowInAllZones = not WGT.Options.ShowInAllZones
   WGT:ShowOrHideWaitTimer(true)
end

function waitTimer:AddZone(zoneName)
   waitTimer:RemoveZone(zoneName)
   table.insert(WGT.Options.ZonesToShow, zoneName)
end

function waitTimer:RemoveZone(zoneName)
   local found = true
   while found do
      found = false
      for _,v in pairs(WGT.Options.ZonesToShow) do
	 if v == zoneName then
	    found = true
	    table.remove(WGT.Options.ZonesToShow, _)
	    break
	 end
      end
   end
end

function waitTimer:GetWintergraspOwnerTextureIndex()
   local continent = GetCurrentMapContinent()
   local zoom = GetCurrentMapZone()
   local level = GetCurrentMapDungeonLevel()

   SetMapZoom(4) -- set to Northrend map

   local i
   local mls = GetNumMapLandmarks()
   for i=1,  mls do
      local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i);
      if description == "Control of Wintergrasp" then
--	 print(textureIndex);
	 -- 46 = alliance
	 -- 48 = horde
	 -- 101 = contested

	 SetMapZoom(continent, zoom)
	 SetDungeonMapLevel(level)
	 return textureIndex
      end
   end

   SetMapZoom(continent, zoom)
   SetDungeonMapLevel(level)
   return -1
end

function waitTimer:GetWintergraspOwnerText()
   local index = self:GetWintergraspOwnerTextureIndex()
   local nextBattleTime = GetWintergraspWaitTime()

   if index == -1 then
      return nil
   end

   if not waitTimer.LastBattleTime or nextBattleTime < waitTimer.LastBattleTime then
      waitTimer.LastBattleTime = nextBattleTime
      waitTimer.LastTime = time()
   else
      local timeSinceLastUpdate = difftime(time(), waitTimer.LastTime)
      if timeSinceLastUpdate > 10 then
	 nextBattleTime = waitTimer.LastBattleTime - timeSinceLastUpdate
	 waitTimer.LastBattleTime = nextBattleTime
	 waitTimer.LastTime = time()
      else
	 nextBattleTime = waitTimer.LastBattleTime
      end
   end

   if nextBattleTime ~= nil and nextBattleTime > 0 then
      if index == 48 then
	 return HORDE.."Next Battle: "..SecondsToTime(nextBattleTime)
      else
	 return ALLIANCE.."Next Battle: "..SecondsToTime(nextBattleTime)
      end
   end

   return DISPUTED.."Wintergrasp in Dispute"
end

function waitTimer:SetScale()
   frame:SetScale(WGT.Options.ScaleFrame)
   WGT:ShowOrHideWaitTimer(true)
end
