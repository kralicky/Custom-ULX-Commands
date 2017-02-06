------------------------------------
--  This file holds fun commands  --
------------------------------------

function ulx.explode( calling_ply, target_plys )

	for k, v in pairs( target_plys ) do	
	
		local playerpos = v:GetPos()	
		
		local waterlevel = v:WaterLevel()	
		
		timer.Simple( 0.1, function()				
			local traceworld = {}				
				traceworld.start = playerpos					
				traceworld.endpos = traceworld.start + ( Vector( 0,0,-1 ) * 250 )					
				local trw = util.TraceLine( traceworld )					
				local worldpos1 = trw.HitPos + trw.HitNormal					
				local worldpos2 = trw.HitPos - trw.HitNormal				
			util.Decal( "Scorch",worldpos1,worldpos2 )				
		end )		
		
		if GetConVarNumber( "explode_ragdolls" ) == 1 then						
			v:SetVelocity( Vector( 0, 0, 10 ) * math.random( 75, 150 ) )			
			timer.Simple( 0.05, function() v:Kill() end )				
		elseif GetConVarNumber( "explode_ragdolls" ) == 0 then			
			v:Kill()				
		end		
		
		util.ScreenShake( playerpos, 5, 5, 1.5, 200 )
		
		if ( waterlevel > 1 ) then		
			local vPoint = playerpos + Vector(0,0,10)				
				local effectdata = EffectData()					
				effectdata:SetStart( vPoint )					
				effectdata:SetOrigin( vPoint )					
				effectdata:SetScale( 1 )					
			util.Effect( "WaterSurfaceExplosion", effectdata )				
			local vPoint = playerpos + Vector(0,0,10)				
				local effectdata = EffectData()					
				effectdata:SetStart( vPoint )					
				effectdata:SetOrigin( vPoint )					
				effectdata:SetScale( 1 )					
			util.Effect( "HelicopterMegaBomb", effectdata ) 				
		else			
			local vPoint = playerpos + Vector( 0,0,10 )				
				local effectdata = EffectData()					
				effectdata:SetStart( vPoint )					
				effectdata:SetOrigin( vPoint )					
				effectdata:SetScale( 1 )					
			util.Effect( "HelicopterMegaBomb", effectdata )				
			v:EmitSound( Sound ("ambient/explosions/explode_4.wav") )				
		end		
		
	end	
	
	ulx.fancyLogAdmin( calling_ply, "#A exploded #T", target_plys )	
	
end
local explode = ulx.command( "Custom", "ulx explode", ulx.explode, "!explode" )
explode:addParam{ type=ULib.cmds.PlayersArg }
explode:defaultAccess( ULib.ACCESS_ADMIN )
explode:help( "Explode a player" )


function ulx.launch( calling_ply, target_plys )

	for k,v in pairs( target_plys ) do
	
		v:SetVelocity( Vector( 0,0,50 ) * 50 )
		
	end

	ulx.fancyLogAdmin( calling_ply, "#A Launched #T", target_plys )

end
local launch = ulx.command( "Custom", "ulx launch", ulx.launch, "!launch" )
launch:addParam{ type=ULib.cmds.PlayersArg }
launch:defaultAccess( ULib.ACCESS_ADMIN )
launch:help( "Launch players into the air." )


function ulx.gravity( calling_ply, target_plys, gravnumber )

	for k,v in pairs( target_plys ) do
	
		if tonumber(gravnumber) == 0 then
		
			v:SetGravity( 0.000000000000000000000001 ) -- because float is dumb
			
		elseif tonumber(gravnumber) > 0 then
		
			v:SetGravity( gravnumber )
			
		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the gravity for #T to #s", target_plys, gravnumber )

end
local gravity = ulx.command( "Custom", "ulx gravity", ulx.gravity, "!gravity" )
gravity:addParam{ type=ULib.cmds.PlayersArg }
gravity:addParam{ type=ULib.cmds.StringArg, hint="gravity" }
gravity:defaultAccess( ULib.ACCESS_SUPERADMIN )
gravity:help( "Sets target's gravity." )


local prevrun
local prevwalk

local function getInitialSpeeds( ply ) -- fetch players' initial walk and run speeds, it's different for each gamemode

	timer.Simple( 0.5, function() -- for some reason this prints the run speed different than it actually is if i dont add the timer...
		if ply:IsValid() then
			prevrun = ply:GetRunSpeed()
			prevwalk = ply:GetWalkSpeed()
			ULib.console( ply, "Initial walk and run speeds fetched.\nWalk Speed: " .. prevwalk .. "\nRun Speed: " .. prevrun )
		end
	end )

end
hook.Add( "PlayerInitialSpawn", "geturspeeds", getInitialSpeeds )

