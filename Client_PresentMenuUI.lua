require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(320,205)
	Game = game; --make it globally accessible

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Us ~= nil) then --don't show declare button to spectators
		UI.CreateButton(vert).SetColor("#123456").SetText("Declare War").SetPreferredWidth(200).SetFlexibleWidth(0).SetOnClick(function()
			game.CreateDialog(DeclareWarDialog);
		end);
		UI.CreateButton(vert).SetColor("#123456").SetText("Offer Peace").SetPreferredWidth(200).SetFlexibleWidth(0).SetOnClick(function()
			game.CreateDialog(OfferPeaceDialog);
		end);
		UI.CreateButton(vert).SetColor("#123456").SetText("Propose Alliance").SetPreferredWidth(200).SetFlexibleWidth(0).SetOnClick(function()
			game.CreateDialog(DeclareWarDialog);
		end);
	end
end

function DeclareWarDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(390, 217);
	WarTargetPlayerID = nil;

	local wars = Mod.PublicGameData.Wars or {};

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Declare war against: ");
	WarTargetPlayerBtn = UI.CreateButton(row1).SetColor("#00ff00").SetText("Select Player").SetFlexibleWidth(1).SetOnClick(WarTargetPlayerClicked);
	UI.CreateLabel(vert).SetText(' \n ');
	UI.CreateButton(vert).SetColor("#123456").SetText("Declare War").SetFlexibleWidth(1).SetOnClick(function() 

		if (WarTargetPlayerID == nil) then
			UI.Alert("Please choose a player first.");
			return;
		end

		local payload = {};
		payload.Message = "Declare War";
		payload.WarTargetPlayerID = WarTargetPlayerID;

		Game.SendGameCustomMessage("Declaring war...", payload, function(returnValue) 
			UI.Alert("A declaration of war will be added to your orders.");
			close(); --Close the propose dialog since we're done with it
		end);
	end);

	if (#wars > 0) then
		UI.CreateLabel(vert).SetText(' ');
		for _,war in pairs(wars) do
			if game.Game.NumberOfTurns >= war.BeginsOnTurn then
				local playerOne = game.Game.Players[war.PlayerOne].DisplayName(nil, false);
				local playerTwo = game.Game.Players[war.PlayerTwo].DisplayName(nil, false);
				UI.CreateLabel(vert).SetText(playerOne .. ' and ' .. playerTwo .. ' are at war.');
			end
		end
	end	

end

function OfferPeaceDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(390, 217);
	PeaceTargetPlayerID = nil;

	local peaceoffers = Mod.PublicGameData.PeaceOffers or {};

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Offer peace to this player: ");
	PeaceTargetPlayerBtn = UI.CreateButton(row1).SetColor("#00ff00").SetText("Select Player").SetFlexibleWidth(1).SetOnClick(PeaceTargetPlayerClicked);
	UI.CreateLabel(vert).SetText(' \n ');
	UI.CreateButton(vert).SetColor("#123456").SetText("Offer Peace").SetFlexibleWidth(1).SetOnClick(function()

		if (PeaceTargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end

		local payload = {};
		payload.Message = "Offer Peace";
		payload.PeaceTargetPlayerID = PeaceTargetPlayerID;

		Game.SendGameCustomMessage("Offering peace...", payload, function(returnValue) 
			UI.Alert("Peace offer sent!");
			close(); --Close the propose dialog since we're done with it
		end);
	end);
--BELOW IS TEMPORARY-- checking peace offers are INDEED being written to publicgamedata in server_customgamemessage
	if (#peaceoffers > 0) then
		UI.CreateLabel(vert).SetText(' ');
		for _,peaceoffer in pairs(peaceoffers) do
			local playerOne = game.Game.Players[peaceoffer.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[peaceoffer.PlayerTwo].DisplayName(nil, false);
			UI.CreateLabel(vert).SetText(playerOne .. ' offered peace to ' .. playerTwo .. '.');
		end
	end

end

function WarTargetPlayerClicked()
	local options = map(filter(Game.Game.Players, IsPotentialWarTarget), WarPlayerButton);
	UI.PromptFromList("Select a player to declare war upon", options);
end

function PeaceTargetPlayerClicked()
	local options = map(filter(Game.Game.Players, IsPotentialPeaceTarget), PeacePlayerButton);
	UI.PromptFromList("Select a player to offer peace to", options);
end

--Determines if the player is one we can declare war on.
function IsPotentialWarTarget(player)
	if (Game.Us.ID == player.ID) then return false end; -- we can never declare war on ourselves.

	local wars = Mod.PublicGameData.Wars or {};
	
	for _,war in pairs(wars) do
			if (Game.Us.ID == war.PlayerOne and war.PlayerTwo == player.ID)
			or (Game.Us.ID == war.PlayerTwo and war.PlayerOne == player.ID) then return false end;
			-- we cannot declare war against someone we are already at war with
	end

	if (Game.Settings.SinglePlayer) then return true end; --in single player, allow declaring on everyone
	if (Game.Settings.MultiPlayer) then return true end; --in multiplayer, allow declaring on everyone

end

--Determines if the player is one we can offer peace to.
function IsPotentialPeaceTarget(player)

	local wars = Mod.PublicGameData.Wars or {};
	
	for _,war in pairs(wars) do
		if (Game.Us.ID == war.PlayerOne and war.PlayerTwo == player.ID)
		or (Game.Us.ID == war.PlayerTwo and war.PlayerOne == player.ID) then return true end;
		-- we can only offer peace to someone we at war with
	end

end

function WarPlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		WarTargetPlayerBtn.SetText(name);
		WarTargetPlayerID = player.ID;
	end
	return ret;
end

function PeacePlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		PeaceTargetPlayerBtn.SetText(name);
		PeaceTargetPlayerID = player.ID;
	end
	return ret;
end