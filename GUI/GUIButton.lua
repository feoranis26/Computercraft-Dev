os.loadAPI("GUIUtils.lua")
Button = {type="GUIButton"}

function Button:display()
    self.coords.w = self.text and string.len(self.text) + 2 or self.coords.w
    paintutils.drawFilledBox((self.coords.x - self.coords.w / 2)+1, (self.coords.y - self.coords.h / 2)+1, self.coords.w / 2 + self.coords.x, self.coords.h / 2 + self.coords.y, self.color)
    a = self.text and GUIUtils.printCentered(self.text, self.textColor, self.coords.x, self.coords.y)
    term.setBackgroundColor(colors.black)
end

function Button:new(gui, name, x,y,w,h, col, onPress, text, textColor)
    btn = {}
    btn.name = name
    w = text and string.len(text) + 2 or w
    btn.coords = {x=x, y=y, w=w, h=h}
    btn.color = col
    btn.onPress = onPress
    btn.text = text
    btn.textColor = textColor
    setmetatable(btn, self)
    self.__index = self
    gui:AddElement(btn)
    return btn
end

function Button:loop()
    while true do
        e, s, x, y = os.pullEvent("monitor_touch")
        if x >= (self.coords.x - self.coords.w / 2) and x <= self.coords.w / 2 + self.coords.x and y >= (self.coords.y - self.coords.h / 2) and y <= self.coords.h / 2 + self.coords.y then
            self.onPress()
        end
    end
end