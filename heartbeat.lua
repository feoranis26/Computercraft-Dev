shutdown = true
IDs = {}
function startClient()
    e, m = rednet.receive("HEARTBEAT", 10)
    if e ~= nil then
        print("Start heartbeat to :".. e)
        local cI = 0
        while true do
            if m == "host" then
                term.setCursorPos(1, 3)
                if cI == 0 then c = "-"; cI = 1 elseif cI == 1 then c = "\\"; cI = 2 elseif cI == 2 then c = "|"; cI = 3 elseif cI == 3 then c = "/"; cI = 0 end
                term.write("Host OK! "..c)
                term.setCursorPos(1, 3)
                rednet.send(e, "client", "HEARTBEAT")
            else
                print("Host disconnected!")
                if shutdown == true then
                    os.reboot()
                end
            end
            e, m = rednet.receive("HEARTBEAT", 10)
        end
    else
        print("Failed to init heartbeat!")
        sleep(1)
        os.reboot()
    end
end
function startHost()
    while true do
        if table.getn(IDs) ~= 0 then
            for id = 0, table.getn(IDs) - 1 do
                if IDs[id + 1] ~= nil then
                    rednet.send(IDs[id + 1], "host", "HEARTBEAT")
                    e, ret = rednet.receive("HEARTBEAT", 2)
                    if ret ~= "client" then
                        print(id + 1 .." disconnected.")
                        table.remove(IDs, id + 1)
                    end
                end
            end
        end
        sleep(0.1)
    end
end