function ulx.speed( calling_ply, target_plys, walk, run )

	for k,v in pairs( target_plys ) do
	
		if walk == 0 and run == 0 then 
		
			GAMEMODE:SetPlayerSpeed( v, prevwalk, prevrun ) -- reset to the fetched default values
				
			ulx.fancyLogAdmin( calling_ply, "#A reset the walk and run speed for #T", target_plys )

		elseif walk > 0 and run == 0 then
		
			GAMEMODE:SetPlayerSpeed( v, walk, v:GetRunSpeed() ) -- skip over run speed
		
			ulx.fancyLogAdmin( calling_ply, "#A set the walk speed for #T to #s", target_plys, walk )
			
		elseif walk == 0 and run > 0 then
		
			GAMEMODE:SetPlayerSpeed( v, v:GetWalkSpeed(), run ) -- skip over walk speed
		
			ulx.fancyLogAdmin( calling_ply, "#A set the run speed for #T to #s", target_plys, run )
			
		elseif walk > 0 and run > 0 then
		
			GAMEMODE:SetPlayerSpeed( v, walk, run ) -- set both
			
			ulx.fancyLogAdmin( calling_ply, "#A set the walk speed for #T to #s and the run speed to #i", target_plys, walk, run )
		
		end
		
	end

end
local speed = ulx.command( "Custom", "ulx speed", ulx.speed, "!speed" )
speed:addParam{ type=ULib.cmds.PlayersArg }
speed:addParam{ type=ULib.cmds.NumArg, default=0, hint="walk speed", min=0, max=20000 }
speed:addParam{ type=ULib.cmds.NumArg, default=0, hint="run speed", min=0, max=20000 }
speed:defaultAccess( ULib.ACCESS_SUPERADMIN )
speed:help( "Sets target's speed.\nSet a value to 0 to leave it unchanged\nSet both to 0 to reset" )

function ulx.model( calling_ply, target_plys, model )
	
	for k,v in pairs( target_plys ) do 
	
		if ( not v:Alive() ) then
		
			ULib.tsayError( calling_ply, v:Nick() .. " is dead", true )
		
		else
		
			v:SetModel( model )

		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the model for #T to #s", target_plys, model )
	
end
local model = ulx.command( "Custom", "ulx model", ulx.model, "!model" )
model:addParam{ type=ULib.cmds.PlayersArg }
model:addParam{ type=ULib.cmds.StringArg, hint="model" }
model:defaultAccess( ULib.ACCESS_ADMIN )
model:help( "Set a player's model." )

function ulx.jumppower( calling_ply, target_plys, power )
	
	for k,v in pairs( target_plys ) do 
	
		if ( not v:Alive() ) then
		
			ULib.tsayError( calling_ply, v:Nick() .. " is dead", true )
		
		else
		
			v:SetJumpPower( power )

		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the jump power for #T to #s", target_plys, power )
	
end
local jumppower = ulx.command( "Custom", "ulx jumppower", ulx.jumppower, "!jumppower" )
jumppower:addParam{ type=ULib.cmds.PlayersArg }
jumppower:addParam{ type=ULib.cmds.NumArg, default=200, hint="power", ULib.cmds.optional }
jumppower:defaultAccess( ULib.ACCESS_ADMIN )
jumppower:help( "Set a player's jump power.\nDefault=200" )

function ulx.frags_deaths( calling_ply, target_plys, number, should_deaths )

	if ( not should_deaths ) then
	
		for k,v in pairs( target_plys ) do 
		
			v:SetFrags( number )

		end
		
		ulx.fancyLogAdmin( calling_ply, "#A set the frags for #T to #s", target_plys, number )
		
	elseif should_deaths then
	
		for k,v in pairs( target_plys ) do 
		
			v:SetDeaths( number )

		end
		
		ulx.fancyLogAdmin( calling_ply, "#A set the deaths for #T to #s", target_plys, number )
		
	end
	
end
local frags_deaths = ulx.command( "Custom", "ulx frags", ulx.frags_deaths, "!frags" )
frags_deaths:addParam{ type=ULib.cmds.PlayersArg }
frags_deaths:addParam{ type=ULib.cmds.NumArg, hint="number" }
frags_deaths:addParam{ type=ULib.cmds.BoolArg, invisible=true }
frags_deaths:defaultAccess( ULib.ACCESS_ADMIN )
frags_deaths:help( "Set a player's frags and deaths." )
frags_deaths:setOpposite( "ulx deaths", { _, _, _, true }, "!deaths" )

