AddCSLuaFile("autorun/client/cl_init.lua")
AddCSLuaFile("autorun/client/cvars.lua")
AddCSLuaFile("autorun/client/fonts.lua")
AddCSLuaFile("autorun/client/helpers.lua")
AddCSLuaFile("autorun/client/style.lua")
AddCSLuaFile("autorun/client/tool_menu_options.lua")

include("autorun/config.lua")

if MCOMPASS_CONFIG.use_fastdl then
    resource.AddFile("materials/compass/compass_marker_01.vmt")
    resource.AddFile("materials/compass/compass_marker_02.vmt")
    resource.AddFile("resource/fonts/exo/Exo-Regular.ttf")
end

-- TODO: re-implement spotting hooks with a nicer API
