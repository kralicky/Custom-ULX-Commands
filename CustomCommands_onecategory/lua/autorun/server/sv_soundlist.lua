
CreateConVar( "soundlist_usedefaultsounds", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_GAMEDLL } )
util.AddNetworkString("sounds_yo")
local blacklist = {
"sound/ambient/construct_tone.wav",
"sound/ambient/forest_day.wav",
"sound/ambient/forest_night.wav",
"sound/garrysmod/balloon_pop_cute.wav",
"sound/garrysmod/content_downloaded.wav",
"sound/garrysmod/save_load1.wav",
"sound/garrysmod/save_load2.wav",
"sound/garrysmod/save_load3.wav",
"sound/garrysmod/save_load4.wav",
"sound/garrysmod/ui_click.wav",
"sound/garrysmod/ui_hover.wav",
"sound/garrysmod/ui_return.wav",
"sound/phx/eggcrack.wav",
"sound/phx/epicmetal_hard.wav",
"sound/phx/epicmetal_hard1.wav",
"sound/phx/epicmetal_hard2.wav",
"sound/phx/epicmetal_hard3.wav",
"sound/phx/epicmetal_hard4.wav",
"sound/phx/epicmetal_hard5.wav",
"sound/phx/epicmetal_hard6.wav",
"sound/phx/epicmetal_hard7.wav",
"sound/phx/epicmetal_soft1.wav",
"sound/phx/epicmetal_soft2.wav",
"sound/phx/epicmetal_soft3.wav",
"sound/phx/epicmetal_soft4.wav",
"sound/phx/epicmetal_soft5.wav",
"sound/phx/epicmetal_soft6.wav",
"sound/phx/epicmetal_soft7.wav",
"sound/phx/explode00.wav",
"sound/phx/explode01.wav",
"sound/phx/explode02.wav",
"sound/phx/explode03.wav",
"sound/phx/explode04.wav",
"sound/phx/explode05.wav",
"sound/phx/explode06.wav",
"sound/phx/hmetal1.wav",
"sound/phx/hmetal2.wav",
"sound/phx/hmetal3.wav",
"sound/phx/kaboom.wav",
"sound/sfx/skidding.wav",
"sound/thrusters/hover00.wav",
"sound/thrusters/hover01.wav",
"sound/thrusters/hover02.wav",
"sound/thrusters/jet00.wav",
"sound/thrusters/jet01.wav",
"sound/thrusters/jet02.wav",
"sound/thrusters/jet03.wav",
"sound/thrusters/jet04.wav",
"sound/thrusters/mh1.wav",
"sound/thrusters/mh2.wav",
"sound/thrusters/rocket00.wav",
"sound/thrusters/rocket01.wav",
"sound/thrusters/rocket02.wav",
"sound/thrusters/rocket03.wav",
"sound/thrusters/rocket04.wav"
}

local good = {
	mp3 = 1,
	wav = 1,
	ogg = 1
}
local find  = file.Find
local sub   = string.sub
local isdir = file.IsDir
local pairs = pairs

local function FindAllIn( dir, path )

	local tab = {}

	local function ScanRecursive( dir, tab )

		local files, folder = find( dir .. "/*", path )

		if folder then
			for k, v in pairs( folder ) do
				files[#files+1] = v
			end
		end

		if not files then
			files = {}
		end

		for k, x in pairs( files ) do

			local ext = sub( x, -3 )
			local y = dir .. "/" .. x

			if not good[ ext ] or isdir( x, path ) then
				ScanRecursive( y, tab )
			elseif good[ ext ] then
				if not tab[y] then
					tab[y] = true
				end
			end

		end

	end

	ScanRecursive( dir, tab )

	return tab

end

local temp = {}
for k, v in pairs(blacklist) do
	temp[v] = true
end
blacklist = temp


local usedefaultsounds = GetConVar("soundlist_usedefaultsounds")
local allSounds

local function SendSounds( ply)
	if ply:IsValid()  then
		net.Start("sounds_yo")
			net.WriteUInt(#allSounds, 16)
			net.WriteData(allSounds, #allSounds)
		net.Send(ply)
	end
end

local function SoundsCommand( ply, c, a )
	if not ULib.ucl.query(ply, "ulx soundlist") then ULib.tsayError( ply, "You are not allowed to request the sound list." ) return end
	if allSounds then
		return SendSounds(ply)
	end
	-- Change to GAME if you want addon sounds to show up; doing so will cause massive lag when the menu is opened so it is disabled by default
	local t = table.GetKeys(FindAllIn( "sound", "MOD" ))

	if not usedefaultsounds:GetBool() then
		for k, v in pairs(t) do
			if not blacklist[v] then
				t[k] = ""
			end
		end
	end

	allSounds = util.Compress( table.concat(t, "\n") )
	SendSounds(ply)
end
concommand.Add( "sounds_request", SoundsCommand )

cvars.AddChangeCallback( "soundlist_usedefaultsounds", function( cvarName, oldValue, newValue )
	allSounds = nil
	for k, v in pairs( player.GetAll() ) do
		umsg.Start( "resetlist", v )
		umsg.End()
	end

	Msg( "[CC] ConVar \"soundlist_usedefaultsounds\" changed to " .. newValue .. "\n" )

end )
