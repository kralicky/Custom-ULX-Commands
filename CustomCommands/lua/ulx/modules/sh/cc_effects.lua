local ulx_trailtable = {
"trails/tube.vmt",
"trails/electric.vmt",
"trails/smoke.vmt",
"trails/plasma.vmt",
"trails/lol.vmt",
"trails/physbeam.vmt",
"trails/laser.vmt",
"trails/love.vmt"
}

local ulx_trail_color_table = {  
"black",
"white", 
"red", 
"blue", 
"green", 
"orange", 
"purple", 
"pink", 
"gray", 
"maroon", 
"yellow" 
}

local ulx_materialtable = {
"models/wireframe",
"debug/env_cubemap_model",
"models/shadertest/shader3",
"models/shadertest/shader4",
"models/shadertest/shader5",
"models/shiny",
"models/debug/debugwhite",
"Models/effects/comball_sphere",
"Models/effects/comball_tape",
"Models/effects/splodearc_sheet",
"Models/effects/vol_light001",
"models/props_combine/stasisshield_sheet",
"models/props_combine/portalball001_sheet",
"models/props_combine/com_shield001a",
"models/props_c17/frostedglass_01a",
"models/props_lab/Tank_Glass001",
"models/props_combine/tprings_globe",
"models/rendertarget",
"models/screenspace",
"brick/brick_model",
"models/props_pipes/GutterMetal01a",
"models/props_pipes/Pipesystem01a_skin3",
"models/props_wasteland/wood_fence01a",
"models/props_foliage/tree_deciduous_01a_trunk",
"models/props_c17/FurnitureFabric003a",
"models/props_c17/FurnitureMetal001a",
"models/props_c17/paper01",
"models/flesh",
"phoenix_storms/metalset_1-2",
"phoenix_storms/metalfloor_2-3",
"phoenix_storms/plastic",
"phoenix_storms/wood",
"phoenix_storms/bluemetal",
"phoenix_storms/cube",
"phoenix_storms/dome",
"phoenix_storms/gear",
"phoenix_storms/stripes",
"phoenix_storms/wire/pcb_green",
"phoenix_storms/wire/pcb_red",
"phoenix_storms/wire/pcb_blue",
"hunter/myplastic"
}

local trailtab = {}

function ulx.trail( calling_ply, target_plys, color, startWidth, endWidth, lifeTime, texture, should_remove )
	
	if not should_remove then
	
		local colorarg

		if color == "pink" then
			colorarg = Color( 255, 0, 97 )
		elseif color == "black" then
			colorarg = Color( 5, 5, 5 )
		elseif color == "white" then
			colorarg = Color( 255, 255, 255 )
		elseif color == "red" then
			colorarg = Color( 255, 0, 0 )
		elseif color == "blue" then
			colorarg = Color( 0, 0, 255 )
		elseif color == "green" then
			colorarg = Color( 0, 255, 0 )
		elseif color == "orange" then
			colorarg = Color( 255, 127, 0 )
		elseif color == "purple" then
			colorarg = Color( 51, 0, 102 )
		elseif color == "gray" then
			colorarg = Color( 96, 96, 96 )
		elseif color == "maroon" then
			colorarg = Color( 128, 0, 0 )	
		elseif color == "yellow" then
			colorarg = Color( 255, 255, 0 )
		end

		for i = 1, #target_plys do	
		
			if trailtab[target_plys[i]:SteamID()] then
				SafeRemoveEntity( trailtab[target_plys[i]:SteamID()] )
			end
			
			trailtab[target_plys[i]:SteamID()] = util.SpriteTrail( target_plys[i], 0, colorarg, true, startWidth, endWidth, lifeTime, ( 1 / ( startWidth + endWidth ) * 0.5 ), texture )
			
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A applied trails on #T", target_plys )
	
	else
	
		for i = 1, #target_plys do
			if trailtab[target_plys[i]:SteamID()] then
				SafeRemoveEntity( trailtab[target_plys[i]:SteamID()] )
			end
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A removed trails from #T", target_plys )
	
	end
