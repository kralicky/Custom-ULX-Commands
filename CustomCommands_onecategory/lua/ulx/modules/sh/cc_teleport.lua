----------------------------------------------
--  This file holds teleportation commands  --
----------------------------------------------

--This local function is required for ULX Bring to work--
------------------------------------------------------------------------------------
local function playerSend( from, to, force )

	if not to:IsInWorld() and not force then return false end -- No way we can do this one

	local yawForward = to:EyeAngles().yaw
	
	local directions = { -- Directions to try
	
		math.NormalizeAngle( yawForward - 180 ), -- Behind first
		
		math.NormalizeAngle( yawForward + 90 ), -- Right
		
		math.NormalizeAngle( yawForward - 90 ), -- Left
		
		yawForward,
		
	}

	local t = {}
	
	t.start = to:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	
	t.filter = { to, from }

	local i = 1
	
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	
	local tr = util.TraceEntity( t, from )
	
	while tr.Hit do -- While it's hitting something, check other angles
	
		i = i + 1
		
		if i > #directions then	 -- No place found
		
			if force then
			
				from.ulx_prevpos = from:GetPos()
				
				from.ulx_prevang = from:EyeAngles()
				
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
				
			else
			
				return false
				
			end
			
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
		
	end

	from.ulx_prevpos = from:GetPos()
	
	from.ulx_prevang = from:EyeAngles()
	
	return tr.HitPos
	
end
------------------------------------------------------------------------------------

function ulx.fbring( calling_ply, target_ply )

	if not calling_ply:IsValid() then

		return
		
	end

	if ulx.getExclusive( calling_ply, calling_ply ) then
	
		ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
		
		return
		
	end

	if ulx.getExclusive( target_ply, calling_ply ) then
	
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		
		return
		
	end

	if not target_ply:Alive() then
	
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )
		
		return
		
	end

	if not calling_ply:Alive() then
	
		ULib.tsayError( calling_ply, "You are dead!", true )
		
		return
		
	end

	if calling_ply:InVehicle() then
	
		ULib.tsayError( calling_ply, "Please leave the vehicle first!", true )
		
		return
		
	end

	local newpos = playerSend( target_ply, calling_ply, target_ply:GetMoveType() == MOVETYPE_NOCLIP )
	
	if not newpos then
	
		ULib.tsayError( calling_ply, "Can't find a place to put the target!", true )
		
		return
		
	end

	if target_ply:InVehicle() then
	
		target_ply:ExitVehicle()
		
	end

	local newang = (calling_ply:GetPos() - newpos):Angle()

	target_ply:SetPos( newpos )
	
	target_ply:SetEyeAngles( newang )
	
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	
	target_ply:Lock()
	
	target_ply.frozen = true
	
	ulx.setExclusive( target_ply, "frozen" )
	
	ulx.fancyLogAdmin( calling_ply, "#A brought and froze #T", target_ply )

end
local fbring = ulx.command( "Custom", "ulx fbring", ulx.fbring, "!fbring" )
fbring:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
fbring:defaultAccess( ULib.ACCESS_ADMIN )
fbring:help( "Brings target to you and freezes them." )

--fteleport
function ulx.fteleport( calling_ply, target_ply )


	if not calling_ply:IsValid() then 
	
		return 
	
	end

	 if ulx.getExclusive( target_ply, calling_ply ) then
	 
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		
		return
		
	end

	if not target_ply:Alive() then
	
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )
		
		return
		
	end

	local t = {}
	
	t.start = calling_ply:GetPos() + Vector( 0, 0, 32 )
	
	t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
	
	t.filter = target_ply
	
	if target_ply ~= calling_ply then
		
		t.filter = { target_ply, calling_ply }
		
	end
	
	local tr = util.TraceEntity( t, target_ply )

	local pos = tr.HitPos

	if target_ply == calling_ply and pos:Distance( target_ply:GetPos() ) < 64 then
	
		return
		
	end

	target_ply.ulx_prevpos = target_ply:GetPos()
	
	target_ply.ulx_prevang = target_ply:EyeAngles()

	if target_ply:InVehicle() then
	
		target_ply:ExitVehicle()
		
	end

	target_ply:SetPos( pos )
	
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	
	target_ply:Lock()
	
	target_ply.frozen = true
	
	ulx.setExclusive( target_ply, "frozen" )

	
	
	ulx.fancyLogAdmin( calling_ply, "#A teleported and froze #T", target_ply )

	
	
end
local fteleport = ulx.command( "Custom", "ulx fteleport", ulx.fteleport, {"!ftp", "!fteleport"} )
fteleport:addParam{ type=ULib.cmds.PlayerArg }
fteleport:defaultAccess( ULib.ACCESS_ADMIN )
fteleport:help( "Teleports target and freezes them." )


-- ULX Warp --
--Set positions to teleport to, then type !warp <position name> to TP to that location

local savedPos = {}

function ulx.setwarp( calling_ply, name )

	local white = Color( 255, 255, 255 )

	local red = Color( 255, 0, 0 )

	if ( not name[1] ) then return end
 
	savedPos[ tostring( name[1] ) ] = calling_ply:GetPos()

	for k, v in pairs( player.GetAll() ) do
	
		if v:IsUserGroup("operator") or v:IsAdmin() then
		
			ULib.tsayColor( v, false, white, "A new warp location has been created: ", red, name )
			
		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, true, "#A set warp position #s", name )

end
local setwarp = ulx.command( "Custom", "ulx setwarp", ulx.setwarp, "!setwarp" )
setwarp:addParam{ type=ULib.cmds.StringArg, hint="name" }
setwarp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
setwarp:defaultAccess( ULib.ACCESS_ADMIN )
setwarp:help( "Sets a warp position." )

function ulx.warp( calling_ply, name )

if ( not name[1] ) then return end
 
	for k, v in pairs( savedPos ) do
	
		if k == tostring( name[1] ) then
		
			calling_ply:SetPos( v )
		
		end
		
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A warped to #s", name )
	
end
local warp = ulx.command( "Custom", "ulx warp", ulx.warp, "!warp" )
warp:addParam{ type=ULib.cmds.StringArg, hint="name" }
warp:defaultAccess( ULib.ACCESS_ADMIN )
warp:help( "Warps to a set position" )

function ulx.warpto( calling_ply, target_ply, name )
	if ( not name[ 1 ] ) then return end
	for k,v in pairs( savedPos ) do
		if k == tostring( name[ 1 ] ) then
			target_ply:SetPos( v )
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A warped #T to #s", target_ply, name )
end
local warpto = ulx.command( "Custom", "ulx warpto", ulx.warpto, "!warpto" )
warpto:addParam{ type=ULib.cmds.PlayerArg }
warpto:addParam{ type=ULib.cmds.StringArg, hint="name" }
warp:defaultAccess( ULib.ACCESS_ADMIN )
warp:help( "Warps a player to a set position." )
