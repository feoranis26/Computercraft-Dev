os.loadAPI("GUIUtils.lua")
Label = {type="GUILabel"}

function Label:display()
    col = self.back or colors.black

    xpos = self.coords.x
    if self.center then
        xpos = (self.coords.x - (string.len(self.text) + 2) / 2)+1
    end

    paintutils.drawFilledBox(xpos, self.coords.y, (string.len(self.text) + 2) / 2 + self.coords.x, self.coords.y, col)
    if self.text and self.center then
        GUIUtils.printCentered(self.text, self.color, self.coords.x, self.coords.y)
    elseif self.text then
        term.setCursorPos(self.coords.x, self.coords.y)
        term.setTextColor(self.color)
        term.write(self.text)
    end
    --term.setBackgroundColor(colors.black)
end

function Label:new(gui, name, x,y, col, text, back, nocenter)
    btn = {}
    btn.name = name
    btn.coords = {x=x, y=y}
    btn.color = col
    btn.onPress = onPress
    btn.text = text
    btn.back = back
    btn.center = not (nocenter ~= nil and nocenter)

    btn.enabled = true
    
    setmetatable(btn, self)
    self.__index = self
    gui:AddElement(btn)
    return btn
end