function ulx.ammo( calling_ply, target_plys, amount, should_setammo )

	for i=1, #target_plys do

		local player = target_plys[ i ]

		local actwep = player:GetActiveWeapon()
	 
		local curammo = actwep:GetPrimaryAmmoType()
	
		if !should_setammo then
			player:GiveAmmo( amount, curammo )
		else
			player:SetAmmo( amount, curammo )
		end
		
	end
	
	if should_setammo then
		ulx.fancyLogAdmin( calling_ply, "#A set the ammo for #T to #s", target_plys, amount )
	else
		ulx.fancyLogAdmin( calling_ply, "#A gave #T #i rounds", target_plys, amount )
	end
	
end
local ammo = ulx.command( "Custom", "ulx giveammo", ulx.ammo, "!giveammo" )
ammo:addParam{ type=ULib.cmds.PlayersArg }
ammo:addParam{ type=ULib.cmds.NumArg, min=0, hint="amount" }
ammo:addParam{ type=ULib.cmds.BoolArg, invisible=true }
ammo:defaultAccess( ULib.ACCESS_ADMIN )
ammo:help( "Set a player's ammo" )
ammo:setOpposite( "ulx setammo", { _, _, _, true }, "!setammo" )

function ulx.scale( calling_ply, target_plys, scale )

	for k, v in pairs( target_plys ) do
		if v:IsValid() then
			v:SetModelScale( scale, 1 )
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the scale for #T to #i", target_plys, scale )
	
end
local scale = ulx.command( "Custom", "ulx scale", ulx.scale, "!scale" )
scale:addParam{ type=ULib.cmds.PlayersArg }
scale:addParam{ type=ULib.cmds.NumArg, default=1, min=0, hint="multiplier" }
scale:defaultAccess( ULib.ACCESS_ADMIN )
scale:help( "Set the model scale of a player." )

local zaptable = {
"ambient/energy/zap1.wav",
"ambient/energy/zap2.wav",
"ambient/energy/zap3.wav"
}

function ulx.shock( calling_ply, target_plys, damage )
	for k,v in ipairs( target_plys ) do
		local fx = EffectData()
			fx:SetEntity( v )
			fx:SetOrigin( v:GetPos() )
			fx:SetStart( v:GetPos() )
			fx:SetScale( 1 )
			fx:SetMagnitude( 15 )
		util.Effect( "TeslaHitBoxes", fx )
		v:EmitSound( tostring( table.Random( zaptable ) ) )
		local dmginfo = DamageInfo()
			dmginfo:SetDamage( damage )
		v:TakeDamageInfo( dmginfo )
		umsg.Start( "ulx_blind", v )
			umsg.Bool( true )
			umsg.Short( 255 )
		umsg.End()
		timer.Simple( 0.2, function()
			for i = -255, 0 do
				umsg.Start( "ulx_blind", v )
					umsg.Bool( true )
					umsg.Short( math.abs( i ) )
				umsg.End()
				if i == 0 then
					umsg.Start( "ulx_blind", v )
						umsg.Bool( false )
						umsg.Short( 0 )
					umsg.End()
				end
			end
		end )
		umsg.Start( "StartBlur", v )
		umsg.End()	
	end
	if damage and damage > 0 then
		ulx.fancyLogAdmin( calling_ply, "#A shocked #T with #i damage", target_plys, damage )
	else
		ulx.fancyLogAdmin( calling_ply, "#A shocked #T", target_plys )
	end
end
local shock = ulx.command( "Custom", "ulx shock", ulx.shock, "!shock" )
shock:addParam{ type=ULib.cmds.PlayersArg }
shock:addParam{ type=ULib.cmds.NumArg, min=0, hint="damage", ULib.cmds.optional }
shock:defaultAccess( ULib.ACCESS_ADMIN )
shock:help( "Shock players" )

