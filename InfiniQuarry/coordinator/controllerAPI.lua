controller = {}
function controller:new(id)
    local mi = {}
    mi.ID = id
    mi.active = true
    mi.working = false
    mi.quarryData = {}

    setmetatable(mi, self)
    self.__index = self
    return mi
end
