GAMBLE.LANG = GAMBLE.LANG or {_List = {}}

if SERVER then 
	GAMBLE.CFG.CreateField("language", "shared", "English") 
	GAMBLE.CFG.CreateField("gamble_currency", "shared", "CR") 
end

GAMBLE.LANG.RegisterLanguage = function(name)
	GAMBLE.LANG._List[name] = {}

	return GAMBLE.LANG._List[name]
end

GAMBLE.LANG.GetActiveLanguage = function()
	if SERVER then
		return GAMBLE.CFG.GetValue("language")
	else
		return GAMBLE.CONFIG.language or "English"
	end
end

GAMBLE.LANG.GetString = function(id)
	local lang = GAMBLE.LANG.GetActiveLanguage()

	return (GAMBLE.LANG._List[lang] and GAMBLE.LANG._List[lang][id]) or "..."
end

GAMBLE.LANG.FormatString = function(id, ...)
	local lang = GAMBLE.LANG.GetActiveLanguage()
	local str = (GAMBLE.LANG._List[lang] and GAMBLE.LANG._List[lang][id]) or "..."

	for k, v in ipairs({...}) do
		str = str:Replace("{" .. k .. "}", tostring(v))
	end

	return str
end

local files, _ = file.Find("gamble/lang/*", "LUA")

for k, v in ipairs(files) do
	local path = "gamble/lang/" .. v 
	if SERVER then AddCSLuaFile(path) end
	include(path)
end  