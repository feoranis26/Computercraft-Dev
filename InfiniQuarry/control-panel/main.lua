--[[ 
    InfiniMiner version 0.426
    by feoranis26
    TODO: Refactor this!
 ]] os.loadAPI("GUI.lua")
os.loadAPI("heartbeat.lua")
os.loadAPI("minerAPI.lua")

mon = peripheral.wrap("left")
m2 = peripheral.wrap("right")

sW, sY = mon.getSize()
print(sW)
term.redirect(mon)

term.setBackgroundColor(colors.black)
term.clear()

sleep(0.1)
rednet.open("back")
miners = {}

quarrySide = 0
quarryPos = 0
quarrySize = 3

quarryCenterPos = {}
quarryCenterPos.x = 0
quarryCenterPos.y = 0
quarryCenterPos.z = 0

hubPosition = {}
hubPosition.x = 0
hubPosition.y = 0
hubPosition.z = 0

handler = fs.open("quarryData", "r")
quarryCenterPos.x = tonumber(handler.readLine())
quarryCenterPos.z = tonumber(handler.readLine())

quarrySide = tonumber(handler.readLine())
quarryPos = tonumber(handler.readLine())
quarrySize = tonumber(handler.readLine())

controlMode = tonumber(handler.readLine())
prevActiveMiners = tonumber(handler.readLine())
isBootAutomatic = handler.readLine() == "true"
isNextBootAutomatic = false

docks = {}
dockSize = tonumber(handler.readLine())

for i = 0, dockSize - 1 do
    dock_x = tonumber(handler.readLine())
    dock_y = tonumber(handler.readLine())
    dock_z = tonumber(handler.readLine())

    table.insert(docks, to_vector(x, y, z))
end

minerLevels = {}
minerLevelsSize = tonumber(handler.readLine())

for i = 0, minerLevelsSize - 1 do
    levelDat = {}
    levelDat.id = tonumber(handler.readLine())
    levelDat.level = tonumber(handler.readLine())

    table.insert(minerLevels, levelDat)
end

activeMiners = 0
workingMiners = 0
term.setCursorPos(1, 1)
scroll = 0

centralControllerID = -1
job_active = false

function connectToController()
    rednet.broadcast("GET_HOSTS", "MINER_CENTRAL_COMMS")
    s, m = rednet.receive("MINER_CENTRAL_COMMS", 5)

    if m ~= nil and m == "HOST_AVAILABLE" then
        rednet.send(s, "CONNECTION_REQUEST", "MINER_CENTRAL_COMMS")

        for i = 0, 5 do
            s2, ms2 = rednet.receive("MINER_CENTRAL_COMMS", 1)

            if s2 == s and ms2 ~= nil and ms2 == "CONNECTION_OK" then
                rednet.send(s, "CONFIRM", "MINER_CENTRAL_COMMS")
                centralControllerID = s
                return
            end
        end
    end
end

function centralControllerComms()
    centraltimeouts = 0
    while true do
        sleep(0.1)

        if centralControllerID == -1 then
            connectToController()
        else
            s, m = rednet.receive("MINER_CENTRAL_COMMS", 5)

            if m == "START" then
                job_active = true
            elseif m == "STOP" then
                job_active = false
            elseif m == nil then
                centraltimeouts = centraltimeouts + 1
            end
        end

        if centraltimeouts >= 2 then
            centraltimeouts = 0
            centralControllerID = -1
        end
    end
end

function to_vector(x, y, z)
    local _vector = {}
    _vector.x = x
    _vector.y = y
    _vector.z = z
    return _vector
end

function getHomePosFromQuarryData()
    tmp = quarrySize / 2
    sitePos = to_vector(quarryCenterPos.x - tmp + 16, 0, quarryCenterPos.z - tmp + 16)

    if quarrySide == 0 then
        mX = sitePos.x + quarryPos
        mZ = sitePos.z
    elseif quarrySide == 1 then
        mX = sitePos.x + quarrySize
        mZ = sitePos.z + quarryPos
    elseif quarrySide == 2 then
        mX = sitePos.x + (quarrySize - quarryPos)
        mZ = sitePos.z + quarrySize
    elseif quarrySide == 3 then
        mX = sitePos.x
        mZ = sitePos.z + (quarrySize - quarryPos)
    end

    vector = {}

    vector.x = mX
    vector.z = mZ

    return vector
