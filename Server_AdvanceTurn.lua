require('Utilities');

OrdersSeen = {}; --remembers what Delcaration Orders we've alerted the player about so we don't alert them twice.

function Server_AdvanceTurn_Start (game,addNewOrder)
	--Check for declarations we haven't alerted the player about yet
    for _,war in pairs(filter(Mod.PublicGameData.Wars or {}, function(war) return OrdersSeen[war.ID] == nil end)) do
        local playerOne = game.Game.Players[war.PlayerOne].DisplayName(nil, false);
		local playerTwo = game.Game.Players[war.PlayerTwo].DisplayName(nil, false);
        addNewOrder(WL.GameOrderEvent.Create(war.PlayerOne, playerOne .. ' declared war on ' .. playerTwo, nil,{}));

        OrdersSeen[war.ID] = true;
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		--Check if the players are at war
		if (game.ServerGame.PreviousTurnStanding.Territories[order.To].OwnerPlayerID == WL.PlayerID.Neutral) then
			skipThisOrder(WL.ModOrderControl.Keep);
		else
			if (PlayersAreAtWar(game, game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID)) then
				skipThisOrder(WL.ModOrderControl.Keep);
			else
				skipThisOrder(WL.ModOrderControl.Skip);
			end
		end	
	end
end

function PlayersAreAtWar(game, playerOne, playerTwo)
	if (playerOne == playerTwo) then return false end; --never at war with yourself.

	return first(Mod.PublicGameData.Wars or {}, function(war) 
		return (war.PlayerOne == playerOne and war.PlayerTwo == playerTwo and war.BeginsOnTurn <= game.Game.NumberOfTurns)
			or (war.PlayerOne == playerTwo and war.PlayerTwo == playerOne and war.BeginsOnTurn <= game.Game.NumberOfTurns);
		end
	) ~= nil;
end