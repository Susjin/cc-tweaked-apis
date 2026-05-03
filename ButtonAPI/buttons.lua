local Button = require("button.lua")

---@class Buttons
---@field buttons Button[] An array of buttons
---@field monitor ccTweaked.peripherals.Monitor? Monitor to display the buttons
local Buttons = {}
Buttons.__index = Buttons

---Creates a new list of buttons
---@param monitor string Name of the monitor or side it is attached
---@return Buttons
function Buttons.new(monitor)
    local bts = setmetatable({}, Buttons)
    bts.buttons = {}
    bts.monitor = peripheral.wrap(monitor)

    return bts
end

---Adds a button to the list of buttons
---@param button Button
function Buttons:addToList(button)
    self.buttons[button.name] = button
    self.buttons[button.name].parent = self
end

---Fills a button on a given place of the screen
---@param button Button The button to be filled on the screen
---@param customDefaultBackgroundColor ccTweaked.colors.color? (Optional) Can set the background color to a different one than black
function Buttons:fillButton(button, customDefaultBackgroundColor)
    if !self.monitor then printError("Monitor not set/found!"); return; end

    local buttonBackgroundColor = button.colorInactive
    if button.state then buttonBackgroundColor = button.colorActive end
    self.monitor.setBackgroundColor(buttonBackgroundColor)
    
    local yspot = math.floor((button.y1 + button.y2) / 2) --Position relatively to the monitor size (eg. '3' is the third pixel of the monitor on the Y level)
    local xspot = math.floor((button.x2 - button.x1 - string.len(button.text)) / 2) + 1 --Position relatively to the button size (eg. '4' is the fourth pixel of the Button on the X level)
    for i = button.y1, button.y2 do
        self.monitor.setCursorPos(button.x1, i)
        if i == yspot then
            for j = 0, button.x2 - button.x1 - string.len(button.text) + 1 do --Used to get the total of blank spaces + the first letter of the text
                if j == xspot then
                    self.monitor.write(button.text)
                else
                    self.monitor.write(" ")
                end
            end
        else
            for j = button.x1, button.x2 do
                self.monitor.write(" ")
            end
        end
    end

    self.monitor.setBackgroundColor(customDefaultBackgroundColor or colors.black)
end

---Fills the screen with all buttons in the current list
function Buttons:fillButtons()
    for _, buttonData in pairs(self.buttons) do
        local buttonBackgroundColor = buttonData.colorInactive
        self:fillButton(buttonData)
    end
end




return Buttons