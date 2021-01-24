---------------------------------------------------
--  This file holds client and server utilities  --
---------------------------------------------------

function ulx.give( calling_ply, target_plys, entity, should_silent )

	for k,v in pairs( target_plys ) do

		if ( not v:Alive() ) then -- Is the player dead?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
	
		elseif v:IsFrozen() then -- Is the player frozen?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
	
		elseif v:InVehicle() then -- Is the player in a vehicle?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is in a vehicle.", true )
		
		else 
	
			v:Give( entity )
			
		end
		
	end
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A gave #T #s", target_plys, entity )
		
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A gave #T #s", target_plys, entity )
	
	end

end
local give = ulx.command( "Custom", "ulx give", ulx.give, "!give" )
give:addParam{ type=ULib.cmds.PlayersArg }
give:addParam{ type=ULib.cmds.StringArg, hint="entity" }
give:addParam{ type=ULib.cmds.BoolArg, invisible=true }
give:defaultAccess( ULib.ACCESS_ADMIN )
give:help( "Give a player an entity" )
give:setOpposite ( "ulx sgive", { _, _, _, true }, "!sgive", true )

function ulx.maprestart( calling_ply )

    timer.Simple( 1, function() -- Wait 1 second so players can see the log
	
		game.ConsoleCommand( "changelevel " .. game.GetMap() .. "\n" ) 
		
	end ) 
	
    ulx.fancyLogAdmin( calling_ply, "#A forced a mapchange" )
	
end
local maprestart = ulx.command( "Custom", "ulx maprestart", ulx.maprestart, "!maprestart" )
maprestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
maprestart:help( "Forces a mapchange to the current map." )

function ulx.stopsounds( calling_ply )

	for _,v in ipairs( player.GetAll() ) do 
	
		v:SendLua([[RunConsoleCommand("stopsound")]]) 
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A stopped sounds" )
	
end
local stopsounds = ulx.command("Custom", "ulx stopsounds", ulx.stopsounds, {"!ss", "!stopsounds"} )
stopsounds:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopsounds:help( "Stops sounds/music of everyone in the server." )

function ulx.multiban( calling_ply, target_ply, minutes, reason )

	local affected_plys = {}
	
	for i=1, #target_ply do
    local v = target_ply[ i ]

	
	if v:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	table.insert( affected_plys, v )
	
	ULib.kickban( v, minutes, reason, calling_ply )
    
	end
	
	local time = "for #i minute(s)"
	
		if minutes == 0 then time = "permanently" end
	
	local str = "#A banned #T " .. time
	
		if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, affected_plys, minutes ~= 0 and minutes or reason, reason )
	
	
end
local multiban = ulx.command( "Custom", "ulx multiban", ulx.multiban )
multiban:addParam{ type=ULib.cmds.PlayersArg }
multiban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
multiban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
multiban:defaultAccess( ULib.ACCESS_ADMIN )
multiban:help( "Bans multiple targets." )

if ( CLIENT ) then

local on = false -- default off

local function toggle()

	on = !on

	if on == true then

		print( 'enabled' )
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode enabled." )

	else

		print( 'disabled')
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode disabled." )

	end

end


hook.Add( "ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function()

	if on and LocalPlayer():Alive() then

		return true

	end

end )

hook.Add( "CalcView", "ThirdPersonView", function( ply, pos, angles, fov )

	if on and ply:Alive() then

		local view = {}
		view.origin = pos - ( angles:Forward() * 70 ) + ( angles:Right() * 20 ) + ( angles:Up() * 5 )
		--view.origin = pos - ( angles:Forward() * 70 )
		view.angles = ply:EyeAngles() + Angle( 1, 1, 0 )
		view.fov = fov

		return GAMEMODE:CalcView( ply, view.origin, view.angles, view.fov )

	end

end )
net.Receive("cc_thirdperson_toggle", function(len, ply)
	toggle()	
	end)
end

if ( SERVER ) then
util.AddNetworkString("cc_thirdperson_toggle")
function ulx.thirdperson( calling_ply )

	net.Start("cc_thirdperson_toggle")
 	net.Send(calling_ply)	

end
local thirdperson = ulx.command( "Custom", "ulx thirdperson", ulx.thirdperson, {"!thirdperson", "!3p"}, true )
thirdperson:defaultAccess( ULib.ACCESS_ALL )
thirdperson:help( "Toggles third person mode" )

end -- end serverside

function ulx.timedcmd( calling_ply, command, seconds, should_cancel )

	ulx.fancyLogAdmin( calling_ply, true, "#A will run command #s in #i seconds", command, seconds )

	timer.Create( "timedcommand", seconds, 1, function()

		calling_ply:ConCommand( command )
	
	end)

	timer.Create( "halftime", ( seconds/2 ), 1, function() -- Print to the chat when half the time is left

		ULib.tsay( calling_ply, ( seconds/2 ) .. " seconds left" )	
	
	end)	
	
end
local timedcmd = ulx.command( "Custom", "ulx timedcmd", ulx.timedcmd, "!timedcmd", true )
timedcmd:addParam{ type=ULib.cmds.StringArg, hint="command" }
timedcmd:addParam{ type=ULib.cmds.NumArg, min=1, hint="seconds", ULib.cmds.round }
timedcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
timedcmd:defaultAccess( ULib.ACCESS_ADMIN )
timedcmd:help( "Runs the specified command after a number of seconds." )

