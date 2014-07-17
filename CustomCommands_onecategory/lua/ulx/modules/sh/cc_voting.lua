---------------------------------------
--  This file holds voting commands  --
---------------------------------------

local function voteGagDone2( t, target, time, ply )

	local shouldGag = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
	
		ulx.logUserAct( ply, target, "#A approved the votegag against #T (" .. time .. " minutes)" )
		
		shouldGag = true
		
	else
	
		ulx.logUserAct( ply, target, "#A denied the votegag against #T" )
		
	end

	if shouldGag then
	
		target:SetPData( "votegagged", time )
		target.cc_voting_votegagged = true
	end
	
end

local function voteGagDone( t, target, time, ply )

	local results = t.results
	
	local winner
	
	local winnernum = 0
	
	for id, numvotes in pairs( results ) do
	
		if numvotes > winnernum then
		
			winner = id
			
			winnernum = numvotes
			
		end
		
	end

	local ratioNeeded = GetConVarNumber( "ulx_votegagSuccessratio" )
	
	local minVotes = GetConVarNumber( "ulx_votegagMinvotes" )
	
	local str
	
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
	
		str = "Vote results: User will not be gagged. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
		
	else
	
		str = "Vote results: User will now be gagged for " .. time .. " minutes, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
		
		ulx.doVote( "Accept result and gag " .. target:Nick() .. "?", { "Yes", "No" }, voteGagDone2, 30000, { ply }, true, target, time, ply )
		
	end

	ULib.tsay( _, str )
	
	ulx.logString( str )
	
	Msg( str .. "\n" )
	
end


function ulx.votegag( calling_ply, target_ply, minutes )

	if voteInProgress then
	
		ULib.tsayError( calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true )
		
		return
		
	end

	local msg = "Gag " .. target_ply:Nick() .. " for " .. minutes .. " minutes?"

	ulx.doVote( msg, { "Yes", "No" }, voteGagDone, _, _, _, target_ply, minutes, calling_ply )
	
	ulx.fancyLogAdmin( calling_ply, "#A started a votegag of #i minute(s) against #T", minutes, target_ply )
	
end
local votegag = ulx.command( "Custom", "ulx votegag", ulx.votegag, "!votegag" )
votegag:addParam{ type=ULib.cmds.PlayerArg }
votegag:addParam{ type=ULib.cmds.NumArg, min=0, default=3, hint="minutes", ULib.cmds.allowTimeString, ULib.cmds.optional }
votegag:defaultAccess( ULib.ACCESS_ALL )
votegag:help( "Starts a public vote gag against target." )
if SERVER then ulx.convar( "votegagSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votegagMinvotes", "3", _, ULib.ACCESS_ADMIN ) end

timer.Create( "votegagtimer", 60, 0, function()

	for k,v in pairs( player.GetAll() ) do
		
		local gag = v:GetPData( "votegagged" )

		if ( gag and gag != "0") then
			
			if ( not v.cc_voting_votegagged ) then
				v.cc_voting_votegagged = true
			end

			v:SetPData( "votegagged", tonumber( gag ) - 1 )
			
			timer.Simple( 0.5, function()
				
				local gag = v:GetPData( "votegagged" )
				if gag == "0" then
				
					v:RemovePData( "votegagged" )
					v.cc_voting_votegagged = nil
					ULib.tsay( nil, v:Nick() .. " was auto-ungagged." )
					
				end
				
			end )

		end

	end
	
end )

function ulx.unvotegag( calling_ply, target_plys )

	for k,v in pairs( target_plys ) do
	
		if ( v:GetPData( "votegagged" ) and v:GetPData( "votegagged" ) ~= 0 and v:GetPData( "votegagged" ) ~= "0" ) then
	
			v:RemovePData( "votegagged" )
			v.cc_voting_votegagged = nil
			ulx.fancyLogAdmin( calling_ply, "#A ungagged #T", target_plys )
			
		else
		
			ULib.tsayError( calling_ply, v:Nick() .. " is not gagged." )
			
		end
		
	end
	
end
local unvotegag = ulx.command( "Custom", "ulx unvotegag", ulx.unvotegag, "!unvotegag" )
unvotegag:addParam{ type=ULib.cmds.PlayersArg }
unvotegag:defaultAccess( ULib.ACCESS_ADMIN )
unvotegag:help( "Ungag the player" )

local function ulxvotegaghook( listener, talker )
	
	local gag = talker.cc_voting_votegagged

	if ( gag and gag != 0 and gag != "0" ) then

		return false
		
	end
	
end
hook.Add("PlayerCanHearPlayersVoice", "ulxvotegaghooks", ulxvotegaghook )


