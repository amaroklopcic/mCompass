include("autorun/client/cvars.lua")


-- This table is just going to hold all of the generated fonts for later use.
-- cached fonts for main headings ("N", "W", "E", "S"), subheadings (e.g. "NE", "SW", etc.), and number headings
main_heading_fonts = main_heading_fonts or {}
subheading_fonts = subheading_fonts or {}
number_heading_fonts = number_heading_fonts or {}

-- TODO: refactor this
-- hook that can be called to regenerate fonts as settings are changed in real-time
-- fonts are only created once, then cached for later use
hook.Add("mcompass_generate_fonts", "mcompass_generate_fonts_addon", function()
    print("regenerating fonts...")
    -- local h = compass_style.height
    -- local r = compass_style.ratio
    -- if r != mCompass_oldFontRatio then
    --     for k, v in pairs(fontRatioChangeTable) do
    --         if "exo_compass_Numbers_" .. r == v.numberName then
    --             mCompass_oldFontRatio = r
    --             return v
    --         end
    --     end
    --     surface.CreateFont("exo_compass_Numbers_" .. r, {
    --         font = "Exo",
    --         size = math.Round((ScrH() * h) / r),
    --         antialias = true
    --     })
    --     surface.CreateFont("exo_compass_Distance-Display-Numbers_" .. r, {
    --         font = "Exo",
    --         size = (ScrH() * (h / r)) * compass_style.maxMarkerSize,
    --         antialias = true
    --     })
    --     surface.CreateFont("exo_compass_Letters", {
    --         font = "Exo",
    --         size = ScrH() * h,
    --         antialias = true
    --     })
    --     local t = {
    --         ratio = r,
    --         numberName = "exo_compass_Numbers_" .. r
    --     }
    --     table.insert(fontRatioChangeTable, t)
    --     mCompass_oldFontRatio = r
    -- end
end)
