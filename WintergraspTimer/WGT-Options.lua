
WGT_Options = {}

WGT_OptionsDefaults = {
   Version = "1.2.30100",
   ScaleFrame = .7,
   WaitTimerFramePoint = "CENTER",
   WaitTimerFrameX = 50,
   WaitTimerFrameY = -30,
   Enabled = true,
   AlwaysShow = false,
   Debug = true,
   ShowInAllZones = true,
   HideInInstances = true,
   HideInWintergrasp = true,
   ZonesToShow = {
      "Dalaran"
   },
};

--Code by Grayhoof (SCT)
function CloneTable(t)				-- return a copy of the table t
	local new = {};					-- create a new table
	local i, v = next(t, nil);		-- i is an index of t, v = t[i]
	while i do
		if type(v)=="table" then 
			v=CloneTable(v);
		end 
		new[i] = v;
		i, v = next(t, i);			-- get next index
	end
	return new;
end

WGT_Options = CloneTable(WGT_OptionsDefaults);

local function Reset_Dropdowns()
   WGT_Options = CloneTable(WGT_OptionsDefaults);
end

function WGT_Options_Reset()
   WGT_Options_Init();
   Reset_Dropdowns();
end

function WGT_Options_OnLoad(panel)
   panel.name = "Wintergrasp Timer";
   panel.default = WGT_Options_Reset;
   InterfaceOptions_AddCategory(panel);
end

function WGT_Options_Init()
--   WGT_OptionsFrameDropDownCats_OnShow();
end
