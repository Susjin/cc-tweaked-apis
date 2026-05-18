# ComputerCraft: Tweaked APIs

This repository contains a bunch of useful APIs to use with the Minecraft mod ComputerCraft: Tweaked.  
Currently, contains the following APIs:

## ButtonAPI

Based on the [direwolf20 Button API](https://www.youtube.com/watch?v=1nuMDtmnEjg).  
This API implements a way of creating buttons on a monitor using OOP.  
You can check the [documentation](ButtonAPI.md) for help on how to use it.  

To get the API, use the following command on your CC computer:  
```lua
wget "https://raw.githubusercontent.com/Susjin/cc-tweaked-apis/dev/install.lua"
```
This code will download a folder named *"ButtonAPI"* that contains all the files needed for it to work.  
***OBS***: To update the API, run the same command, and it will overwrite the existing files with the ones on the new version.
### Example:
```lua
local ButtonAPI = require("ButtonAPI")
local manager = ButtonAPI.ButtonsManager.new("monitor_0")

--Declare your button variables before creating the button, or set the fucntion later.
local function changeState(button)
    button:toggle()
end

--Default button
local button1 = ButtonAPI.Button.new("b1", "Zombie", changeState, 10, 20, 8, 10)
--Button with custom colors
local button2 = ButtonAPI.Button.new("b2", "Creeper", changeState, 10, 20, 3, 5, colors.black, colors.yellow, colors.blue)
manager:addToList(button1, button2)

manager:clearScreen()
manager:heading("Mob Spawner Farm")
manager:label(10, 12, "Test label")
manager:fillButtons()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    if manager:checkClick(x, y) then print("Button clicked!") end
end
```