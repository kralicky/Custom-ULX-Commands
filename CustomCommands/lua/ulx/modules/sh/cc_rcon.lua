----------------------------------
--  This file holds Rcon tools  --
--   Be careful with these...   --
----------------------------------

function ulx.sendlua( calling_ply, target_plys, lua, should_silent )

	for k,v in pairs( target_plys ) do

		v:SendLua( lua )
	
	end

	if should_silent then

		ulx.fancyLogAdmin( calling_ply, true, "#A ran lua #s on #T", lua, target_plys )

	else

		ulx.fancyLogAdmin( calling_ply, "#A ran lua #s on #T", lua, target_plys )

	end
	
end

local sendlua = ulx.command( "Rcon", "ulx sendlua", ulx.sendlua, "!sendlua" )
sendlua:addParam{ type=ULib.cmds.PlayersArg }
sendlua:addParam{ type=ULib.cmds.StringArg, hint="string", ULib.cmds.takeRestOfLine }
sendlua:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sendlua:defaultAccess( ULib.ACCESS_SUPERADMIN )
sendlua:help( "Run a lua string on a client.\nssendlua = silent echo" )
sendlua:setOpposite( "ulx ssendlua", { _, _, _, true } ) 


function ulx.url( calling_ply, target_plys, openedurl, should_silent )
	
	if( string.find( openedurl, "porn" ) ) then
	
		ULib.tsayError( calling_ply, "Nice try...", true ) -- get rekt
		
		return
		
	end

	for k,v in pairs( target_plys ) do

		v:SendLua([[gui.OpenURL( "]] .. openedurl .. [[" )]])
	
	end

	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A opened url #s on #T", openedurl, target_plys )
	
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A opened url #s on #T", openedurl, target_plys )
		
	end
	
end

local url = ulx.command( "Rcon", "ulx url", ulx.url, "!url" )
url:addParam{ type=ULib.cmds.PlayersArg }
url:addParam{ type=ULib.cmds.StringArg, hint="url", ULib.cmds.takeRestOfLine }
url:addParam{ type=ULib.cmds.BoolArg, invisible=true }
url:defaultAccess( ULib.ACCESS_SUPERADMIN )
url:help( "Open a URL on target(s)." )
url:setOpposite( "ulx surl", { _, _, _, true }, "!surl" )

function ulx.changeconvar( calling_ply, variable, value, should_silent )

	if ( variable == nil and value == nil ) or ( variable == "" and value == "" ) then 
	
		ULib.tsayError( calling_ply, "Enter a ConVar and value!" )
		
		return
	
	end

	
	if variable == nil or variable == "" then 
	
		ULib.tsayError( calling_ply, "Enter a ConVar!" )
		
		return 
	
	end

	if ( not ConVarExists( variable ) ) then
	
		ULib.tsayError( calling_ply, "Convar '" .. variable .. "' does not exist!" )
		
		return
		
	end

	if value == nil or value == "" then 
	
		ULib.tsayError( calling_ply, "Enter a value!" )
		
		return 
		
	end
	
	if variable == "sv_cheats" or variable == "host_framerate" then
	
		ULib.tsayError( calling_ply, "Cannot change ConVar '" .. variable .. "'" )
		
		return
		
	end
	
	if variable == "host_timescale" and GetConVarNumber( "sv_cheats" ) == 0 then
	
		ULib.tsayError( calling_ply, "Cannot change ConVar '" .. variable .. "' while sv_cheats is set to 0!" )
		
		return
		
	end
	
	if variable == "host_timescale" and tostring( value ) == "0" then
	
		ULib.tsayError( calling_ply, "You probably shouldn't do that..." ) -- srs
		
		return
		
	end
	
	if variable == "host_timescale" and ( not isnumber( tonumber( value ) ) ) then
	
		ULib.tsayError( calling_ply, "You probably shouldn't do that..." )
		
		return
		
	end

	RunConsoleCommand( variable, value )
	
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A changed ConVar #s to value #i", variable, value )
		
	elseif ( not should_silent ) then
	
		ulx.fancyLogAdmin( calling_ply, "#A changed ConVar #s to value #i", variable, value )
		
	end
	
