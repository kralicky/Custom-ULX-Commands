local soundsTable = {}

function OpenPanelSounds( ply, cmd, args, str )

	if not ULib.ucl.query(ply, "ulx soundlist") then
		chat.AddText( Color( 255, 127, 0 ), "You are not allowed to open the soundlist." )
		return
	end

	local main = vgui.Create( "DFrame" )

	main:SetPos( 50, 50 )
	main:SetSize( 350, 550 )
	main:SetTitle( "Sound List" )
	main:SetVisible( true )
	main:SetDraggable( true )
	main:ShowCloseButton( false )
	main:MakePopup()
	main:Center()


	local list = vgui.Create( "DListView" )
	list:SetParent( main )
	list:SetPos( 4, 27 )
	list:SetSize( 342, 519 )
	list:SetMultiSelect( false )
	list:AddColumn( "Sound" )

	list.OnRowRightClick = function( main, line )

        local menu = DermaMenu()

			menu:AddOption( "Play for all", function()
				RunConsoleCommand( "ulx", "playsound", tostring( list:GetLine( line ):GetValue( 1 ) ) )
			end ):SetIcon("icon16/control_play_blue.png")

			menu:AddOption( "Play for self", function()
				RunConsoleCommand( "play", tostring( list:GetLine( line ):GetValue( 1 ) ) )
				chat.AddText( Color( 151, 211, 255 ), "Sound ", Color( 0, 255, 0 ), tostring( list:GetLine( line ):GetValue( 1 ) ), Color( 151, 211, 255 ), " playing locally." )
			end ):SetIcon("icon16/control_play.png")

			menu:AddOption( "Stop all sounds", function()
				RunConsoleCommand( "ulx", "stopsounds" )
			end ):SetIcon("icon16/control_stop_blue.png")

			menu:AddOption( "Stop sounds for self", function()
				RunConsoleCommand( "stopsound" )
				chat.AddText( Color( 151, 211, 255 ), "Stopped sounds locally." )
			end ):SetIcon("icon16/control_stop.png")

		menu:Open()

	end

	if ( table.Count( soundsTable ) == 0 ) then

		RunConsoleCommand( "sounds_request" )
		list:AddLine( "Please wait while the list populates..." )

		timer.Simple( 2, function()

			list:RemoveLine( 1 )

			for k, v in pairs( soundsTable ) do
				list:AddLine( v )
			end

			list:SortByColumn( 1, false )
			main:ShowCloseButton( true )

		end )

		return

	end

	for k, v in pairs( soundsTable ) do

		list:AddLine( v )

		list:SortByColumn( 1, false )
		main:ShowCloseButton( true )

	end

end
concommand.Add( "menu_sounds", OpenPanelSounds )

net.Receive( "sounds_yo", function()
	local len = net.ReadUInt(16)
	local data = util.Decompress(net.ReadData(len))

	for k, v in pairs(string.Explode("\n", data, false)) do
		if v == "" then continue end
		soundsTable[v] = v
	end

end)

usermessage.Hook( "resetlist", function()
	soundsTable = {}

	RunConsoleCommand( "sounds_request" )

end )