--cancel the active timed command--
function ulx.cancelcmd( calling_ply )

	timer.Destroy( "timedcommand" )
	
	timer.Destroy( "halftime" )
	
	ulx.fancyLogAdmin( calling_ply, true, "#A cancelled the timed command" )
	
end
local cancelcmd = ulx.command( "Custom", "ulx cancelcmd", ulx.cancelcmd, "!cancelcmd", true )
cancelcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
cancelcmd:defaultAccess( ULib.ACCESS_ADMIN )
cancelcmd:help( "Runs the specified command after a number of seconds." )

function ulx.cleardecals( calling_ply )

	for _,v in ipairs( player.GetAll() ) do
		
		v:ConCommand("r_cleardecals")
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A cleared decals" )
	
end
local cleardecals = ulx.command( "Custom", "ulx cleardecals", ulx.cleardecals, "!cleardecals" )
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clear decals for all players." )

function ulx.resetmap( calling_ply )

	game.CleanUpMap()
	
	ulx.fancyLogAdmin( calling_ply, "#A reset the map to its original state" )
	
end
local resetmap = ulx.command( "Custom", "ulx resetmap", ulx.resetmap, "!resetmap" )
resetmap:defaultAccess( ULib.ACCESS_SUPERADMIN )
resetmap:help( "Resets the map to its original state." )

function ulx.bot( calling_ply, number, should_kick )

	if ( not should_kick ) then
	
		if number == 0 then
			
			for i=1, 256 do 
			
				RunConsoleCommand("bot")
				
			end
			
		elseif number > 0 then
		
			for i=1, number do
		
				RunConsoleCommand("bot")
				
			end
			
		end
		
		if number == 0 then

			ulx.fancyLogAdmin( calling_ply, "#A filled the server with bots" )
			
		elseif number == 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bot", number )
			
		elseif number > 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bots", number )
			
		end
		
	elseif should_kick then

		for k,v in pairs( player.GetAll() ) do
		
			if v:IsBot() then
			
				v:Kick("") 
				
			end
			
		end

		ulx.fancyLogAdmin( calling_ply, "#A kicked all bots from the server" )
		
	end
	
end
local bot = ulx.command( "Custom", "ulx bot", ulx.bot, "!bot" )
bot:addParam{ type=ULib.cmds.NumArg, default=0, hint="number", ULib.cmds.optional }
bot:addParam{ type=ULib.cmds.BoolArg, invisible=true }
bot:defaultAccess( ULib.ACCESS_ADMIN )
bot:help( "Spawn or remove bots." )
bot:setOpposite( "ulx kickbots", { _, _, true }, "!kickbots" )

function ulx.banip( calling_ply, minutes, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	local plys = player.GetAll()
	
	for i=1, #plys do
	
		if string.sub( tostring( plys[ i ]:IPAddress() ), 1, string.len( tostring( plys[ i ]:IPAddress() ) ) - 6 ) == ip then
			
			ip = ip .. " (" .. plys[ i ]:Nick() .. ")"
			
			break
			
		end
		
	end

	RunConsoleCommand( "addip", minutes, ip )
	RunConsoleCommand( "writeip" )

	ulx.fancyLogAdmin( calling_ply, true, "#A banned ip address #s for #i minutes", ip, minutes )
	
	if ULib.fileExists( "cfg/banned_ip.cfg" ) then
		ULib.execFile( "cfg/banned_ip.cfg" )
	end
	
end
local banip = ulx.command( "Custom", "ulx banip", ulx.banip )
banip:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.allowTimeString, min=0 }
banip:addParam{ type=ULib.cmds.StringArg, hint="address" }
banip:defaultAccess( ULib.ACCESS_SUPERADMIN )
banip:help( "Bans ip address." )

hook.Add( "Initialize", "banips", function()
	if ULib.fileExists( "cfg/banned_ip.cfg" ) then
		ULib.execFile( "cfg/banned_ip.cfg" )
	end
end )

