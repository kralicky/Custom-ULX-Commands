local version = "1.5.17"
http.Fetch("http://raw.githubusercontent.com/jkralicky/Custom-ULX-Commands/master/version.txt", function( body, len, headers, code)
  local nversion = body
  if nversion != version then 
    chat.AddText(Color(0,191,255), "[ULX-Custom-Commands]", color_white, ": A new version is available on GitHub.")
  end
end)
