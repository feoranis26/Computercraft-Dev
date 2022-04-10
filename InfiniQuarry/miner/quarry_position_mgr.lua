worksitePos = {}
worksitePos.x = 0
worksitePos.z = 0

side = 0
pos = 0
size = 3

function toVector(x, y, z)
    local vector = {}
    vector.x = x
    vector.y = y
    vector.z = z
    return vector
end

function gotoWorksite()
    if (not (miner.busy or miner.working)) and worksitePos ~= nil and quarry_position_mgr.worksitePos.x ~= 0 and quarry_position_mgr.worksitePos.z ~= 0 then
        busy = true
        moveFunctions.goto_multiple(quarry_position_mgr.worksitePos.x, quarry_position_mgr.worksitePos.z, true)
        for i = 0, quarry_position_mgr.side do
            turtle.turnRight()
        end
        busy = false
        return true
    elseif (not (miner.busy or miner.working)) then
        moveFunctions.faceFront()
        turtle.turnRight()
        return false
    end
end

function checkPos()
    tmp = (quarry_position_mgr.size - 1) / 2
    sitePos = toVector(miner.homePos.x - tmp + 1, 0, miner.homePos.z - tmp + 1)

    tmpsize = quarry_position_mgr.size - 1

    if quarry_position_mgr.side == 0 then
        mX = sitePos.x + quarry_position_mgr.pos
        mZ = sitePos.z
    elseif quarry_position_mgr.side == 1 then
        mX = sitePos.x + quarry_position_mgr.size
        mZ = sitePos.z + quarry_position_mgr.pos
    elseif quarry_position_mgr.side == 2 then
        mX = sitePos.x + quarry_position_mgr.size - quarry_position_mgr.pos
        mZ = sitePos.z + quarry_position_mgr.size
    elseif quarry_position_mgr.side == 3 then
        mX = sitePos.x
        mZ = sitePos.z + quarry_position_mgr.size - quarry_position_mgr.pos
    end
    term.setCursorPos(1, 8)

    lX, lY, lZ = gps.locate()
    if lX == lX and lZ == lZ and lY == lY then
        quarry_position_mgr.worksitePos = toVector(lX, lY, lZ)

        print(quarry_position_mgr.size, miner.homePos.x, miner.homePos.z, sitePos.x, sitePos.z, mX, mZ, quarry_position_mgr.size, quarry_position_mgr.pos, quarry_position_mgr.side, lX, lZ)

        if math.abs(mX - lX) > 1 or math.abs(mZ - lZ) > 1 then
            miner.busy = true
            print("I'm not aligned! Trying to go to worksite...")
            atPos = false
            while atPos == false do
                moveFunctions.faceFront_Goto()
                moveFunctions.goto(mX, mZ, true)
                x, y, z = gps.locate()
                if x == mX and z == mZ then
                    atPos = true
                end
            end 
            moveFunctions.faceFront()
            for i = 0, quarry_position_mgr.side do
                turtle.turnRight()
            end
            miner.busy = false
        end

        
    end
end

function checkYLevel()
    if miner.yLevel ~= -1 and lY ~= miner.yLevel then
        moveFunctions.gotoY(miner.yLevel)
    end
end

function next_block()
    if quarry_position_mgr.side ~= 3 and quarry_position_mgr.pos == quarry_position_mgr.size - 1 then
        quarry_position_mgr.side = quarry_position_mgr.side + 1
        quarry_position_mgr.pos = 0
        turtle.turnRight()
    elseif quarry_position_mgr.pos == quarry_position_mgr.size - 1 then
        quarry_position_mgr.side = 0
        quarry_position_mgr.pos = 0
        actions.changeSize()
        quarry_position_mgr.size = quarry_position_mgr.size + 2
        print("CHANGING SIZE to ".. size)
    end
    lX, lY, lZ = gps.locate()
    quarry_position_mgr.worksitePos = toVector(lX, lY, lZ)
    quarry_position_mgr.pos = quarry_position_mgr.pos + 1
    checkPos()
end