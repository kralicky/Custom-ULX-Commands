----------------------------------------
--  This file holds the PMute command  --
----------------------------------------

function ulx.pmute(calling_ply, target_plys, should_unmute)
	if should_unpmute then
		for k,v in pairs(target_plys) do
			v:RemovePData("permmuted")
			v.perma_muted = false
		end

		ulx.fancyLogAdmin(calling_ply, "#A removed the permanent mute for #T ", target_plys)
	else
		for k,v in pairs(target_plys) do
			v:SetPData("permmuted", "true")
			v.perma_muted = true
		end

		ulx.fancyLogAdmin(calling_ply, "#A permanently muted #T", target_plys)
	end
end


local pmute = ulx.command("Chat", "ulx pmute", ulx.pmute, "!pmute")
pmute:addParam{ type=ULib.cmds.PlayersArg }
pmute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmute:defaultAccess(ULib.ACCESS_ADMIN)
pmute:help("Prevents the player from typing in chat, even after reconnecting.")
pmute:setOpposite("ulx unpmute", { _, _, true }, "!unpmute")




function ulx.pmuteid(calling_ply, steamID, should_unmute)
	if should_unmute then
		util.RemovePData(steamID, "permmuted")

		local ply = player.GetBySteamID(steamID)
		if(ply) then
			ply.perma_muted = false
		end

		ulx.fancyLogAdmin(calling_ply, "#A removed the permanent mute for #s", steamID)
	else
		util.SetPData(steamID, "permmuted", "true")
		local ply = player.GetBySteamID(steamID)
		if(ply) then
			ply.perma_muted = true
		end

		ulx.fancyLogAdmin(calling_ply, "#A permanently muted #s", steamID)
	end
end

local pmuteid = ulx.command("Chat", "ulx pmuteid", ulx.pmuteid, "!pmuteid")
pmuteid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
pmuteid:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmuteid:defaultAccess( ULib.ACCESS_ADMIN )
pmute:help("Prevents the player from typing in chat, even after reconnecting.")
pmuteid:setOpposite("ulx unpmuteid", { _, _, true }, "!unpmuteid")



if SERVER then
	hook.Remove("PlayerSay", "CustomULXCommands_PMute_PlayerSay")
	hook.Add("PlayerSay", "CustomULXCommands_PMute_PlayerSay", function(ply, text, isTeamChat)
		if(ply.perma_muted) then return "" end
	end)
end



hook.Remove("PlayerDisconnected", "CustomULXCommands_PMute_PlayerDisconnected")
hook.Add("PlayerDisconnected", "CustomULXCommands_PMute_PlayerDisconnected", function(ply)
	if ply.perma_muted then
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has left the server and is permanently muted.")
			end
		end
	end
end)


hook.Remove("PlayerAuthed", "CustomULXCommands_PMute_PlayerConnected")
hook.Add("PlayerAuthed", "CustomULXCommands_PMute_PlayerConnected", function(ply)
	local isPlayerPermanentlyMuted = ply:GetPData("permmuted")
	if isPlayerPermanentlyMuted == "true" then
		ply.perma_muted = true

		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has joined and is permanently muted.")
			end
		end
	else
		ply.perma_muted = false
	end
end)



function ulx.printpmutes(calling_ply)
	local permanentlyMutedPlayers = {}

	for k,v in pairs(player.GetHumans()) do
		if v.perma_muted then
			table.insert(permanentlyMutedPlayers, v:Nick())
		end
	end

	local message = table.concat(permanentlyMutedPlayers, ", ")
	ulx.fancyLog({calling_ply}, "PMuted: #s ", message)
end

local printpmutes = ulx.command("Chat", "ulx printpmutes", ulx.printpmutes, "!printpmutes", true)
printpmutes:defaultAccess( ULib.ACCESS_ADMIN )
printpmutes:help("Lists any players connected to the server who are permanently muted.")
