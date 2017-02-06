--------------------------------
--        Hook commands       --
--  dont break ur server pls  --
--------------------------------

local hooktable = {}

function ulx.addhook( calling_ply, hooktype, hookid, args, string, should_print )
	
	if not should_print then
	
		RunString( "function " .. hookid .. "( " .. args .. " ) " .. string .. " end hook.Add( \"" .. hooktype .. "\", \"" .. hookid .. "\", " .. hookid .. " )" )
		
		table.insert( hooktable, hooktype .. "  -  " .. hookid )
		
		ulx.fancyLogAdmin( calling_ply, true, "#A hooked type #s with id #s with args #s which runs #s", hooktype, hookid, args, string )
	
	else
		
		local white = Color( 255, 255, 255 )
		local blue = Color( 50, 150, 255 )
		
		ULib.tsayColor( calling_ply, false, white, "Hooks added with ulx hook:" )
		ULib.tsayColor( calling_ply, false, white, "Type  -  Identifier" )
		
		for k,v in pairs( hooktable ) do
			ULib.tsayColor( calling_ply, false, blue, v )
		end
	
	end

end
local addhook = ulx.command( "Custom", "ulx hook", ulx.addhook )
addhook:addParam{ type=ULib.cmds.StringArg, hint="type" }
addhook:addParam{ type=ULib.cmds.StringArg, hint="identifier" }
addhook:addParam{ type=ULib.cmds.StringArg, hint="args" }
addhook:addParam{ type=ULib.cmds.StringArg, hint="string to run" }
addhook:addParam{ type=ULib.cmds.BoolArg, invisible=true }
addhook:defaultAccess( ULib.ACCESS_SUPERADMIN )
addhook:help( "Hook a function to run a string on the server." )
addhook:setOpposite( "ulx printhooks", { _, _, _, _, _, true } )

function ulx.removehook( calling_ply, hooktype, hookid )

	hook.Remove( hooktype, hookid )

	ulx.fancyLogAdmin( calling_ply, true, "#A removed hook type #s with identifier #s", hooktype, hookid )
	
	if table.HasValue( hooktable, hooktype .. "  -  " .. hookid ) then
		local pos = table.KeyFromValue( hooktable, hooktype .. "  -  " .. hookid )
		table.remove( hooktable, pos )
	else
		return
	end

end
local removehook = ulx.command( "Custom", "ulx removehook", ulx.removehook )
removehook:addParam{ type=ULib.cmds.StringArg, hint="type" }
removehook:addParam{ type=ULib.cmds.StringArg, hint="identifier" }
removehook:defaultAccess( ULib.ACCESS_SUPERADMIN )
removehook:help( "Remove a previously added hook." )

function ulx.removehookcl( calling_ply, target_ply, hooktype, hookid )

	umsg.Start( "sendhook", target_ply )
		umsg.String( hooktype )
		umsg.String( hookid )
	umsg.End()

	ulx.fancyLogAdmin( calling_ply, true, "#A removed hook type #s with identifier #s from #T", hooktype, hookid, target_ply )

end
local removehookcl = ulx.command( "Custom", "ulx removehookcl", ulx.removehookcl )
removehookcl:addParam{ type=ULib.cmds.PlayerArg }
removehookcl:addParam{ type=ULib.cmds.StringArg, hint="type" }
removehookcl:addParam{ type=ULib.cmds.StringArg, hint="identifier" }
removehookcl:defaultAccess( ULib.ACCESS_SUPERADMIN )
removehookcl:help( "Remove a previously added hook." )

if ( CLIENT ) then

	usermessage.Hook( "sendhook", function( um )
		local htype = um:ReadString()
		local hid = um:ReadString()
		hook.Remove( htype, hid )
	end )
	
end

function ulx.gethooktable( calling_ply, target_ply )

	umsg.Start( "hstart", target_ply )
		umsg.Entity( calling_ply )
		umsg.String( tostring( target_ply:Nick() ) )
	umsg.End()
	
	ulx.fancyLog( { calling_ply }, "Hook table of #T printed to console", target_ply )

end
local gethooktable = ulx.command( "Custom", "ulx gethooktable", ulx.gethooktable, "!gethooktable", true )
gethooktable:addParam{ type=ULib.cmds.PlayerArg }
gethooktable:defaultAccess( ULib.ACCESS_SUPERADMIN )
gethooktable:help( "Get a player's table of hooks that have been added with lua" )

if ( CLIENT ) then

	usermessage.Hook( "hstart", function( um )
	
		local cctable = {}
		
		local contable = hook.GetTable()
		
		for k, v in pairs( contable ) do 
			table.insert( cctable, "\n" .. k .. ":" )
			for q, w in pairs( v ) do 
				table.insert( cctable, "\t" .. tostring( q ) )
			end 
		end

		
		local one = {}
		local two = {}
		local mid = math.floor( table.Count( cctable ) / 2 )
		
		for i = 1, mid do 
			one[i] = cctable[i]
		end
		
		for i = mid + 1 , #cctable do
			two[i] = cctable[i]
		end
		
		local c = um:ReadEntity()
		local t = um:ReadString()
		
		net.Start( "hsend" )
			net.WriteTable( one )
			net.WriteTable( two )
			net.WriteEntity( c )
			net.WriteString( t )
		net.SendToServer()
		
	end )
	
	net.Receive( "hcl", function()
	
		local ntable = net.ReadTable()
		local ntable2 = net.ReadTable()
		local target = net.ReadString()

		local newtab = {}
		
		for i = 1, #ntable do
			newtab[i] = ntable[i]
		end
		
		for i = #ntable + 1, #ntable2 do
			newtab[i] = ntable2[i]
		end
		
		MsgC( Color( 255, 255, 255 ), "\n\n---------------" )
		MsgC( Color( 255, 255, 255 ), "\nHook table from " ) 
		MsgC( Color( 50, 150, 255 ), target )
		MsgC( Color( 255, 255, 255 ), ":\n" )
		
		for k, v in ipairs( newtab ) do
			Msg( v .. "\n" )
		end
		
		MsgC( Color( 255, 255, 255 ), "---------------\n\n" )
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "hsend" )
	util.AddNetworkString( "hcl" )
	
	net.Receive( "hsend", function( ply )
	
		local rtable = net.ReadTable()
		local rtable2 = net.ReadTable()
		local call = net.ReadEntity()
		local targ = net.ReadString()
		
		net.Start( "hcl" )
			net.WriteTable( rtable )
			net.WriteTable( rtable2 )
			net.WriteString( targ )
		net.Send( call )
		
	end )
	
end