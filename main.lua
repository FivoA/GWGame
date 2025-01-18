--  scene system table
local gamestateTable = {"menu", "roomscene", "paused"} 
local currentGamestate = "menu"

local items = {} -- table with clickable items in room
--the rest are tables for the actual items themselves, not just the rendered sprites
local manual = {} -- code manual

-- day specific variables
local muffinRemoved = false
local displayedDaily = false
local dailyText = nil

-- Time system variables
local realSecondsPerInGameHour = 5
local gameTime = 8 * 3600
local gameHours = 8
local gameMinutes = 0
local timeText = nil
-- day system variables
local day = 1
local dayText = nil

-- clickable mutex (only one item can be opened at once type shi)
local somethingOpen = false

-- info textbox system variables
local infoBoxVisible = false
local infoBoxTimer = 0
local infoBoxText = nil

-- day to night gradient system variables
local colors = {
    day = {0.843, 0.910, 0.992},        -- 8:00 AM
    evening = {0.243, 0.310, 0.412},    -- 6:00 PM
    night = {0.031, 0.039, 0.086}       -- 11:59 PM
}
-- fade effect variables
local fadeDuration = 3
local fadeTime = 0  -- time since fade started
local fading = false
local fadeAlpha = 0  -- Alpha value for fade

--manual book text variables
local manualPageText = nil
local manualText = nil

-- menu timer variable
menuTimer = 0
menuIndex = 1

-- sick pause menu animation variables
local lavaLampFrames = {}
local currentFrame = 1 -- current frame index
local animationTimer = 0
local frameDuration = 0.2


