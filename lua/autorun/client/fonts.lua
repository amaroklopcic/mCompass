-- This table is just going to hold all of the generated fonts for later use.
fontRatioChangeTable = fontRatioChangeTable or {}

-- Doing this just so we could remake fonts and see ratio effects live. Kinda messy, sorry :/
hook.Add("mCompass_loadFonts", "mCompass_loadFonts_addon", function()
    local h = compass_style.height
    local r = compass_style.ratio
    local ms = ScrH() * (compass_style.maxMarkerSize / 45)
    if r != mCompass_oldFontRatio then
        for k, v in pairs(fontRatioChangeTable) do
            if "exo_compass_Numbers_" .. r == v.numberName then
                mCompass_oldFontRatio = r
                return v
            end
        end
        surface.CreateFont("exo_compass_Numbers_"..r, {
            font = "Exo",
            size = math.Round((ScrH() * h) / r),
            antialias = true
        })
        surface.CreateFont("exo_compass_Distance-Display-Numbers_"..r, {
            font = "Exo",
            size = (ScrH() * (h / r)) * compass_style.maxMarkerSize,
            antialias = true
        })
        surface.CreateFont("exo_compass_Letters", {
            font = "Exo",
            size = ScrH() * h,
            antialias = true
        })
        local t = {
            ratio = r,
            numberName = "exo_compass_Numbers_"..r
        }
        table.insert(fontRatioChangeTable, t)
        mCompass_oldFontRatio = r
    end
end)
