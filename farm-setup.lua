-- Collect 1 item from the chest
turtle.select(1)
turtle.suck(1)

-- Move left by one
turtle.turnRight()
turtle.forward()
turtle.turnLeft()

-- Right click the block below with the item from the chest
turtle.select(1)
turtle.placeDown()

-- Move back
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