end
local trail = ulx.command( "Fun", "ulx trail", ulx.trail, "!trail" )
trail:addParam{ type=ULib.cmds.PlayersArg }
trail:addParam{ type=ULib.cmds.StringArg, hint="color", completes=ulx_trail_color_table, ULib.cmds.restrictToCompletes }
trail:addParam{ type=ULib.cmds.NumArg, default=16, hint="Start Width" }
trail:addParam{ type=ULib.cmds.NumArg, default=0, hint="End Width" }
trail:addParam{ type=ULib.cmds.NumArg, default=5, hint="Length" }
trail:addParam{ type=ULib.cmds.StringArg, hint="type", completes=ulx_trailtable, ULib.cmds.restrictToCompletes }
trail:addParam{ type=ULib.cmds.BoolArg, invisible=true }
trail:defaultAccess( ULib.ACCESS_ADMIN )
trail:help( "Add trails on players." )
trail:setOpposite( "ulx removetrail", { _, _, _, _, _, _, _, true }, "!removetrail" )

function ulx.material( calling_ply, target_plys, material, should_reset )

	if not should_reset then

		for _, v in ipairs( target_plys ) do
			v:SetMaterial( material )
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A set the material for #T to #s", target_plys, material )
		
	else
	
		for _, v in ipairs( target_plys ) do
			v:SetMaterial( nil )
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A reset the material for #T", target_plys )
		
	end
	
end
local material = ulx.command( "Fun", "ulx material", ulx.material, "!material" )
material:addParam{ type=ULib.cmds.PlayersArg }
material:addParam{ type=ULib.cmds.StringArg, hint="material", completes=ulx_materialtable, ULib.cmds.restrictToCompletes }
material:defaultAccess( ULib.ACCESS_ADMIN )
material:addParam{ type=ULib.cmds.BoolArg, invisible=true }
material:help( "Set a player's material." )
material:setOpposite( "ulx resetmaterial", { _, _, _, true }, "!resetmaterial" )

function ulx.color( calling_ply, target_plys, color, should_reset )

	if not should_reset then
	
		local colorarg2

		if color == "pink" then
			colorarg2 = Color( 255, 0, 97 )
		elseif color == "black" then
			colorarg2 = Color( 0, 0, 0 )
		elseif color == "white" then
			colorarg2 = Color( 255, 255, 255 )
		elseif color == "red" then
			colorarg2 = Color( 255, 0, 0 )
		elseif color == "blue" then
			colorarg2 = Color( 0, 0, 255 )
		elseif color == "green" then
			colorarg2 = Color( 0, 255, 0 )
		elseif color == "orange" then
			colorarg2 = Color( 255, 127, 0 )
		elseif color == "purple" then
			colorarg2 = Color( 51, 0, 102 )
		elseif color == "gray" then
			colorarg2 = Color( 96, 96, 96 )
		elseif color == "maroon" then
			colorarg2 = Color( 128, 0, 0 )	
		elseif color == "yellow" then
			colorarg2 = Color( 255, 255, 0 )
		end
		
		for _, v in ipairs( target_plys ) do
			v:SetColor( colorarg2 )
		end

		ulx.fancyLogAdmin( calling_ply, "#A set the color for #T to #s", target_plys, color )
		
	else
	
		for _, v in ipairs( target_plys ) do 
			v:SetColor( Color( 255, 255, 255 ) )
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A reset the color for #T", target_plys )
		
	end
	
end
local color = ulx.command( "Fun", "ulx color", ulx.color, "!setcolor" )
color:addParam{ type=ULib.cmds.PlayersArg }
color:addParam{ type=ULib.cmds.StringArg, hint="color", completes=ulx_trail_color_table, ULib.cmds.restrictToCompletes }
color:addParam{ type=ULib.cmds.BoolArg, invisible=true }
color:defaultAccess( ULib.ACCESS_ADMIN )
color:help( "Add trails on players." )
color:setOpposite( "ulx resetcolor", { _, _, _, true }, "!resetcolor" )