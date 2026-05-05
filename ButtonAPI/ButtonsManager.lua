---Buttons Manager Class
---
---With this class, you can use button objects with the Button class, and render then on the monitor
---
---You can tweak the background and text color of the monitor
---@class ButtonsManager
---@field buttons Button[] An array of buttons
---@field monitor ccTweaked.peripherals.Monitor? Monitor to display the buttons
---@field defaultBGColor ccTweaked.colors.color Default background color of the monitor
---@field defaultTextColor ccTweaked.colors.color Default text color of the monitor
local ButtonsManager = {}
ButtonsManager.__index = ButtonsManager

---Creates a new list of buttons
---@param monitor string Name of the monitor or side it is attached
---@param defaultTextColor ccTweaked.colors.color? (Optional) Default text color of the monitor (default to white)
---@param defaultBackgroundColor ccTweaked.colors.color? (Optional) Default background color of the monitor (default to black)
---@return ButtonsManager
function ButtonsManager.new(monitor, defaultTextColor, defaultBackgroundColor)
    local bts = setmetatable({}, ButtonsManager)
    bts.buttons = {}
    bts.monitor = peripheral.wrap(monitor)
    bts.defaultBGColor = defaultBackgroundColor or colors.black
    bts.defaultTextColor = defaultTextColor or colors.white

    return bts
end

---Checks if a given text has a even lenght. Returns the lenght and if it's even
---@param text string Text to be checked
---@return integer lenght Lenght of that text
---@return integer sum Number to sum when checking where to place text
function ButtonsManager.checkText(text)
    local lenght = string.len(text)
    local even = lenght % 2 == 0
    return lenght, even and 1 or 1
end

---Adds a button to the list of buttons
---@param button Button
function ButtonsManager:addToList(button)
    self.buttons[button.name] = button
    self.buttons[button.name].manager = self
end

function ButtonsManager:clearScreen()
    self.monitor.setBackgroundColor(self.defaultBGColor)
    self.monitor.clear()
end

---Fills a button on a given place of the screen
---@param button Button The button to be filled on the screen
function ButtonsManager:fillButton(button)
    if not self.monitor then printError("Monitor not set/found!"); return; end
    
    local oldTextColor = self.monitor.getTextColor()

    local buttonBackgroundColor = button.colorInactive
    if button.state then buttonBackgroundColor = button.colorActive end
    self.monitor.setBackgroundColor(buttonBackgroundColor)

    local lenght, sum = self.checkText(button.text)

    local yspot = math.floor((button.y1 + button.y2) / 2) --Position relatively to the monitor size (eg. '3' is the third pixel of the monitor on the Y level)
    local xspot = math.floor((button.x2 - button.x1 - lenght) / 2) + sum --Position relatively to the button size (eg. '4' is the fourth pixel of the Button on the X level)
    for i = button.y1, button.y2 do
        self.monitor.setCursorPos(button.x1, i)
        self.monitor.setTextColor(button.textColor)
        if i == yspot then
            for j = 0, button.x2 - button.x1 - lenght + 1 do --Used to get the total of blank spaces + the first letter of the text
                if j == xspot then
                    self.monitor.write(button.text)
                else
                    self.monitor.write(" ")
                end
            end
        else
            for _ = button.x1, button.x2 do
                self.monitor.write(" ")
            end
        end
    end

    self.monitor.setTextColor(oldTextColor)
    self.monitor.setBackgroundColor(self.defaultBGColor)
end

---Fills the screen with all buttons in the current list
function ButtonsManager:fillButtons()
    for _, buttonData in pairs(self.buttons) do
        self:fillButton(buttonData)
    end
end

---Given a X and Y coordinate, checks if it was inside of one of the buttons, if so, execute the funcion and returns true
---@param x integer X coordinate of the clicked pixel of the monitor
---@param y integer Y coordinate of the clicked pixel of the monitor
---@return boolean
function ButtonsManager:checkClick(x, y)
    for _, button in pairs(self.buttons) do
        if x >= button.x1 and x <= button.x2  then
            if y >= button.y1 and y <= button.y2 then
               if button.func then button:func() end
               return true
            end
        end
    end
    return false
end

function ButtonsManager:heading(text)
    local width, _ = self.monitor.getSize()
    local lenght, sum = self.checkText(text)
    local oldTextColor = self.monitor.getTextColor()
    
    self.monitor.setCursorPos((width - lenght) / 2 + sum, 1)
    self.monitor.setTextColor(self.defaultTextColor)
    self.monitor.write(text)
    self.monitor.setTextColor(oldTextColor)
end

function ButtonsManager:label(x, y, text)
    local oldTextColor = self.monitor.getTextColor()

    self.monitor.setCursorPos(x, y)
    self.monitor.setTextColor(self.defaultTextColor)
    self.monitor.write(text)
    self.monitor.setTextColor(oldTextColor)
end

---Returns a table with only the button state data and it's
---@return table<string, boolean> buttons Contains the name and the state of all buttons
function ButtonsManager:getButtonsStates()
    local buttons = {}
    for name, button in pairs(self.buttons) do
        buttons[name] = {}
        buttons[name].state = button.state
    end
    return buttons
end

---Saves all button states to a given file path
---@param filePath string Path to the file + it's name (*eg.: "data/buttons"*)(**The extension .json is not needed**)
function ButtonsManager:storeDataJSON(filePath)
    local buttons = self:getButtonsStates()
    local jsonData = textutils.serialiseJSON(buttons)
    local file = fs.open(filePath .. ".json", "w")
    if file then
        file.write(jsonData)
        file.close()
    end
end

---Loads all button states from a given file path
---@param filePath string Path to the file + it's name (*eg.: "data/buttons"*)(**The extension .json is not needed**)
function ButtonsManager:loadDataJSON(filePath)
    local file = fs.open(filePath .. ".json", "r")
    if not file then return "File could not be read, ignoring store data..." end

    local jsonData = file.readAll()
    if not jsonData then return "File is empty" end

    local buttonStates = textutils.unserialiseJSON(jsonData)
    if not buttonStates then return "Not a valid JSON file" end
    for name, state in pairs(buttonStates) do
        print(name)
        print(state.state)
        self.buttons[name].state = state.state
    end
end


return ButtonsManager