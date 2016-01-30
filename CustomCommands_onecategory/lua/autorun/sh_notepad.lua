if SERVER then

	util.AddNetworkString( "GetContents" )
	util.AddNetworkString( "SendContents" )
	util.AddNetworkString( "WriteQuery" )
	util.AddNetworkString( "sendUpdate" )
	
	if not file.Exists( "notepad", "DATA" ) then
		file.CreateDir( "notepad" )
	end
	
	if not file.Exists( "notepad/note.txt", "DATA" ) then
		file.Write( "notepad/note.txt", "ULX Notepad by Cobalt77" )
	end

	function OpenNotepadChecks( ply )

		if not ULib.ucl.query(ply, "ulx notepad") then
			ULib.tsayError( ply, "You are not allowed to open this menu." )
			return
		end
		
		for k, v in pairs( player.GetAll() ) do
			if v:GetPData( "notepad" ) == "true" and v ~= ply then			
				umsg.Start( "DQuery", ply )
					umsg.String( v:Nick() )
				umsg.End()		
				return				
			end
		end
		
		umsg.Start( "OpenMenu", ply )
		umsg.End()
		
		ply:SetPData( "notepad", "true" )
		
	end
	concommand.Add( "notepad_open", OpenNotepadChecks )

	hook.Add( "PlayerInitialSpawn", "givepeoplestuff", function( ply )
		if not ULib.ucl.query(ply, "ulx notepad") then return end
		local contents = file.Read( "notepad/note.txt" )
		
		net.Start( "SendContents" )
			net.WriteString( contents )
		net.Send( ply )
		
	end )
	
	net.Receive( "GetContents", function( len, ply )
		if not ULib.ucl.query(ply, "ulx notepad") then
			ULib.tsayError( ply, "You are not allowed to open this menu." )
			return
		end
		local contents = file.Read( "notepad/note.txt" )
		
		net.Start( "SendContents" )
			net.WriteString( contents )
		net.Send( ply )
		
	end )
	
	net.Receive( "WriteQuery", function( len, ply )
		if not ULib.ucl.query(ply, "ulx notepad") then
			ULib.tsayError( ply, "You are not allowed to open this menu." )
			return
		end
		local toWrite = net.ReadString()
		
		if file.Exists( "notepad/note.txt", "DATA" ) then
			file.Write( "notepad/note.txt", toWrite )
		end
		
	end )
	
	net.Receive( "sendUpdate", function( len, ply )
		
		if ply:GetPData( "notepad" ) and ply:GetPData( "notepad" ) == "true" then
			ply:RemovePData( "notepad" )
		end
	
	end )
	
	hook.Add( "PlayerDisconnected", "pdataRemoveDC", function( ply )
	
		if ply:GetPData( "notepad" ) and ply:GetPData( "notepad" ) == "true" then
			ply:RemovePData( "notepad" )
		end
		
	end )
	
	hook.Add( "PlayerAuthed", "pdataRemoveAuth", function( ply )
	
		if ply:GetPData( "notepad" ) and ply:GetPData( "notepad" ) == "true" then
			ply:RemovePData( "notepad" )
		end
		
	end )
	
end

if CLIENT then

	local t
	
	net.Receive( "SendContents", function()
		t = net.ReadString()
	end )
	
	function MenuOpen()	

		net.Start( "GetContents" )
			net.WriteFloat( 1 )
		net.SendToServer()
	
		local main = vgui.Create( "DFrame" )

		main:SetPos( 50, 50 )
		main:SetSize( 650, 500 )
		main:SetTitle( "Notepad" )	
		main:SetVisible( true )
		main:SetDraggable( true )
		main:ShowCloseButton( false )
		main:MakePopup()
		main:Center()

		local text = vgui.Create( "DTextEntry", main )

		text:SetPos( 4, 27 )
		text:SetSize( 642, 469 )
		text:SetMultiline( true )
		
		text:SetText( "Please wait while the content loads..." )
		
		timer.Simple( 1, function()
			text:SetText( t or "No content found!" )
			main:ShowCloseButton( true )
		end )
		
		main.OnClose = function()

			local toWrite = text:GetText()
			
			net.Start( "WriteQuery" )
				net.WriteString( toWrite )
			net.SendToServer()
			
			net.Start( "sendUpdate" )
			net.SendToServer()

		end
		
	end
	
	function MenuOpenReadOnly()	

		net.Start( "GetContents" )
			net.WriteFloat( 1 )
		net.SendToServer()
	
		local main = vgui.Create( "DFrame" )

		main:SetPos( 50, 50 )
		main:SetSize( 650, 500 )
		main:SetTitle( "Notepad (READ ONLY)" )	
		main:SetVisible( true )
		main:SetDraggable( true )
		main:ShowCloseButton( false )
		main:MakePopup()
		main:Center()

		local text = vgui.Create( "DTextEntry", main )

		text:SetPos( 4, 27 )
		text:SetSize( 642, 469 )
		text:SetMultiline( true )
		
		text:SetText( "Please wait while the content loads..." )
		
		timer.Simple( 1, function()
			text:SetText( t or "No content found!" )
			main:ShowCloseButton( true )
		end )
		
		main.OnClose = function()
			chat.AddText( "No text saved, you were in read-only mode." )
		end
		
	end
	
	usermessage.Hook( "OpenMenu", function( um )
		MenuOpen()
	end )
	
	usermessage.Hook( "OpenMenuReadOnly", function( um )
		MenuOpenReadOnly()
	end )
	
	usermessage.Hook( "DQuery", function( um )
	
		local pl = um:ReadString()
		
		Derma_Query( "Player " .. pl .. " is already using the notepad. Open in read-only mode?", "Notice",
			"Yes", function() MenuOpenReadOnly() end,
			"No", function() end
		)
		
	end )
	
end
