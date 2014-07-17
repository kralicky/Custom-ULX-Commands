-------------------------------------
--  This file holds the chat tags  --
-------------------------------------

if ( SERVER ) then

	AddCSLuaFile( )
	
	return
	
end

if ( CLIENT ) then

local string = string

local str = string

local str2

local TagColor = {}

--TagColor["YourCustomUsergroupNameHere"] = Color( red, green, blue )

TagColor["operator"] = Color( 0, 255, 0 )

TagColor["admin"] = Color( 220, 180, 0 )

TagColor["superadmin"] = Color( 255, 0, 0 )

local function OnPlayerChat( ply, strText, bTeamOnly, bPlayerIsDead )

	local tab = {}
	
	local defcol = Color( 0, 201, 0 )

	if ( bPlayerIsDead ) then
	
		table.insert( tab, Color( 255, 30, 40 ) )
		
		table.insert( tab, "*DEAD* " )
		
	end
	
	if ( bTeamOnly ) then
	
		table.insert( tab, Color( 30, 160, 40 ) )
		
		table.insert( tab, "(TEAM) " )
		
	end
	
	if ( IsValid( ply ) ) then
	
		if ( ply.GetUserGroup ) then
		
			if ( ply:GetUserGroup() ~= "user" ) then
			
				table.insert( tab, TagColor[ ply:GetUserGroup() ] or Color( 255, 255, 255 ) )
				
				str = ply:GetUserGroup()
				
				str2 = str
				
				if string.find( str2, "%s" ) then
				
					string.sub( str2, string.find( str2, "%s" ), string.len( str2 ) )
					
					str2 = str2:gsub( "^%l", string.upper )
					
				end
				
				str = str:gsub( "^%l", string.upper )
				
				table.insert( tab, "[" .. str .. "] " )
				
			end
			
		end

		table.insert( tab, defcol )
		
		table.insert( tab, ply:GetName() )
		
	else
	
		table.insert( tab, "Console" )
		
	end

	table.insert( tab, Color( 255, 255, 255 ) )
	
	table.insert( tab, ": "..strText )
 
	chat.AddText( unpack( tab ) )
 
	return true
	
end
hook.Add( "OnPlayerChat", "Tags.OnPlayerChat", OnPlayerChat )

end --End clientside 
