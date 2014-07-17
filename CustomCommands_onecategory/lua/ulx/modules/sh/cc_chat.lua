-------------------------------------
--  This file holds chat commands  --
-------------------------------------

ulx_tsay_color_table = { "black", "white", "red", "blue", "green", "orange", "purple", "pink", "gray", "yellow" }

function ulx.tsaycolor( calling_ply, message, color )
	
		local pink = Color( 255, 0, 97 )
		
		local white = Color( 255, 255, 255 )
		
		local black = Color( 0, 0, 0 )
		
		local red = Color( 255, 0, 0 )
		
		local blue = Color( 0, 0, 255 )
		
		local green = Color( 0, 255, 0 )
		
		local orange = Color( 255, 127, 0 )
		
		local purple = Color( 51, 0, 102 )
		
		local gray = Color( 96, 96, 96 )
		
		local grey = Color( 96, 96, 96 )
		
		local maroon = Color( 128, 0, 0 )
		
		local yellow = Color( 255, 255, 0 )

	
	if color == "pink" then
	
		ULib.tsayColor( nil, false, pink, message )
	
	elseif color == "white" then
	
		ULib.tsayColor( nil, false, white, message )

	elseif color == "black" then
	
		ULib.tsayColor( nil, false, black, message )
	
	elseif color == "red" then
	
		ULib.tsayColor( nil, false, red, message )

	elseif color == "blue" then
	
		ULib.tsayColor( nil, false, blue, message )
	
	elseif color == "green" then
	
		ULib.tsayColor( nil, false, green, message )

	elseif color == "orange" then
	
		ULib.tsayColor( nil, false, orange, message )
	
	elseif color == "purple" then
	
		ULib.tsayColor( nil, false, purple, message )

	elseif color == "gray" then
	
		ULib.tsayColor( nil, false, gray, message )
	
	elseif color == "grey" then
	
		ULib.tsayColor( nil, false, grey, message )

	elseif color == "maroon" then
	
		ULib.tsayColor( nil, false, maroon, message )
	
	elseif color == "yellow" then
	
		ULib.tsayColor( nil, false, yellow, message )	

	elseif color == "default" then
	
		ULib.tsay( nil, message )

	end

	if util.tobool( GetConVarNumber( "ulx_logChat" ) ) then
	
		ulx.logString( string.format( "(tsay from %s) %s", calling_ply:IsValid() and calling_ply:Nick() or "Console", message ) )
		
	end
	
end
local tsaycolor = ulx.command( "Custom", "ulx tsaycolor", ulx.tsaycolor, "!color", true, true )
tsaycolor:addParam{ type=ULib.cmds.StringArg, hint="message" }
tsaycolor:addParam{ type=ULib.cmds.StringArg, hint="color", completes=ulx_tsay_color_table, ULib.cmds.restrictToCompletes } -- only allows values in that table
tsaycolor:defaultAccess( ULib.ACCESS_ADMIN )
tsaycolor:help( "Send a message to everyone in the chat box with color." )

local seesasayAccess = "ulx seesasay"

if SERVER then ULib.ucl.registerAccess( seesasayAccess, ULib.ACCESS_SUPERADMIN, "Ability to see 'ulx sasay'", "Other" ) end

function ulx.sasay( calling_ply, message )

	local format
	
	local me = "/me "
	
	if message:sub( 1, me:len() ) == me then
	
		format = "(SUPERADMINS) *** #P #s"
		
		message = message:sub( me:len() + 1 )
		
	else
	
		format = "#P to superadmins: #s"
		
	end

	local players = player.GetAll()
	
	for i=#players, 1, -1 do
	
		local v = players[ i ]
		
		if not ULib.ucl.query( v, seesasayAccess ) and v ~= calling_ply then 
		
			table.remove( players, i )
			
		end
		
	end

	ulx.fancyLog( players, format, calling_ply, message )
	
end
local sasay = ulx.command( "Custom", "ulx sasay", ulx.sasay, "$", true, true )
sasay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
sasay:defaultAccess( ULib.ACCESS_SUPERADMIN )
sasay:help( "Send a message to currently connected superadmins." )

ulx_csay_color_table = { "black", "white", "red", "blue", "green", "orange", "purple", "pink", "gray", "yellow" }

