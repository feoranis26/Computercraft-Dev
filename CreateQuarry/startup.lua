print("Startup...")

function getFile(path, fileName)
    print("Get "..fileName)
    f = http.get(path)
    file = fs.open(fileName, "w")
    file.write(f.readAll())
    file.close()
end

getFile("http://localhost:8080/CreateQuarry/startup.lua", "startup.lua")
getFile("http://localhost:8080/CreateQuarry/main.lua", "main.lua")
getFile("http://localhost:8080/CreateQuarry/coords.lua", "coords.lua")
getFile("http://localhost:8080/CreateQuarry/motionSequences.lua", "motionSequences.lua")
getFile("http://localhost:8080/moveFunctions.lua", "moveFunctions.lua")

print("Running program...")
shell.run("main.lua")