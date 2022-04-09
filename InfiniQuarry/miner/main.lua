--[[ 
    InfiniMiner version 0.426
    by feoranis26
 ]]


rednet.open("right")
os.loadAPI("heartbeat.lua")
os.loadAPI("moveFunctions.lua")

os.loadAPI("Commands.lua")
os.loadAPI("miner.lua")
os.loadAPI("actions.lua")
os.loadAPI("comms.lua")
os.loadAPI("quarry_position_mgr.lua")

function mine()
    while true do
        if miner.working and not miner.helper then
            turtle.dig()
            turtle.forward()
            turtle.digUp()
            turtle.digDown()
            actions.checkForLiquids() -- TODO: Test this!
            quarry_position_mgr.next_block()
        else
            sleep(0.1)
        end
    end
end     

function init()
    moveFunctions.faceFront()
    
    comms.hostID = comms.Connect()

    term.clear()
    term.setCursorPos(1, 1)

    print("Connected to : " .. comms.hostID)
    parallel.waitForAll(heartbeat.startClient, comms.start, mine)
end

init()