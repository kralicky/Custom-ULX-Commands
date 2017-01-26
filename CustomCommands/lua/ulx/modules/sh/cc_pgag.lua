----------------------------------------
--  This file holds the PGag command  --
----------------------------------------

function ulx.pgag( calling_ply, target_plys, should_unpgag )

	if should_unpgag then
	
		for k,v in pairs( target_plys ) do
	
			v:RemovePData( "permgagged" )
			
			v.perma_gagged = false
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A un-permagagged #T ", target_plys )
		
	elseif ( not should_unpgag ) then 
		
		for k,v in pairs( target_plys ) do
	
			v:SetPData( "permgagged", "true" )
			
			v.perma_gagged = true
		end
	
		ulx.fancyLogAdmin( calling_ply, "#A permanently gagged #T", target_plys )
		
	end
	

	
end
local pgag = ulx.command( "Chat", "ulx pgag", ulx.pgag, "!pgag" )
pgag:addParam{ type=ULib.cmds.PlayersArg }
pgag:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pgag:defaultAccess( ULib.ACCESS_ADMIN )
pgag:help( "Gag target(s), disables microphone using pdata." )
pgag:setOpposite( "ulx unpgag", { _, _, true }, "!unpgag" )

local function pgagHook( listener, talker )

	if talker.perma_gagged == true then
	
		return false
		
	end
	
end
hook.Add( "PlayerCanHearPlayersVoice", "pdatagag", pgagHook )

---- functions to check if players are gagged upon them leaving and joining ----
function pgagPlayerDisconnect( ply )

	if ply:GetPData( "permgagged" ) == "true" then
	
		for k,v in pairs( player.GetAll() ) do
		
			if v:IsAdmin() then
			
				ULib.tsayError( v, ply:Nick() .. " has left the server and is permanently gagged." )
				
			end	
			
		end
		
	end
	
end
hook.Add( "PlayerDisconnected", "pgagdisconnect", pgagPlayerDisconnect )

function pgaguserAuthed( ply )
	
	local pdata = ply:GetPData( "permgagged" )
	
	if  pdata == "true" then
		
		ply.perma_gagged = true
		
		for k,v in pairs( player.GetAll() ) do
		
			if v:IsAdmin() then
			
				ULib.tsayError( v, ply:Nick() .. " has joined and is permanently gagged." )
				
			end
			
		end
		
	else 
		
		ply.perma_gagged = false	
		
	end
	
end
hook.Add( "PlayerAuthed", "pgagauthed", pgaguserAuthed )

---- function to list players who are pgagged ----
function ulx.printpgags( calling_ply )

	pgagged = {}
	
	for k,v in pairs( player.GetAll() ) do
	
		if v:GetPData( "permgagged" ) == "true" then -- find all players who have "gagged" set to true
		
			table.insert( pgagged, v:Nick() )
			
		end
		
	end
	
	local pgags = table.concat(  pgagged, ", " ) -- concatenate each player in the table with a comma
	
	ulx.fancyLog( {calling_ply}, "PGagged: #s ", pgags ) -- only prints this to the player who called the function
	
end
local printpgags = ulx.command( "Chat", "ulx printpgags", ulx.printpgags, "!printpgags", true )
printpgags:defaultAccess( ULib.ACCESS_ADMIN )
printpgags:help( "Prints players who are pgagged." )
