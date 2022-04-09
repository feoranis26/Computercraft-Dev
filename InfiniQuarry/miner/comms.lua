hostID = -1
function toVector(x, y, z)
    local vector = {}
    vector.x = x
    vector.y = y
    vector.z = z
    return vector
end

function Connect()
    numTries = 0
    cI = 0
    while hostID == -1 do
        term.setCursorPos(1, 1)
        if cI == 0 then c = "-"; cI = 1 elseif cI == 1 then c = "\\"; cI = 2 elseif cI == 2 then c = "|"; cI = 3 elseif cI == 3 then  = "/"; cI = 0 end
        print("Connecting, try " .. numTries .. " " .. c)
        numTries = numTries + 1
        rednet.broadcast("CONNECTION_REQUEST", "MINER_CONNECTION")
        if numTries > 10 then
            print("Can't connect to host.\nCheck if the host is running.")
        end
        s, m = rednet.receive("MINER_CONNECTOR", 0.25)
        if m ~= nil then
            hostID = s
            x, y, z = gps.locate()
            pos = toVector(x, y, z)
            rednet.send(s, pos, "MINER_CONNECTOR")
            print("Connected to: " .. s)
            miner.homePos = m
            break
        else
            sleep(0.5)
        end
    end
    if hostID == -1 then
        print("Connection failed.")
        sleep(1)
        os.reboot()
    end
    return hostID
end

function emergency_stopper()
    while true do
        s, m = rednet.receive("MINER_COMMS")
        if s == comms.hostID then
            if m == "EMERGENCY" then
                os.reboot()
            end
        else
            rednet.send(s, "UNRECOGNIZED_COMMAND", "MINER_COMMS")
            print("Command from unknown computer received.\n Possible hacking or conflicting protocols?")
        end
    end
end

commandQueue = {}
function processComms()
    while true do
        s, m = rednet.receive("MINER_COMMS")
        if s == hostID then
            command_ok = false
            for i = 1, table.getn(Commands.commands) - 1 do
                local command = Commands.commands[i]
                if command.name == m then
                    s, m2 = rednet.receive("MINER_COMMS", 1)
                    term.setCursorPos(1, 4)
                    print(command.name)
                    rednet.send(s, "QUEUED " .. m, "MINER_COMMS")
                    command_ok = true
                    table.insert(commandQueue, {name = command.name, args = m2})
                    break
                end
            end
            if not command_ok then
                rednet.send(s, "UNRECOGNIZED_COMMAND", "MINER_COMMS")
            end
        else
            rednet.send(s, "UNRECOGNIZED_COMMAND", "MINER_COMMS")
            print("Command from unknown computer received.\n Possible hacking or conflicting protocols?")
        end
    end
end

function executeCommandQueue()
    while true do
        if #commandQueue > 0 then
            cmd = commandQueue[1]
            for i = 1, table.getn(Commands.commands) - 1 do
                local command = Commands.commands[i]
                if command.name == cmd then
                    if not command.wait or not miner.busy then
                        term.setCursorPos(1, 5)
                        print("Executing " .. cmd)
                        rednet.send(hostID, "OK " .. m, "MINER_COMMS")
                        command.execute()
                        rednet.send(hostID, "DONE " .. m, "MINER_COMMS")
                        table.remove(commandQueue, 1)
                    end
                end
            end
        end
        sleep(1)
    end
end

function processTelemetry()
    sleep(1)
    while true do
        s, m, p = rednet.receive("MINER_TELEMETRY" .. os.getComputerID())
        if m == "TELEMETRY_REQUEST" then
            dat = {}
            x, y, z = gps.locate()
            dat.pos = toVector(x, y, z)
            dat.y = l
            dat.energy = turtle.getFuelLevel()
            dat.items = 0
            dat.working = miner.working or miner.goingToWork
            dat.quarryData = {
                side = quarry_position_mgr.side,
                pos = quarry_position_mgr.pos,
                size = quarry_position_mgr.size
            }
            dat.busy = miner.busy
            dat.homePos = miner.homePos
            dat.helper = miner.helper
            rednet.send(s, dat, "MINER_TELEMETRY" .. os.getComputerID())
        end
    end
end

function start()
    parallel.waitForAll(executeCommandQueue, processComms, processTelemetry, emergency_stopper)
end