end
local changeconvar = ulx.command( "Rcon", "ulx convar", ulx.changeconvar, { "!convar", "!var", "!changeconvar" } )
changeconvar:addParam{ type=ULib.cmds.StringArg, hint="variable" }
changeconvar:addParam{ type=ULib.cmds.StringArg, hint="value" }
changeconvar:addParam{ type=ULib.cmds.BoolArg, invisible=true }
changeconvar:defaultAccess( ULib.ACCESS_SUPERADMIN )
changeconvar:help( "Change a server ConVar." )
changeconvar:setOpposite ( "ulx sconvar", { _, _, _, true }, "!sconvar" )

function ulx.runscript( calling_ply, pathname, should_printtoconsole, should_silent )

	if not ULib.fileExists( "lua/" .. pathname ) then
		ULib.tsayError( calling_ply, "File does not exist!" )
		return
	end	
	
	local file = file.Read( pathname, "LUA" )	

	RunString( file )
	
	if should_printtoconsole then
		
		ULib.tsayColor( calling_ply, false, Color( 255, 0, 0 ), "Script printed to console." )	
		
		local toprint = ULib.explode( "\n", file )
		
		for _, line in ipairs( toprint ) do
			calling_ply:PrintMessage( HUD_PRINTCONSOLE, line )
		end
	
	end
	
	if should_silent then
		ulx.fancyLogAdmin( calling_ply, true, "#A ran script #s", pathname )
	else
		ulx.fancyLogAdmin( calling_ply, "#A ran script #s", pathname )
	end
	
end
local runscript = ulx.command( "Rcon", "ulx runscript", ulx.runscript )
runscript:addParam{ type=ULib.cmds.StringArg, hint="pathname" }
runscript:addParam{ type=ULib.cmds.BoolArg, default=false, ULib.cmds.optional, hint="Print script to console?" }
runscript:addParam{ type=ULib.cmds.BoolArg, invisible=true }
runscript:defaultAccess( ULib.ACCESS_SUPERADMIN )
runscript:help( "Run a lua script on the server." )
runscript:setOpposite( "ulx srunscript", {_, _, _, true } )

function ulx.runscriptcl( calling_ply, target_plys, pathname, should_printtoconsole, should_silent )

	if not ULib.fileExists( "lua/" .. pathname ) then
		ULib.tsayError( calling_ply, "File does not exist!" )
		return
	end	
	
	local fileToSend = file.Read( pathname, "LUA" )	

	util.AddNetworkString( "SendFile" )
	
	for i=1, #target_plys do
	
		net.Start( "SendFile" )
			net.WriteString( fileToSend )
		net.Send( target_plys[ i ] )
		
	end
	
	if should_printtoconsole then
		
		ULib.tsayColor( calling_ply, false, Color( 255, 0, 0 ), "Script printed to console." )	
		
		local toprint = ULib.explode( "\n", fileToSend )
		
		for _, line in ipairs( toprint ) do
			calling_ply:PrintMessage( HUD_PRINTCONSOLE, line )
		end
	
	end
	
	if should_silent then
		ulx.fancyLogAdmin( calling_ply, true, "#A ran script #s on #T", pathname, target_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A ran script #s on #T", pathname, target_plys )
	end
	
end
local runscriptcl = ulx.command( "Rcon", "ulx runscriptcl", ulx.runscriptcl )
runscriptcl:addParam{ type=ULib.cmds.PlayersArg }
runscriptcl:addParam{ type=ULib.cmds.StringArg, hint="pathname" }
runscriptcl:addParam{ type=ULib.cmds.BoolArg, default=false, ULib.cmds.optional, hint="Print script to console?" }
runscriptcl:addParam{ type=ULib.cmds.BoolArg, invisible=true }
runscriptcl:defaultAccess( ULib.ACCESS_SUPERADMIN )
runscriptcl:help( "Run a lua script on target(s)." )
runscriptcl:setOpposite( "ulx srunscriptcl", {_, _, _, _, true } )

if ( CLIENT ) then

	net.Receive( "SendFile", function()
		local runFile = net.ReadString()
		RunString( runFile )
	end )
	
end