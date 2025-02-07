WGT = {
   Loaded = false
}
WGT.Options = {}

SLASH_WINTERGRASPTIMER1 = "/wgt"
SLASH_WINTERGRASPTIMER2 = "/wintergrasptimer"
SlashCmdList["WINTERGRASPTIMER"] = function(line)
    local _, _, command, argument = string.find(line, "^%s*([^%s]-)%s+(.-)%s*$")
    if not command then
       command, argument = line, ""
    end
  
    command = string.upper(command)

    if command == "SHOW" then
       argument = string.upper(argument)
       if argument == "" then
	  WGT.WaitTimer:Show()
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt SHOWN")
       elseif argument == "ALL" then
	  WGT.Options.ShowInAllZones = not WGT.Options.ShowInAllZones
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: ShowInAllZones = "..tostring(WGT.Options.ShowInAllZones))
       else
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: unknown argument: "..command.." "..argument)
       end
    elseif command == "HIDE" then
       argument = string.upper(argument)
       if argument == "" then
	  WGT.WaitTimer:Hide()
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt HIDDEN")
       elseif argument == "INSTANCES" then
	  WGT.Options.HideInInstances = not WGT.Options.HideInInstances
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: HIDE INSTANCES = "..tostring(WGT.Options.HideInInstances))
       elseif argument == "WINTERGRASP" then
	  WGT.Options.HideInWintergrasp = not WGT.Options.HideInWintergrasp
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: HIDE WINTERGRASP = "..tostring(WGT.Options.HideInWintergrasp))
       else
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: unknown argument: "..command.." "..argument)
       end
    elseif command == "ADD" then
       argument = GetZoneText()
       WGT.WaitTimer:AddZone(argument)
       WGT:ShowOrHideWaitTimer(true)
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: ADD "..argument)
    elseif command == "REMOVE" then
       argument = GetZoneText()
       WGT.WaitTimer:RemoveZone(argument)
       WGT:ShowOrHideWaitTimer(true)
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: REMOVE "..argument)
    elseif command == "CONFIG" then
       if WGT.Options.Enabled then
	  DEFAULT_CHAT_FRAME:AddMessage(("/wgt version %s ENABLED"):format(WGT.Options.Version))
       else
	  DEFAULT_CHAT_FRAME:AddMessage(("/wgt version %s DISABLED"):format(WGT.Options.Version))
       end

       DEFAULT_CHAT_FRAME:AddMessage("/wgt: AlwaysShow = "..tostring(WGT.Options.AlwaysShow))
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: ShowInAllZones = "..tostring(WGT.Options.ShowInAllZones))
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: HideInInstances = "..tostring(WGT.Options.HideInInstances))
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: HideInWintergrasp = "..tostring(WGT.Options.HideInWintergrasp))

       if #WGT.Options.ZonesToShow == 0 then
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt show list is empty")
       else
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt shown list:")
	  local v
	  for _,v in pairs(WGT.Options.ZonesToShow) do
	     DEFAULT_CHAT_FRAME:AddMessage(":"..v)
	  end
       end
    elseif command == "ENABLE" then
       WGT.Options.Enabled = true
       WGT:ShowOrHideWaitTimer(true)
       DEFAULT_CHAT_FRAME:AddMessage("/wgt ENABLED")
    elseif command == "DISABLE" then
       WGT.Options.Enabled = false
       WGT:ShowOrHideWaitTimer(true)
       DEFAULT_CHAT_FRAME:AddMessage("/wgt DISABLED")
    elseif command == "TOGGLE" then
       WGT.Options.Enabled = not WGT.Options.Enabled
       WGT:ShowOrHideWaitTimer(true)
       if WGT.Options.Enabled then
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt TOGGLED ON")
       else
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt TOGGLED OFF")
       end
    elseif command == "DEBUG" then
       WGT.Options.Debug = not WGT.Options.Debug
    elseif command == "ALWAYS" then
       argument = string.upper(argument)
       if argument == "ON" then
	  WGT.Options.AlwaysShow = true
	  WGT:ShowOrHideWaitTimer(true)
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt ALWAYS ON")
       elseif argument == "OFF" then
	  WGT.Options.AlwaysShow = false
	  WGT:ShowOrHideWaitTimer(true)
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt ALWAYS OFF")
       else
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt: unknown argument: "..command.." "..argument)
       end
    elseif command == "RESET" then
       WGT_Options = CloneTable(WGT_OptionsDefaults);
       WGT.Options = WGT_Options
       WGT:ShowOrHideWaitTimer(true)
       DEFAULT_CHAT_FRAME:AddMessage("/wgt options reset")
    elseif command == "SCALE" then
       local number = tonumber(argument)
       if number < 0.1 or number > 3.0 then
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt ERROR: scale "..argument..": value should be between 0.1 and 3.0")
       else
	  WGT.Options.ScaleFrame = number
	  WGT.WaitTimer:SetScale(number)
	  DEFAULT_CHAT_FRAME:AddMessage("/wgt scale "..argument)
       end
    elseif command == "HELP" then
       DEFAULT_CHAT_FRAME:AddMessage("/wgt")
       DEFAULT_CHAT_FRAME:AddMessage("- without any argument, displays the time for next wintergrasp battle")
       DEFAULT_CHAT_FRAME:AddMessage("- show||hide: show or hide the panel (until you move to another declared zone)")
       DEFAULT_CHAT_FRAME:AddMessage("- show all: (toggle) show in all zones")
       DEFAULT_CHAT_FRAME:AddMessage("- hide instances: (toggle) hide panel in instances")
       DEFAULT_CHAT_FRAME:AddMessage("- hide wintergrasp: (toggle) hide panel in wintergrasp")
       DEFAULT_CHAT_FRAME:AddMessage("- config: show the current configuration")
       DEFAULT_CHAT_FRAME:AddMessage("- always on||always off: always/never show the panel")
       DEFAULT_CHAT_FRAME:AddMessage("- add||remove: add/remove the current zone to the shown list")
       DEFAULT_CHAT_FRAME:AddMessage("- enable||disable||toggle: enable/disable this add-on")
       DEFAULT_CHAT_FRAME:AddMessage("- scale VALUE: cale the panel (0.1 - 3.0)")
       DEFAULT_CHAT_FRAME:AddMessage("- reset: reset values to default")
    elseif command == "" then
       local text = WGT.WaitTimer:GetWintergraspOwnerText()
       if text ~= nil then
	  DEFAULT_CHAT_FRAME:AddMessage(text)
       else
	  DEFAULT_CHAT_FRAME:AddMessage("Can't get Wintergrasp information")
       end
    else
       DEFAULT_CHAT_FRAME:AddMessage("/wgt: unknown command: "..command)
    end
