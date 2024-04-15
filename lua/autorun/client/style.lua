include("autorun/client/cvars.lua")


-- table holding current mcompass settings; holds server style if it's forced, uses client config otherwise
MCOMPASS_STYLE = {}

function updateCompassSettings()
    if MCOMPASS_CONFIG.force_server_style then
        print("[mCompass] Using server-side enforced style...")
        MCOMPASS_STYLE = MCOMPASS_CONFIG.styles[MCOMPASS_CONFIG.forced_style]
        MCOMPASS_STYLE = MCOMPASS_CONFIG.forced_style
    else
        print("[mCompass] Using client-side style...")
        local selected_style
        if MCOMPASS_CVARS.style == 1 then selected_style = "fortnite" end
        if MCOMPASS_CVARS.style == 2 then selected_style = "squad" end
        if MCOMPASS_CVARS.style == 3 then selected_style = "pubg" end

        MCOMPASS_STYLE = {
            style = selected_style,
            heading = MCOMPASS_CVARS.display_heading,
            x_pos = MCOMPASS_CVARS.x_pos,
            y_pos = MCOMPASS_CVARS.y_pos,
            width = MCOMPASS_CVARS.width,
            height = MCOMPASS_CVARS.height,
            spacing = MCOMPASS_CVARS.spacing,
            -- ratio = cl_cvar_mcompass_ratio,
            -- TODO: add a client cvar for offset
            -- offset = MCOMPASS_CONFIG.styles[selected_style].offset,
            color = MCOMPASS_CVARS.color,
            -- maxMarkerSize = 1,
            -- minMarkerSize = 0.5
        }
    end
    hook.Call("mCompass_loadFonts")
end

updateCompassSettings()
