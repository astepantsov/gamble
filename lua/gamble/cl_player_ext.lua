GAMBLE.GetCredits = function()
	return GAMBLE.Client.credits
end

GAMBLE.CanAfford = function(value)
	return GAMBLE.GetCredits() >= value
end