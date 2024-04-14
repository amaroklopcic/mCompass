include("autorun/config.lua")

include("autorun/client/cvars.lua")
include("autorun/client/font.lua")
include("autorun/client/tool_menu_options.lua")




local function loadFonts()
    local returnVal = hook.Call("mCompass_loadFonts")
end

-- not cvars
local cl_style_selected_str, compass_style

local function updateCompassSettings()
    -- ternary operators sorry not sorry
    cl_style_selected_str = (cl_cvar_mcompass_style == 1 and "fortnite" or cl_cvar_mcompass_style == 2 and "squad" or cl_cvar_mcompass_style == 3 and "pubg")
    compass_style = mCompass_Settings.Force_Server_Style
        and mCompass_Settings.Styles[mCompass_Settings.Style_Selected]
        or {
            style = cl_style_selected_str,
            heading = cl_cvar_mcompass_heading,
            compassX = cl_cvar_mcompass_xposition,
            compassY = cl_cvar_mcompass_yposition,
            width = cl_cvar_mcompass_width,
            height = cl_cvar_mcompass_height,
            spacing = cl_cvar_mcompass_spacing,
            ratio = cl_cvar_mcompass_ratio,
            offset = mCompass_Settings.Styles[cl_style_selected_str].offset,
            color = cl_cvar_mcompass_color,
            maxMarkerSize = 1,
            minMarkerSize = 0.5
        }
    if mCompass_Settings.Force_Server_Style then
        compass_style.style = mCompass_Settings.Style_Selected
    end
    loadFonts()
end



----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----====----


updateCompassSettings()

----------------------------------------------------------------------------------------------------------------

local cl_mCompass_MarkerTable = cl_mCompass_MarkerTable or {}

local mat = Material("compass/compass_marker_01")
local mat2 = Material("compass/compass_marker_02")

net.Receive("mCompass_AddMarker", function(len)
    local id = net.ReadInt(4)
    local isEntity = net.ReadBool()
    local pos = (!isEntity and net.ReadVector() or nil)
    local ent = (isEntity and net.ReadEntity() or nil)
    local time = net.ReadFloat()
    local color = net.ReadColor()
    local icon_mat = net.ReadString()
    local icon_name = net.ReadString()
    icon_mat = (icon_mat == "") and mat or Material(icon_mat)
    icon_name = icon_name or ""
    table.insert(cl_mCompass_MarkerTable, {isEntity, (pos or (ent or nil)), time, color, id, icon_mat, icon_name})
end)

