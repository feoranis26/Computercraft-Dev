redoGoto = false

is_moving = false

is_paused = false
function faceFront_Goto()
    pcall(faceFront_Goto_unprotected)
end
function faceFront()
    pcall(faceFront_unprotected)
end

function faceFront_unprotected()
    pX, pZ, pY = gps.locate()
    if turtle.detect() == true then
        while turtle.detect() == true do
            turtle.turnLeft()
        end
    end
    turtle.forward()

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
    turtle.forward()
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
function gotoReverse(sX, sY)
    redoGoto = false
    print("Goto attempt 2")
    aX, aZ, aY = gps.locate()
    x2 = aX - sX
    y2 = aY - sY 
    if aX ~= sX or aY ~= sY then
        if y2 > 0 then
            for b = 0, y2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
            end
        else
            turtle.turnLeft()
            turtle.turnLeft()
            for b = 0, y2 * -1 -1 do
                while is_paused do sleep(1) end
                turtle.forward()
            end
            turtle.turnRight()
            turtle.turnRight()
        end
        if x2 > 0 then
            turtle.turnLeft()
            for a = 0, x2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
            end
            turtle.turnRight()
        else
            turtle.turnRight()
            for a = 0, x2 * -1 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
            end
            turtle.turnLeft()
        end
    end
end
function goto(sX, sY, dig)
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
    term.setCursorPos(1, 5)
    print("Goto pos:",sX,sY," from ",aX,aY)
    x = aX - sX
    y2 = aY - sY 

    print(x, y2)
    if (aX ~= sX) or (aY ~= sY) then
        if x > 0 then
            turtle.turnLeft()
            for a = 0, x - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
                if dig then
                    turtle.dig()
                    turtle.digUp()
                    turtle.digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    print("redoing")
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
                    turtle.dig()
                    turtle.digUp()
                    turtle.digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    print("redoing")
                    break;
                end
            end
            turtle.turnLeft()
        end
        print(redoGoto)
        if y2 > 0 and redoGoto == false then
            for b = 0, y2 - 1 do
                while is_paused do sleep(1) end
                turtle.forward()
                if dig then
                    turtle.dig()
                    turtle.digUp()
                    turtle.digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    print("redoing")
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
                    turtle.dig()
                    turtle.digUp()
                    turtle.digDown()
                elseif turtle.detect() == true then
                    redoGoto = true
                    print("redoing")
                    break;
                end
            end
            turtle.turnRight()
            turtle.turnRight()
        end
        if redoGoto == true then
            gotoReverse(sX, sY)
        end
    end
end
function gotoY(goZ)
    x, y, z = gps.locate()
    if z > goZ then
        for i = 0, (z - goZ) - 1 do
            turtle.down()
        end
    elseif z < goZ then
        for i = 0, (goZ - z) - 1 do
            turtle.up()
        end
    end
end

function goto_multiple(tX, tZ, dig)
    tX = math.floor(tX)
    tZ = math.floor(tZ)

    while true do
        sleep(1)
        faceFront_Goto()
        goto(tX, tZ, dig)
        x, y, z = gps.locate()
        if x == tX and z == tZ then
            break
        end
    end 
    faceFront()
end

function pause_movements(pause)
    is_paused = pause
end