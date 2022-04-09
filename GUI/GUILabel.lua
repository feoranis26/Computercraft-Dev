os.loadAPI("GUIUtils.lua")
Label = {type="GUILabel"}

function Label:display()
    col = self.back or colors.black
    paintutils.drawFilledBox((self.coords.x - (string.len(self.text) + 2) / 2)+1, self.coords.y, (string.len(self.text) + 2) / 2 + self.coords.x, self.coords.y, col)
    a = self.text and GUIUtils.printCentered(self.text, self.color, self.coords.x, self.coords.y)
    --term.setBackgroundColor(colors.black)
end

function Label:new(gui, name, x,y, col, text, back)
    btn = {}
    btn.name = name
    btn.coords = {x=x, y=y}
    btn.color = col
    btn.onPress = onPress
    btn.text = text
    btn.back = back
    setmetatable(btn, self)
    self.__index = self
    gui:AddElement(btn)
    return btn
end