end

relocating = false
relocationStatus = ""

startRelocation = false

function updateRelocationUI()
    while true do
        if relocating then
            gui:ChangeElement("controlModeLabel", "enabled", false)
            gui:ChangeElement("controlModeButton", "enabled", false)

            gui:ChangeElement("relocateStatusLabel", "enabled", true)
            gui:ChangeElement("relocateStatusLabel", "text", "RELOCATING! STATUS: " .. relocationStatus)
        end

        sleep(1)
    end
end

function waitForMinersToFinish()
    while true do
        minersAreBusy = false
        for i = 0, #miners - 1 do
            local miner = miners[i + 1]
            if miner.busy then
                minersAreBusy = true
            end
        end
        if not minersAreBusy then
            break
        end
        sleep(1)
    end
end

function homeAllMiners()
    while true do
        minersNotHomed = false
        for i = 0, #miners - 1 do
            local miner = miners[i + 1]
            if not miner.busy and (miner.pos.x ~= hubPosition.x or miner.pos.z ~= hubPosition.z) then
                minersNotHomed = true
                miner:send("HOME")
            end
        end
        if not minersNotHomed then
            break
        end
        sleep(1)
    end
end

function relocatePosition()
    quarryPos = quarryPos + 16
    if quarrySide ~= 3 and quarryPos == quarrySize then
        quarrySide = quarrySide + 1
        quarryPos = 0
    elseif quarryPos == quarrySize then
        quarrySide = 0
        quarryPos = 0
        quarrySize = quarrySize + 32
        print("CHANGING SIZE to " .. quarrySize)
    end
end

function getNewLocation()

    if centralControllerID ~= -1 then
        rednet.broadcast("GET_NEW_POS", "MINER_CENTRAL_COMMS")
        s, m = rednet.receive("MINER_CENTRAL_COMMS")
        if m ~= nil and m.size ~= nil and m.pos ~= nil and m.side ~= nil then
            quarrySize = m.size
            quarryPos = m.pos
            quarrySide = m.side
        end
    else
        relocatePosition()
    end
end

function relocate()
    chposStatus = "GETTING NEW LOCATION..."

    relocating = true

    relocatePosition()

    chposStatus = "STOPPING MINERS"

    while true do
        minersAreNotStopped = false
        for i = 0, #miners - 1 do
            local miner = miners[i + 1]
            if miner.working then
                minersAreNotStopped = true
                broadcastToMiners("STOP")
            end
        end
        if not minersAreNotStopped then
            break
        end
        sleep(1)
    end

    relocationStatus = "HOMING MINERS"

    homeAllMiners()
    waitForMinersToFinish()

    relocationStatus = "RECONFIGURING MINERS"

    prevHubPosition = hubPosition
    hubPosition = getHomePosFromQuarryData()
    nextHubPosition = hubPosition

    broadcastToMiners("RESTART")
    sleep(5)
    broadcastToMiners("RESTART")

    sleep(5)
    broadcastToMiners("RESET_SIZE")
    sleep(1)

    relocationStatus = "MOVING MINERS"

    homeAllMiners()
    waitForMinersToFinish()

    isNextBootAutomatic = true
    sleep(1)

    broadcastToMiners("RESTART")
    os.reboot()
end

function movePrev()
    for i = 1, 40 do
        scroll = scroll + 1
        if scroll < sW - #miners * 40 then
            scroll = sW - #miners * 40
        end
        if scroll > 0 then
            scroll = 0
        end
        sleep(0.025)
    end
end
function moveNext()
    for i = 1, 40 do
        scroll = scroll - 1
        if scroll < sW - #miners * 40 then
            scroll = sW - #miners * 40
        end
        if scroll > 0 then
            scroll = 0
        end
        print(scroll)
        sleep(0.025)
    end
end
function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function toVector(x, y, z)
    local vector = {}
    vector.x = x
    vector.y = y
    vector.z = z
