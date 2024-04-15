include("autorun/config.lua")

include("autorun/client/cvars.lua")
include("autorun/client/fonts.lua")
include("autorun/client/style.lua")
include("autorun/client/tool_menu_options.lua")

local compass_bearing_map = {
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

local debug_mode = true

hook.Add("HUDPaint", "HUDPaint_Compass", function()
    if not MCOMPASS_CVARS.enabled then
        return
    end

    local ply = LocalPlayer()
    local ang = ply:GetAngles()

    local compass_x, compass_y = ScrW() * MCOMPASS_STYLE.x_pos, ScrH() * MCOMPASS_STYLE.y_pos
    local compass_width, compass_height = ScrW() * MCOMPASS_STYLE.width, ScrH() * MCOMPASS_STYLE.height

    local desired_inflated_spacing = 2
    local graduation_gap = (compass_width * desired_inflated_spacing) / 360
    local number_of_visible_graduations = compass_width / graduation_gap

    -- draw helpful debug lines
    if debug_mode then
        local start_x = compass_x - compass_width / 2
        local end_x = compass_x + compass_width / 2
        -- draw compass middle debug line
        surface.SetDrawColor(Color(255, 255, 0))
        surface.DrawLine(compass_x, compass_y, compass_x, compass_y + compass_height * 2)
        -- draw compass border debug lines
        surface.SetDrawColor(Color(0, 255, 0))
        surface.DrawLine(start_x, compass_y, start_x, compass_y + compass_height * 1)
        surface.DrawLine(end_x, compass_y, end_x, compass_y + compass_height * 1)
        -- draw current angle
        surface.SetTextPos(start_x, compass_y + compass_height)
        surface.SetTextColor(0, 255, 0, 255)
        surface.DrawText(math.Round(ang.y) % 360)
    end

    local ang_y = math.Round(ang.y) % 360
    local compass_start_x = (compass_x - (compass_width / 2))
    -- local compass_end_x = (compass_x + (compass_width / 2))

    for i = 0, number_of_visible_graduations do
        -- the x position of the initial graduation line, or "tick". all the graduations in the compass
        -- are drawn after, and in reference to, this one
        local initial_graduation_x = (ang_y * desired_inflated_spacing / 360) * compass_width
        -- the x position of the graduation line
        local x = compass_start_x + ((initial_graduation_x + (i * graduation_gap)) % compass_width)

        if i % 90 == 0 then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.8)
        elseif i % 45 == 0 then
            surface.SetDrawColor(200, 200, 200, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.5)
        elseif i % 5 == 0 then
            surface.SetDrawColor(150, 150, 150, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.2)
        end

        -- surface.SetTextPos(x - w / 2, compassY + height * 0.6)
        -- surface.DrawText(text)
    end
end)
