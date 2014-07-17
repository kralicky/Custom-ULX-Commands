------------------------------------------
--  This file holds menu related items  --
------------------------------------------

function ulx.donate( calling_ply )

	calling_ply:SendLua([[gui.OpenURL( "]] .. GetConVarString("donate_url") .. [[" )]])
	
end

local donate = ulx.command( "Custom", "ulx donate", ulx.donate, "!donate" )
donate:defaultAccess( ULib.ACCESS_ALL )
donate:help( "View donation information." )