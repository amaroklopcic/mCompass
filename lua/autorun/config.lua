-- Shared file.

MCOMPASS_CONFIG = {}

-- Enables/Disables compass for everyone in the entire server
MCOMPASS_CONFIG.compass_enabled = true

-- Automatically download the nessesary textures, fonts, etc. for clients
MCOMPASS_CONFIG.use_fastdl = true

-- Force the style specified by the server to be dispalyed on the client
MCOMPASS_CONFIG.force_server_style = false
-- If `force_server_style` is true, this is the style that will be used from the below table.
MCOMPASS_CONFIG.forced_style = "squad"

-- TODO: re-implement spotting system
-- TODO: implement player spotting
-- TODO: implement entity spotting

-- Maximum spotting distance allowed by the client, in GMOD units | Default( 15748.03 == 300m )
MCOMPASS_CONFIG.max_spotting_distance = 15748.03

-- Maxium amount of time a spot marker stays active, in seconds
MCOMPASS_CONFIG.max_spotting_duration = 10

-- color of a generic spot marker
MCOMPASS_CONFIG.spot_marker_color = Color(255, 0, 0)

MCOMPASS_CONFIG.styles = {
	["fortnite"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.05,	-- This value is multiplied by users screen height. (Default: 0.05)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2.5,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 2,			-- The is the ratio of the size of the letters and numbers text. (Default: 2)
		offset = 0,			-- The number of degrees the compass will offset by. (Default: 0)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	},
	["squad"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.9,		-- This value is multiplied by users screen height. (Default: 0.9)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
		offset = 0,			-- The number of degrees the compass will offset by. (Default: 0)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	},
	["pubg"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.05,	-- This value is multiplied by users screen height. (Default: 0.05)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2.5,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
		offset = 0,			-- The number of degrees the compass will offset by. (Default: 0)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	}
}