end

local function handleEvent(self, event, ...)
   if event == "ADDON_LOADED" then
      if WGT_Options.Version ~= WGT_OptionsDefaults.Version then
	 WGT_Options = CloneTable(WGT_OptionsDefaults);
      end
      WGT.Options = WGT_Options
      WGT.Loaded = true
   end
   if WGT.Loaded then
      WGT:ShowOrHideWaitTimer()
   end
end

function WGT:ShowOrHideWaitTimer(force)
   if force then
      WGT.WaitTimer:Hide()
   end
   if WGT.Options.Enabled then
      if WGT.Options.AlwaysShow then
	 WGT.WaitTimer:Show()
      else
	 if WGT:ShownInCurrentZone() then
	    WGT.WaitTimer:Show()
	 else
	    WGT.WaitTimer:Hide()
	 end
      end
   end
end

function WGT:ShownInZone(zoneName)
   local v
   for _,v in pairs(WGT.Options.ZonesToShow) do
      if v == zoneName then
	 return true
      end
   end
   return false
end

function WGT:ShownInCurrentZone()
   local inInstance, instanceType = IsInInstance()
   if WGT.Options.HideInInstances and inInstance then
      return false
   end
   if WGT.Options.HideInWintergrasp and GetZoneText() == "Wintergrasp" then
      return false
   end
   if WGT.Options.ShowInAllZones then
      return true
   end
   local zoneName = GetZoneText()
   return self:ShownInZone(zoneName)
end

WGT.mainFrame = CreateFrame('Frame')

WGT.mainFrame:SetScript('OnEvent', handleEvent)
WGT.mainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
WGT.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
WGT.mainFrame:RegisterEvent("ADDON_LOADED")
