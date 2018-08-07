require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
    if (payload.Message == "Declare War") then
		--Create the war
		local war = {};
		war.ID = math.random(2000000000);
		war.PlayerOne = playerID;
		war.PlayerTwo = payload.WarTargetPlayerID;
		war.BeginsOnTurn = game.Game.TurnNumber + 1

		--Write it into Mod.PublicGameData for all to see
		local data = Mod.PublicGameData;
		local wars = data.Wars or {};
		table.insert(wars, 1, war);
		data.Wars = wars;
		Mod.PublicGameData = data;
		
	elseif (payload.Message == "Offer Peace") then
		--Create a peace offer
		local peaceoffer = {};
		peaceoffer.ID = math.random(2000000000);
		peaceoffer.PlayerOne = playerID;
		peaceoffer.PlayerTwo = payload.PeaceTargetPlayerID;

		--Write it into Mod.PublicGameData for all to see
		local data = Mod.PublicGameData;
		local peaceoffers = data.PeaceOffers or {};
		table.insert(peaceoffers, 1, peaceoffer);
		data.PeaceOffers = peaceoffers;
		Mod.PublicGameData = data;		

		if (game.Settings.SinglePlayer) then
			--In single-player, just auto-accept proposals for testing.
			PeaceOfferAccepted(peaceoffer, game);
		else
			--Write it into the player-specific data
			local playerData = Mod.PlayerGameData;
			if (playerData[payload.PeaceTargetPlayerID] == nil) then
				playerData[payload.PeaceTargetPlayerID] = {};
			end

			local pendingPeaceOffers = playerData[payload.PeaceTargetPlayerID].PendingPeaceOffers or {};
			table.insert(pendingPeaceOffers, peaceoffer);
			playerData[payload.PeaceTargetPlayerID].PendingPeaceOffers = pendingPeaceOffers;
			Mod.PlayerGameData = playerData;
		end
	elseif (payload.Message == "AcceptPeaceOffer" or payload.Message == "DeclinePeaceOffer") then
		local peaceoffer = first(Mod.PlayerGameData[playerID].PendingPeaceOffers, function(po) return po.ID == payload.PeaceOfferID end);

		if (peaceoffer == nil) then error("Peace Offer with ID " .. payload.PeaceOfferID .. ' not found') end;

		--Remove it from PlayerGameData
		local pgd = Mod.PlayerGameData;
		pgd[playerID].PendingPeaceOffers = filter(pgd[playerID].PendingPeaceOffers, function(po) return po.ID ~= payload.PeaceOfferID end);
		Mod.PlayerGameData = pgd;

		--If we're accepting it, call PeaceOfferAccepted. If we're declining it, just do nothing and let it be removed.
		if (payload.Message == "AcceptPeaceOffer") then
			PeaceOfferAccepted(peaceoffer, game);
		end
	else
		error("Payload message not understood: " .. payload.Message);
	end

end

function PeaceOfferAccepted(peaceoffer, game)

	--NEED TO REMOVE THE WAR FROM MOD.PUBLICGAMEDATA--

	local P1 = peaceoffer.PlayerOne;
	local P2 = peaceoffer.PlayerTwo;
	local wars = Mod.PublicGameData.Wars or {};

	for k,war in pairs(wars) do --find key in table(wars) corresponding to the former war now at peace
		if (war.PlayerOne == P1 and war.PlayerTwo == P2)
		or (war.PlayerOne == P2 and war.PlayerTwo == P1) then

		local data = Mod.PublicGameData;
		local wars = data.Wars or {};
		table.remove(wars, k);
		data.Wars = wars;
		Mod.PublicGameData = data;
		end
	end
end