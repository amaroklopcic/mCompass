-- Shared file.

mCompass_Settings = {}

-- Enables/Disables compass for everyone in the entire server
mCompass_Settings.Compass_Enabled = true
mCompass_Settings.Force_Server_Style = false -- Force the below compass settings on the client.
mCompass_Settings.Use_FastDL = true -- Auto download the nessesary content for clients.

mCompass_Settings.Style_Selected = "squad"
mCompass_Settings.Allow_Player_Spotting = true -- Allow / Disallow players from spotting. (Disabling just allows servers to implement their own method of spotting)
mCompass_Settings.Allow_Entity_Spotting = false -- Not yet working.
mCompass_Settings.Max_Spot_Distance = 15748.03 -- In GMOD units | Default( 15748.03 / 300m )
mCompass_Settings.Spot_Duration = 10 -- In seconds

mCompass_Settings.Styles = {
	["fortnite"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.05,	-- This value is multiplied by users screen height. (Default: 0.05)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2.5,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 2,			-- The is the ratio of the size of the letters and numbers text. (Default: 2)
		offset = 180,		-- The number of degrees the compass will offset by. (Default: 180)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	},
	["squad"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.9,		-- This value is multiplied by users screen height. (Default: 0.9)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2.5,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
		offset = 180,		-- The number of degrees the compass will offset by. (Default: 180)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	},
	["pubg"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.05,	-- This value is multiplied by users screen height. (Default: 0.05)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2.5,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
		offset = 180,		-- The number of degrees the compass will offset by. (Default: 180)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	}
}

--------------------------------------------------------------
-- Dont edit anything below this line.
--------------------------------------------------------------

if SERVER then

	util.AddNetworkString("Adv_Compass_AddMarker")
	util.AddNetworkString("Adv_Compass_RemoveMarker")

	local mCompass_MarkerTable = mCompass_MarkerTable || {}

	function Adv_Compass_AddMarker(isEntity, pos, time, color, playersWhoCanSeeMarker, icon, name)
		icon = icon || ""
		name = name || ""

		local id = #mCompass_MarkerTable + 1
		if playersWhoCanSeeMarker then
			for k, v in pairs(playersWhoCanSeeMarker) do
				net.Start("Adv_Compass_AddMarker")
					net.WriteBool(isEntity) -- IsEntity
					if isEntity then
						net.WriteEntity(pos)
					else
						net.WriteVector(pos)
					end
					net.WriteFloat(time)
					net.WriteColor(color && color || Color(214, 48, 49))
					net.WriteInt(id, 4)
					net.WriteString(icon)
					net.WriteString(name)
				net.Send(v)
			end
		elseif !playersWhoCanSeeMarker then
			net.Start("Adv_Compass_AddMarker")
				net.WriteBool(isEntity) -- IsEntity
				if isEntity then
					net.WriteEntity(pos)
				else
					net.WriteVector(pos)
				end
				net.WriteFloat(time)
				net.WriteColor(color && color || Color(250, 177, 160))
				net.WriteInt(id, 4)
				net.WriteString(icon)
				net.WriteString(name)
			net.Broadcast()
		end
		table.insert(mCompass_MarkerTable, { pos, time, color || Color(214, 48, 49), id, icon, name })
		return id
	end

	function Adv_Compass_RemoveMarker(markerID)
		for k, v in pairs(mCompass_MarkerTable) do
			if markerID == v[5] then
				net.Start("Adv_Compass_RemoveMarker")
					net.WriteInt(markerID, 4)
				net.Broadcast()
				table.remove(mCompass_MarkerTable, k)
			end
		end
	end

	if mCompass_Settings.Use_FastDL then
		resource.AddFile("materials/compass/compass_marker_01.vmt")
		resource.AddFile("materials/compass/compass_marker_02.vmt")
		resource.AddFile("resource/fonts/exo/Exo-Regular.ttf")
	end

	local function v(arg)
		local arg = tonumber(arg)
		return math.Clamp(arg && arg || 255, 0, 255)
	end

	concommand.Add("mcompass_spot", function(ply, cmd, args)
		if mCompass_Settings.Allow_Player_Spotting then
			local color = string.ToColor(v(args[1]).." "..v(args[2]).." "..v(args[3]).." "..v(args[4]))
			local tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:EyeAngles():Forward() * mCompass_Settings.Max_Spot_Distance,
				filter = ply
			})
			local id
			if tr.Entity && !tr.HitWorld then
				id = Adv_Compass_AddMarker(true, tr.Entity, CurTime() + mCompass_Settings.Spot_Duration, color)
			else
				id = Adv_Compass_AddMarker(false, tr.HitPos, CurTime() + mCompass_Settings.Spot_Duration, color)
			end
		end
	end)

