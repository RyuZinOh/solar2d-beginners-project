local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

math.randomseed( os.time() )

local sheetOptions = {
    frames = {
        { x = 0, y = 0, width = 102, height = 85 },
        { x = 0, y = 85, width = 90, height = 83 },
        { x = 0, y = 168, width = 100, height = 97 },
        { x = 0, y = 265, width = 98, height = 79 },
        { x = 98, y = 265, width = 14, height = 40 }
    }
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

local lives, score, died = 3, 0, false
local asteroidsTable = {}
local ship, gameLoopTimer, livesText, scoreText

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect( backGroup, "background.png", 800, 1400 )
background.x, background.y = display.contentCenterX, display.contentCenterY

ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x, ship.y = display.contentCenterX, display.contentHeight - 100
physics.addBody( ship, { radius = 30, isSensor = true } )
ship.myName = "ship"

livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

display.setStatusBar( display.HiddenStatusBar )

local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

local function createAsteroid()
	local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius = 40, bounce = 0.8 } )
	newAsteroid.myName = "asteroid"

	local whereFrom = math.random( 3 )
	if whereFrom == 1 then
		newAsteroid.x = -60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif whereFrom == 2 then
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	else
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end
	newAsteroid:applyTorque( math.random( -6,6 ) )
end

local function fireLaser()
	local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
	physics.addBody( newLaser, "dynamic", { isSensor = true } )
	newLaser.isBullet = true
	newLaser.myName = "laser"
	newLaser.x, newLaser.y = ship.x, ship.y
	newLaser:toBack()

	transition.to( newLaser, { y = -40, time = 500, onComplete = function() display.remove( newLaser ) end })
end

ship:addEventListener( "tap", fireLaser )

local function dragShip( event )
	local ship = event.target
	local phase = event.phase
	if phase == "began" then
		display.currentStage:setFocus( ship )
		ship.touchOffsetX = event.x - ship.x
	elseif phase == "moved" then
		ship.x = event.x - ship.touchOffsetX
	else
		display.currentStage:setFocus( nil )
	end
	return true
end

ship:addEventListener( "touch", dragShip )

local function gameLoop()
	createAsteroid()
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]
		if thisAsteroid.x < -100 or thisAsteroid.x > display.contentWidth + 100 or thisAsteroid.y < -100 or thisAsteroid.y > display.contentHeight + 100 then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )
		end
	end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )

local function restoreShip()
	ship.isBodyActive = false
	ship.x, ship.y = display.contentCenterX, display.contentHeight - 100
	transition.to( ship, { alpha = 1, time = 4000, onComplete = function()
		ship.isBodyActive = true
		died = false
	end })
end

local function onCollision( event )
	if event.phase == "began" then
		local obj1, obj2 = event.object1, event.object2
		if (obj1.myName == "laser" and obj2.myName == "asteroid") or (obj1.myName == "asteroid" and obj2.myName == "laser") then
			display.remove( obj1 )
			display.remove( obj2 )
			for i = #asteroidsTable, 1, -1 do
				if asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 then
					table.remove( asteroidsTable, i )
					break
				end
			end
			score = score + 100
			scoreText.text = "Score: " .. score
		elseif (obj1.myName == "ship" and obj2.myName == "asteroid") or (obj1.myName == "asteroid" and obj2.myName == "ship") then
			if not died then
				died = true
				lives = lives - 1
				livesText.text = "Lives: " .. lives
				if lives == 0 then
					display.remove( ship )
				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		end
	end
end

Runtime:addEventListener( "collision", onCollision )
