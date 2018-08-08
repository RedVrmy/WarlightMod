require('Utilities');

WarIDsSeen = {}; --remembers what war IDs we've alerted the player about so we don't alert them twice.
PeaceOfferIDsSeen = {}; --remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.

function Client_GameRefresh(game)

    --Notify players of new wars via UI.Alert()
    local unseenWars = filter(Mod.PublicGameData.Wars or {}, function(war) return WarIDsSeen[war.ID] == nil end);
    if (#unseenWars > 0) then
        for _,war in pairs(unseenWars) do
            WarIDsSeen[war.ID] = true;
        end

        local msgs = map(unseenWars, function(war)
            local playerOne = game.Game.Players[war.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[war.PlayerTwo].DisplayName(nil, false);
			return playerOne .. ' has declared war on ' .. playerTwo .. '!';
        end);
        local finalMsg = table.concat(msgs, '\n');
        UI.Alert(finalMsg);
    end

    --Check for proposals we haven't alerted the player about yet
    for _,peaceoffer in pairs(filter(Mod.PlayerGameData.PendingPeaceOffers or {}, function(peaceoffer) return PeaceOfferIDsSeen[peaceoffer.ID] == nil end)) do
        local otherPlayer = game.Game.Players[peaceoffer.PlayerOne].DisplayName(nil, false);
        UI.PromptFromList(otherPlayer .. ' has offered peace. Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });

        IDsSeen[proposal.ID] = true;
    end
    
end