term.clear()
term.setCursorPos(1, 1)
print("CREATE QUARRY v0")
print("\n\n")
print("Starting up...")
print("Loading libraries")

os.loadAPI("moveFunctions.lua")
os.loadAPI("coords.lua")
os.loadAPI("motionSequences.lua")

saveData = {}

function toVector(x, y, z)
    local vector = {}
    vector.x = x
    vector.y = y
    vector.z = z
    return vector
end

function readSaved()
    local config = {}
    local handle = fs.open("saved", "r")

    if handle == nil then
        config = nil
        return
    end

    config.QuarryPos = toVector(tonumber(handle.readLine()), tonumber(handle.readLine()), tonumber(handle.readLine()))
    config.QuarryState = handle.readLine()

    config.CurrentSeqName = handle.readLine()
    config.CurrentSeqStep = handle.readLine()

    config.CurrentSequenceQueue = {}
    local queueLength = tonumber(handle.readLine())

    for i = 0, queueLength - 1 do
        table.insert(config.CurrentSequenceQueue, handle.readLine())
    end

    return config
end

function doSelfCheck()
    moveFunctions.gotoY(saveData.QuarryPos.y + 6)
    moveFunctions.goTo(saveData.QuarryPos.x, saveData.QuarryPos.z)
    moveFunctions.gotoY(saveData.QuarryPos.y)

    s, block = turtle.inspectDown()

    if not s or block.name ~= "create:brass_block" then
        return false
    end

    return true
end

function saveState()
    local handle = fs.open("saved", "w")
    handle.writeLine(saveData.QuarryPos.x)
    handle.writeLine(saveData.QuarryPos.y)
    handle.writeLine(saveData.QuarryPos.z)

    handle.writeLine(saveData.QuarryState)

    handle.writeLine(saveData.CurrentSeqName)
    handle.writeLine(saveData.CurrentSeqStep)

    handle.writeLine(#saveData.CurrentSequenceQueue)

    for i = 0, #saveData.CurrentSequenceQueue - 1 do
        handle.writeLine(saveData.CurrentSequenceQueue[i + 1])
    end

    handle.close()
end

function gotoOffset(off)
    local tX = off.x + saveData.QuarryPos.x
    local tY = off.y + saveData.QuarryPos.y
    local tZ = off.z + saveData.QuarryPos.z

    local x, y, z = gps.locate()

    moveFunctions.gotoY(saveData.QuarryPos.y + 6)
    moveFunctions.goTo(tX, tZ)
    moveFunctions.gotoY(tY)
end

function executeSequence(seqname, step)
    print("Running Sequence:" ..seqname)
    saveData.CurrentSeqName = seqname
    sequence = motionSequences.sequences[seqname]

    if step == nil then
        step = 0
    end

    for i = step, #sequence - 1 do
        local act = sequence[i + 1]
        saveData.CurrentSeqStep = i
        saveState()

        if act.action == "activate" then
            local off = toVector(act.off.x, act.off.y + 1, act.off.z)
            gotoOffset(off)

            --[[ if act.block ~= nil then
                local s, block = turtle.inspectDown()
                if act.block ~= block.name then
                    error("Activate failed!")
                end
            end]]

            turtle.select(2)
            turtle.placeDown()

        elseif act.action == "wait_for_block" then
            gotoOffset(act.off)
            turtle.turnRight()
            while not turtle.detect() do
                sleep(1)
            end
            turtle.turnLeft()

        elseif act.action == "checkPowercell" then
            gotoOffset(act.off)

            local s, block = turtle.inspectDown()
            if block.name ~= "thermal:energy_cell" then
                error("Check powercell failed!")
            end

            local cell = peripheral.wrap("bottom")

            local energy = cell.getEnergy()
            print("Cell has " .. math.floor(energy / 1000) .. " kRF remaining.")

            if energy < 100000 then
                print("Replacing cell.")

                -- remove old powercell
                turtle.select(6)
                turtle.digDown()

                -- get new powercell
                turtle.select(3)
                turtle.placeDown()
                turtle.select(5)
                turtle.suckDown(1)
                turtle.select(3)
                turtle.digDown()
                turtle.select(5)
                turtle.placeDown()

                -- get rid of old powercell
                turtle.up()
                turtle.select(4)
                turtle.placeDown()
                turtle.select(6)
                turtle.dropDown()
                turtle.select(4)
                turtle.digDown()
            else
                print("Cell is ok.")
            end

        elseif act.action == "deactivate" then
            local off = toVector(act.off.x, act.off.y + 1, act.off.z)
            gotoOffset(off)

            s, block = turtle.inspectDown()
            if block.name ~= "minecraft:redstone_block" then
                error("Deactivate failed!")
            end

            turtle.down()

            turtle.select(2)
            turtle.digDown()

        elseif act.action == "gotoY" then
            moveFunctions.gotoY(saveData.QuarryPos.y + act.off)

        elseif act.action == "add_to_pos" then
            saveData.QuarryPos = toVector(saveData.QuarryPos.x + act.change.x, saveData.QuarryPos.y + act.change.y,
                saveData.QuarryPos.z + act.change.z)
            saveState()
        elseif act.action == "delay" then
            sleep(act.delay)
        else
            error("Unknown action: ".. act.action .." in sequence ".. seqname)
        end

    end

    saveData.CurrentSeqName = "NONE"
    saveState()
end

function runSequenceQueue(queue)
    saveData.CurrentSequenceQueue = queue
    print("\nExecuting sequence queue\nSequences:")

    for i = 0, #queue - 1 do
        local sequence = motionSequences.sequences[queue[i + 1] ]
        if sequence == nil then
            error("Invalid sequence: " .. queue[i + 1])
        end

        print("\t"..queue[i + 1])
    end

    while #queue > 0 do
        local seqname = queue[1]
        table.remove(queue, 1)
        saveData.CurrentSequenceQueue = queue

        executeSequence(seqname)
    end
end

function main()
    local x, y, z = gps.locate()
    if x == nil or y == nil or z == nil then
        print("Can't connect to GPS sattelite.")
        return
    end
    moveFunctions.faceFront()

    saveData = readSaved()

    local success = doSelfCheck()

    if not success then
        print("Self check failed!")
        return
    end

    print("Self check passed!")
    print("Beginning!")

    if saveData.CurrentSeqName ~= "NONE" then
        print("UNFINISHED SEQUENCE FOUND!")
        print("Sequence name: " .. saveData.CurrentSeqName)
        print("Sequence step: " .. saveData.CurrentSeqStep)

        executeSequence(saveData.CurrentSeqName, saveData.CurrentSeqStep)
    end

    if #saveData.CurrentSequenceQueue > 0 then
        runSequenceQueue(saveData.CurrentSequenceQueue)
    end
end

main()