if ( CLIENT ) then

	usermessage.Hook( "StartBlur", function()
		
		hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
			DrawMotionBlur( 0.1, 1, 0.05)
		end )
		timer.Simple( 0.3, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.9, 0.05)
			end )	
		end )
		timer.Simple( 0.5, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.8, 0.05)
			end )	
		end )
		timer.Simple( 0.7, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.7, 0.05)
			end )	
		end )
		timer.Simple( 0.9, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.6, 0.05)
			end )
		end )
		timer.Simple( 1.1, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.5, 0.05)
			end )	
		end )
		timer.Simple( 1.3, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.4, 0.05)
			end )	
		end )
		timer.Simple( 1.5, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.3, 0.05)
			end )	
		end )
		timer.Simple( 1.7, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.2, 0.05)
			end )	
		end )
		timer.Simple( 1.9, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.1, 0.05)
			end )		
		end )
		timer.Simple( 2.1, function()
			hook.Remove( "RenderScreenspaceEffects", "DrawMotionBlur" )
		end )
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "egg" )
	
	local blue = Color( 50, 150, 255 )
	local white = Color( 255, 255, 255 )
	
	hook.Add( "PlayerSay", "cc_easteregg", function( ply, text, public )	
	
		if string.sub( text:lower(), 1, 5 ) == "4bigz" then		
		
			if not ( ply:GetPData( "eastereggs1" ) and ply:GetPData( "eastereggs1" ) == "true" ) then	
			
				ply:SetPData( "eastereggs1", "true" )	
				
				if not ply:GetPData( "eastereggs" ) then
					ply:SetPData( "eastereggs", 1 )
				else
					ply:SetPData( "eastereggs", ply:GetPData( "eastereggs" ) + 1 )
				end		
				
				ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #1!" )		
				
				if ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) == "3" then
					ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!" )
				elseif ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) ~= "3" then
					ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData( "eastereggs" ), white, "/3 easter eggs." )
				end
				
				for k, v in pairs( player.GetAll() ) do
					v:SendLua([[	surface.PlaySound( "garrysmod/content_downloaded.wav" )	]])
				end
				
				return ""
				
			elseif ply:GetPData( "eastereggs1" ) and ply:GetPData( "eastereggs1" ) == "true" then		
			
				ply:ChatPrint( "You have already found easter egg 1!" )		
				
			end		
			
		end	
		
	end )
	
	concommand.Add( "cc_egg2", function( ply )
	
		if not ( ply:GetPData( "eastereggs2" ) and ply:GetPData( "eastereggs2" ) == "true" ) then	
		
			ply:SetPData( "eastereggs2", "true" )		
			
			if not ply:GetPData( "eastereggs" ) then
				ply:SetPData( "eastereggs", 1 )
			else
				ply:SetPData( "eastereggs", ply:GetPData( "eastereggs" ) + 1 )
			end		
			
			ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #2!" )	
			
			if ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) == "3" then
				ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!" )
			elseif ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) ~= "3" then
				ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData( "eastereggs" ), white, "/3 easter eggs." )
			end
			
			for k, v in pairs( player.GetAll() ) do
				v:SendLua([[	surface.PlaySound( "garrysmod/content_downloaded.wav" )	]])
			end			
			
			return
			
		elseif ply:GetPData( "eastereggs2" ) and ply:GetPData( "eastereggs2" ) == "true" then	
		
			ply:ChatPrint( "You have already found easter egg 2!" )	
			
		end		
		
	end )
	
	net.Receive( "egg", function( len, ply )
	
		if not ( ply:GetPData( "eastereggs3" ) and ply:GetPData( "eastereggs3" ) == "true" ) then	
		
			ply:SetPData( "eastereggs3", "true" )	
			
			if not ply:GetPData( "eastereggs" ) then
				ply:SetPData( "eastereggs", 1 )
			else
				ply:SetPData( "eastereggs", ply:GetPData( "eastereggs" ) + 1 )
			end			
			
			ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #3!" )
			
			if ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) == "3" then
				ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!" )
			elseif ply:GetPData( "eastereggs" ) and ply:GetPData( "eastereggs" ) ~= "3" then
				ULib.tsayColor( nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData( "eastereggs" ), white, "/3 easter eggs." )
			end
			
			for k, v in pairs( player.GetAll() ) do
				v:SendLua([[	surface.PlaySound( "garrysmod/content_downloaded.wav" )	]])
			end		
			
			return
			
		elseif ply:GetPData( "eastereggs3" ) then
		
			if ply:GetPData( "eastereggs3" ) and ply:GetPData( "eastereggs3" ) == "true" then
				ply:ChatPrint( "You have already found easter egg 3!" )
			else
				return
			end		
			
		end		
		
	end )
	
end

if ( CLIENT ) then

	CreateConVar( "eastereggs_enable", "0" )
	
	cvars.AddChangeCallback( "eastereggs_enable", function( cvar, oldValue, newValue )	
	
		if oldValue == "0" and newValue == "1" then
			net.Start( "egg" )
			net.SendToServer()
		end		
		
	end )
	
end

function ulx.resetdata( calling_ply, target_ply )

	if target_ply:GetPData( "eastereggs" ) then
		target_ply:RemovePData( "eastereggs" )
	end
	
	if target_ply:GetPData( "eastereggs1" ) then
		target_ply:RemovePData( "eastereggs1" )
	end
	
	if target_ply:GetPData( "eastereggs2" ) then
		target_ply:RemovePData( "eastereggs2" )
	end
	
	if target_ply:GetPData( "eastereggs3" ) then
		target_ply:RemovePData( "eastereggs3" )
	end
	
	ulx.fancyLogAdmin( calling_ply, true, "#A reset data for #T", target_ply )
	
end
local resetdata = ulx.command( "Custom", "ulx resetdata", ulx.resetdata )
resetdata:addParam{ type=ULib.cmds.PlayerArg }
resetdata:help( "Reset easter egg data." )


