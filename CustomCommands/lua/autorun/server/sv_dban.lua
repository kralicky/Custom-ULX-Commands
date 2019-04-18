util.AddNetworkString("disconnects_u")
local allDisconnected = {}

local function plyDiscoBan( ply )
	allDisconnected[#allDisconnected+1] = { ply:SteamID(), ply:Nick(), tostring( string.sub( tostring( ply:IPAddress() ), 1, string.len( ply:IPAddress() ) - 6 ) ), tostring( os.date( "%H:%M UTC%z" ) ) }
end
hook.Add( "PlayerDisconnected", "plyDiscoBan", plyDiscoBan )

local function printIDTable(ply)
	if IsValid(ply) then return end
	PrintTable( allDisconnected )
end
concommand.Add( "print_disc_steamids", printIDTable )

local function DisconnectsCommand( ply, c, a )

	if ply:IsValid() and ULib.ucl.query(ply, "ulx dban") then
		net.Start( "disconnects_u" )
			local str = util.Compress(util.TableToJSON(allDisconnected))
			net.WriteUInt(#str, 32)
			net.WriteData(str, #str)
		net.Send(ply)
	end

end

concommand.Add( "discs_request", DisconnectsCommand )
