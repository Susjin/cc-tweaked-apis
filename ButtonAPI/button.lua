---@class Button Main button class
---@field name string Name of the button to be indexed
---@field text string Text to be shown on the button (smaller than x2-x1)
---@field func function Function to be executed when the button is pressed (always put the argument self as first, because it will always pass itself)
---@field x1 integer Button's starting X position
---@field x2 integer Button's finishing X position
---@field y1 integer Button's starting Y position
---@field y2 integer Button's finishing Y position
---@field textColor ccTweaked.colors.color Background color of the button text, default is colors.white
---@field colorInactive ccTweaked.colors.color Background color of the button, default is colors.red
---@field colorActive ccTweaked.colors.color Background color of the button when activated, default is colors.lime 
---@field state boolean Current state of the button. True for active and false for inactive
---@field manager Buttons Parent of the button, responsible for it's rendering
local Button = {}
Button.__intex = Button

---Creates a new Button
---@param name string Name of the button to be indexed
---@param text string Text to be shown on the button (smaller than x2-x1)
---@param func function Function to be executed when the button is pressed (always put the argument self as first, because it will always pass itself)
---@param x1 integer Button's starting X position
---@param x2 integer Button's finishing X position
---@param y1 integer Button's starting Y position
---@param y2 integer Button's finishing Y position
---@param textColor ccTweaked.colors.color? (Optional) Color of the button text, default is colors.white
---@param colorInactive ccTweaked.colors.color? (Optional) Background color of the button, default is colors.red
---@param colorActive ccTweaked.colors.color? (Optional) Background color of the button when activated, default is colors.lime 
---@return Button
function Button.new(name, text, func, x1, x2, y1, y2, textColor, colorInactive, colorActive)
    ---@class Button
    local b = setmetatable({}, Button)

    b.name = name
    b.text = text
    b.func = func
    b.x1 = x1
    b.x2 = x2
    b.y1 = y1
    b.y2 = y2

    b.textColor = textColor or colors.white
    b.colorInactive = colorInactive or colors.red
    b.colorActive = colorActive or colors.lime

    b.state = false
    b.manager = nil
    return b
end

   
local mon = peripheral.wrap("top")
if !mon then return end

mon.setTextScale(1)
mon.setTextColor(colors.white)
local button={}
mon.setBackgroundColor(colors.black)

local function screen()
    
end

function Button:toggle()
    self.state = not self.state
    self.manager:fillButton(self)
end

function Button:flash()
    self:toggle()
    self.manager:fillButton(self)

    sleep(0.15)

    self:toggle()
    self.manager:fillButton(self)
end



function funcName()
    print("You clicked buttonText")
end   


return Button