end

if CLIENT then

	concommand.Add("mcompass_reset", function(ply, cmd, args)
		RunConsoleCommand("mcompass_enabled", "1")
		RunConsoleCommand("mcompass_style", "1")
		RunConsoleCommand("mcompass_heading", "1")
		RunConsoleCommand("mcompass_xposition", "0.5")
		RunConsoleCommand("mcompass_yposition", "0.05")
		RunConsoleCommand("mcompass_width", "0.25")
		RunConsoleCommand("mcompass_height", "0.03")
		RunConsoleCommand("mcompass_spacing", "2.5")
		RunConsoleCommand("mcompass_ratio", "1.8")
		RunConsoleCommand("mcompass_color", "255", "255", "255", "255")
	end)

	-- cvars defined by client
	local cl_cvar_mcompass_enabled, cl_cvar_mcompass_style, cl_cvar_mcompass_heading
	local cl_cvar_mcompass_xposition, cl_cvar_mcompass_yposition, cl_cvar_mcompass_width, cl_cvar_mcompass_height
	local cl_cvar_mcompass_spacing, cl_cvar_mcompass_ratio, cl_cvar_mcompass_color

	-- not cvars
	local cl_style_selected_str, compass_style

	local function updateCompassSettings()
		-- ternary operators sorry not sorry
		cl_style_selected_str = (cl_cvar_mcompass_style == 1 && "fortnite" || cl_cvar_mcompass_style == 2 && "squad" || cl_cvar_mcompass_style == 3 && "pubg")
		compass_style = mCompass_Settings.Force_Server_Style
			&& mCompass_Styles[mCompass_Settings.Style_Selected]
			|| {
				heading = cl_cvar_mcompass_heading,
				compassX = cl_cvar_mcompass_xposition,
				compassY = cl_cvar_mcompass_yposition,
				width = cl_cvar_mcompass_width,
				height = cl_cvar_mcompass_height,
				spacing = cl_cvar_mcompass_spacing,
				offset = cl_cvar_mcompass_offset,
				color = Color(255, 255, 255),
				maxMarkerSize = 1,
				minMarkerSize = 0.5
			}
	end

	local function loadFonts()
		local returnVal = hook.Call("mCompass_loadFonts")
	end

	local function v(arg)
		local arg = tonumber(arg)
		return math.Clamp(arg && arg || 255, 0, 255)
	end

	CreateClientConVar("mcompass_enabled", "1", true, false)
	cvars.AddChangeCallback("mcompass_enabled", function(convar, oldValue, newValue)
		if newValue == "1" || newValue == "0" then
			cl_cvar_mcompass_enabled = tobool(newValue)
		end
	end, "mcompass_enabled_cvar_callback")
	cl_cvar_mcompass_enabled = tobool(GetConVar("mcompass_enabled"):GetInt())

	CreateClientConVar("mcompass_style", "1", true, false)
	cvars.AddChangeCallback("mcompass_style", function(convar, oldValue, newValue)
		if newValue == "1" || newValue == "2" || newValue == "3" then
			cl_cvar_mcompass_style = tonumber(newValue)
		end
		updateCompassSettings()
	end, "mcompass_style_cvar_callback")
	cl_cvar_mcompass_style = GetConVar("mcompass_style"):GetInt()

	CreateClientConVar("mcompass_heading", "1", true, false)
	cvars.AddChangeCallback("mcompass_heading", function(convar, oldValue, newValue)
		if newValue == "1" || newValue == "0" then
			cl_cvar_mcompass_heading = tobool(newValue)
		end
	end, "mcompass_heading_cvar_callback")
	cl_cvar_mcompass_heading = tobool(GetConVar("mcompass_heading"):GetInt())

	CreateClientConVar("mcompass_xposition", "0.5", true, false)
	cvars.AddChangeCallback("mcompass_xposition", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo >= 0 && foo <= 1 then
			cl_cvar_mcompass_xposition = newValue
		end
	end, "mcompass_xposition_cvar_callback")
	cl_cvar_mcompass_xposition = GetConVar("mcompass_xposition"):GetFloat()

	CreateClientConVar("mcompass_yposition", "0.05", true, false)
	cvars.AddChangeCallback("mcompass_yposition", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo >= 0 && foo <= 1 then
			cl_cvar_mcompass_yposition = newValue
		end
	end, "mcompass_yposition_cvar_callback")
	cl_cvar_mcompass_yposition = GetConVar("mcompass_yposition"):GetFloat()

	CreateClientConVar("mcompass_width", "0.25", true, false)
	cvars.AddChangeCallback("mcompass_width", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo >= 0 && foo <= 1 then
			cl_cvar_mcompass_width = tonumber(newValue)
		end
	end, "mcompass_width_cvar_callback")
	cl_cvar_mcompass_width = GetConVar("mcompass_width"):GetFloat()

	CreateClientConVar("mcompass_height", "0.03", true, false)
	cvars.AddChangeCallback("mcompass_height", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo >= 0 && foo <= 1 then
			cl_cvar_mcompass_height = tonumber(newValue)
		end
	end, "mcompass_height_cvar_callback")
	cl_cvar_mcompass_height = GetConVar("mcompass_height"):GetFloat()

	CreateClientConVar("mcompass_spacing", "2.5", true, false)
	cvars.AddChangeCallback("mcompass_spacing", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo > 1 && foo < 10 then
			cl_cvar_mcompass_spacing = foo
		end
	end, "mcompass_spacing_cvar_callback")
	cl_cvar_mcompass_spacing = GetConVar("mcompass_spacing"):GetFloat()

	CreateClientConVar("mcompass_ratio", "1.8", true, false)
	cvars.AddChangeCallback("mcompass_ratio", function(convar, oldValue, newValue)
		local foo = tonumber(newValue)
		if foo > 0 && foo < 10 then
			cl_cvar_mcompass_ratio = foo
		end
		loadFonts()
	end, "mcompass_ratio_cvar_callback")
	cl_cvar_mcompass_ratio = GetConVar("mcompass_ratio"):GetFloat()

	CreateClientConVar("mcompass_color", "255 255 255 255", true, false)
	cvars.AddChangeCallback("mcompass_color", function(convar, oldValue, newValue)
		local args = string.Explode(" ", newValue)
		cl_cvar_mcompass_color = string.ToColor(v(args[1]).." "..v(args[2]).." "..v(args[3]).." "..v(args[4]))
	end, "mcompass_color_cvar_callback")
	local foo = string.Explode(" ", GetConVar("mcompass_color"):GetString())
	cl_cvar_mcompass_color = string.ToColor(v(foo[1]).." "..v(foo[2]).." "..v(foo[3]).." "..v(foo[4]))

	updateCompassSettings()

	----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----

	-- This table is just going to hold all of the generated fonts for later use.
	displayDistanceFontTable = displayDistanceFontTable || {}
	fontRatioChangeTable = fontRatioChangeTable || {}

	-- Function that handles fonts for the spot marker.
	local function markerScaleFunc(markerSizeScale)
		local returnVal
		local n = math.Round(markerSizeScale)
		if !oldMarkerSizeScale || oldMarkerSizeScale != n then
			if displayDistanceFontTable[n] then
				returnVal = displayDistanceFontTable[n].name
			else
				local newFontName = tostring("exo_compass_DDN_"..n)
				displayDistanceFontTable[n] = {
					name = newFontName,
					size = n
				}
				surface.CreateFont(newFontName, {
					font = "Exo",
					size = n,
					antialias = true
				})
				returnVal = displayDistanceFontTable[n].name
			end
			oldMarkerSizeScale = n
		else
			return displayDistanceFontTable[oldMarkerSizeScale].name
		end
		return returnVal
	end

	-- Doing this just so we could remake fonts and see ratio effects live. Kinda messy, sorry :/
	hook.Add("mCompass_loadFonts", "mCompass_loadFonts_addon", function()
		local h, r, ms
		if mCompass_Settings.Force_Server_Style then
			h = mCompass_Settings.Style[mCompass_Settings.Style_Selected].height
			r = mCompass_Settings.Style[mCompass_Settings.Style_Selected].ratio
			ms = ScrH() * (mCompass_Settings.Style[mCompass_Settings.Style_Selected].maxMarkerSize / 45)
		else
			h = cl_cvar_mcompass_height
			r = cl_cvar_mcompass_ratio
			ms = ScrH() * (mCompass_Settings.Style[clientStyleSelection].maxMarkerSize / 45)
		end
		if r != oldFontRatio then
			for k, v in pairs(fontRatioChangeTable) do
				if "exo_compass_Numbers_"..r == v.numberName then
					oldFontRatio = r
					return v
				end
			end
			local maxMarkerSize = mCompass_Settings.Force_Server_Style && mCompass_Settings.Style[mCompass_Settings.Style_Selected].maxMarkerSize || mCompass_Settings.Style[clientStyleSelection].maxMarkerSize
			surface.CreateFont("exo_compass_Numbers_"..r, {
				font = "Exo",
				size = ScrH() * (h / r),
				antialias = true
			})
			surface.CreateFont("exo_compass_Distance-Display-Numbers_"..r, {
				font = "Exo",
				size = (ScrH() * (h / r)) * maxMarkerSize,
				antialias = true
			})
			surface.CreateFont("exo_compass_Letters", {
				font = "Exo",
				size = ScrH() * h,
				antialias = true
			} )
			local t = {
				ratio = r,
				numberName = "exo_compass_Numbers_"..r
			}
			table.insert(fontRatioChangeTable, t)
			oldFontRatio = r
		end
	end)

	loadFonts()

	----------------------------------------------------------------------------------------------------------------

	local cl_mCompass_MarkerTable = cl_mCompass_MarkerTable || {}

	local mat = Material( "compass/compass_marker_01" )
	local mat2 = Material( "compass/compass_marker_02" )

	net.Receive("Adv_Compass_AddMarker", function(len)
		local isEntity = net.ReadBool()
		local pos = (isEntity && net.ReadEntity() || net.ReadVector())
		local time, color, id, icon_mat, icon_name = net.ReadFloat(), net.ReadColor(), net.ReadInt(4), net.ReadString(), net.ReadString()
		icon_mat = (icon_mat == "") && mat || Material(icon_mat)
		icon_name = icon_name || ""
		table.insert(cl_mCompass_MarkerTable, {isEntity, pos, time, color, id, icon_mat, icon_name})
	end)

	net.Receive("Adv_Compass_RemoveMarker", function(len)
		local id = net.ReadInt(4)
		for k, v in pairs(cl_mCompass_MarkerTable) do
			if id == v[5] then
				table.remove(cl_mCompass_MarkerTable, k)
			end
		end
	end)

	local function getMetricValue(units)
		local meters = math.Round(units * 0.01905)
		local kilometers = math.Round(meters / 1000, 2)
		return (kilometers > 1) && kilometers.."km" || meters.."m"
	end

	local function getTextSize(font, text)
		surface.SetFont(font)
		local w, h = surface.GetTextSize(text)
		return w, h
	end

	local adv_compass_tbl = {
		[0] = "N",
		[45] = "NE",
		[90] = "E",
		[135] = "SE",
		[180] = "S",
		[225] = "SW",
		[270] = "W",
		[315] = "NW",
		[360] = "N"
	}

	hook.Add("HUDPaint", "HUDPaint_Compass", function()

	end)

	hook.Add("PopulateToolMenu", "mCompass_PopulateToolMenu", function()

	end)

end