net.Receive("mCompass_RemoveMarker", function(len)
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
    return (kilometers > 1) and kilometers.."km" or meters.."m"
end

local function getTextSize(font, text)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(text)
    return w, h
end

-- Basically draws lines with two masks that limit where the lines can be drawn
-- Not entirely sure how this affects performance... yolo
local function custom_compass_DrawLineFunc(mask1, mask2, line, color)
    render.ClearStencil()
    render.SetStencilEnable(true)
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

        render.SetStencilWriteMask(1)
        render.SetStencilReferenceValue(1)

        surface.SetDrawColor(Color(0, 0, 0, 1))
        surface.DrawRect(mask1[1], mask1[2], mask1[3], mask1[4]) -- left
        surface.DrawRect(mask2[1], mask2[2], mask2[3], mask2[4]) -- right

        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilTestMask(1)

        surface.SetDrawColor(color)
        surface.DrawLine(line[1], line[2], line[3], line[4])
    render.SetStencilEnable(false)
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
    local ply = LocalPlayer()
    if mCompass_Settings.Compass_Enabled and cl_cvar_mcompass_enabled then

        local ang = ply:GetAngles()
        local compassX, compassY = ScrW() * compass_style.compassX, ScrH() * compass_style.compassY
        local width, height = ScrW() * compass_style.width, ScrH() * compass_style.height
        local cl_spacing = compass_style.spacing
        local ratio = compass_style.ratio
        local color = compass_style.color
        local minMarkerSize = ScrH() * (compass_style.minMarkerSize / 45)
        local maxMarkerSize = ScrH() * (compass_style.maxMarkerSize / 45)
        local heading = compass_style.heading
        local offset = compass_style.offset

        spacing = (width * cl_spacing) / 360
        numOfLines = width / spacing
        fadeDistMultiplier = 1
        fadeDistance = (width / 2) / fadeDistMultiplier

        surface.SetFont("exo_compass_Numbers_"..ratio)

        if compass_style.style == "squad" then
            local text = math.Round(360 - ((ang.y - offset) % 360))
            local font = "exo_compass_Numbers_"..ratio
            compassBearingTextW, compassBearingTextH = getTextSize(font, text)
            surface.SetFont(font)
            surface.SetTextColor(Color(255, 255, 255))
            surface.SetTextPos(compassX - compassBearingTextW / 2, compassY)
            surface.DrawText(text)
        end

        for i = math.Round(-ang.y) % 360, (math.Round(-ang.y) % 360) + numOfLines do
            -- DEBUGGING LINES
            -- local compassStart = compassX - width / 2
            -- local compassEnd = compassX + width / 2
            -- surface.SetDrawColor(Color(0, 255, 0))
            -- surface.DrawLine(compassStart, compassY, compassStart, compassY + height * 2)
            -- surface.DrawLine(compassEnd, compassY, compassEnd, compassY + height * 2)

            local x = ((compassX - (width / 2)) + (((i + ang.y) % 360) * spacing))
            local value = math.abs(x - compassX)
            local calc = 1 - ((value + (value - fadeDistance)) / (width / 2))
            local calculation = 255 * math.Clamp(calc, 0.001, 1)

            local i_offset = -(math.Round(i - offset - (numOfLines / 2))) % 360
            if i_offset % 15 == 0 and i_offset >= 0 then
                local a = i_offset
                local text = adv_compass_tbl[360 - (a % 360)] and adv_compass_tbl[360 - (a % 360)] or 360 - (a % 360)
                local font = type(text) == "string" and "exo_compass_Letters" or "exo_compass_Numbers_"..ratio
                local w, h = getTextSize(font, text)

                surface.SetDrawColor(Color(color.r, color.g, color.b, calculation))
                surface.SetTextColor(Color(color.r, color.g, color.b, calculation))
                surface.SetFont(font)

                if compass_style.style == "pubg" then
                    surface.DrawLine(x, compassY, x, compassY + height * 0.2)
                    surface.DrawLine(x, compassY, x, compassY + height * 0.5)
                    surface.SetTextPos(x - w / 2, compassY + height * 0.6)
                    surface.DrawText(text)
                elseif compass_style.style == "fortnite" then
                    if font == "exo_compass_Numbers_"..ratio then
                        surface.DrawLine(x, compassY, x, compassY + height * 0.2)
                        surface.DrawLine(x, compassY, x, compassY + height * 0.3)
                        surface.SetTextPos(x - w / 2, compassY + height * 0.5)
                        surface.DrawText(text)
                    elseif font == "exo_compass_Letters" then
                        surface.SetTextPos(x - w / 2, compassY)
                        surface.DrawText(text)
                    end
                elseif compass_style.style == "squad" then
                    local mask1 = {compassX - width/2 - fadeDistance, compassY, width / 2 + fadeDistance - (compassBearingTextW / 1.5), height * 2}
                    local mask2 = {compassX + (compassBearingTextW / 1.5), compassY, width / 2 + fadeDistance - (compassBearingTextW / 1.5), height * 2}
                    local col = Color(color.r, color.g, color.b, calculation)
                    local line = {x, compassY, x, compassY + height * 0.5}
                    custom_compass_DrawLineFunc(mask1, mask2, line, col)
                    surface.SetTextPos(x - w / 2, compassY + height * 0.55)
                    surface.DrawText(text)
                end

                if compass_style.style == "squad" then
                    local mask1 = {compassX - width/2 - fadeDistance, compassY, width/2 + fadeDistance - (compassBearingTextW / 1.5), height * 2}
                    local mask2 = {compassX + (compassBearingTextW / 1.5), compassY, width/2 + fadeDistance - (compassBearingTextW / 1.5), height * 2}
                    local col = Color(color.r, color.g, color.b, calculation)

                    local line = {x, compassY, x, compassY + height * 0.5}
                    custom_compass_DrawLineFunc(mask1, mask2, line, col)
                end
            end

            if compass_style.style == "squad" then
                if i_offset % 5 == 0 and i_offset % 15 != 0 then
                    local mask1 = {compassX - width/2 - fadeDistance, compassY, width/2 + fadeDistance - (compassBearingTextW / 1.5), height}
                    local mask2 = {compassX + (compassBearingTextW / 1.5), compassY, width/2 + fadeDistance - (compassBearingTextW / 1.5), height}
                    local col = Color(color.r, color.g, color.b, calculation)

                    local line = {x, compassY, x, compassY + height * 0.25}
                    custom_compass_DrawLineFunc(mask1, mask2, line, col)
                end
            end
        end

        for k, v in pairs(cl_mCompass_MarkerTable) do
            if CurTime() > v[3] or (v[1] and !IsValid(v[2]))  then
                table.remove(cl_mCompass_MarkerTable, k)
                continue
            end

            local spotPos = (v[1] and v[2]:GetPos() or v[2])
            local d = ply:GetPos():Distance(spotPos)
            local currentVar = 1 - (d / (300 / 0.01905)) -- Converting 300m to gmod units
            local markerScale = Lerp(currentVar, minMarkerSize, maxMarkerSize)
            local font = markerScaleFunc(markerScale)

            local yAng = ang.y - (spotPos - ply:GetPos()):GetNormalized():Angle().y
            local markerSpot = math.Clamp(((compassX + (width / 2 * cl_spacing)) - (((-yAng - offset - 180) % 360) * spacing)), compassX - (width / 2), compassX + (width / 2))

            surface.SetMaterial(v[6])
            surface.SetDrawColor(v[4])
            surface.DrawTexturedRect(markerSpot - markerScale/2, compassY - markerScale - markerScale/2, markerScale, markerScale)

            -- Drawing text above markers
            local text = (v[7] != "") and v[7].." - "..getMetricValue(d) or getMetricValue(d)
            local w, h = getTextSize(font, text)

            surface.SetFont(font)
            surface.SetTextColor(Color(255, 255, 255))
            surface.SetTextPos(markerSpot - w/2, compassY - markerScale - markerScale/2 - h)
            surface.DrawText(text)
        end

        if compass_style.heading and compass_style.style != "squad" then
            -- Middle Triangle
            local triangleSize = 8
            local triangleHeight = compassY

            local triangle = {
                { x = compassX - triangleSize/2, y = triangleHeight - (triangleSize * 2) },
                { x = compassX + triangleSize/2, y = triangleHeight - (triangleSize * 2) },
                { x = compassX, y = triangleHeight - triangleSize },
            }
            surface.SetDrawColor(255, 255, 255)
            draw.NoTexture()
            surface.DrawPoly(triangle)

            if heading then
                local text = math.Round(-ang.y - offset) % 360
                local font = "exo_compass_Numbers_"..ratio
                local w, h = getTextSize(font, text)
                surface.SetFont(font)
                surface.SetTextColor(Color(255, 255, 255))
                surface.SetTextPos(compassX - w/2, compassY - h - (triangleSize * 2))
                surface.DrawText(text)
            end
        end
    end
end)
