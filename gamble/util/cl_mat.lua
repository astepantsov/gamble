GAMBLE.MAT = GAMBLE.MAT or {}
GAMBLE.MAT._cached = GAMBLE.MAT._cached or {}

file.CreateDir("gamble")
file.CreateDir("gamble/materials")

function GAMBLE.MAT.Download(key, url, callback)
	local crc = util.CRC(key)
	
	if file.Exists("gamble/materials/" .. crc .. ".png", "DATA") then
		GAMBLE.MAT._cached[key] = Material("../data/gamble/materials/" .. crc .. ".png", "smooth")
		
		if callback then
			callback(GAMBLE.MAT._cached[key])
		end
		
		return
	end

	http.Fetch(url, function(body)
		file.Write("gamble/materials/" .. crc .. ".png", body)
		
		GAMBLE.MAT._cached[key] = Material("../data/gamble/materials/" .. crc .. ".png", "smooth")
		
		if callback then
			callback(GAMBLE.MAT._cached[key])
		end
	end)
end 

function GAMBLE.MAT.GetMaterial(key)
	if GAMBLE.MAT._cached[key] then
		return GAMBLE.MAT._cached[key]
	end
	
	local crc = util.CRC(key)
	GAMBLE.MAT._cached[key] = Material("../data/gamble/materials/" .. crc .. ".png", "smooth")
	
	return GAMBLE.MAT.GetMaterial(key)
end

GAMBLE.MAT.Download("main/profile", "http://i.imgur.com/wXP6K36.png") // http://www.flaticon.com/free-icon/user-avatar_16363
GAMBLE.MAT.Download("main/games", "http://i.imgur.com/SOy3yU4.png")  // http://www.flaticon.com/free-icon/poker-full_107589
GAMBLE.MAT.Download("main/admin", "http://i.imgur.com/9wuo7vV.png") // http://www.flaticon.com/free-icon/admin-with-cogwheels_78948
GAMBLE.MAT.Download("main/top", "http://i.imgur.com/KbE2XVy.png") // http://www.flaticon.com/free-icon/first-prize-trophy_47844
GAMBLE.MAT.Download("main/info", "http://i.imgur.com/gB4xUPE.png") // http://www.flaticon.com/free-icon/round-info-button_61093
GAMBLE.MAT.Download("main/back", "http://i.imgur.com/RF3ECZg.png") // http://www.flaticon.com/free-icon/back-arrow_60577
GAMBLE.MAT.Download("main/games/blackjack", "http://i.imgur.com/uHkeG0i.png") // http://www.flaticon.com/free-icon/two-trebol-aces_75960
GAMBLE.MAT.Download("main/top/wreath", "http://i.imgur.com/mfcHNlF.png")

GAMBLE.MAT.Download("games/bugsrace", "http://i.imgur.com/nZQsuTD.png")
GAMBLE.MAT.Download("games/bugsrace/finish", "http://i.imgur.com/mvsdEKh.png")
GAMBLE.MAT.Download("games/bugsrace/bug1", "http://i.imgur.com/mISApoG.png")

GAMBLE.MAT.Download("games/jackpot", "http://i.imgur.com/MXqsUjN.png") // http://www.flaticon.com/free-icon/two-dices_14882

GAMBLE.MAT.Download("games/roulette1", "http://i.imgur.com/k37ukGv.png") // http://www.flaticon.com/free-icon/casino-roulette_82952
GAMBLE.MAT.Download("games/roulette/wheel1", "http://i.imgur.com/jd4NExO.png")
GAMBLE.MAT.Download("games/roulette/ball", "http://i.imgur.com/Q5gBfK5.png")