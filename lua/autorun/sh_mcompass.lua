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

end