print("Startup...")
os.loadAPI("get.lua")

get.getFile("http://localhost:8080/InfiniQuarry/InfiniQuarry/control-panel/startup.lua", "startup.lua")
get.getFile("http://localhost:8080/InfiniQuarry/InfiniQuarry/control-panel/main.lua", "main.lua")

get.getFile("http://localhost:8080/InfiniQuarry/InfiniQuarry/control-panel/disconnected.nfp", "disconnected.nfp")
get.getFile("http://localhost:8080/heartbeat.lua", "heartbeat.lua")
get.getFile("http://localhost:8080/get.lua", "get.lua")
get.getFile("http://localhost:8080/InfiniQuarry/InfiniQuarry/control-panel/minerAPI.lua", "minerAPI.lua")


get.getFile("http://localhost:8080/GUI/GUI.lua", "GUI.lua")
get.getFile("http://localhost:8080/GUI/GUILabel.lua", "GUILabel.lua")
get.getFile("http://localhost:8080/GUI/GUIButton.lua", "GUIButton.lua")
get.getFile("http://localhost:8080/GUI/GUIUtils.lua", "GUIUtils.lua")

print("Running program...")
shell.run("main.lua")