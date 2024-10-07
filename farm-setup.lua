-- Turtle farming script for 10x10 area
-- Starting position should be in front of chest, facing it
-- User inputs coordinates for farm location

-- Constants
local AREA_SIZE = 10
local ITEMS_NEEDED = AREA_SIZE * AREA_SIZE

-- Get coordinates from user
local function getCoordinates()
    print("Enter the coordinates for the bottom-left corner of the farm:")
    io.write("X coordinate: ")
    local x = tonumber(io.read())
    io.write("Y coordinate: ")
    local y = tonumber(io.read())
    io.write("Z coordinate: ")
    local z = tonumber(io.read())
    
    if not (x and y and z) then
        print("Invalid coordinates. Please enter numbers only.")
        return nil
    end
    
    return {x = x, y = y, z = z}
end

-- Calculate relative direction and distance
local function calculatePath(target)
    -- Get current position
    local success, x, y, z = commands.getBlockPosition()
    if not success then
        print("Error: Cannot get current position. Make sure computer.enableGPS() has been run.")
        return nil
    end
    
    -- Calculate distances
    local dx = target.x - x
    local dy = target.y - y
    local dz = target.z - z
    
    return {dx = dx, dy = dy, dz = dz}
end

-- Navigate to coordinates
local function navigateToCoordinates(path)
    -- Move to correct Y level first
    if path.dy > 0 then
        for i = 1, path.dy do
            while not turtle.up() do
                turtle.digUp()
            end
        end
    elseif path.dy < 0 then
        for i = 1, -path.dy do
            while not turtle.down() do
                turtle.digDown()
            end
        end
    end
    
    -- Face correct direction (assume starting facing -Z)
    if path.dx > 0 then
        turtle.turnRight()
    elseif path.dx < 0 then
        turtle.turnLeft()
    elseif path.dz > 0 then
        turtle.turnRight()
        turtle.turnRight()
    end
    
    -- Move in X direction
    for i = 1, math.abs(path.dx) do
        while not turtle.forward() do
            turtle.dig()
        end
    end
    
    -- Adjust for Z movement
    if path.dx > 0 then
        turtle.turnLeft()
    elseif path.dx < 0 then
        turtle.turnRight()
    end
    
    -- Move in Z direction
    for i = 1, math.abs(path.dz) do
        while not turtle.forward() do
            turtle.dig()
        end
    end
    
    return true
end

-- Check if we have enough fuel
local function checkFuel()
    -- Estimate fuel needed for navigation and farming
    local fuelNeeded = ITEMS_NEEDED * 2 + 200  -- Extra 200 for navigation
    if turtle.getFuelLevel() < fuelNeeded then
        print(string.format("Warning: Low fuel. Need at least %d fuel.", fuelNeeded))
        return false
    end
    return true
end

-- Collect items from chest
local function collectFromChest()
    local success = turtle.suck(ITEMS_NEEDED)
    if not success then
        print("Failed to get items from chest. Make sure chest contains at least " .. ITEMS_NEEDED .. " items.")
        return false
    end
    
    -- Verify item count
    local itemCount = 0
    for i = 1, 16 do
        turtle.select(i)
        itemCount = itemCount + turtle.getItemCount()
    end
    
    if itemCount < ITEMS_NEEDED then
        print(string.format("Not enough items. Need %d, only got %d.", ITEMS_NEEDED, itemCount))
        -- Return items to chest
        for i = 1, 16 do
            turtle.select(i)
            turtle.drop()
        end
        return false
    end
    
    turtle.select(1)
    return true
end

-- Right click on the block below
local function rightClickBlock()
    if turtle.getItemCount() == 0 then
        for i = 1, 16 do
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                break
            end
        end
    end
    turtle.placeDown()
end

-- Main farming function
local function farmArea()
    for row = 1, AREA_SIZE do
        for col = 1, AREA_SIZE do
            rightClickBlock()
            
            if col < AREA_SIZE then
                turtle.forward()
            end
        end
        
        if row < AREA_SIZE then
            if row % 2 == 1 then
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        end
    end
end

-- Store starting position and orientation
local startX, startY, startZ, startFacing

-- Save starting position
local function saveStartPosition()
    local success, x, y, z = commands.getBlockPosition()
    if not success then
        print("Error: Cannot get current position. Make sure computer.enableGPS() has been run.")
        return false
    end
    startX, startY, startZ = x, y, z
    -- We'll assume the turtle starts facing -Z (north)
    startFacing = 0
    return true
end

-- Return to starting position
local function returnToStart()
    local target = {x = startX, y = startY, z = startZ}
    local path = calculatePath(target)
    if path then
        return navigateToCoordinates(path)
    end
    return false
end

-- Main program
local function main()
    print("Starting farming program...")
    
    -- Enable GPS
    if not commands.enableGPS() then
        print("Error: Could not enable GPS. Make sure GPS system is set up.")
        return
    end
    
    if not saveStartPosition() then
        return
    end
    
    if not checkFuel() then
        return
    end
    
    if not collectFromChest() then
        return
    end
    
    local farmCoords = getCoordinates()
    if not farmCoords then
        return
    end
    
    print("Navigating to farm location...")
    local pathToFarm = calculatePath(farmCoords)
    if not pathToFarm or not navigateToCoordinates(pathToFarm) then
        print("Failed to navigate to farm location.")
        return
    end
    
    print("Starting farming operation...")
    farmArea()
    
    print("Returning to starting position...")
    if not returnToStart() then
        print("Failed to return to starting position.")
        return
    end
    
    -- Drop any leftover items
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    
    print("Farming complete!")
end

-- Run the program
main()