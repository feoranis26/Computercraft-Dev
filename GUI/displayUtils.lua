Button = {}

function Button:display()
    paintutils.drawFilledBox((self.coords.x - self.coords.w / 2)+1, (self.coords.y - self.coords.h / 2)+1, self.coords.w / 2 + self.coords.x, self.coords.h / 2 + self.coords.y, self.color)
    a = self.text and printCentered(self.text, self.textColor, self.coords.x, self.coords.y)
    term.setBackgroundColor(colors.black)
end

function Button:new(x,y,w,h, col, onPress, text, textColor)
    btn = {}
    w = text and string.len(text) + 2 or w
    btn.coords = {x=x, y=y, w=w, h=h}
    btn.color = col
    btn.onPress = onPress
    btn.text = text
    btn.textColor = textColor
    setmetatable(btn, self)
    self.__index = self
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

function printCentered(text, color, x, y)
    color = color or colors.white
    len = string.len(text)
    start = x - len / 2
    term.setTextColor(color)
    term.setCursorPos(start + 1,y)
    term.write(text)
end
