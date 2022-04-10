--wget run http://localhost:8080/InfiniQuarry/control-panel/startup.lua

print("Startup...")

function getFile(path, fileName)
    print("Get "..fileName)
    f = http.get(path)
    file = fs.open(fileName, "w")
    file.write(f.readAll())
    file.close()
end

getFile("http://localhost:8080/InfiniQuarry/control-panel/startup.lua", "startup.lua")
getFile("http://localhost:8080/InfiniQuarry/control-panel/main.lua", "main.lua")

getFile("http://localhost:8080/InfiniQuarry/control-panel/disconnected.nfp", "disconnected.nfp")
getFile("http://localhost:8080/heartbeat.lua", "heartbeat.lua")
getFile("http://localhost:8080/get.lua", "get.lua")
getFile("http://localhost:8080/InfiniQuarry/control-panel/minerAPI.lua", "minerAPI.lua")


getFile("http://localhost:8080/GUI/GUI.lua", "GUI.lua")
getFile("http://localhost:8080/GUI/GUILabel.lua", "GUILabel.lua")
getFile("http://localhost:8080/GUI/GUIButton.lua", "GUIButton.lua")
getFile("http://localhost:8080/GUI/GUIUtils.lua", "GUIUtils.lua")

print("Running program...")
shell.run("main.lua")