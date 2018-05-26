GAMBLE.ObjectToString = function(obj)
	if obj == NULL then
		return "null"
	elseif isentity(obj) then
		if obj:IsPlayer() then
			return obj:Nick() .. " [" .. obj:SteamID64() .. "]"
		else
			return obj:GetClass() .. " [" .. obj:EntIndex() .. "]"
		end
	else
		return tostring(obj)
	end
end

GAMBLE.FormatString = function(str, ...)
	for k, v in ipairs({...}) do
		str = str:Replace("{" .. k .. "}", GAMBLE.ObjectToString(v))
	end

	return str
end

GAMBLE.MaxLength = function(str, maxlen)
	if string.len(str) > maxlen then
		return string.sub(str, 1, maxlen - 2) .. "...";
	else
		return str;
	end
end