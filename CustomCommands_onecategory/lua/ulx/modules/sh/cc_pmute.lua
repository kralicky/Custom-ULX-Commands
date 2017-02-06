--[[-------------------------------------------------
	Created by iViscosity for CustomCommands addon.
		Based on Cobalt's 'pgag'
-----------------------------------------------------]]

function ulx.pmute( calling_ply, target_plys, should_unpmute )

	if should_unpmute then
	
		for k,v in pairs( target_plys ) do
	
			v:RemovePData( "permmuted" )
		
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A un-permamuted #T ", target_plys )
		
	elseif ( not should_unpmute ) then 
		
		for k,v in pairs( target_plys ) do
	
			v:SetPData( "permmuted", "true" )
		
		end
	
		ulx.fancyLogAdmin( calling_ply, "#A permanently muted #T", target_plys )
		
	end

end
local pmute = ulx.command( "Custom", "ulx pmute", ulx.pmute, "!pmute" )
pmute:addParam{ type=ULib.cmds.PlayersArg }
pmute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmute:defaultAccess( ULib.ACCESS_ADMIN )
pmute:help( "Mute target(s), disables chat using pdata." )
pmute:setOpposite( "ulx unpmute", { _, _, true }, "!unpmute" )

function pmuteHook( text, team, listener, speaker )

	if speaker:GetPData( "permmuted" ) == "true" then
	
		-- ULib.tsayError( speaker, "You are permanently muted and cannot speak, please ask an Admin (@) to unpmute you." )
		return false
		
	end
	
end
hook.Add( "PlayerCanSeePlayersChat", "pdatamute", pmuteHook )

---- functions to check if players are muted upon them leaving and joining ----
function pmutePlayerDisconnect( ply )

	if ply:GetPData( "permmuted" ) == "true" then
	
		for k,v in pairs( player.GetAll() ) do
		
			if v:CheckGroup( "trial" ) then -- This will error if your server does not have a "trial" group. Change to your liking.
			
				ULib.tsayError( v, ply:Nick() .. " has left the server and is permanently muted." )
				
			end	
			
		end
		
	end
	
end
hook.Add( "PlayerDisconnected", "pmutedisconnect", pmutePlayerDisconnect )

function pmuteuserAuthed( ply )

	if ply:GetPData( "permmuted" ) == "true" then
	
		for k,v in pairs( player.GetAll() ) do
		
			if v:CheckGroup( "trial" ) then -- This will error if your server does not have a "trial" group. Change to your liking.
			
				ULib.tsayError( v, ply:Nick() .. " has joined and is permanently muted." )
				
			end
			
		end
		
	end
	
end
hook.Add( "PlayerAuthed", "pmuteauthed", pmuteuserAuthed )

---- function to list players who are pmuted ----
function ulx.printpmutes( calling_ply )

	pmuted = {}
	
	for k,v in pairs( player.GetAll() ) do
	
		if v:GetPData( "permmuted" ) == "true" then -- find all players who have "muted" set to true
		
			table.insert( pmuted, v:Nick() )
			
		end
		
	end
	
	local pmutes = table.concat(  pmuted, ", " ) -- concatenate each player in the table with a comma
	
	ulx.fancyLog( { calling_ply }, "pmuted: #s ", pmutes ) -- only prints this to the player who called the function
	
end
local printpmutes = ulx.command( "Custom", "ulx printpmutes", ulx.printpmutes, "!printpmutes", true )
printpmutes:defaultAccess( ULib.ACCESS_ADMIN )
printpmutes:help( "Prints players who are pmuted." )
