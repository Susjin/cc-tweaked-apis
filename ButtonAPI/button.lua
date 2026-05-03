---@class Button Main button class
---@field name string Name of the button to be indexed
---@field text string Text to be shown on the button (smaller than x2-x1)
---@field x1 integer Button's starting X position
---@field x2 integer Button's finishing X position
---@field y1 integer Button's starting Y position
---@field y2 integer Button's finishing Y position
---@field colorInactive ccTweaked.colors.color (Optional) Background color of the button, default is colors.red
---@field colorActive ccTweaked.colors.color (Optional) Background color of the button when activated, default is colors.lime 
---@field state boolean Current state of the button. True for active and false for inactive
---@field parent Buttons Parent of the button, responsible for it's rendering
local Button = {}
Button.__intex = Button

---Creates a new Button
---@param name string Name of the button to be indexed
---@param text string Text to be shown on the button (smaller than x2-x1)
---@param x1 integer Button's starting X position
---@param x2 integer Button's finishing X position
---@param y1 integer Button's starting Y position
---@param y2 integer Button's finishing Y position
---@param colorInactive ccTweaked.colors.color (Optional)   Background color of the button, default is colors.red
---@param colorActive ccTweaked.colors.color (Optional) Background color of the button when activated, default is colors.lime 
---@return Button
function Button.new(name, text, x1, x2, y1, y2, colorInactive, colorActive)
    ---@class Button
    local b = setmetatable({}, Button)
    
    b.name = name
    b.text = text
    b.x1 = x1
    b.x2 = x2
    b.y1 = y1
    b.y2 = y2
    b.colorInactive = colorInactive or colors.red
    b.colorActive = colorActive or colors.lime

    b.state = false
    b.parent = nil

    return b
end


local mon = peripheral.wrap("top")
if !mon then return end

mon.setTextScale(1)
mon.setTextColor(colors.white)
local button={}
mon.setBackgroundColor(colors.black)
 
function clearTable()
   button = {}
   mon.clear()
end
               
function setTable(name, func, xmin, xmax, ymin, ymax)
   button[name] = {}
   button[name]["func"] = func
   button[name]["active"] = false
   button[name]["xmin"] = xmin
   button[name]["ymin"] = ymin
   button[name]["xmax"] = xmax
   button[name]["ymax"] = ymax
end
 
function funcName()
   print("You clicked buttonText")
end
        
function fillTable()
   setTable("ButtonText", funcName, 5, 25, 4, 8)
end     
 
 
function toggleButton(name)
   button[name]["active"] = not button[name]["active"]
   screen()
end     
 
function flash(name)
   toggleButton(name)
   screen()
   sleep(0.15)
   toggleButton(name)
   screen()
end
                                             
function checkxy(x, y)
   for name, data in pairs(button) do
      if y>=data["ymin"] and  y <= data["ymax"] then
         if x>=data["xmin"] and x<= data["xmax"] then
            data["func"]()
            return true
            --data["active"] = not data["active"]
            --print(name)
         end
      end
   end
   return false
end
     
function heading(text)
   w, h = mon.getSize()
   mon.setCursorPos((w-string.len(text))/2+1, 1)
   mon.write(text)
end
     
function label(w, h, text)
   mon.setCursorPos(w, h)
   mon.write(text)
end

return Button