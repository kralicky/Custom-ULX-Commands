hook.Add( "PlayerInitialSpawn", "checkversion", function( ply )
local version = "4.5"
	http.Fetch( "http://frost.site.nfoservers.com/version/version.txt", function( body, len, headers, code ) 
		if string.Trim( tostring( body ) ) ~= tostring( version ) then
			timer.Simple( 4, function()
				if ply:IsAdmin() then
					ply:ChatPrint( "CustomCommands is out of date! Your version is " .. version .. ". The current version is " .. string.Trim( tostring( body ) ) .. ".\nGet the newest version at http://coderhire.com/scripts/view/660" )
					for i=1,5 do
						ply:SendLua([[surface.PlaySound("Resource/warning.wav")]])
					end
				end
			end )
			ply:PrintMessage( HUD_PRINTCONSOLE, "ULX Custom Commands by Cobalt77 version " .. version .. " loaded!\nVersion is not up to date! Most Recent Version: " .. string.Trim( tostring( body ) )  )
		else
			ply:PrintMessage( HUD_PRINTCONSOLE, "ULX Custom Commands by Cobalt77 version " .. version .. " loaded!\nVersion is up to date!" )
		end 
	end )
end )