end
function connectionHost()
    while true do
        c = false
        s, m = rednet.receive("MINER_CONNECTION")
        if m == "CONNECTION_REQUEST" then
            rednet.send(s, hubPosition, "MINER_CONNECTOR")
            s, m = rednet.receive("MINER_CONNECTOR", 5)
            print(s, m)
            if m ~= nil then
                miner = minerAPI.minerData:new(s, m)
                for j = 1, #miners do
                    if miners[j].ID == miner.ID then
                        print(miners[j].ID)
                        table.insert(heartbeat.IDs, s)
                        miners[j].active = true
                        c = true
                    end
                end
                if c == false then
                    print("Connecting" .. miner.ID)
                    sleep(1)
                    table.insert(miners, miner)
                    table.insert(heartbeat.IDs, s)
                end
            end
        end
    end
end
function updateMinerInfo()
    while true do
        if table.getn(miners) ~= 0 then
            for i = 0, table.getn(miners) - 1 do
                local miner = miners[i + 1]
                if contains(heartbeat.IDs, miner.ID) == true then
                    rednet.send(miner.ID, "TELEMETRY_REQUEST", "MINER_TELEMETRY" .. miner.ID)
                    s, m = rednet.receive("MINER_TELEMETRY" .. miner.ID, 1)
                    if m ~= nil and s == miner.ID then
                        miner.pos = m.pos
                        miner.layer = m.y
                        miner.energyLevel = m.energy
                        miner.itemsSent = m.items
                        miner.working = m.working
                        miner.quarryData = m.quarryData
                        miner.busy = m.busy
                        miner.homePos = m.homePos
                    end
                else
                    miner.active = false
                    miner.working = false
                end
            end
        end
        sleep(1)
    end
