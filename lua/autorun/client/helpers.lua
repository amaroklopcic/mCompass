local clamp_color = function(val)
    local arg = tonumber(arg)
    return math.Clamp(arg and arg or 255, 0, 255)
end

-- helper function to transform client color cvar to a Color instance
function string_to_color(color_cvar)
    local split = string.Explode(" ", GetConVar("mcompass_color"):GetString())
    local red = clamp_color(split[1])
    local blue = clamp_color(split[2])
    local green = clamp_color(split[3])
    local alpha = clamp_color(split[4])

    return string.ToColor(red .. " " .. blue .. " " .. green .. " " .. alpha)
end

function get_metric_value(units)
    local meters = math.Round(units * 0.01905)
    local kilometers = math.Round(meters / 1000, 2)
    return (kilometers > 1) and kilometers .. "km" or meters .. "m"
end

function get_text_size(font, text)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(text)
    return w, h
end
