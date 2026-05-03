--Initialization of the ButtonAPI
--Returns the two main workers of the library. You can use then separatly or together
--Separatly:
--In your code, do the following: 'local Button, ButtonsManager = require("ButtonAPI")'
--Where 'ButtonAPI' is the folder with the three main files (init.lua, ButtonsManager.lua and Button.lua)
--Together:
--In your code, do the following: 'local ButtonAPI = {}; ButtonAPI.Button, ButtonAPI.ButtonsManager = require("ButtonAPI");'
--Where 'ButtonAPI' is the folder with the three main files (init.lua, ButtonsManager.lua and Button.lua)

local Button = require("ButtonAPI.button")
local ButtonsManager = require("ButtonAPI.buttons")

return Button, ButtonsManager