-- ULX Votemute --

local function voteMuteDone2( t, target, time, ply )

	local shouldMute = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
	
		ulx.logUserAct( ply, target, "#A approved the vote mute against #T (" .. time .. " minutes)" )
		
		shouldMute = true
		
	else
	
		ulx.logUserAct( ply, target, "#A denied the vote mute against #T" )
		
	end

	if shouldMute then
	
		target:SetPData( "votemuted", time )
	
	end
	
end

local function voteMuteDone( t, target, time, ply )

	local results = t.results
	
	local winner
	
	local winnernum = 0
	
	for id, numvotes in pairs( results ) do
	
		if numvotes > winnernum then
		
			winner = id
			
			winnernum = numvotes
			
		end
		
	end

	local ratioNeeded = GetConVarNumber( "ulx_votemuteSuccessratio" )
	
	local minVotes = GetConVarNumber( "ulx_votemuteMinvotes" )
	
	local str
	
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
	
		str = "Vote results: User will not be muted. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
		
	else
	
		str = "Vote results: User will now be muted for " .. time .. " minutes, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
		
		ulx.doVote( "Accept result and mute " .. target:Nick() .. "?", { "Yes", "No" }, voteMuteDone2, 30000, { ply }, true, target, time, ply )
		
	end

	ULib.tsay( _, str )
	
	ulx.logString( str )
	
	Msg( str .. "\n" )
	
end


function ulx.votemute( calling_ply, target_ply, minutes )

	if voteInProgress then
	
		ULib.tsayError( calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true )
		
		return
		
	end

	local msg = "Mute " .. target_ply:Nick() .. " for " .. minutes .. " minutes?"

	ulx.doVote( msg, { "Yes", "No" }, voteMuteDone, _, _, _, target_ply, minutes, calling_ply )
	
	ulx.fancyLogAdmin( calling_ply, "#A started a vote mute of #i minute(s) against #T", minutes, target_ply )
	
end
local votemute = ulx.command( "Custom", "ulx votemute", ulx.votemute, "!votemute" )
votemute:addParam{ type=ULib.cmds.PlayerArg }
votemute:addParam{ type=ULib.cmds.NumArg, min=0, default=3, hint="minutes", ULib.cmds.allowTimeString, ULib.cmds.optional }
votemute:defaultAccess( ULib.ACCESS_ALL )
votemute:help( "Starts a public vote mute against target." )
if SERVER then ulx.convar( "votemuteSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) ulx.convar( "votemuteMinvotes", "3", _, ULib.ACCESS_ADMIN ) end

timer.Create( "votemutetimer", 60, 0, function()

	for k,v in pairs( player.GetAll() ) do
	
		if ( not v or not IsValid(v) ) then return end

			if ( v:GetPData( "votemuted" ) and v:GetPData( "votemuted" ) ~= 0 and v:GetPData( "votemuted" ) ~= "0" ) then

			v:SetPData( "votemuted", tonumber( v:GetPData( "votemuted" ) ) - 1 )
					
			timer.Simple( 0.5, function()
					
				if v:GetPData( "votemuted" ) == 0 or v:GetPData( "votemuted" ) == "0" then
						
					v:RemovePData( "votemuted" )
							
					ULib.tsay( nil, v:Nick() .. " was auto-unmuted." )
							
				end
						
			end )

		end

	end

end )

function ulx.unvotemute( calling_ply, target_plys )

	for k,v in pairs( target_plys ) do
	
		if ( v:GetPData( "votemuted" ) and v:GetPData( "votemuted" ) ~= 0 and v:GetPData( "votemuted" ) ~= "0" ) then
	
			v:RemovePData( "votemuted" )
			
			ulx.fancyLogAdmin( calling_ply, "#A unmuted #T", target_plys )
			
		else
		
			ULib.tsayError( calling_ply, v:Nick() .. " is not muted." )
			
		end
		
	end
	
end
local unvotemute = ulx.command( "Custom", "ulx unvotemute", ulx.unvotemute, "!unvotemute" )
unvotemute:addParam{ type=ULib.cmds.PlayersArg }
unvotemute:defaultAccess( ULib.ACCESS_ADMIN )
unvotemute:help( "Unmute the player" )

local function ulxvotemutehook( ply )

	if ( ply:GetPData( "votemuted" ) and ply:GetPData( "votemuted" ) ~= 0 and ply:GetPData( "votemuted" ) ~= "0" ) then

		return ""
		
	end
	
end
hook.Add( "PlayerSay", "ulxvotemutedhook", ulxvotemutehook )