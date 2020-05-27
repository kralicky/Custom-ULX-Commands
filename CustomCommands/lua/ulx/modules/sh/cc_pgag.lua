----------------------------------------
--  This file holds the PGag command  --
----------------------------------------

function ulx.pgag( calling_ply, target_plys, should_ungag )
	if should_ungag then
		for k,v in pairs(target_plys) do
			v:RemovePData("permgagged")
			v.perma_gagged = false
			v:SetNWBool("perma_gagged", v.perma_gagged)
		end
		
		ulx.fancyLogAdmin(calling_ply, "#A un-permagagged #T ", target_plys)
	else
		for k,v in pairs(target_plys) do
			v:SetPData("permgagged", "true")
			v.perma_gagged = true
			v:SetNWBool("perma_gagged", v.perma_gagged)
		end

		ulx.fancyLogAdmin(calling_ply, "#A permanently gagged #T", target_plys)
	end
end

local pgag = ulx.command( "Chat", "ulx pgag", ulx.pgag, "!pgag" )
pgag:addParam{ type=ULib.cmds.PlayersArg }
pgag:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pgag:defaultAccess( ULib.ACCESS_ADMIN )
pgag:help( "Gag target(s), disables microphone using pdata." )
pgag:setOpposite( "ulx unpgag", { _, _, true }, "!unpgag" )



function ulx.pgagid(calling_ply, steamID, should_unpgag)
	if should_unpgag then
		util.RemovePData(steamID, "permgagged")

		local ply = player.GetBySteamID(steamID)
		if(ply) then
			ply.perma_gagged = false
			ply:SetNWBool("perma_gagged", ply.perma_gagged)
		end

		ulx.fancyLogAdmin(calling_ply, "#A un-permagagged #s", steamID)
	else
		util.SetPData(steamID, "permgagged", "true")

		local ply = player.GetBySteamID(steamID)
		if(ply) then
			ply.perma_gagged = true
			ply:SetNWBool("perma_gagged", ply.perma_gagged)
		end

		ulx.fancyLogAdmin(calling_ply, "#A permanently gagged #s", steamID)
	end
end

local pgagid = ulx.command( "Chat", "ulx pgagid", ulx.pgagid, "!pgagid" )
pgagid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
pgagid:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pgagid:defaultAccess( ULib.ACCESS_ADMIN )
pgagid:help("Permanently gag target Steam ID, disabling their microphone.")
pgagid:setOpposite("ulx unpgagid", { _, _, true }, "!unpgagid")



if SERVER then
	hook.Remove("PlayerCanHearPlayersVoice", "CustomULXCommands_PGag_PlayerCanHearPlayersVoice")
	hook.Add("PlayerCanHearPlayersVoice", "CustomULXCommands_PGag_PlayerCanHearPlayersVoice", function(listener, talker)
		if talker.perma_gagged == true then
			return false
		end
	end)
end

if CLIENT then
	local lastGagNotifTime = -1

	hook.Remove("PlayerStartVoice", "CustomULXCommands_PGag_PlayerStartVoice")
	hook.Add("PlayerStartVoice", "CustomULXCommands_PGag_PlayerStartVoice", function(ply)
		if ply:GetNWBool("perma_gagged") || ply:GetNWBool("ulx_gagged") then
			if(lastGagNotifTime + 10 < CurTime()) then
				ULib.csay(ply, "You are gagged. No-one can hear you!", nil, 3)
				lastGagNotifTime = CurTime()
			end
		end
	end)
end



hook.Remove("PlayerDisconnected", "CustomULXCommands_PGag_PlayerDisconnected")
hook.Add("PlayerDisconnected", "CustomULXCommands_PGag_PlayerDisconnected", function(ply)
	if ply.perma_gagged then
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has left the server and is permanently gagged.")
			end	
		end
	end
end)


hook.Remove("PlayerAuthed", "CustomULXCommands_PGag_PlayerConnected")
hook.Add("PlayerAuthed", "CustomULXCommands_PGag_PlayerConnected", function(ply)
	if ply:GetPData("permgagged") == "true" then
		ply.perma_gagged = true
		ply:SetNWBool("perma_gagged", ply.perma_gagged)
		
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has joined and is permanently gagged.")
			end
		end
	else 
		ply.perma_gagged = false
		ply:SetNWBool("perma_gagged", ply.perma_gagged)
	end
end)




function ulx.printpgags(calling_ply)
	local permanentlyGaggedPlayers = {}
	
	for k,v in pairs(player.GetHumans()) do
		if v.perma_gagged then
			table.insert(permanentlyGaggedPlayers, v:Nick())
		end
	end
	
	local message = table.concat(permanentlyGaggedPlayers, ", ")
	ulx.fancyLog({calling_ply}, "PGagged: #s", message)
end


local printpgags = ulx.command( "Chat", "ulx printpgags", ulx.printpgags, "!printpgags", true )
printpgags:defaultAccess( ULib.ACCESS_ADMIN )
printpgags:help("Lists any players connected to the server who are permanently gagged.")