function ulx.csaycolor( calling_ply, message, color )
	
		local pink = Color( 255, 0, 97 )
		
		local white = Color( 255, 255, 255 )
		
		local black = Color( 0, 0, 0 )
		
		local red = Color( 255, 0, 0 )
		
		local blue = Color( 0, 0, 255 )
		
		local green = Color( 0, 255, 0 )
		
		local orange = Color( 255, 127, 0 )
		
		local purple = Color( 51, 0, 102 )
		
		local gray = Color( 96, 96, 96 )
		
		local grey = Color( 96, 96, 96 )
		
		local maroon = Color( 128, 0, 0 )
		
		local yellow = Color( 255, 255, 0 )
	
	if color == "pink" then
	
		ULib.csay( nil, message, pink )
	
	elseif color == "white" then
	
		ULib.csay( nil, message, white )

	elseif color == "black" then
	
		ULib.csay( nil, message, black )
	
	elseif color == "red" then
	
		ULib.csay( nil, message, red )

	elseif color == "blue" then
	
		ULib.csay( nil, message, blue )
	
	elseif color == "green" then
	
		ULib.csay( nil, message, green )

	elseif color == "orange" then
	
		ULib.csay( nil, message, orange )
	
	elseif color == "purple" then
	
		ULib.csay( nil, message, purple )

	elseif color == "gray" then
	
		ULib.csay( nil, message, gray )
	
	elseif color == "grey" then
	
		ULib.csay( nil, message, grey )

	elseif color == "maroon" then
	
		ULib.csay( nil, message, maroon )
	
	elseif color == "yellow" then
	
		ULib.csay( nil, message, yellow )	

	elseif color == "color" then
	
		ULib.csay( nil, message )
		
	end
	
end
local csaycolor = ulx.command( "Custom", "ulx csaycolor", ulx.csaycolor, {"!csaycolor", "!ccolor"}, true, true )
csaycolor:addParam{ type=ULib.cmds.StringArg, hint="message" }
csaycolor:addParam{ type=ULib.cmds.StringArg, hint="color", completes=ulx_csay_color_table, ULib.cmds.restrictToCompletes } -- only allows values in that table
csaycolor:defaultAccess( ULib.ACCESS_ADMIN )
csaycolor:help( "Send a message to everyone in the center of their screen with color." )

notification_types_table = { "generic", "error", "undo", "hint", "cleanup", "progress" }

function ulx.notifications( calling_ply, target_plys, text, ntype, duration )

	if ntype == "generic" then
	
		for k,v in pairs( target_plys ) do
		
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", NOTIFY_GENERIC, " .. duration .. ")")
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			ULib.console( v, text )
			
		end
		
	elseif ntype == "error" then
	
		for k,v in pairs( target_plys ) do
		
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", NOTIFY_ERROR, " .. duration .. ")")
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			ULib.console( v, text )
			
		end
		
	elseif ntype == "undo" then
	
		for k,v in pairs( target_plys ) do
		
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", NOTIFY_UNDO, " .. duration .. ")")
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			ULib.console( v, text )
			
		end
		
	elseif ntype == "hint" then
	
		for k,v in pairs( target_plys ) do
		
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", NOTIFY_HINT, " .. duration .. ")")
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			ULib.console( v, text )
			
		end
		
	elseif ntype == "cleanup" then
	
		for k,v in pairs( target_plys ) do
		
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", NOTIFY_CLEANUP, " .. duration .. ")")
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			ULib.console( v, text )
			
		end
		
	elseif ntype == "progress" then	
		
		for k,v in pairs( target_plys ) do
		
			local x = math.random() --can't have the same process ID for different notifications
			
			v:SendLua("notification.AddProgress(" .. x .. ",\"" .. text .. "\")" )
			
			v:SendLua([[surface.PlaySound("buttons/button15.wav")]])
			
			timer.Simple( duration, function()
			
				v:SendLua("notification.Kill(" .. x .. ")")
				
			end )
			
		end
		
	end
	
end
local notifications = ulx.command( "Custom", "ulx notifications", ulx.notifications, "!notifications" )
notifications:addParam{ type=ULib.cmds.PlayersArg }
notifications:addParam{ type=ULib.cmds.StringArg, hint="text" }
notifications:addParam{ type=ULib.cmds.StringArg, hint="type", completes=notification_types_table, ULib.cmds.restrictToCompletes }
notifications:addParam{ type=ULib.cmds.NumArg, default=5, min=1, max=120, hint="duration", ULib.cmds.optional }
notifications:defaultAccess( ULib.ACCESS_ADMIN )
notifications:help( "Send a sandbox-type notification to players." )