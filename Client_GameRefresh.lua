require('Utilities');

WarIDsSeen = {}; --remembers what war IDs we've alerted the player about so we don't alert them twice.
PeaceOfferIDsSeen = {}; --remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.

function Client_GameRefresh(game)

    --Check for proposals we haven't alerted the player about yet
    for _,peaceoffer in pairs(filter(Mod.PlayerGameData.PendingPeaceOffers or {}, function(peaceoffer) return PeaceOfferIDsSeen[peaceoffer.ID] == nil end)) do
        local otherPlayer = game.Game.Players[peaceoffer.PlayerOne].DisplayName(nil, false);
        UI.PromptFromList(otherPlayer .. ' has offered peace. Do you accept?', { AcceptPeaceOfferBtn(game, peaceoffer), DeclinePeaceOfferBtn(game, peaceoffer) });

        PeaceOfferIDsSeen[peaceoffer.ID] = true;
    end
end


function AcceptPeaceOfferBtn(game, peaceoffer)
	local ret = {};
	ret["text"] = 'Accept';
	ret["selected"] = function() 
        local payload = {};
        payload.Message = "AcceptPeaceOffer";
        payload.PeaceOfferID = peaceoffer.ID;
		game.SendGameCustomMessage('Accepting peace offer...', payload, function(returnValue) end);
	end
	return ret;
end


function DeclinePeaceOfferBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Decline';
	ret["selected"] = function() 
        local payload = {};
        payload.Message = "DeclinePeaceOffer";
        payload.PeaceOfferID = peaceoffer.ID;
		game.SendGameCustomMessage('Declining peace offer...', payload, function(returnValue) end);
	end
	return ret;
end