os.loadAPI("GUI.lua")
os.loadAPI("heartbeat.lua")
os.loadAPI("controllerAPI.lua")

rednet.open("back")

controllers = {}

dashboard = peripheral.wrap("monitor_0")
controllersDashboard = peripheral.wrap("right")

term.clear()
term.setCursorPos(1, 1)
print("InfiniQuarry Coordinator Server Init")

function coordinatorServer()
    while true do
        c = false

        s, m = rednet.receive("MINER_CENTRAL_COMMS")

        if m == "CONNECTION_REQUEST" then
            print("[SERVER] CONNECTION REQUEST " .. s)
            sleep(0.1)
            rednet.send(s, "CONNECTION_OK", "MINER_CENTRAL_COMMS")
            s, m = rednet.receive("MINER_CENTRAL_COMMS", 5)
            if m ~= nil and m == "CONFIRM" then
                print("[SERVER] CONFIRMATION RECEIVED")
                cnt = controllerAPI.controller:new(s)

                for j = 1, #controllers do
                    if controllers[j].ID == cnt.ID then
                        print("RECONENCTING")

                        table.insert(heartbeat.IDs, s)
                        controllers[j].active = true
                        c = true
                    end
                end
                if c == false then
                    onConnect(cnt)
                end
            end

        elseif m == "GET_HOSTS" then
            print("[SERVER] GET HOSTS " .. s)
            rednet.send(s, "HOST_AVAILABLE", "MINER_CENTRAL_COMMS")
        end
    end
end

function onConnect(ctl)
    print("[SERVER] CONNECTED " .. cnt.ID)

    table.insert(controllers, cnt)
    table.insert(heartbeat.IDs, s)

    GUILabel.Label:new(controllersGUI, "ctlLabel-" .. ctl.ID, 1, #controllers + 2, colors.blue,
        "Controller: " .. ctl.ID, colors.black, true)
end

running = false

function updateGUI()
    while true do
        if running then
            gui:ChangeElement("statusLabel", "text", "STATUS: " .. "RUNNING")

            gui:ChangeElement("stopBtn", "enabled", true)
            gui:ChangeElement("startBtn", "enabled", false)
        else
            gui:ChangeElement("statusLabel", "text", "STATUS: " .. "STOPPED")

            gui:ChangeElement("stopBtn", "enabled", false)
            gui:ChangeElement("startBtn", "enabled", true)
        end

        for i = 1, #controllers do
            ctl = controllers[i]
            if ctl.active then
                controllersGUI:ChangeElement("ctlLabel-" .. ctl.ID, "color", colors.blue)

                minersTxt = ctl.miners ~= nil and ctl.miners or "0"
                workTxt = ctl.working and "ACTIVE" or "STOPPED"
                posTxt = ctl.quarryData and ctl.quarryData.home and
                             (" X: " .. ctl.quarryData.home.x .. " Z: " .. ctl.quarryData.home.z) or " UNKNOWN"
                controllersGUI:ChangeElement("ctlLabel-" .. ctl.ID, "text", "Controller: " .. ctl.ID .. " M: " ..
                    minersTxt .. " W: " .. workTxt .. posTxt)
            else
                controllersGUI:ChangeElement("ctlLabel-" .. ctl.ID, "color", colors.red)
            end
        end

        sleep(1)
    end
end

function sendToControllers(msg)
    for i = 1, #controllers do
        rednet.send(controllers[i].ID, msg, "MINER_CENTRAL_COMMS")
    end
end

function controllerTelemetry()
    while true do
        for i = 1, #controllers do
            ctl = controllers[i]

            rednet.send(ctl.ID, "REQUEST_TELEMETRY", "MINER_CENTRAL_COMMS")
            s, m = rednet.receive("MINER_CENTRAL_COMMS", 1)

            if s ~= nil and m ~= nil then
                ctl.active = true
                ctl.working = m.working
                ctl.quarryData = m.quarryData
                ctl.miners = m.miners
            else
                ctl.active = false
            end
        end

        sleep(1)
    end
end

gui = {}
controllersGUI = {}
function initGUI()
    dashboard.setTextScale(2)

    controllersDashboard.setTextScale(0.5)

    sx, sy = dashboard.getSize()
    leftMonSX, leftMonSY = controllersDashboard.getSize()

    gui = GUI.UI:new("monitor_0")

    GUILabel.Label:new(gui, "Label", sx / 2, 1, colors.white, "---------InfiniQuarry----------", colors.gray)
    GUILabel.Label:new(gui, "posLabel", sx / 2, 4, colors.green, "NEXT POSITION: 0, 0", colors.black)
    GUILabel.Label:new(gui, "statusLabel", sx - 8, sy - 3, colors.blue, "STATUS: OK", colors.black)

    GUIButton.Button:new(gui, "startBtn", 5, sy - 3, 5, 5, colors.green, function()
        sendToControllers("START")
        running = true
    end, "START", colors.black)

    GUIButton.Button:new(gui, "stopBtn", 5, sy - 3, 5, 5, colors.red, function()
        sendToControllers("STOP")
        running = false
    end, "STOP!", colors.black)

    gui:ChangeElement("startBtn", "enabled", false)

    controllersGUI = GUI.UI:new("right")
    GUILabel.Label:new(controllersGUI, "Label", leftMonSX / 2, 1, colors.white,
        "            ----InfiniQuarry - Controllers----             ", colors.gray)
end

function init()
    initGUI()

    parallel.waitForAll(coordinatorServer, function()
        gui:Loop()
    end, function()
        controllersGUI:Loop()
    end, updateGUI, controllerTelemetry)
end

init()
