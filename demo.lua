local ButtonAPI = require("ButtonAPI")


local manager = ButtonAPI.ButtonsManager.new("monitor_0")

manager:clearScreen()
manager:heading("Mob Spawner Farm")

local function toggle(button)
    button:toggle()
end




local button1 = ButtonAPI.Button.new("b1", "Creeper", toggle, 10, 20, 3, 5, colors.black, colors.yellow, colors.blue)
local button2 = ButtonAPI.Button.new("b2", "Zombie", toggle, 10, 20, 8, 10)
manager:addToList(button1)
manager:addToList(button2)

manager:loadDataJSON("data")

manager:fillButtons()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    if manager:checkClick(x, y) then print("Done"); manager:storeDataJSON("data"); end
end