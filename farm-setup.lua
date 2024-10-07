-- Collect 1 item from the chest
turtle.suck(1)

-- Move left by one
turtle.turnLeft()
turtle.forward()
turtle.turnRight()

-- Right click the block below with the item from the chest
turtle.placeDown()

-- Move back
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
