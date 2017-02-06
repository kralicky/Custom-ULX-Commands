------------------------------------------
--  This file holds menu related items  --
------------------------------------------

-- Edit cc_cvars.lua for more information as to how this works.

function ulx.google( calling_ply, search )

	calling_ply:SendLua( [[ gui.OpenURL( "]] .. GetConVarString( "google_url" ) .. [[" )]] )
	
end
local google = ulx.command( "Custom", "ulx google", ulx.google, "!google" )
google:defaultAccess( ULib.ACCESS_ALL )
google:help( "Opens Google." )
