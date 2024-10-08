local physics = require("physics")
physics.start()

local tapSound = audio.loadSound("tap.mp3")

local background = display.newImageRect("background.png", 360, 570)
background.x, background.y = display.contentCenterX, display.contentCenterY

local platform = display.newImageRect("platform.png", 300, 50)
platform.x, platform.y = display.contentCenterX, display.contentHeight - 25

local balloon = display.newImageRect("balloon.png", 112, 112)
balloon.x, balloon.y = display.contentCenterX, display.contentCenterY
balloon.alpha = 0.8

physics.addBody(platform, "static")
physics.addBody(balloon, "dynamic", { radius = 50, bounce = 0.3 })

local tapCount = 0
local tapText = display.newText(tapCount, display.contentCenterX, 20, native.systemFont, 40)
tapText:setFillColor(0, 0, 0)

local function pushBalloon()
    balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
    audio.play(tapSound)  
    tapCount = tapCount + 1
    tapText.text = tapCount
end
balloon:addEventListener("tap", pushBalloon)