function ulx.unbanip( calling_ply, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	RunConsoleCommand( "removeip", ip )
	RunConsoleCommand( "writeip" )

	ulx.fancyLogAdmin( calling_ply, true, "#A unbanned ip address #s", ip )
	
end
local unbanip = ulx.command( "Custom", "ulx unbanip", ulx.unbanip )
unbanip:addParam{ type=ULib.cmds.StringArg, hint="address" }
unbanip:defaultAccess( ULib.ACCESS_SUPERADMIN )
unbanip:help( "Unbans ip address." )

function ulx.ip( calling_ply, target_ply )

	calling_ply:SendLua([[SetClipboardText("]] .. tostring(string.sub( tostring( target_ply:IPAddress() ), 1, string.len( tostring( target_ply:IPAddress() ) ) - 6 )) .. [[")]])

	ulx.fancyLog( {calling_ply}, "Copied IP Address of #T", target_ply )
	
end
local ip = ulx.command( "Custom", "ulx ip", ulx.ip, "!copyip", true )
ip:addParam{ type=ULib.cmds.PlayerArg }
ip:defaultAccess( ULib.ACCESS_SUPERADMIN )
ip:help( "Copies a player's IP address." )

function ulx.sban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end	
	
	ULib.ban( target_ply, minutes, reason, calling_ply )
	
	target_ply:Kick( "Disconnect: Kicked by " .. calling_ply:Nick() .. "(" .. calling_ply:SteamID() .. ")" .. " " .. "(" .. "Banned for " .. minutes .. " minute(s): " .. reason .. ")." )

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, true, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local sban = ulx.command( "Custom", "ulx sban", ulx.sban, "!sban" )
sban:addParam{ type=ULib.cmds.PlayerArg }
sban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
sban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
sban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sban:defaultAccess( ULib.ACCESS_ADMIN )
sban:help( "Bans target silently." )

function ulx.fakeban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local fakeban = ulx.command( "Custom", "ulx fakeban", ulx.fakeban, "!fakeban", true )
fakeban:addParam{ type=ULib.cmds.PlayerArg }
fakeban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
fakeban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
fakeban:defaultAccess( ULib.ACCESS_SUPERADMIN )
fakeban:help( "Doesn't actually ban the target." )

function ulx.profile( calling_ply, target_ply )

    calling_ply:SendLua("gui.OpenURL('http://steamcommunity.com/profiles/".. target_ply:SteamID64() .."')")
	
    ulx.fancyLogAdmin( calling_ply, true, "#A opened the profile of #T", target_ply )
	
end
local profile = ulx.command( "Custom", "ulx profile", ulx.profile, "!profile", true )
profile:addParam{ type=ULib.cmds.PlayerArg }
profile:addParam{ type=ULib.cmds.BoolArg, invisible=true }
profile:defaultAccess( ULib.ACCESS_ALL )
profile:help( "Opens target's profile" )

function ulx.dban( calling_ply )
	calling_ply:ConCommand( "xgui hide" )
	calling_ply:ConCommand( "menu_disc" )
end
local dban = ulx.command( "Custom", "ulx dban", ulx.dban, "!dban" )
dban:defaultAccess( ULib.ACCESS_ADMIN )
dban:help( "Open the disconnected players menu" )

function ulx.skick( calling_ply, target_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, true, "#A kicked #T (#s)", target_ply, reason )
	else
		reason = nil
		ulx.fancyLogAdmin( calling_ply, true, "#A kicked #T", target_ply )
	end
	ULib.kick( target_ply, reason, calling_ply )
end
local skick = ulx.command( "Custom", "ulx skick", ulx.skick, "!skick" )
skick:addParam{ type=ULib.cmds.PlayerArg }
skick:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
skick:defaultAccess( ULib.ACCESS_ADMIN )
skick:help( "Kicks target." )

CreateConVar( "ulx_hide_notify_superadmins", 0 )

function ulx.hide( calling_ply, command )
	
	if GetConVarNumber( "ulx_logecho" ) == 0 then
		ULib.tsayError( calling_ply, "ULX Logecho is already set to 0. Your commands are hidden!" )
		return
	end

	local strexc = false
	
	local newstr
	
	if string.find( command, "!" ) then
		newstr = string.gsub( command, "!", "ulx " )
		strexc = true
	end
	
	if strexc == false and not string.find( command, "ulx" ) then
		ULib.tsayError( calling_ply, "Invalid ULX command!" )
		return
	end
	
	local prevecho = GetConVarNumber( "ulx_logecho" )
	
	game.ConsoleCommand( "ulx logecho 0\n" )
	if IsValid(calling_ply) then
		if strexc == false then
			calling_ply:ConCommand( command )
		else
			string.gsub( newstr, "ulx ", "!" )
			calling_ply:ConCommand( newstr )
		end
	else
		if strexc == false then
			game.ConsoleCommand( command )
		else
			string.gsub( newstr, "ulx ", "!" )
			game.ConsoleCommand( newstr )
		end
	end
	timer.Simple( 0.25, function()
		game.ConsoleCommand( "ulx logecho " .. prevecho .. "\n" )
	end )
	
	ulx.fancyLog( {calling_ply}, "(HIDDEN) You ran command #s", command )
	
	if GetConVarNumber( "ulx_hide_notify_superadmins" ) == 1 then
	
		if calling_ply:IsValid() then
			for k,v in pairs( player.GetAll() ) do
				if v:IsSuperAdmin() and v ~= calling_ply then
					ULib.tsayColor( v, false, Color( 151, 211, 255 ), "(HIDDEN) ", Color( 0, 255, 0 ), calling_ply:Nick(), Color( 151, 211, 255 ), " ran hidden command ", Color( 0, 255, 0 ), command )
				end
			end
		end
		
	end
	
end
local hide = ulx.command( "Custom", "ulx hide", ulx.hide, "!hide", true )
hide:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
hide:defaultAccess( ULib.ACCESS_SUPERADMIN )
hide:help( "Run a command without it displaying the log echo." )

function ulx.administrate( calling_ply, should_revoke )

	if not should_revoke then
		calling_ply:GodEnable()
	else
		calling_ply:GodDisable()
	end
	
	if not should_revoke then
		ULib.invisible( calling_ply, true, 255 )
	else
		ULib.invisible( calling_ply, false, 255 )
	end
	
	if not should_revoke then
		calling_ply:SetMoveType( MOVETYPE_NOCLIP )
	else
		calling_ply:SetMoveType( MOVETYPE_WALK )
	end
	
	if not should_revoke then
		ulx.fancyLogAdmin( calling_ply, true, "#A is now administrating" )
	else
		ulx.fancyLogAdmin( calling_ply, true, "#A has stopped administrating" )
	end

end
local administrate = ulx.command( "Custom", "ulx administrate", ulx.administrate, { "!admin", "!administrate"}, true )
administrate:addParam{ type=ULib.cmds.BoolArg, invisible=true }
administrate:defaultAccess( ULib.ACCESS_SUPERADMIN )
administrate:help( "Cloak yourself, noclip yourself, and god yourself." )
administrate:setOpposite( "ulx unadministrate", { _, true }, "!unadministrate", true )

function ulx.enter( calling_ply, target_ply )

	local vehicle = calling_ply:GetEyeTrace().Entity

	if not vehicle:IsVehicle() then
		ULib.tsayError( calling_ply, "That isn't a vehicle!" )
		return
	end
	
	target_ply:EnterVehicle( vehicle )
	
	ulx.fancyLogAdmin( calling_ply, "#A forced #T into a vehicle", target_ply )
	
end
local enter = ulx.command( "Custom", "ulx enter", ulx.enter, "!enter")
enter:addParam{ type=ULib.cmds.PlayerArg }
enter:defaultAccess( ULib.ACCESS_ADMIN )
enter:help( "Force a player into a vehicle." )

function ulx.exit( calling_ply, target_ply )

	if not IsValid( target_ply:GetVehicle() ) then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is not in a vehicle!" )
		return
	else
		target_ply:ExitVehicle()
	end

	ulx.fancyLogAdmin( calling_ply, "#A forced #T out of a vehicle", target_ply )
	
end
local exit = ulx.command( "Custom", "ulx exit", ulx.exit, "!exit")
exit:addParam{ type=ULib.cmds.PlayerArg }
exit:defaultAccess( ULib.ACCESS_ADMIN )
exit:help( "Force a player out of a vehicle." )

function ulx.forcerespawn( calling_ply, target_plys )

	if GetConVarString("gamemode") == "terrortown" then
		for k, v in pairs( target_plys ) do
			if v:Alive() then
				v:Kill()
				v:SpawnForRound( true )
			else
				v:SpawnForRound( true )			
			end
		end
	else
		for k, v in pairs( target_plys ) do
			if v:Alive() then
				v:Kill()
				v:Spawn()
			else
				v:Spawn()
			end
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A respawned #T", target_plys )
	
end
local forcerespawn = ulx.command( "Custom", "ulx forcerespawn", ulx.forcerespawn, { "!forcerespawn", "!frespawn"} )
forcerespawn:addParam{ type=ULib.cmds.PlayersArg }
forcerespawn:defaultAccess( ULib.ACCESS_ADMIN )
forcerespawn:help( "Force-respawn a player." )

function ulx.serverinfo( calling_ply )

	local str = string.format( "\n\nServer Information:\nULX version: %s\nULib version: %.2f\n", ulx.getVersion(), ULib.VERSION )
	str = str .. string.format( "Gamemode: %s\nMap: %s\n", GAMEMODE.Name, game.GetMap() )
	str = str .. "Dedicated server: " .. tostring( game.IsDedicated() ) .. "\n"
	str = str .. "Hostname: " .. GetConVarString("hostname") .. "\n"
	str = str .. "Server IP: " .. GetConVarString("ip") .. "\n\n"

	local players = player.GetAll()
	
	str = str .. string.format( "----------\n\nCurrently connected players:\nNick%s steamid%s uid%s id lsh\n", str.rep( " ", 27 ), str.rep( " ", 11 ), str.rep( " ", 7 ) )
	
	for _, ply in ipairs( players ) do
	
		local id = string.format( "%i", ply:EntIndex() )		
		local steamid = ply:SteamID()		
		local uid = tostring( ply:UniqueID() )
		
		local plyline = ply:Nick() .. str.rep( " ", 32 - ply:Nick():len() )		
		plyline = plyline .. steamid .. str.rep( " ", 19 - steamid:len() )
		plyline = plyline .. uid .. str.rep( " ", 11 - uid:len() )
		plyline = plyline .. id .. str.rep( " ", 3 - id:len() )
		
		if ply:IsListenServerHost() then
			plyline = plyline .. "y	  "
		else
			plyline = plyline .. "n	  "
		end

		str = str .. plyline .. "\n"
		
	end

	local gmoddefault = util.KeyValuesToTable( ULib.fileRead( "settings/users.txt" ) )
	
	str = str .. "\n----------\n\nUsergroup Information:\n\nULib.ucl.users (Users: " .. table.Count( ULib.ucl.users ) .. "):\n" .. ulx.dumpTable( ULib.ucl.users, 1 ) .. "\n"
	str = str .. "ULib.ucl.authed (Players: " .. table.Count( ULib.ucl.authed ) .. "):\n" .. ulx.dumpTable( ULib.ucl.authed, 1 ) .. "\n"
	str = str .. "Garrysmod default file (Groups:" .. table.Count( gmoddefault ) .. "):\n" .. ulx.dumpTable( gmoddefault, 1 ) .. "\n----------\n"

	str = str .. "\nAddons on this server:\n"
	
	local _, possibleaddons = file.Find( "addons/*", "GAME" )
	
	for _, addon in ipairs( possibleaddons ) do	
		if ULib.fileExists( "addons/" .. addon .. "/addon.txt" ) then
			local t = util.KeyValuesToTable( ULib.fileRead( "addons/" .. addon .. "/addon.txt" ) )
				if tonumber( t.version ) then 
					t.version = string.format( "%g", t.version ) 
				end
			str = str .. string.format( "%s%s by %s, version %s (%s)\n", addon, str.rep( " ", 24 - addon:len() ), t.author_name, t.version, t.up_date )
		end		
	end

	local f = ULib.fileRead( "workshop.vdf" )
	
	if f then
		local addons = ULib.parseKeyValues( ULib.stripComments( f, "//" ) )
		addons = addons.addons
		if table.Count( addons ) > 0 then
			str = str .. string.format( "\nPlus %i workshop addon(s):\n", table.Count( addons ) )
			PrintTable( addons )
			for _, addon in pairs( addons ) do
				str = str .. string.format( "Addon ID: %s\n", addon )
			end
		end
	end

	ULib.tsay( calling_ply, "Server information printed to console." )
	
	local lines = ULib.explode( "\n", str )
	
	for _, line in ipairs( lines ) do
	
		ULib.console( calling_ply, line )
		
	end
	
end
local serverinfo = ulx.command( "Custom", "ulx serverinfo", ulx.serverinfo, { "!serverinfo", "!info" } )
serverinfo:defaultAccess( ULib.ACCESS_ADMIN )
serverinfo:help( "Print server information." )

function ulx.timescale( calling_ply, number, should_reset )

	if not should_reset then
	
		if number <= 0.1 then
			ULib.tsayError( calling_ply, "Cannot set the timescale at or below 0.1, doing so will cause instability." )
			return
		end

		if number >= 5 then
			ULib.tsayError( calling_ply, "Cannot set the timescale at or above 5, doing so will cause instability" )
			return
		end

		game.SetTimeScale( number )

		ulx.fancyLogAdmin( calling_ply, "#A set the game timescale to #i", number )

	else

		game.SetTimeScale( 1 )
		
		ulx.fancyLogAdmin( calling_ply, "#A reset the game timescale" )
		
	end
	
end
local timescale = ulx.command( "Custom", "ulx timescale", ulx.timescale, "!timescale" )
timescale:addParam{ type=ULib.cmds.NumArg, default=1, hint="multiplier" }
timescale:addParam{ type=ULib.cmds.BoolArg, invisible=true }
timescale:defaultAccess( ULib.ACCESS_SUPERADMIN )
timescale:help( "Set the server timescale." )
timescale:setOpposite( "ulx resettimescale", { _, _, true } )

if ( SERVER ) then

	hook.Add( "ShutDown", "reallyimportanthook", function()
		if game.GetTimeScale() ~= 1 then
			game.SetTimeScale( 1 )
		end 
	end )
	
end

function ulx.removeragdolls( calling_ply )

	for k,v in pairs( player.GetAll() ) do
		v:SendLua([[game.RemoveRagdolls()]])
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A removed ragdolls" )
	
end
local removeragdolls = ulx.command( "Custom", "ulx removeragdolls", ulx.removeragdolls, "!removeragdolls" )
removeragdolls:defaultAccess( ULib.ACCESS_ADMIN )
removeragdolls:help( "Remove all ragdolls." )

function ulx.bancheck( calling_ply, steamid )

	if not ULib.isValidSteamID( steamid ) then
	
		if ( ULib.isValidIP( steamid ) and not ULib.isValidSteamID( steamid ) ) then
		
			local file = file.Read( "cfg/banned_ip.cfg", "GAME" )
	
			if string.find( file, steamid ) then
				ulx.fancyLog( {calling_ply}, "IP Address #s is banned!", steamid )				
			else
				ulx.fancyLog( {calling_ply}, "IP Address #s is not banned!", steamid )				
			end
			
			return
			
		elseif not ( ULib.isValidIP( steamid ) and ULib.isValidSteamID( steamid ) ) then
		
			ULib.tsayError( calling_ply, "Invalid string." )			
			return
			
		end
		
	end
	
	if calling_ply:IsValid() then
	
		if ULib.bans[steamid] then
		
			ulx.fancyLog( {calling_ply}, "SteamID #s is banned! Information printed to console.", steamid )
			
			umsg.Start( "steamid", calling_ply )
				umsg.String( steamid )
			umsg.End()
			
		else
			ulx.fancyLog( {calling_ply}, "SteamID #s is not banned!", steamid )
		end
		
	else
	
		if ULib.bans[steamid] then
			PrintTable( ULib.bans[steamid] )
		else
			Msg( "SteamID " .. steamid .. " is not banned!" )
		end
	
	end
	
end
local bancheck = ulx.command( "Custom", "ulx bancheck", ulx.bancheck, "!bancheck" )
bancheck:addParam{ type=ULib.cmds.StringArg, hint="string" }
bancheck:defaultAccess( ULib.ACCESS_ADMIN )
bancheck:help( "Checks if a steamid or ip address is banned." )

if ( SERVER ) then

	util.AddNetworkString( "steamid2" )
	util.AddNetworkString( "sendtable" )

	net.Receive( "steamid2", function( len, ply )
		if not ULib.ucl.query(ply, "ulx bancheck") then return end
		local id2 = net.ReadString()
		local tab = ULib.bans[ id2 ]
		net.Start( "sendtable" )
			net.WriteTable( tab )
		net.Send( ply )			
	end )
	
end

if ( CLIENT ) then

	usermessage.Hook( "steamid", function( um )
		local id = um:ReadString()
		net.Start( "steamid2" )
			net.WriteString( id )
		net.SendToServer()
	end )
	
	net.Receive( "sendtable", function()
		PrintTable( net.ReadTable() )
	end )
	
end
local requests = {}
function ulx.friends( calling_ply, target_ply )
	requests[ calling_ply:SteamID() .. target_ply:SteamID() ] = true
	umsg.Start( "getfriends", target_ply )
		umsg.Entity( calling_ply )
	umsg.End()
	
end
local friends = ulx.command( "Custom", "ulx friends", ulx.friends, { "!friends", "!listfriends" }, true )
friends:addParam{ type=ULib.cmds.PlayerArg }
friends:defaultAccess( ULib.ACCESS_ADMIN )
friends:help( "Print a player's connected steam friends." )

if ( CLIENT ) then

	local friendstab = {}
	
	usermessage.Hook( "getfriends", function( um )
	
		for k, v in pairs( player.GetAll() ) do
			if v:GetFriendStatus() == "friend" then
				table.insert( friendstab, v:Nick() )
			end
		end
		
		net.Start( "sendtable" )
			net.WriteEntity( um:ReadEntity() )
			net.WriteTable( friendstab )
		net.SendToServer()
		
		table.Empty( friendstab )
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "sendtable" )
	
	net.Receive( "sendtable", function( len, ply )
	
		local calling, tabl = net.ReadEntity(), net.ReadTable() 
		local tab = table.concat( tabl, ", " )
		if not IsValid(calling) or not calling:IsPlayer() then return end

		if not requests[calling:SteamID() .. ply:SteamID()] then return end
		
		if ( string.len( tab ) == 0 and table.Count( tabl ) == 0 ) then			
			ulx.fancyLog( {calling}, "#T is not friends with anyone on the server", ply )
		else
			ulx.fancyLog( {calling}, "#T is friends with #s", ply, tab )
		end
		requests[calling:SteamID() .. ply:SteamID()] = nil
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString("Watchlist_Open")
	util.AddNetworkString("Watchlist_RequestWatchedPlayers")
	util.AddNetworkString("Watchlist_RequestWatchedPlayersCallback")
	util.AddNetworkString("Watchlist_RequestDeletion")

	if not file.Exists( "watchlist", "DATA" ) then
		file.CreateDir( "watchlist" )
	end

	WatchlistData = {
		GetFilePath = function(steamID)
			local filename = (steamID:gsub(":", "x") .. ".txt"):lower()
			return "watchlist/" .. filename
		end,

		AddPlayer = function(steamID, playerName, adminName, reason)
			local filePath = WatchlistData.GetFilePath(steamID)

			file.Write(filePath, "") -- Removes existing watch reason

			file.Append(filePath, playerName .. "\n")
			file.Append(filePath, adminName .. "\n")
			file.Append(filePath, string.Trim(reason) .. "\n")
			file.Append(filePath, os.date("%m/%d/%y %H:%M") .. "\n")
		end,

		IsPlayerOnWatchlist = function(steamID)
			return file.Exists(WatchlistData.GetFilePath(steamID), "DATA")
		end,

		GetPlayerWatchlistInfo = function(steamID)
			if(not WatchlistData.IsPlayerOnWatchlist(steamID)) then return nil end

			local watchInfoRaw = file.Read(WatchlistData.GetFilePath(steamID), "DATA")
			local watchInfo = string.Explode("\n", watchInfoRaw)

			return {
				SteamID = steamID:upper(),
				PlayerName = watchInfo[1],
				AdminName = watchInfo[2],
				Reason = watchInfo[3],
				DateTime = watchInfo[4]
			}
		end,

		RemovePlayer = function(steamID)
			file.Delete(WatchlistData.GetFilePath(steamID))
		end,

		GetAllWatchedPlayers = function()
			local watchedPlayers = {}

			local files = file.Find("watchlist/*", "DATA")
			for k, filename in pairs(files) do
				local watchInfoRaw = file.Read("watchlist/" .. filename, "DATA")
				local watchInfo = string.Explode("\n", watchInfoRaw)

				table.insert(watchedPlayers, {
					SteamID = filename:gsub(".txt", ""):gsub("x", ":"):upper(),
					PlayerName = watchInfo[1],
					AdminName = watchInfo[2],
					Reason = watchInfo[3],
					DateTime = watchInfo[4]
				})
			end

			return watchedPlayers
		end
	}

	net.Receive("Watchlist_RequestWatchedPlayers", function(len, ply)
		if not ULib.ucl.query(ply, "ulx watchlist") then
			ULib.tsayError( ply, "You are not allowed to see who is on the watchlist" )
			return
		end

		local watchedPlayers = WatchlistData.GetAllWatchedPlayers()

		local payload = util.Compress(util.TableToJSON(watchedPlayers))
		net.Start("Watchlist_RequestWatchedPlayersCallback")
			net.WriteUInt(string.len(payload), 32)
			net.WriteData(payload, string.len(payload))
		net.Send(ply)
	end)
	
	net.Receive("Watchlist_RequestDeletion", function(len, ply)
		if not ULib.ucl.query(ply, "ulx unwatch") then
			ULib.tsayError( ply, "You are not allowed to remove players from watchlist." )
			return
		end

		local steamid = net.ReadString()
		
		if WatchlistData.IsPlayerOnWatchlist(steamid) then
			WatchlistData.RemovePlayer(steamid)
			ulx.fancyLogAdmin(ply, true, "#A removed #s from the watchlist", steamid)
		else
			ULib.tsayError(ply, steamid .. " is not on the watchlist." )
		end
	end)
	
	hook.Add("PlayerInitialSpawn", "CheckWatchedPlayers", function(ply)
		local watchlistInfo = WatchlistData.GetPlayerWatchlistInfo(ply:SteamID())
		if(watchlistInfo == nil) then return end

		for k, otherPlayer in pairs( player.GetHumans()) do
			if otherPlayer:IsAdmin() then
				ULib.tsayError(otherPlayer, ply:Nick() .. " (" .. ply:SteamID() .. ") has joined the server and is on the watchlist!" )
				ULib.tsayColor(otherPlayer, Color(255, 141, 34), "Reason: ", Color(255, 0, 0), watchlistInfo.Reason)
			end
		end
	end)
	
	hook.Add("PlayerDisconnected", "CheckWatchedPlayersDC", function(ply)
		if(WatchlistData.IsPlayerOnWatchlist(ply:SteamID()) == false) then return end

		for k, otherPlayer in pairs( player.GetHumans()) do
			if otherPlayer:IsAdmin() then
				ULib.tsayError(otherPlayer, ply:Nick() .. " (" .. ply:SteamID() .. ") has left the server and is on the watchlist!" )
			end
		end
	end)
end

function ulx.watch( calling_ply, target_ply, reason, should_unwatch )
	local targetSteamID = target_ply:SteamID()
	local targetPlayerName = target_ply:Nick()

	if should_unwatch then
		if WatchlistData.IsPlayerOnWatchlist(targetSteamID) then
			WatchlistData.RemovePlayer(targetSteamID)
			ulx.fancyLogAdmin(calling_ply, true, "#A removed #T from the watchlist", target_ply)
		else
			ULib.tsayError(calling_ply, targetPlayerName .. " is not on the watchlist.")
		end
	else
		WatchlistData.AddPlayer(targetSteamID, targetPlayerName, calling_ply:Nick(), reason)
		ulx.fancyLogAdmin(calling_ply, true, "#A added #T to the watchlist (#s)", target_ply, reason)
	end
end

local watch = ulx.command( "Custom", "ulx watch", ulx.watch, "!watch", true )
watch:addParam{ type=ULib.cmds.PlayerArg }
watch:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
watch:addParam{ type=ULib.cmds.BoolArg, invisible=true }
watch:defaultAccess( ULib.ACCESS_ADMIN )
watch:help( "Watch or unwatch a player" )
watch:setOpposite( "ulx unwatch", { _, _, false, true }, "!unwatch", true )




function ulx.watchlist( calling_ply )
	if calling_ply:IsValid() then
		net.Start("Watchlist_Open")
		net.Send(calling_ply)
	end
end
local watchlist = ulx.command( "Custom", "ulx watchlist", ulx.watchlist, "!watchlist", true )
watchlist:defaultAccess( ULib.ACCESS_ADMIN )
watchlist:help( "View the watchlist" )



if ( CLIENT ) then
	function debounce(func, wait)
		local timerName

		return function(...)
			local args = ...
			local later = function()
				timerName = nil
				func(args)
			end

			if(timerName != nil) then timer.Remove(timerName) end
			timerName = tostring(func) .. tostring(math.random(1, 9999999))
			timer.Create(timerName, wait, 1, later)
		end
	end

	local WatchlistUIList = nil
	local WatchlistData = {}

	local function UpdateWatchlistUIList(watchedPlayersList)
		if(WatchlistUIList == nil) then return end

		WatchlistUIList:Clear()

		for k, watchedPlayer in pairs(watchedPlayersList) do
			WatchlistUIList:AddLine(watchedPlayer.SteamID, watchedPlayer.PlayerName, watchedPlayer.AdminName, watchedPlayer.Reason, watchedPlayer.DateTime)
		end
	end
	
	net.Receive("Watchlist_RequestWatchedPlayersCallback", function()
		local length = net.ReadUInt(32)
		local dataCompressed = net.ReadData(length)

		WatchlistData = util.JSONToTable(util.Decompress(dataCompressed))
		UpdateWatchlistUIList(WatchlistData)
	end)


	local function RenderWatchlist()
		local main = vgui.Create( "DFrame" )	
			main:SetPos( 50,50 )
			main:SetSize( 700, 425 )
			main:SetTitle( "Watchlist" )
			main:SetVisible( true )
			main:SetDraggable( true )
			main:ShowCloseButton( true )
			main:MakePopup()
			main:Center()

		function main:OnClose()
			WatchlistUIList = nil
		end


		local searchBox = vgui.Create("DTextEntry", main)
		searchBox:SetPos(4, 27)
		searchBox:SetSize(300, 25)
		searchBox:SetPlaceholderText("Search...")
		searchBox:SetValue("")

		searchBox:SetUpdateOnType(true)
		searchBox.OnValueChange = debounce(function(self)
			local searchTerm = string.lower(string.sub(self:GetValue(), 1, 200))

			if(searchTerm == "") then
				UpdateWatchlistUIList(WatchlistData)
				return
			end


			local searchResults = {}
			for k, watchedPlayer in pairs(WatchlistData) do
				if(string.find(watchedPlayer.SteamID:lower(), searchTerm) != nil) then
					table.insert(searchResults, watchedPlayer)
				elseif(string.find(watchedPlayer.PlayerName:lower(), searchTerm) != nil) then
					table.insert(searchResults, watchedPlayer)
				elseif(string.find(watchedPlayer.Reason:lower(), searchTerm) != nil) then
					table.insert(searchResults, watchedPlayer)
				elseif(string.find(watchedPlayer.AdminName:lower(), searchTerm) != nil) then
					table.insert(searchResults, watchedPlayer)
				end
			end

			UpdateWatchlistUIList(searchResults)
		end, 0.5)


		WatchlistUIList = vgui.Create( "DListView", main )
			WatchlistUIList:SetPos( 4, 52 )
			WatchlistUIList:SetSize( 692, 369 )
			WatchlistUIList:SetMultiSelect( false )
			WatchlistUIList:AddColumn( "SteamID" )
			WatchlistUIList:AddColumn( "Name" )
			WatchlistUIList:AddColumn( "Admin" )
			WatchlistUIList:AddColumn( "Reason" )
			WatchlistUIList:AddColumn( "Time" )

			WatchlistUIList.OnRowRightClick = function( main, line )
				local menu = DermaMenu()

					menu:AddOption( "Copy SteamID", function()
						SetClipboardText( WatchlistUIList:GetLine( line ):GetValue( 1 ) )
						chat.AddText( "SteamID Copied" )
					end ):SetIcon( "icon16/tag_blue_edit.png" )

					menu:AddOption( "Copy Name", function()
						SetClipboardText( WatchlistUIList:GetLine( line ):GetValue( 2 ) )
						chat.AddText( "Username Copied" )
					end ):SetIcon( "icon16/user_edit.png" )

					menu:AddOption( "Copy Reason", function()
						SetClipboardText( WatchlistUIList:GetLine( line ):GetValue( 4 ) )
						chat.AddText( "Reason Copied" )
					end ):SetIcon( "icon16/note_edit.png" )

					menu:AddOption( "Copy Time", function()
						SetClipboardText( WatchlistUIList:GetLine( line ):GetValue( 5 ) )
						chat.AddText( "Time Copied" )
					end ):SetIcon( "icon16/clock_edit.png" )	

					menu:AddOption("Remove", function()
						local rowSteamID = WatchlistUIList:GetLine(line):GetValue(1)

						net.Start("Watchlist_RequestDeletion")
							net.WriteString(rowSteamID)
						net.SendToServer()

						-- Refresh list of watched players
						net.Start("Watchlist_RequestWatchedPlayers")
						net.SendToServer()

					end):SetIcon( "icon16/table_row_delete.png" )

					menu:AddOption( "Ban by SteamID", function()
						local Frame = vgui.Create( "DFrame" )
						Frame:SetSize( 250, 98 )
						Frame:Center()
						Frame:MakePopup()
						Frame:SetTitle( "Ban by SteamID..." )

						local TimeLabel = vgui.Create( "DLabel", Frame )
						TimeLabel:SetPos( 5,27 )
						TimeLabel:SetColor( Color( 0,0,0,255 ) )
						TimeLabel:SetFont( "DermaDefault" )
						TimeLabel:SetText( "Time:" )

						local Time = vgui.Create( "DTextEntry", Frame )
						Time:SetPos( 47, 27 )
						Time:SetSize( 198, 20 )
						Time:SetText( "" )

						local ReasonLabel = vgui.Create( "DLabel", Frame )
						ReasonLabel:SetPos( 5,50 )
						ReasonLabel:SetColor( Color( 0,0,0,255 ) )
						ReasonLabel:SetFont( "DermaDefault" )
						ReasonLabel:SetText( "Reason:" )

						local Reason = vgui.Create( "DTextEntry", Frame )
						Reason:SetPos( 47, 50 )
						Reason:SetSize( 198, 20 )
						Reason:SetText("")

						local execbutton = vgui.Create( "DButton", Frame )
						execbutton:SetSize( 75, 20 )
						execbutton:SetPos( 47, 73 )
						execbutton:SetText( "Ban!" )
						execbutton.DoClick = function()
							local rowSteamID = WatchlistUIList:GetLine(line):GetValue(1)
							RunConsoleCommand( "ulx", "banid", tostring(rowSteamID), Time:GetText(), Reason:GetText() )
							Frame:Close()
						end

						local cancelbutton = vgui.Create( "DButton", Frame )
						cancelbutton:SetSize( 75, 20 )
						cancelbutton:SetPos( 127, 73 )
						cancelbutton:SetText( "Cancel" )
						cancelbutton.DoClick = function( cancelbutton )
							Frame:Close()
						end

					end):SetIcon( "icon16/tag_blue_delete.png" )

				menu:Open()
			end

		-- Request the list of watched players
		net.Start("Watchlist_RequestWatchedPlayers")
		net.SendToServer()
	end

	net.Receive("Watchlist_Open", function()
		RenderWatchlist()
	end)
end