end
function buttons()
    while true do
        e, m, x, y = os.pullEvent("monitor_touch")
        if m == "left" then
            x = x - scroll
            minerClicked = math.floor(x / 40)
            m2.setCursorPos(1, 7)
            m2.write(minerClicked)
            if miners[minerClicked + 1] ~= nil and m == "left" then
                bX = x - (minerClicked * 40)
                bY = y
                if y > 18 and y < 22 then
                    if bX > 2 and bX < 8 then
                        miners[minerClicked + 1]:toggle()
                    end
                    if bX > 12 and bX < 18 then
                        miners[minerClicked + 1]:gotohome()
                    end
                    if bX > 22 and bX < 28 then
                        miners[minerClicked + 1]:shutdown()
                    end
                    if bX > 32 and bX < 38 then
                        miners[minerClicked + 1]:reboot()
                    end
                end
            end
        elseif m == "right" then
            m2.setCursorPos(1, 10)
            m2.write(sW - #miners * 40)
            if y > 20 and x < 7 then
                movePrev()
            elseif y > 20 and x > 21 then
                moveNext()
            end
            if scroll < sW - #miners * 40 then
                scroll = sW - #miners * 40
            end
            if scroll > 0 then
                scroll = 0
            end
        end
    end
end

gui = {}

controlModeNames = {"MANUAL", "BALANCED", "AUTO", "CENTRAL"}

busyMiners = 0

function initControls()
    sx, sy = m2.getSize()
    m2.setBackgroundColor(colors.gray)

    gui = GUI.UI:new("right")

    GUILabel.Label:new(gui, "Label", sx / 2, 1, colors.white, "                MINER CTL                 ", colors.gray)
    GUILabel.Label:new(gui, "minersLabelText", sx / 2, 2, colors.white, "Total / Connected / Working / Busy:")
    GUILabel.Label:new(gui, "minersLabel", sx / 2, 3, colors.white,
        #miners .. " / " .. activeMiners .. " / " .. workingMiners .. " / " .. busyMiners)
    GUILabel.Label:new(gui, "homePosLabel", sx / 2, 4, colors.white, "0, 0")

    GUILabel.Label:new(gui, "controlModeLabel", sx / 2, 6, colors.white, "Control mode:")

    -- GUILabel.Label:new(gui, "controlModeLabel", sx / 2, 6, colors.white, "Control mode:")

    GUIButton.Button:new(gui, "controlModeButton", sx / 2, 8, 0, 3, colors.gray, function()
        controlMode = math.max(1, math.min(5, controlMode + 1))
        if controlMode == 5 then
            controlMode = 1
        end
    end, "MANUAL", colors.black)

    GUIButton.Button:new(gui, "allOn", 1 * sx / 4 - 2, 12, 0, 3, colors.green, function()
        broadcastToMiners("START")
    end, "ALL ON", colors.black)
    GUIButton.Button:new(gui, "allHome", 2 * sx / 4, 12, 0, 3, colors.orange, function()
        broadcastToMiners("HOME")
    end, "ALL HOME", colors.black)
    GUIButton.Button:new(gui, "allOff", 3 * sx / 4 + 2, 12, 0, 3, colors.red, function()
        broadcastToMiners("STOP")
    end, "ALL OFF", colors.black)

    GUIButton.Button:new(gui, "nextChunk", sx / 3, 21, 0, 3, colors.red, function()
        startRelocation = true
    end, "NEXT CHUNK!", colors.black)
    GUIButton.Button:new(gui, "rstAll", 2 * sx / 3, 21, 0, 3, colors.red, function()
        broadcastToMiners("RESET_SIZE")
    end, "RESET SIZES", colors.black)

    GUIButton.Button:new(gui, "allReboot", sx / 2, 16, 0, 3, colors.red, function()
        broadcastToMiners("RESTART", true)
    end, "ALL REBOOT", colors.black)

    GUIButton.Button:new(gui, "EMERGENCY_STOP", 3, 1, 1, 1, colors.yellow, function()
        broadcastToMiners("EMERGENCY")
        sleep(1)
        os.reboot()
    end, "!", colors.black)
    GUIButton.Button:new(gui, "RebootBTN", 1, 1, 1, 1, colors.red, function()
        os.reboot()
    end, "R", colors.black)

    GUILabel.Label:new(gui, "relocateStatusLabel", sx / 2, 6, colors.white, "CHANGING POS! STATUS:")
    gui:ChangeElement("relocateStatusLabel", "enabled", false)

end

function updateControls()
    while true do
        if activeMiners > 0 and workingMiners == 0 then
            break
        end
        sleep(1)
    end
    while true do
        sleep(0.1)
        gui:ChangeElement("minersLabel", "text",
            #miners .. " / " .. activeMiners .. " / " .. workingMiners .. " / " .. busyMiners)

        gui:ChangeElement("homePosLabel", "text", "Home :" .. hubPosition.x .. ", " .. hubPosition.z .. ", " ..
            quarryPos .. ", " .. quarrySide .. ", " .. quarrySize)

        gui:ChangeElement("controlModeButton", "text", controlModeNames[controlMode])
    end
end

function displayMinerInfo()
    mon.setTextScale(0.5)
    m2.setTextScale(0.5)
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    paintutils.drawFilledBox(1, 1, sW, sY)
    while true do
        term.redirect(mon)
        activeMiners = 0
        workingMiners = 0
        busyMiners = 0
        term.setBackgroundColor(colors.black)
        term.clear()
        if table.getn(miners) ~= 0 then
            for i = 0, #miners - 1 do
                clr = colors.red
                if i % 2 == 0 then
                    clr = colors.gray
                else
                    clr = colors.lightGray
                end
                paintutils.drawFilledBox(i * 40 + scroll, 0, (i + 1) * 40 - 1 + scroll, 24, clr)
                local miner = miners[i + 1]
                if i % 2 == 0 then
                    clr = colors.gray
                else
                    clr = colors.lightGray
                end
                term.setCursorPos(i * 40 + 16 + scroll, 2)
                term.write("Miner  " .. i)
                if miner.active then
                    term.setCursorPos(i * 40 + 14 + scroll, 3)
                    term.write("(CONNECTED!)")
                    activeMiners = activeMiners + 1
                else
                    term.setCursorPos(i * 40 + 12 + scroll, 3)
                    term.write("(!DISCONNECTED!)")
                end
                if miner.active then

                    -- telemetry
                    if miner.position.z ~= nil then
                        if miner.quarryData ~= nil and miner.quarryData.size ~= nil and miner.quarryData.side ~= nil and
                            miner.quarryData.pos ~= nil then
                            totalBlocks = miner.quarryData.size * miner.quarryData.size - (miner.quarryData.size - 2) *
                                              (miner.quarryData.size - 2)
                            blocksMined = ((miner.quarryData.pos + 1) + (miner.quarryData.side * totalBlocks / 4))
                            blocksLeft = (totalBlocks - blocksMined) * 3
                            completeness = math.floor(blocksMined / totalBlocks * 100)
                            term.setCursorPos(i * 40 + 7 + scroll, 11)
                            term.write("Size : " .. miner.quarryData.size .. ", Completed : %" .. completeness)
                            term.setCursorPos(i * 40 + 12 + scroll, 12)
                            term.write("Blocks left: " .. blocksLeft)
                        else
                            term.setCursorPos(i * 40 + 7 + scroll, 11)
                            term.write("NO QUARRY DATA!")
                        end
                        term.setCursorPos(i * 40 + 12 + scroll, 8)
                        term.write("Fuel level :" .. miner.energyLevel)
                        term.setCursorPos(i * 40 + 10 + scroll, 9)
                        term.write("Position : " .. miner.position.x .. ", " .. miner.position.y .. ", " ..
                                       miner.position.z)
                        term.setCursorPos(i * 40 + 12 + scroll, 10)
                        term.write("Busy :" .. tostring(miner.working or miner.busy))
                    end

                    -- start/stop button
                    if miner.working then
                        clr = colors.red
                        t = "STOP!"
                        workingMiners = workingMiners + 1
                    else
                        clr = colors.green
                        t = "START"
                    end

                    if miner.busy then
                        busyMiners = busyMiners + 1
                    end

                    -- buttons
                    paintutils.drawFilledBox(i * 40 + 2 + scroll, 18, i * 40 + 8 + scroll, 22, clr)
                    term.setCursorPos(i * 40 + 3 + scroll, 20)
                    term.write(t)
                    paintutils.drawFilledBox(i * 40 + 12 + scroll, 18, i * 40 + 18 + scroll, 22, colors.orange)
                    term.setCursorPos(i * 40 + 13 + scroll, 20)
                    term.write("CLLHM")
                    if i % 2 == 0 then
                        clr2 = colors.lightGray
                    else
                        clr2 = colors.gray
                    end
                    paintutils.drawFilledBox(i * 40 + 22 + scroll, 18, i * 40 + 28 + scroll, 22, clr2)
                    term.setCursorPos(i * 40 + 23 + scroll, 20)
                    term.write("SHTDN")
                    paintutils.drawFilledBox(i * 40 + 32 + scroll, 18, i * 40 + 38 + scroll, 22, clr2)
                    term.setCursorPos(i * 40 + 33 + scroll, 20)
                    term.write("RSTRT")
                else
                    img = paintutils.loadImage("disconnected.nfp")
                    paintutils.drawImage(img, i * 40 + 14 + scroll, 10)
                end

            end
        end
        term.redirect(term.native())
        gui:displayOnce()
        sleep(1)
    end
end

function broadcastToMiners(message, delayed)
    if table.getn(miners) ~= 0 then
        for i = 0, table.getn(miners) - 1 do
            local miner = miners[i + 1]
            if miner.active then
                miner:send(message)
                if delayed then
                    sleep(1)
                end
            end
        end
    end
end

function checkAutoBoot()
    if isBootAutomatic then
        while true do
            if activeMiners == prevActiveMiners and workingMiners == 0 then
                break
            end
            sleep(1)
        end
    end
end

function waitForConnections()
    while true do
        if activeMiners > 0 and workingMiners == 0 then
            break
        end
        sleep(1)
    end
end

function getActiveMiners()
    local activeMiners = {}

    if table.getn(miners) ~= 0 then
        for i = 0, table.getn(miners) - 1 do
            local miner = miners[i + 1]
            if miner.active then
                table.insert(activeMiners, miner)
            end
        end
    end

    return activeMiners
end

function controlMiners()
    checkAutoBoot()
    waitForConnections();

    while true do
        if controlMode == 3 or controlMode == 4 and job_active then

            for i = 0, table.getn(miners) - 1 do
                local miner = miners[i + 1]
                if miner.active and miner.quarryData ~= nil and miner.quarryData.size ~= nil then
                    if miner.working and miner.quarryData.size > 18 then
                        miner:stop()
                        miner:send("HOME")
                    elseif not miner.working then
                        miner:start()
                    end
                end
            end

            allMinersBigEnough = true
            for i = 0, table.getn(miners) - 1 do
                local miner = miners[i + 1]
                if miner.active and miner.quarryData ~= nil and miner.quarryData.size ~= nil and miner.quarryData.size <
                    18 then
                    allMinersBigEnough = false
                else
                    miner:stop()
                    miner:send("HOME")
                end
            end

            if allMinersBigEnough then
                relocate()
            end
        end

        if controlMode == 4 and not job_active then
            for i = 0, table.getn(miners) - 1 do
                local miner = miners[i + 1]
                if miner.active then
                    miner:stop()
                    miner:send("HOME")
                end
            end
        end

        for i = 0, table.getn(miners) - 1 do
            local miner = miners[i + 1]
            if miner.active and miner.pos ~= nil and miner.pos.y ~= nil then
                level = -1
                for j = 0, #minerLevels - 1 do
                    if minerLevels[j + 1].id == miner.ID then
                        level = minerLevels[j + 1].level
                        break
                    end
                end

                if level == -1 then
                    ldat = {}
                    ldat.id = miner.ID
                    ldat.level = miner.pos.y

                    table.insert(minerLevels, ldat)
                    level = miner.pos.y
                end

                miner:send("UPDATE_YLEVEL")
                miner:sendArgs(level)
            end
        end

        if startRelocation then
            relocate()
        end

        if centralControllerID ~= -1 and controlMode ~= 4 then
            pcontrolMode = controlMode
            controlMode = 4
        elseif pcontrolMode ~= nil then
            controlMode = pcontrolMode
        elseif centralControllerID == -1 then
            controlMode = 1
        end

        sleep(1)
    end
end

function centralTelemetry()
    while true do
        sleep(1)

        s, m = rednet.receive("MINER_CENTRAL_COMMS")

        if m == "REQUEST_TELEMETRY" then
            dat = {}

            dat.working = controlMode == 4 and job_active
            dat.miners = workingMiners

            qDat = {}
            qDat.size = quarrySize
            qDat.pos = quarryPos
            qDat.side = quarrySide
            qDat.home = hubPosition

            dat.quarryData = qDat

            rednet.send(s, dat, "MINER_CENTRAL_COMMS")
        end
    end
end

function saveQuarryData()
    while true do
        handler = fs.open("quarryData", "w")
        handler.writeLine(quarryCenterPos.x)
        handler.writeLine(quarryCenterPos.z)
        handler.writeLine(quarrySide)
        handler.writeLine(quarryPos)
        handler.writeLine(quarrySize)
        handler.writeLine(controlMode)
        handler.writeLine(activeMiners)
        handler.writeLine(isNextBootAutomatic)

        handler.writeLine(#docks)

        for i = 0, #docks - 1 do
            handler.writeLine(docks[i + 1].x)
            handler.writeLine(docks[i + 1].y)
            handler.writeLine(docks[i + 1].z)
        end

        handler.writeLine(#miners)

        for i = 0, #miners - 1 do
            local miner = miners[i + 1]

            level = -1
            for i = 0, #minerLevels - 1 do
                if minerLevels[i + 1].id == miner.ID then
                    level = minerLevels[i + 1].level
                    break
                end
            end

            handler.writeLine(miner.ID)
            handler.writeLine(level)
        end

        handler.close()
        sleep(10)
    end
end

function init()
    initControls()
    hubPosition = getHomePosFromQuarryData()
    parallel.waitForAll(heartbeat.startHost, connectionHost, updateMinerInfo, displayMinerInfo, buttons, function()
        gui:events()
    end, updateControls, controlMiners, saveQuarryData, updateRelocationUI, centralControllerComms, centralTelemetry)
end
init()
