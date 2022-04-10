--wget run http://localhost:8080/InfiniQuarry/miner/startup.lua

print("Startup...")

function getFile(path, fileName)
    print("Get "..fileName)
    f = http.get(path)
    file = fs.open(fileName, "w")
    file.write(f.readAll())
    file.close()
end

getFile("http://localhost:8080/InfiniQuarry/miner/startup.lua", "startup.lua")
getFile("http://localhost:8080/InfiniQuarry/miner/main.lua", "main.lua")
getFile("http://localhost:8080/moveFunctions.lua", "moveFunctions.lua")
getFile("http://localhost:8080/heartbeat.lua", "heartbeat.lua")
getFile("http://localhost:8080/get.lua", "get.lua")

getFile("http://localhost:8080/InfiniQuarry/miner/miner.lua", "miner.lua")
getFile("http://localhost:8080/InfiniQuarry/miner/comms.lua", "comms.lua")
getFile("http://localhost:8080/InfiniQuarry/miner/actions.lua", "actions.lua")
getFile("http://localhost:8080/InfiniQuarry/miner/Commands.lua", "Commands.lua")
getFile("http://localhost:8080/InfiniQuarry/miner/quarry_position_mgr.lua", "quarry_position_mgr.lua")

print("Running program...")
shell.run("main.lua")