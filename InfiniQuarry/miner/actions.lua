function home()
    if not (miner.busy or miner.working) then
        miner.busy = true
        moveFunctions.goto_multiple(miner.homePos.x, miner.homePos.z, true)
        miner.busy = false
    end
end
function startup()
    if not (miner.busy or miner.working) then
        miner.busy = true
        miner.goingToWork = true
        if turtle.detectUp then
            turtle.digUp()
        end
        turtle.up()
        turtle.down()
        turtle.up()
        turtle.down()
        quarry_position_mgr.gotoWorksite()
        miner.working = true
        miner.goingToWork = false
        miner.busy = false
    end
end
function corner()
    miner.busy = true
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
    if not turtle.detect() then
        turtle.back()
        turtle.turnLeft()
    end
    miner.busy = false
end
function dropItems()
    miner.busy = true
    moveFunctions.pause_movements(true)
    sleep(5)
    turtle.select(1)
    turtle.placeDown()
    for a = 4, 16 do
        turtle.select(a)
        turtle.dropDown()
    end
    turtle.select(1)
    turtle.digDown()
    moveFunctions.pause_movements(false)
    miner.busy = false
end

function checkItems()
    if turtle.getItemCount(13) > 0 then
        dropItems()
    end
end

function checkFuel()
    if turtle.getFuelLevel() < 1000 then
        moveFunctions.pause_movements(true)
        sleep(5)
        turtle.select(2)
        turtle.placeDown()
        turtle.suckDown(64)
        turtle.refuel(64)
        turtle.select(2)
        turtle.digDown()
        moveFunctions.pause_movements(false)
    end
end

function changeSize()
    miner.busy = true
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
    turtle.turnRight()
    miner.busy = false
end

function checks()
    while true do
        checkFuel()
        checkItems()
    end
end

function chunkLoader(mine)
    turtle.select(3)
    turtle.up()
    if mine then
        turtle.select(4)
        turtle.equipLeft()
        turtle.select(3)
        turtle.digUp()
        turtle.select(4)
        turtle.equipLeft()
    else
        turtle.placeUp()
    end
    turtle.down()
end

function checkForLiquids() --TODO: Test this!
    local x, dat = turtle.inspect()
    local x, datUp = turtle.inspectUp()
    local x, datDown = turtle.inspectDown()

    go = false

    if dat ~= nil then
        if dat.name == "minecraft:water" or dat.name == "minecraft:lava" or dat.name == "minecraft:flowing_water" or
            dat.name == "minecraft:flowing_lava" then
            go = true
        end
    end
    if datUp ~= nil then
        if datUp.name == "minecraft:water" or datUp.name == "minecraft:lava" or datUp.name == "minecraft:flowing_water" or
            datUp.name == "minecraft:flowing_lava" then
            go = true
        end
    end
    if datDown ~= nil then
        if datDown.name == "minecraft:water" or datDown.name == "minecraft:lava" or datDown.name ==
            "minecraft:flowing_water" or datDown.name == "minecraft:flowing_lava" then
            go = true
        end
    end

    if go then
        turtle.digUp()
        turtle.digDown()
        turtle.up()
        turtle.down()
        turtle.down()
        turtle.up()
    end
end
