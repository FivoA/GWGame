local menuScene = {
    -- insert functions here
}

-- Menu Scene Functions
function menuScene.drawMenu()
    love.graphics.draw(menuBG, 0, 0, 0 , 1, 1) 
    if menuIndex == 1 then
        love.graphics.draw(titleTextSpecial, (love.graphics.getWidth() / 2) - titleText:getWidth() + 500, 70, 0 , 1, 1)
        love.graphics.draw(startText, (love.graphics.getWidth() / 2) - startText:getWidth() + 170, 240, 0 , 1, 1)
        love.graphics.draw(quitText, (love.graphics.getWidth() / 2) - quitText:getWidth() + 195, 340, 0 , 1, 1) 
    else 
        love.graphics.draw(titleText, (love.graphics.getWidth() / 2) - titleText:getWidth() + 500, 70, 0 , 1, 1)
        love.graphics.draw(startTextSpecial, (love.graphics.getWidth() / 2) - startText:getWidth() + 170, 240, 0 , 1, 1)
        love.graphics.draw(quitTextSpecial, (love.graphics.getWidth() / 2) - quitText:getWidth() + 195, 340, 0 , 1, 1) 
    end
end

function menuScene.updateMenu(dt)
    menuTimer = menuTimer + dt
    if menuTimer > 0.75 then -- threshhold to change images
        menuTimer = 0
        if menuIndex == 1 then
            menuIndex = 2
        else
            menuIndex = 1
        end
    end
end

function menuScene.mousePressMenu(x, y, button, istouch)
    -- No mouse interaction in main menu bismillah
end
-- End Menu Scene Functions


return menuScene