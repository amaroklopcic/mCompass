include("autorun/client/helpers.lua")


-- add console command to reset compass config to defaults
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

-- create necessary client console variables
CreateClientConVar("mcompass_enabled", "1", true, false)
CreateClientConVar("mcompass_style", "1", true, false)
CreateClientConVar("mcompass_heading", "1", true, false)
CreateClientConVar("mcompass_xposition", "0.5", true, false)
CreateClientConVar("mcompass_yposition", "0.05", true, false)
CreateClientConVar("mcompass_width", "0.25", true, false)
CreateClientConVar("mcompass_height", "0.03", true, false)
CreateClientConVar("mcompass_spacing", "2.5", true, false)
CreateClientConVar("mcompass_ratio", "1.8", true, false)
CreateClientConVar("mcompass_color", "255 255 255 255", true, false)

-- cached cvars defined by client
MCOMPASS_CVARS = {}
MCOMPASS_CVARS.enabled = tobool(GetConVar("mcompass_enabled"):GetInt())
-- TODO: get away from pre-defined styes
MCOMPASS_CVARS.style = GetConVar("mcompass_style"):GetInt()
MCOMPASS_CVARS.display_heading = tobool(GetConVar("mcompass_heading"):GetInt())
MCOMPASS_CVARS.x_pos = GetConVar("mcompass_xposition"):GetFloat()
MCOMPASS_CVARS.y_pos = GetConVar("mcompass_yposition"):GetFloat()
MCOMPASS_CVARS.width = GetConVar("mcompass_width"):GetFloat()
MCOMPASS_CVARS.height = GetConVar("mcompass_height"):GetFloat()
MCOMPASS_CVARS.spacing = GetConVar("mcompass_spacing"):GetFloat()
-- TODO: ratio is confusing, should instead be split into main heading font size, sub heading font size, and number heading font size
-- cl_cvar_mcompass_ratio = GetConVar("mcompass_ratio"):GetFloat()
MCOMPASS_CVARS.color = string_to_color(GetConVar("mcompass_color"):GetString())

-- add hooks to handle cvar changes from client
cvars.AddChangeCallback("mcompass_enabled", function(convar, oldValue, newValue)
    if newValue == "1" or newValue == "0" then
        MCOMPASS_CVARS.enabled = tobool(newValue)
    end
    updateCompassSettings()
end, "mcompass_enabled_cvar_callback")

cvars.AddChangeCallback("mcompass_style", function(convar, oldValue, newValue)
    local style = tonumber(newValue)
    if style == 1 or style == 2 or style == 3 then
        MCOMPASS_CVARS.style = style
    end
    updateCompassSettings()
end, "mcompass_style_cvar_callback")

cvars.AddChangeCallback("mcompass_heading", function(convar, oldValue, newValue)
    MCOMPASS_CVARS.display_heading = tobool(newValue)
    updateCompassSettings()
end, "mcompass_heading_cvar_callback")

cvars.AddChangeCallback("mcompass_xposition", function(convar, oldValue, newValue)
    local x_pos = tonumber(newValue)
    if x_pos >= 0 and x_pos <= 1 then
        MCOMPASS_CVARS.x_pos = x_pos
    end
    updateCompassSettings()
end, "mcompass_xposition_cvar_callback")

cvars.AddChangeCallback("mcompass_yposition", function(convar, oldValue, newValue)
    local y_pos = tonumber(newValue)
    if y_pos >= 0 and y_pos <= 1 then
        MCOMPASS_CVARS.y_pos = y_pos
    end
    updateCompassSettings()
end, "mcompass_yposition_cvar_callback")

cvars.AddChangeCallback("mcompass_width", function(convar, oldValue, newValue)
    local width = tonumber(newValue)
    if width >= 0 and width <= 1 then
        MCOMPASS_CVARS.width = width
    end
    updateCompassSettings()
end, "mcompass_width_cvar_callback")

cvars.AddChangeCallback("mcompass_height", function(convar, oldValue, newValue)
    local height = tonumber(newValue)
    if height >= 0 and height <= 1 then
        MCOMPASS_CVARS.height = height
    end
    updateCompassSettings()
end, "mcompass_height_cvar_callback")

cvars.AddChangeCallback("mcompass_spacing", function(convar, oldValue, newValue)
    local spacing = tonumber(newValue)
    if spacing > 1 and spacing < 10 then
        MCOMPASS_CVARS.spacing = spacing
    end
    updateCompassSettings()
end, "mcompass_spacing_cvar_callback")

-- cvars.AddChangeCallback("mcompass_ratio", function(convar, oldValue, newValue)
--     local foo = tonumber(newValue)
--     if foo > 0 and foo < 10 then
--         cl_cvar_mcompass_ratio = foo
--     end
--     updateCompassSettings()
-- end, "mcompass_ratio_cvar_callback")

cvars.AddChangeCallback("mcompass_color", function(convar, oldValue, newValue)
    MCOMPASS_CVARS.color = string_to_color(newValue)
    updateCompassSettings()
end, "mcompass_color_cvar_callback")
