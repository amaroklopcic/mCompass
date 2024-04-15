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

    local desired_inflated_spacing = 1
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

    -- looping left to right, angs are -180 to positive 180

    local ang_y = math.Round(ang.y) % 360
    local compass_start_x = (compass_x - (compass_width / 2))
    local compass_end_x = (compass_x + (compass_width / 2))

    -- TODO: calculate the x position of the graduation lines
    -- we should be taking compass start x, plus the distance to the next line
    -- distance to next line should be current iteration * spacing in between ticks
    -- spacing between ticks is calcualted by dividing compass width by 360 and multiplying that by client desired spacing
    -- client desired spacing is just arbitrary value to inflate the distance between ticks

    for i = 0, number_of_visible_graduations do
        -- TODO: problem here: as graduation_gap increases the color/size of the lines and 
        -- roation speed of the compass don't change, which makes it act as sort of an offset.
        -- it effectively does increase the spacing between lines, but creates a mismatch between
        -- the actual angle of the player and the lines representing the angle
        local x = compass_start_x + ((((ang_y / 360) * compass_width) + (i * graduation_gap)) % compass_width)
        -- local x = compass_start_x + ((ang_y / 360) * compass_width)

        local i_offset = i
        if i_offset % 90 == 0 then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.8)
        elseif i_offset % 45 == 0 then
            surface.SetDrawColor(200, 200, 200, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.5)
        elseif i_offset % 5 == 0 then
            surface.SetDrawColor(150, 150, 150, 255)
            surface.DrawLine(x, compass_y, x, compass_y + compass_height * 0.2)
        end

        -- surface.SetTextPos(x - w / 2, compassY + height * 0.6)
        -- surface.DrawText(text)
    end
end)