function love.load() -- done once on game start up, load all assets and resources
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    love.window.setMode(screenWidth, screenHeight, { fullscreen = true }) -- just scales the game to fullscreen no matter what ur on

    --black
    blackBG = love.graphics.newImage("assets/images/blackBG.png")
    -- sprites
    bg = love.graphics.newImage("assets/images/room.png")
    infoBox = love.graphics.newImage("assets/images/infoBox.png")
    clock = love.graphics.newImage("assets/images/clock.png")
    -- sprites of items
    computer = love.graphics.newImage("assets/images/computer.png")
    computerHovered = love.graphics.newImage("assets/images/computerHovered.png")
    manual = love.graphics.newImage("assets/images/manual.png")
    manualHovered = love.graphics.newImage("assets/images/manualHovered.png")
    muffin = love.graphics.newImage("assets/images/muffin.png")
    muffinHovered = love.graphics.newImage("assets/images/muffinHovered.png")
    note = love.graphics.newImage("assets/images/note.png")
    noteHovered = love.graphics.newImage("assets/images/noteHovered.png")
    switch = love.graphics.newImage("assets/images/switch.png")
    switchHovered = love.graphics.newImage("assets/images/switchHovered.png")

    table.insert(items, {
        image = {computer, computerHovered},
        width = computer:getWidth(),
        height = computer:getHeight(),
        x = (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) +370,
        y = love.graphics.getHeight() - (bg:getHeight()) + 220,
        rot = 0,
        scaleX =  1.75,
        scaleY =  1.75,
        isHovered = false
    })
    table.insert(items, {
        image = {manual, manualHovered},
        width = manual:getWidth(),
        height = manual:getHeight(),
        x = (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) +220,
        y = love.graphics.getHeight() - (bg:getHeight()) + 240,
        rot = 0,
        scaleX =  1.75,
        scaleY =  1.75,
        isHovered = false
    })
    table.insert(items, {
        image = {muffin, muffinHovered},
        width = muffin:getWidth(),
        height = muffin:getHeight(),
        x = (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) +330,
        y = love.graphics.getHeight() - (bg:getHeight()) + 410,
        rot = 0,
        scaleX = 1.75,
        scaleY = 1.75,
        isHovered = false
    })
    table.insert(items, {
        image = {switch, switchHovered},
        width = switch:getWidth(),
        height = switch:getHeight(),
        x = (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) +510,
        y = love.graphics.getHeight() - (bg:getHeight()) + 360,
        rot = 0,
        scaleX = 1.75,
        scaleY = 1.75,
        isHovered = false
    })

    --music
    backgroundMusic = love.audio.newSource("assets/sounds/bgmusic.wav", "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:play()
    backgroundMusic:setVolume(0.05)

    --base Rendering Settings
    love.graphics.setColor(1, 1, 1) -- sets no tint on rendered stuff
    love.graphics.setNewFont(12)

    -- in-game objects
    --code-manual
    manual = {
        isOpen = false,
        position = {
            x= (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) -390,
            y= love.graphics.getHeight() - (bg:getHeight()) + 70
        },
        pages = {
            "Command: Exists the terminal\n\nTo use: exit",
            "Command: Change Directory\n\nTo use: cd <availible subdirectory> or cd .. (this goes to parent directory)",
            "Command: Lists all subdirectories\n\nTo use: ls"
        }, -- we can dynamically add new pages for new terminal commands here!
        currentPage = 1,
        pageCount = 3,
        sprites = {
            open = {
                image = love.graphics.newImage("assets/images/openBook.png"),
                position = {
                    x = 300,
                    y = 200
                },
                scaleX = 2,
                scaleY = 2
            },
            xButton = {
                image = love.graphics.newImage("assets/images/xButton.png"),
                position = {
                    x = 0,
                    y = 0
                },
                scaleX = 0.075,
                scaleY = 0.075
            },
            leftButton = {
                image = love.graphics.newImage("assets/images/leftButton.png"),
                position = {
                    x = 0,
                    y = 0
                },
                scaleX = 0.2,
                scaleY = 0.2
            },
            rightButton = {
                image = love.graphics.newImage("assets/images/rightButton.png"),
                position = {
                    x = 0,
                    y = 0
                },
                scaleX = 0.2,
                scaleY = 0.2
            }
        }
    }
    -- we have to make this assignment here cause fuckass lua cant use the value bEfOrE tHe tAbLe iS cReAtEd
    manual.sprites.xButton.position.x = manual.position.x + 505
    manual.sprites.xButton.position.y = manual.position.y + 80

    manual.sprites.leftButton.position.x = manual.position.x + 155
    manual.sprites.leftButton.position.y = manual.position.y + 260

    manual.sprites.rightButton.position.x = manual.position.x + 390
    manual.sprites.rightButton.position.y = manual.position.y + 260

    -- Main Menu asset Loading
    startText = love.graphics.newImage("assets/images/startText.png")
    startTextSpecial = love.graphics.newImage("assets/images/startTextSpecial.png")
    quitText = love.graphics.newImage("assets/images/quitText.png")
    quitTextSpecial = love.graphics.newImage("assets/images/quitTextSpecial.png")
    menuBG = love.graphics.newImage("assets/images/menuBG.png")
    titleText = love.graphics.newImage("assets/images/title.png")
    titleTextSpecial = love.graphics.newImage("assets/images/titleSpecial.png")

    -- Pause Menu asset Loading
    resumeText = love.graphics.newImage("assets/images/resumeText.png")
    quitTextPause = love.graphics.newImage("assets/images/quitTextPause.png")
    for i = 1, 24 do
        local filename = string.format("assets/images/lava/LavaLamp_%d.png", i)
        table.insert(lavaLampFrames, love.graphics.newImage(filename))
    end

    --daily msg asset loading
    dailyBanner = love.graphics.newImage("assets/images/dailyBanner.png")
    dailyX = {
        image = love.graphics.newImage("assets/images/xButton.png"),
        x = (love.graphics.getWidth()/2) + (dailyBanner:getWidth()/2 ) - 25,
        y = 40,
        scaleX = 0.06,
        scaleY = 0.06
    }

    love.graphics.setNewFont(14)

end

function love.draw()
    if currentGamestate == "roomscene" then
        drawRoom()
    elseif currentGamestate == "paused" then
        drawPause()
    else
        drawMenu()
    end
end

function love.update(dt) 
    if currentGamestate == "roomscene" then
        updateRoom(dt)
    elseif currentGamestate == "paused" then
        updatePause(dt)
    else
        updateMenu(dt)
    end
end

function love.mousepressed(x, y, button, istouch) 
    if currentGamestate == "roomscene" then
        mousePressRoom(x, y, button, istouch)
    elseif currentGamestate == "paused" then
        mousePressPause(x, y, button, istouch)
    else
        mousePressMenu(x, y, button, istouch)
    end
end

-- Pause Menu Functions
function drawPause()
    -- light tint and background game rendering
    drawRoom()
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

function updatePause(dt)
    animationTimer = animationTimer + dt
    if animationTimer >= frameDuration then
        animationTimer = animationTimer - frameDuration
        currentFrame = currentFrame + 1
        if currentFrame > #lavaLampFrames then
            currentFrame = 1
        end
    end
end

function mousePressPause(x, y, button, istouch)
    -- No mouse interaction in pause menu bismillah
end
-- End Pause Menu Functions

-- Menu Scene Functions
function drawMenu()
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

function updateMenu(dt)
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

function mousePressMenu(x, y, button, istouch)
    -- No mouse interaction in main menu bismillah
end
-- End Menu Scene Functions

-- Room Scene Functions
function drawRoom()
    -- display daily story helper msg
    if not displayedDaily then
        displayDailyHelpMsg(day)
        love.graphics.draw(dailyBanner, (love.graphics.getWidth() /2 ) - (dailyBanner:getWidth()/2), 30, 0, 1, 1)
        love.graphics.draw(dailyText, (love.graphics.getWidth() /2 ) - (dailyText:getWidth()/2) , (dailyBanner:getHeight()/2) - 35, 0, 1, 1)
        love.graphics.draw(dailyX.image, dailyX.x, dailyX.y, 0, dailyX.scaleX, dailyX.scaleY)
    end

    -- remove muffin from item table on day 2 and add note!
    if (day == 2) and (not muffinRemoved) then
        muffinRemoved = true
        table.remove(items, 3)
        table.insert(items, 3, {
            image = {note, noteHovered},
            width = note:getWidth(),
            height = note:getHeight(),
            x = (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) +330,
            y = love.graphics.getHeight() - (bg:getHeight()) + 410,
            rot = 0,
            scaleX = 1.25,
            scaleY = 1.25,
            isHovered = false
        })
    end

    -- background drawing
    love.graphics.draw(bg, (love.graphics.getWidth() / 2) - (bg:getWidth()/ 2) - 300, love.graphics.getHeight() - (bg:getHeight()) - 310, 0 , 1.75, 1.75) 
    -- draw all clickable items in room
    for _, sprite in ipairs(items) do
        if sprite.isHovered then
            love.graphics.draw(sprite.image[2], sprite.x, sprite.y, sprite.rot, sprite.scaleX, sprite.scaleY)  --drawing highlighted version if hovered
        else
            love.graphics.draw(sprite.image[1], sprite.x, sprite.y, sprite.rot, sprite.scaleX, sprite.scaleY) 
        end
    end

    --code-manual drawing
    if manual.isOpen then
        love.graphics.draw(manual.sprites.open.image, manual.position.x, manual.position.y, 0 , manual.sprites.open.scaleX, manual.sprites.open.scaleY)

        drawManualText(manual.currentPage)
        love.graphics.draw(manualText, manual.position.x + 131,manual.position.y+113 )
        love.graphics.draw(manualPageText, manual.position.x + 400,manual.position.y+180)

        love.graphics.draw(manual.sprites.xButton.image, manual.sprites.xButton.position.x, manual.sprites.xButton.position.y, 0 ,manual.sprites.xButton.scaleX, manual.sprites.xButton.scaleY)
        love.graphics.draw(manual.sprites.leftButton.image, manual.sprites.leftButton.position.x, manual.sprites.leftButton.position.y, 0 ,manual.sprites.leftButton.scaleX, manual.sprites.leftButton.scaleY)
        love.graphics.draw(manual.sprites.rightButton.image, manual.sprites.rightButton.position.x, manual.sprites.rightButton.position.y, 0 , manual.sprites.leftButton.scaleX, manual.sprites.leftButton.scaleY)
    end

    -- Time and day system drawing
    drawTime() -- creates drawable text
    love.graphics.draw(clock, (love.graphics.getWidth()) - 137, 0, 0 , 0.38, 0.38)
    love.graphics.draw(timeText, love.graphics.getWidth() -113, 30, 0, 1, 1)
    love.graphics.draw(clock, 20, 0, 0 , 0.38, 0.38)
    love.graphics.draw(dayText,  49, 30, 0, 1, 1)

    --infobox drawing
    if infoBoxVisible then
        love.graphics.draw(infoBox, (love.graphics.getWidth() / 2) - (infoBox:getWidth()/ 2), love.graphics.getHeight() - (infoBox:getHeight()) - 20, 0 , 1, 1)
        love.graphics.draw(infoBoxText,(love.graphics.getWidth() / 2) - (infoBox:getWidth()*0.5 / 2),  love.graphics.getHeight() - (infoBox:getHeight()*0.5)-55 )
    end

    -- fade drawing
    if fading then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
    end
end

function updateRoom(dt)
    -- day cycle logic with fading logic
    if gameHours < 24 then
        gameTime = gameTime + dt * (3600 / realSecondsPerInGameHour)

        gameHours = math.floor(gameTime / 3600)
        gameMinutes = math.floor((gameTime % 3600) / 60)

        local color = getInterpolatedColor(gameHours, gameMinutes)
        love.graphics.setBackgroundColor(color)
    else
        fading = true
        fadeTime = fadeTime + dt
        if fadeTime < fadeDuration then
            fadeAlpha = fadeTime / fadeDuration
        else 
            fading = false
            fadeAlpha = 0
            fadeTime = 0
            resetDay()
        end
    end

    -- update info box logic to make sure it disappears after some time - cba to read into lua coroutines so this is how i do it - sue me
    updateInfoBox(dt)

    -- check for hover over interactable sprites
    local mouseX, mouseY = love.mouse.getPosition()
    for _, sprite in ipairs(items) do
        sprite.isHovered = 
        mouseX >= sprite.x 
        and mouseX <= sprite.x + sprite.width * sprite.scaleX
        and mouseY >= sprite.y 
        and mouseY <= sprite.y + sprite.height * sprite.scaleY
    end
end

function mousePressRoom(x, y, button, istouch)
    if button == 1 then -- is left MB

        -- Check if Computer was clicked
        if not somethingOpen then
            if x >= items[1].x and x <= items[1].x + (items[1].width*items[1].scaleX) and y >= items[1].y and y <= items[1].y + (items[1].height*items[1].scaleY) then
                print("Computer Clicked") -- debug
                infoBoxVisible = false
                somethingOpen = true
            end
        end

        --Check if Manual was clicked
        if not somethingOpen then
            if x >= items[2].x and x <= items[2].x + (items[2].width *items[2].scaleX)  and y >= items[2].y and y <= items[2].y + (items[2].height* items[2].scaleY) then
                print("Manual Clicked") -- debug
                if not manual.isOpen then
                    infoBoxVisible = false
                    somethingOpen = true
                    manual.isOpen = true
                    drawInfo("Your trusty Computer Manual. All the commands you know are in here!")
                end
            end
        end

        if manual.isOpen then
            -- Check if Manual X was clicked
            if x >= manual.sprites.xButton.position.x 
            and x <= manual.sprites.xButton.position.x + (manual.sprites.xButton.image:getWidth() *manual.sprites.xButton.scaleX)  
            and y >= manual.sprites.xButton.position.y 
            and y <= manual.sprites.xButton.position.y + (manual.sprites.xButton.image:getHeight() *manual.sprites.xButton.scaleY) then
                somethingOpen = false
                manual.isOpen = false
            end
            -- Check if Manual left was clicked
            if x >= manual.sprites.leftButton.position.x 
            and x <= manual.sprites.leftButton.position.x + (manual.sprites.leftButton.image:getWidth() *manual.sprites.leftButton.scaleX)  
            and y >= manual.sprites.leftButton.position.y 
            and y <= manual.sprites.leftButton.position.y + (manual.sprites.leftButton.image:getHeight() *manual.sprites.leftButton.scaleY) then
                if manual.currentPage > 1 then
                    manual.currentPage = manual.currentPage - 1
                end
            end
            -- Check if Manual right was clicked
            if x >= manual.sprites.rightButton.position.x 
            and x <= manual.sprites.rightButton.position.x + (manual.sprites.rightButton.image:getWidth() * manual.sprites.rightButton.scaleX)  
            and y >= manual.sprites.rightButton.position.y 
            and y <= manual.sprites.rightButton.position.y + (manual.sprites.rightButton.image:getHeight() *manual.sprites.rightButton.scaleY) then
                if manual.currentPage < manual.pageCount then
                    manual.currentPage = manual.currentPage + 1
                end
            end
        end


        -- check for clicking close on the daily text
        if not displayedDaily then
            if x >= dailyX.x 
            and x <= dailyX.x + (dailyX.image:getWidth() * dailyX.scaleX) 
            and y >= dailyX.y 
            and y <= dailyX.y + (dailyX.image:getHeight() * dailyX.scaleY) then
                displayedDaily = true
            end
        end

        -- check for any interactable that only displays infobox
        if not somethingOpen then
            if not infoBoxVisible then
                -- was cat clicked?
                if x >= items[3].x and x <= items[3].x + (items[3].width *items[3].scaleX)  and y >= items[3].y and y <= items[3].y + (items[3].height* items[3].scaleY) then
                    if day == 1 then
                        print("Cat clicked") -- debug
                        drawInfo("This is Muffin! You've been with him ever since you can remember.")
                    else -- after this the note is here instead!
                        print("Note clicked") -- debug
                        drawInfo("'YOUR FELINE HAS BEEN TAKEN AS PER A NEW RULE \n\n - THE AI'")
                    end 
                end
                -- was nintendo switch clicked?
                if x >= items[4].x and x <= items[4].x + (items[4].width *items[4].scaleX)  and y >= items[4].y and y <= items[4].y + (items[4].height* items[4].scaleY) then
                    print("Switch Clicked") -- debug
                    drawInfo("Your Nintedo Switch. You love playing 'Super Mario Brothers - The Movie - The Game' on this!")
                end

            end
        end


    end
end

--create text for clock with time of day and day info
function drawTime()
    local period = (gameHours >= 12) and "PM" or "AM"
    timeText = love.graphics.newText(love.graphics.getFont(), {{0, 0, 0}, string.format("%02d:%02d %s", gameHours, gameMinutes, period)})
    dayText = love.graphics.newText(love.graphics.getFont(), {{0, 0, 0}, string.format("Day: %02d", day)})
end

-- draw little info box about a clickable item! disappears after 3 secs
function drawInfo(text)
    infoBoxVisible = true
    infoBoxTimer = 0
    infoBoxText = love.graphics.newText(love.graphics.getFont(), {{0, 0, 0}, string.format("%s", text)})
    infoBoxText:setf({{0, 0, 0}, string.format("%s", text)}, 160, "left")

end

--create text for manual book
function drawManualText(page)
    manualText = love.graphics.newText(love.graphics.getFont(), {{0, 0, 0}, string.format("%s", manual.pages[page])})
    manualText:setf({{0, 0, 0}, string.format("%s", manual.pages[page])}, 120, "left")
    manualPageText = love.graphics.newText(love.graphics.getFont(), {{0, 0, 0}, string.format("%02d / %02d", page, manual.pageCount)})
end

-- essentially a coroutine to make info box disappear after some time (its called in update())
function updateInfoBox(dt)
    if infoBoxVisible then
        infoBoxTimer = infoBoxTimer + dt
        if infoBoxTimer > 4 then
            infoBoxVisible = false
            infoBoxTimer = 0
        end
    end
end

-- mini lerp helper
function lerp(a, b, t)
    return a + (b - a) * t
end

-- background gradient
function getInterpolatedColor(hour, minute)
    local time = hour + minute / 60 -- Current time as a float

    if time >= 8 and time <= 18 then
        -- Phase 1: Day to Evening (8:00 AM to 6:00 PM)
        local t = (time - 8) / 10
        return {
            lerp(colors.day[1], colors.evening[1], t),
            lerp(colors.day[2], colors.evening[2], t),
            lerp(colors.day[3], colors.evening[3], t)
        }
    elseif time > 18 and time <= 23.9833 then
        -- Phase 2: Evening to Night (6:00 PM to 11:59 PM)
        local t = (time - 18) / 6
        return {
            lerp(colors.evening[1], colors.night[1], t),
            lerp(colors.evening[2], colors.night[2], t),
            lerp(colors.evening[3], colors.night[3], t)
        }
    else
        --default to night color
        return colors.night
    end
end

-- End room functions 



-- Other general Functions 

function resetDay()
     -- start next day!
     if manual.isOpen then
        manual.isOpen = false
    end
    if infoBoxVisible then
        infoBoxVisible = false
    end
    if somethingOpen then
        somethingOpen = false
    end
    -- TODO: add terminal close check

    -- reset values
    gameTime = 8 * 3600
    gameHours = 8
    gameMinutes = 0

    day = day + 1
    displayedDaily = false
    love.graphics.setColor(1, 1, 1)
end

-- game closing / playing
function love.keypressed(key)
    if key == 'escape' then
        if currentGamestate == "roomscene" then
            currentGamestate = "paused"
        else
            love.event.quit() -- only instant quit from main menu or pause menu
        end
    elseif key == 'space' and (currentGamestate == "menu" or currentGamestate == "paused") then
        currentGamestate = "roomscene"
    end
end

function displayDailyHelpMsg(day)
    if day == 1 then
        drawInfoBig("This is your Room Kelly! You spend all your days here, going through your old stuff and hanging out (mostly spending time on your computer though...)")
    elseif day == 2 then
        drawInfoBig("Ah, new day new - Wait, somethings is off. Muffin??")
    else
        drawInfoBig("Time to bring out the big guns now Kelly. You need to take the AI down TODAY!")
    end
end

-- draw big info about something! disappears after confirmation through click!
function drawInfoBig(text)
    local bigFont = love.graphics.newFont(16)
    dailyText = love.graphics.newText(bigFont, {{0, 0, 0}, string.format("%s", text)})
    dailyText:setf({{0, 0, 0}, string.format("%s", text)}, 300, "center")
end
-- End General Functions