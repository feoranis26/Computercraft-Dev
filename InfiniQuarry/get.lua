function getFile(path, fileName)
    print("Get "..fileName)
    f = http.get(path)
    file = fs.open(fileName, "w")
    file.write(f.readAll())
    file.close()
end

function getFileFromServer(fileName)
    print("Get "..fileName)
    rednet.broadcast("GET "..fileName, "ftp")
    while true do
        s, f, p = rednet.receive("ftp", 60)
        if s == nil or f == nil then
            print("Could not connect to file server.")
            return
        end
        if f:sub(1, 3) == "SND" then
            f = f:sub(5)
            file = fs.open(fileName, "w")
            file.write(f)
            file.close()
            return
        end
    end
end

function fileServer()
    while true do
        s, m, p = rednet.receive("ftp")
        if m:sub(1, 3) == "GET" then
            file = fs.open(m:sub(5), "r")
            if file ~= nil then
                f = file.readAll()
                rednet.send(s, "SND "..f, "ftp")
            end
        end
    end
end
