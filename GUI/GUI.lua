os.loadAPI("GUIButton.lua")
os.loadAPI("GUILabel.lua")
UI = {}
function UI:new(name_of_monitor)
    new_gui = {}
    new_gui.elements = {}
    new_gui.monitor = peripheral.wrap(name_of_monitor)
    new_gui.side = name_of_monitor
    setmetatable(new_gui, self)
    self.__index = self
    return new_gui
end

function UI:display()
    while true do
        if self.monitor ~= nil then
            term.redirect(self.monitor)
        end
        term.clear()
        for n, element in pairs(self.elements) do
            element:display()
        end

        sleep(0.1)
    end
end
function UI:displayOnce()
    if self.monitor ~= nil then
        term.redirect(self.monitor)
    end
    term.clear()
    for n, element in pairs(self.elements) do
        element:display()
    end
end

function UI:AddElement(element)
    table.insert(self.elements, element)
end
function UI:Loop()
    parallel.waitForAny(function() self:display() end, function() self:events() end)
end
function UI:events()
    while true do
        e, s, x, y = os.pullEvent("monitor_touch")
        if self.monitor == nil or s == self.side then
            for n, element in pairs(self.elements) do
                if element.type == "GUIButton" and x >= (element.coords.x - element.coords.w / 2) and x <= element.coords.w / 2 + element.coords.x and y >= (element.coords.y - element.coords.h / 2) and y <= element.coords.h / 2 + element.coords.y then
                    element.onPress()
                end
            end
        end
    end
end
function UI:ChangeElement(name, key, value)
    for n, element in pairs(self.elements) do
        if element.name == name then
            element[key] = value
        end
    end
end