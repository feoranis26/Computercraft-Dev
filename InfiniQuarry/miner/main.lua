--[[ 
    InfiniMiner version 0.426
    by feoranis26
 ]] rednet.open("right")
os.loadAPI("heartbeat.lua")
os.loadAPI("moveFunctions.lua")

os.loadAPI("Commands.lua")
os.loadAPI("miner.lua")
os.loadAPI("actions.lua")
os.loadAPI("comms.lua")
os.loadAPI("quarry_position_mgr.lua")

handler = fs.open("host", "r")

if handler ~= nil then
    comms.prevHostID = tonumber(handler.readLine())
else
    comms.prevHostID = -1
end

function mine()
    while true do
        if miner.working and not miner.helper then
            t, dwn = turtle.inspectDown()
            t, up = turtle.inspectUp()

            moveFunctions.digForward()
            turtle.forward()
            moveFunctions.digUp()
            moveFunctions.digDown()

            actions.checkForLiquids()
            actions.checkItems()
            actions.checkFuel()

            quarry_position_mgr.checkYLevel()
            quarry_position_mgr.next_block()
        else
            sleep(0.1)
        end

        quarry_position_mgr.checkYLevel()
    end
end

function init()
    x, y, z = gps.locate()
    if x == nil or y == nil or z == nil then
        print("Can't connect to GPS sattelite.")
        return
    end
    moveFunctions.faceFront()

    miner.yLevel = y

    comms.hostID = comms.Connect()

    print("New host address permanently set to: " .. comms.hostID)
    handler2 = fs.open("host", "w")
    handler2.writeLine(comms.hostID)

    term.clear()
    term.setCursorPos(1, 1)

    print("Connected to : " .. comms.hostID)
    parallel.waitForAll(heartbeat.startClient, comms.start, mine)
end

init()
