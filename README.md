# ribbet
A Love2d library that adds a button and tab ribbon at the top of the window.

some config options are found in the ribbet.lua file at the top.

To use simply add the ribbet folder to the folder containing main.lua

Add the following to the top of the main.lua file.

local Ribbet = require("ribbet")

Building "fly" contents :

  local flycontents = {
    Ribbet.buildTab("tabname", flytabcontents)
  }

flytabcontents is filled with the following :

  click = funtion() whatevercode.youwant() end

and
  
  hotKey = {"key pressed", "key held", ...}

hotKey's keypressed can be any key press check ex, "i", "space" or "escape"
and the keyheld and any string of a key passed in after must be held to active the hotkey.

Building a Tabs contents called a "fly" :

  local tabcontents = {}
  tabcontents.fly = Ribbet.buildFly(flycontents)

Adding a new tab to top bar:

  local tab = Ribbet.buildTab("tabname", tabcontents)
  Ribbet:addTab(tab)

tabcontents can be nil, making a empty tab.

My apologies if this is confusing, I'm not good at explaining what code does very well...
