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
    if (not (miner.busy or miner.working)) and worksitePos ~= nil and worksitePos.x ~= 0 and worksitePos.z ~= 0 then
        busy = true
        moveFunctions.goto_multiple(worksitePos.x, worksitePos.z, true)
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
    tmp = (size - 1) / 2
    sitePos = toVector(miner.homePos.x - tmp + 1, 0, miner.homePos.z - tmp + 1)

    size = size - 1

    if side == 0 then
        mX = sitePos.x + pos
        mZ = sitePos.z
    elseif side == 1 then
        mX = sitePos.x + size
        mZ = sitePos.z + pos
    elseif side == 2 then
        mX = sitePos.x + size - pos
        mZ = sitePos.z + size
    elseif side == 3 then
        mX = sitePos.x
        mZ = sitePos.z + size - pos
    end
    term.setCursorPos(1, 8)

    lX, lY, lZ = gps.locate()
    if lX == lX and lZ == lZ then
        worksitePos = toVector(lX, lY, lZ)

        print(mX, mZ, size, pos, side, lX, lZ)

        if mX ~= lX or mZ ~= lZ then
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
            for i = 0, side do
                turtle.turnRight()
            end
            miner.busy = false
        end
    end
end

function next_block()
    if side ~= 3 and pos == size - 1 then
        side = side + 1
        pos = 0
        turtle.turnRight()
    elseif pos == size - 1 then
        side = 0
        pos = 0
        actions.changeSize()
        size = size + 2
        print("CHANGING SIZE to ".. size)
    end
    lX, lY, lZ = gps.locate()
    worksitePos = toVector(lX, lY, lZ)
    pos = pos + 1
    checkPos()
end