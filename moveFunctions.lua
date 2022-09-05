redoGoto = false

is_moving = false

is_paused = false
function faceFront_Goto(dig)
    pcall(function() faceFront_Goto_unprotected(dig) end)
end
function faceFront(dig)
    pcall(function() faceFront_unprotected(dig) end)
end

function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end


function checkForLiquids() -- TODO: Test this!
    local x, datUp = turtle.inspectUp()
    local x, datDown = turtle.inspectDown()

    if datUp ~= nil then
        if datUp.name == "minecraft:water" or datUp.name == "minecraft:lava" then
            turtle.digUp()

            turtle.up()
            turtle.down()
        end
    end
    if datDown ~= nil then
        if datDown.name == "minecraft:water" or datDown.name == "minecraft:lava" or datDown.name ==
            "minecraft:flowing_water" or datDown.name == "minecraft:flowing_lava" then
            turtle.digDown()
            turtle.down()
            turtle.up()
        end
    end
end


bannedBlocks = {"computercraft:turtle_advanced", "chisel:technical", "chisel:technical1", "chisel:factory"}

function digUp()
    local t, d = turtle.inspectUp()
    if t and not contains(bannedBlocks, d.name) then
        turtle.digUp()
    end
end

function digForward()
    local t, d = turtle.inspect()
    if t and not contains(bannedBlocks, d.name) then
        turtle.dig()
        checkForLiquids()
    end
end

function digDown()
    local t, d = turtle.inspectDown()
    if t and not contains(bannedBlocks, d.name) then
        turtle.digDown()
    end
end

function faceFront_unprotected(dig)
    pX, pZ, pY = gps.locate()
    if turtle.detect() == true then
        while turtle.detect() == true do
            turtle.turnLeft()
        end
    end
    turtle.forward()

    if dig then
        digUp()
        digForward()
        digDown()
    end

    aX = 0
    aY = 0
    while true do
        aX, aZ, aY = gps.locate()
        if aX == aX or aY == aY then
            break
        end
        sleep(1)
    end

    nX = aX - pX
    nY = aY - pY
    turtle.back()

    if dig then
        digUp()
        digForward()
        digDown()
    end

    if nY == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif nX == 1 then
        turtle.turnLeft()
    elseif nX == -1 then
        turtle.turnRight()
    end
end

function faceFront_Goto_unprotected()
    pX, pZ, pY = gps.locate()
    if turtle.detect() == true then
        while turtle.detect() == true do
            turtle.turnLeft()
        end
    end
    if dig then
        digUp()
        digForward()
        digDown()
    end

    turtle.forward()

    if dig then
        digUp()
        digForward()
        digDown()
    end

    aX, aZ, aY = gps.locate()
    nX = aX - pX
    nY = aY - pY
    --turtle.back()
    if nY == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif nX == 1 then
        turtle.turnLeft()
    elseif nX == -1 then
        turtle.turnRight()
    end
end
function gotoReverse(sX, sY, dig)
    redoGoto = false
    --print("goTo attempt 2")
    aX, aZ, aY = gps.locate()
    x2 = aX - sX
    y2 = aY - sY 
    if aX ~= sX or aY ~= sY then
        if y2 > 0 then
            for b = 0, y2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                end
            end
        else
            turtle.turnLeft()
            turtle.turnLeft()
            for b = 0, y2 * -1 -1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                end
            end
            turtle.turnRight()
            turtle.turnRight()
        end
        if x2 > 0 then
            turtle.turnLeft()
            for a = 0, x2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                end
            end
            turtle.turnRight()
        else
            turtle.turnRight()
            for a = 0, x2 * -1 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                end
            end
            turtle.turnLeft()
        end
    end
end
function goTo(sX, sY, dig)
    if dig == nil then
        dig = false
    end

    sX = math.floor(sX)
    sY = math.floor(sY)
    if not is_moving then
        is_moving = true
        pcall(function() goto_unprotected(sX, sY, dig) end)
        is_moving = false
    end
end

function goto_unprotected(sX, sY, dig)
    redoGoto = false;
    aX, aZ, aY = gps.locate()
    if aX ~= aX or aY ~= aY then
        return nil
    end
    --term.setCursorPos(1, 5)
    --print("goTo pos:",sX,sY," from ",aX,aY)
    x = aX - sX
    y2 = aY - sY 

    --print(x, y2)
    if (aX ~= sX) or (aY ~= sY) then
        if x > 0 then
            turtle.turnLeft()
            for a = 0, x - 1 do
                while is_paused do sleep(1) end
                turtle.forward()

                
                if dig then
                    digUp()
                    digForward()
                    digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    --print("redoing")
                    break;
                end
            end
            turtle.turnRight()
        elseif x < 0 then
            turtle.turnRight()
            for a = 0, x * -1 -1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    --print("redoing")
                    break;
                end
            end
            turtle.turnLeft()
        end
        --print(redoGoto)
        if y2 > 0 and redoGoto == false then
            for b = 0, y2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
                
                if dig then
                    digUp()
                    digForward()
                    digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    --print("redoing")
                    break;
                end
            end
        elseif redoGoto == false and y2 < 0 then
            turtle.turnLeft()
            turtle.turnLeft()
            for b = 0, y2 * -1 -1 do
                while is_paused do sleep(1) end
                turtle.forward()

                if dig then
                    digUp()
                    digForward()
                    digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    --print("redoing")
                    break;
                end
            end
            turtle.turnRight()
            turtle.turnRight()
        end
        if redoGoto == true then
            gotoReverse(sX, sY, dig)
        end
    end
end
function gotoY(goY, dig)
    gyx, gyy, gyz = gps.locate()
    if gyy > goY then
        for i = 0, (gyy - goY) - 1 do
            if dig then
                digDown()
            end
            turtle.down()
        end
    elseif gyy < goY then
        for i = 0, (goY - gyy) - 1 do
            if dig then
                digDown()
            end
            turtle.up()
        end
    end
end

function goto_multiple(tX, tZ, dig)
    tX = math.floor(tX)
    tZ = math.floor(tZ)

    while true do
        x, y, z = gps.locate()
        if x == tX and z == tZ then
            return
        end

        sleep(1)
        faceFront_Goto(dig)
        goTo(tX, tZ, dig)
    end 
    faceFront(dig)
end

function pause_movements(pause)
    is_paused = pause
end

