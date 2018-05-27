GAMBLE = GAMBLE or {CONFIG = {}, ConnectedUsers = {}}

GAMBLE._VERSION = 1 // script version (0 enables debug messages)
GAMBLE._FOLDER = "gamble" // don't change it

GAMBLE._CORE = {
	"sh_mdesign.lua",
	"sh_pon.lua", // https://github.com/thelastpenguin/gLUA-Library/blob/master/pON/pON-recommended.lua
	"sv_config.lua",
	"sh_language.lua",
	"games/sh_base.lua",
	"sv_player_extension.lua",
	"sv_connect.lua"
}  

GAMBLE._MANUAL_LOAD = {
	"util/cl_mat.lua",
	"util/sh_util.lua",
	"menu/cl_main.lua",
	"menu/main/cl_games.lua",
	"menu/main/cl_profile.lua",
	"menu/main/cl_top.lua",
	"menu/main/cl_info.lua",
	"menu/main/cl_admin.lua"
} 
  
local function LoadFileByName(name, path)
	path = path or name

	if name:match("sh_.+%.lua$") then
		if SERVER then AddCSLuaFile(path) end
		include(path)
	elseif name:match("sv_.+%.lua$") then
		if SERVER then include(path) end
	elseif name:match("cl_.+%.lua$") then
		if SERVER then AddCSLuaFile(path)
		else include(path) end
	else
		MsgC(Color(255, 0, 0), "[GAMBLE] Unknown file prefix: " .. path .. "\n")
	end
end

file.CreateDir("gamble")
file.CreateDir("gamble/users")
file.CreateDir("gamble/src")

function GAMBLE.Initialize()
	local fol = GAMBLE._FOLDER

	//LoadFileByName("sh_config.lua", fol .. "/config.lua")
	
	// first, load core files
	for k, v in ipairs(GAMBLE._CORE) do
		LoadFileByName(v, fol .. "/core/" .. v)
	end
	
	// second, load another files in manual order
	for k, v in ipairs(GAMBLE._MANUAL_LOAD) do
		LoadFileByName(v, fol .. "/" .. v)
	end
	
	// then load everything else from the directory
	local files, _ = file.Find("gamble/*", "LUA")
	for k, v in ipairs(files) do
		if v == "config.lua" then continue end
		LoadFileByName(v, "gamble/" .. v)
	end
	
	// load games at the end
	local files, _ = file.Find("gamble/games/*", "LUA")
	for k, v in ipairs(files) do
		if SERVER then
			AddCSLuaFile("gamble/games/" .. v)
		end
		
		include("gamble/games/" .. v)
		
		print("[GAMBLE] Loading Game: " .. v)
	end

end

GAMBLE.Initialize()