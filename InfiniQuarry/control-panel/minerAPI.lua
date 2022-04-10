minerData = {}
function minerData:new(id, pos)
    local mi = {}
    print(id)
    mi.home = pos
    mi.position = pos
    mi.ID = id
    mi.active = true
    mi.working = false
    mi.layer = pos.y
    mi.energyLevel = "GETTING..."
    mi.itemsSent = "GETTING..."
    mi.working = "GETTING..."
    mi.busy = true
    mi.helper = false
    mi.quarryData = {}

    mi.commandQueue = {}
    
    setmetatable(mi, self)
    self.__index = self
    return mi
end

function minerData:gotohome()
    rednet.send(self.ID, "HOME", "MINER_COMMS")
end

function minerData:start()
    if not self.helper then
        rednet.send(self.ID, "START", "MINER_COMMS")
    end
end

function minerData:stop()
    rednet.send(self.ID, "STOP", "MINER_COMMS")
end

function minerData:shutdown()
    rednet.send(self.ID, "SHUTDOWN", "MINER_COMMS")
end

function minerData:reboot()
    rednet.send(self.ID, "RESTART", "MINER_COMMS")
end

function minerData:toggle()
    if not self.helper then
        if self.working then 
            rednet.send(self.ID, "STOP", "MINER_COMMS") 
        else
            rednet.send(self.ID, "START", "MINER_COMMS")
        end
    end
end

function minerData:send(message)
    rednet.send(self.ID, message, "MINER_COMMS")
end

function minerData:sendArgs(message)
    rednet.send(self.ID, message, "MINER_ARGS")
end

function minerData:queueCommand(cmdName, args)
    cmd = {}
    cmd.name = cmdName
    cmd.args = args

    table.insert(self.commandQueue, cmd)
end

function minerData:sendCommands()
    command = self.commandQueue[1]

    while true do
        rednet.send(self.ID, command.name, "MINER_COMMS")

        for i = 0, 10 do
            s, m = rednet.receive("MINER_COMMS", 1)

            if s == self.ID and m == "QUEUED " .. command.name then
                break
            end
        end
    end
end

function minerData:setHelper(helper)
    rednet.send(self.ID, "SET_HELPER", "MINER_COMMS")
    rednet.send(self.ID, helper, "MINER_ARGS")
end