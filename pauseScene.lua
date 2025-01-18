local pauseScene = {}
local roomScene = require("roomScene")

-- Pause Menu Functions
function pauseScene.drawPause()
    -- light tint and background game rendering
    roomScene.drawRoom()
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    -- funny pause png
    if #lavaLampFrames > 0 then
        love.graphics.draw(lavaLampFrames[currentFrame], (love.graphics.getWidth() / 2) - lavaLampFrames[currentFrame]:getWidth() + 25, 250, 0, 1.5, 1.5)
    end
    -- "buttons"
    love.graphics.draw(resumeText, (love.graphics.getWidth() / 2) - resumeText:getWidth() + 170, 340, 0 , 1, 1)
    love.graphics.draw(quitTextPause, (love.graphics.getWidth() / 2) - quitText:getWidth() + 195, 400, 0 , 1, 1)
end

function pauseScene.updatePause(dt)
    animationTimer = animationTimer + dt
    if animationTimer >= frameDuration then
        animationTimer = animationTimer - frameDuration
        currentFrame = currentFrame + 1
        if currentFrame > #lavaLampFrames then
            currentFrame = 1
        end
    end
end

function pauseScene.mousePressPause(x, y, button, istouch)
    -- No mouse interaction in pause menu bismillah
end
-- End Pause Menu Functions


return pauseScene