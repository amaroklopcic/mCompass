include("autorun/client/helpers.lua")


-- TODO: add the following cvars
-- justify top/bottom -> align ticks to the top or bottom if they aren't full height ticks
-- headings above/below -> moves main headings, sub headings above or below the compass
-- display compass heading carrot -> optionally display carrot
-- display compass heading carrot above or below -> display carrot above or below compass
-- show main heading text -> display "N", "S", "E" every 90 degrees
-- show sub heading text -> display "NE", "NW", "SE" every 45 degrees
-- show num heading text -> display "330", "345", "15", "30" every 15 degrees
-- show ticks -> optionally choose to display ticks or not
-- font -> allow user to select fonts
-- main heading font size
-- sub heading font size
-- number heading font size
-- compass line thickness
-- TODO: get away from pre-defined styes
-- TODO: ratio is confusing, should instead be split into main heading font size, sub heading font size, and number heading font size
-- spacing convar is also kind of confusing, wondering if using the word gap would make more sense

local _mcompass_cvars_definitions = {
    ["enabled"] = {
        ["default"] = "1",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "Should mCompass be enabled/disabled"
    },
    ["display_heading"] = {
        ["default"] = "1",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "Should mCompass display the precise heading"
    },
    ["x_pos"] = {
        ["default"] = "0.5",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "Where mCompass should be drawn on the x position"
    },
    ["y_pos"] = {
        ["default"] = "0.05",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "Where mCompass should be drawn on the y position"
    },
    ["width"] = {
        ["default"] = "0.25",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "How wide mCompass should be drawn on screen (e.g. a value of 0.25 takes up 25% of the screen width)"
    },
    ["height"] = {
        ["default"] = "0.03",
        ["min"] = 0,
        ["max"] = 1,
        ["help"] = "How tall mCompass should be drawn on screen (e.g. a value of 0.03 takes up 3% of the screen height)"
    },
    ["color"] = {
        ["default"] = "255 255 255 255",
        ["help"] = "Color of mCompass in [Red Green Blue Alpha] format",
    },
}

-- add console command to reset compass config to defaults
concommand.Add("mcompass_reset", function(ply, cmd, args)
    for k, v in pairs(_mcompass_cvars_definitions) do
        RunConsoleCommand("mcompass_" .. k, v["default"])
    end
end)

-- create necessary client console variables
for k, v in pairs(_mcompass_cvars_definitions) do
    CreateClientConVar("mcompass_" .. k, v["default"], true, false, v["help"], v["min"], v["max"])
end

-- parse client cvars and return a table with the parsed values
function fetch_mcompass_cvars()
    -- TODO: add error handling and display for each of these
    local mcompass_cvars = {}
    mcompass_cvars.enabled = tobool(GetConVar("mcompass_enabled"):GetInt())
    mcompass_cvars.display_heading = tobool(GetConVar("mcompass_display_heading"):GetInt())
    mcompass_cvars.x_pos = GetConVar("mcompass_x_pos"):GetFloat()
    mcompass_cvars.y_pos = GetConVar("mcompass_y_pos"):GetFloat()
    mcompass_cvars.width = GetConVar("mcompass_width"):GetFloat()
    mcompass_cvars.height = GetConVar("mcompass_height"):GetFloat()
    mcompass_cvars.color = string_to_color(GetConVar("mcompass_color"):GetString())
    return mcompass_cvars
end

MCOMPASS_CVARS = fetch_mcompass_cvars()

function update_mcompass_cvars()
    MCOMPASS_CVARS = fetch_mcompass_cvars()
end

-- add hooks to handle cvar changes from client
MCOMPASS_CVAR_CALLBACK_IDS = {}
for k, v in pairs(_mcompass_cvars_definitions) do
    local cvar_cmd = "mcompass_" .. k
    local cvar_callback_identifier = "mcompass_" .. k .. "_cvar_callback"
    cvars.AddChangeCallback(cvar_cmd, function(convar, old_val, new_val)
        update_mcompass_cvars()
    end, cvar_callback_identifier)
    table.insert(MCOMPASS_CVAR_CALLBACK_IDS, cvar_callback_identifier)
end
