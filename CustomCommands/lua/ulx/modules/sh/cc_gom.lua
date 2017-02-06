--[[
  	Created by iViscosity for the CustomCommands addon
	Future plans:
		- Add support to target a specific player.
]]

function ulx.gom( calling_ply )
	
	-- Set up the original tables
	local mute = {}
	local gag = {}
	local both = {}
  
	-- Grab all the users who are gagged or muted, then put them in the respective table
	for _, v in pairs( player.GetAll() ) do
		
		if v:GetNWBool( "ulx_gagged", false ) and v:GetNWBool( "ulx_muted", false ) then -- These are used in the "chat.lua" of your main ULX folder.
			
			table.insert( both, v:Nick() )
			
		elseif v:GetNWBool( "ulx_muted", false ) then
			
			table.insert( mute, v:Nick() )

		elseif v:GetNWBool( "ulx_gagged", false ) then

			table.insert( gag, v:Nick() )
			
		end
		
	end
	
	-- Concatenate the tabes with a comma in-between the names.
	local mutes = table.concat( mute, ", " )
	local gags = table.concat( gag, ", " )
	local boths = table.concat( both, ", " )
			
	-- Finally, display all the muted and gagged players.
	ulx.fancyLog( { calling_ply }, "Gagged and Muted: #s", boths )
	ulx.fancyLog( { calling_ply }, "Muted: #s", mutes )
	ulx.fancyLog( { calling_ply }, "Gagged: #s", gags )
	
end
local gom = ulx.command( "Chat", "ulx gom", ulx.gom, "!gom" )
gom:defaultAccess( ULib.ACCESS_OPERATOR )
gom:help( "Returns a list of gagged and muted players." )
