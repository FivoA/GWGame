local roomScene = {}
local screenWidth, screenHeight = love.window.getDesktopDimensions()
local sX, sY, scale, bgX, bgY -- Declare these globally to calculate later in love.load()

-- Function to calculate item positions relative to background
local function calculateRelativePosition(bgX, bgY, bgWidth, bgHeight, relX, relY)
    local absoluteX = bgX + (bgWidth * relX)
    local absoluteY = bgY + (bgHeight * relY)
    return absoluteX, absoluteY
end

-- Room Scene Functions
function roomScene.drawRoom()
    -- Calculate scale and positions after loading bg
    sX = screenWidth / bg:getWidth()
    sY = screenHeight / bg:getHeight()
    scale = math.min(sX, sY)
        
    bgX = (screenWidth - (bg:getWidth() * scale)) / 2
    bgY = (screenHeight - (bg:getHeight() * scale)) / 2
    
    love.graphics.setColor(1, 1, 1)
    -- set font accordingly
    love.graphics.setFont(love.graphics.newFont(roomFontSize))

    -- display daily story helper msg
    if not displayedDaily then
        local xN, yN = calculateRelativePosition(bgX, bgY, bg:getWidth() * scale, bg:getHeight() * scale, 0.4, 0.07)
        displayDailyHelpMsg(day)
        love.graphics.draw(dailyBanner, xN, yN, 0, 0.75 * scale, 0.75 * scale)
        love.graphics.draw(dailyText,  xN + (25 * scale),
        yN + (20 * scale), 0, 0.75 * scale, 0.75 *scale)
        dailyX.x = xN + (280 * scale)
        dailyX.y = yN 
        love.graphics.draw(dailyX.image, dailyX.x,dailyX.y, 0, dailyX.scaleX, dailyX.scaleY)
    end

    -- remove muffin from item table on day 2 and add note!
    if (day == 2) and (not muffinRemoved) then
        local xN, yN = calculateRelativePosition(bgX, bgY, bg:getWidth() * scale, bg:getHeight() * scale, 0.45, 0.53)
        muffinRemoved = true
        table.remove(items, 3)
        table.insert(items, 3, {
            image = { note, noteHovered },
            width = note:getWidth(),
            height = note:getHeight(),
            x = xN,
            y = yN,
            rot = 0,
            scaleX = 1,
            scaleY = 1,
            isHovered = false
        })
    end

    love.graphics.draw(bg, (screenWidth - (bg:getWidth() * scale)) / 2,
    (screenHeight - (bg:getHeight() * scale)) / 2, 0, scale,  scale)
    -- draw all clickable items in room
    for _, sprite in ipairs(items) do
        if sprite.isHovered then
            love.graphics.draw(sprite.image[2], sprite.x, sprite.y, sprite.rot, sprite.scaleX, sprite.scaleY) --drawing highlighted version if hovered
        else
            love.graphics.draw(sprite.image[1], sprite.x, sprite.y, sprite.rot, sprite.scaleX, sprite.scaleY)
        end
    end

    --code-manual drawing
    if manual.isOpen then
        love.graphics.draw(manual.sprites.open.image, manual.position.x, manual.position.y, 0, manual.sprites.open
            .scaleX, manual.sprites.open.scaleY)

        roomScene.drawManualText(manual.currentPage)
        love.graphics.draw(manualText, manual.position.x + (131 * scale), manual.position.y + (113* scale), 0, scale, scale)
        love.graphics.draw(manualPageText, manual.position.x + (400*scale), manual.position.y + (180*scale), 0, scale, scale)

        love.graphics.draw(manual.sprites.xButton.image, manual.sprites.xButton.position.x,
            manual.sprites.xButton.position.y, 0, manual.sprites.xButton.scaleX, manual.sprites.xButton.scaleY)
        love.graphics.draw(manual.sprites.leftButton.image, manual.sprites.leftButton.position.x,
            manual.sprites.leftButton.position.y, 0, manual.sprites.leftButton.scaleX, manual.sprites.leftButton.scaleY)
        love.graphics.draw(manual.sprites.rightButton.image, manual.sprites.rightButton.position.x,
            manual.sprites.rightButton.position.y, 0, manual.sprites.leftButton.scaleX, manual.sprites.leftButton.scaleY)
    end

    --  day system drawing
    roomScene.drawTime() -- creates drawable text
    local clockWidth = clock:getWidth() * 0.38 * scale
    local clockHeight = clock:getHeight() * 0.38 * scale

    local clockX = love.graphics.getWidth() * 0.01
    local clockY = love.graphics.getHeight() * 0.02

    love.graphics.draw(clock, clockX, clockY, 0, 0.38 * scale, 0.38 *scale )
    local dayTextX = clockX + (33 * scale)
    local dayTextY = clockY + (30 * scale)

    love.graphics.draw(dayText, dayTextX, dayTextY, 0, scale , scale )

    --think bubble drawing
    love.graphics.draw(bubble.image, bubble.x, bubble.y, 0, bubble.scale, bubble.scale)


    --infobox drawing
    if infoBoxVisible then
        local infoBoxWidth = infoBox:getWidth() * 1.2 * scale
        local infoBoxHeight = infoBox:getHeight() * 1.2 * scale
        local infoBoxX = (love.graphics.getWidth() / 2) - (infoBoxWidth / 2)
        local infoBoxY = love.graphics.getHeight() - (infoBoxHeight)
    
        love.graphics.draw(infoBox, infoBoxX, infoBoxY, 0, 1.2 *scale, 1.2 * scale)
        local textX = infoBoxX + (90 * scale)
        local textY = infoBoxY + (70 * scale)
    
        love.graphics.draw(infoBoxText, textX,textY, 0, 1.2 * scale, 1.2* scale)

    end

    -- fade drawing
    if fading then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
    end
end

function roomScene.updateRoom(dt)
    -- day cycle logic with fading logic
    if gameHours < 24 then
        gameTime = gameTime + dt * (3600 / realSecondsPerInGameHour)

        gameHours = math.floor(gameTime / 3600)
        gameMinutes = math.floor((gameTime % 3600) / 60)

        local color = roomScene.getInterpolatedColor(gameHours, gameMinutes)
        love.graphics.setBackgroundColor(color)
    else
        if switchDay then -- set switchDay variable when we want to switch events after 24 hours!
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
    end

    -- update info box logic to make sure it disappears after some time - cba to read into lua coroutines so this is how i do it - sue me
    roomScene.updateInfoBox(dt)

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

function roomScene.mousePressRoom(x, y, button, istouch)
    if button == 1 then -- is left MB
        -- Check if Computer was clicked
        if not somethingOpen then
            if x >= items[1].x and x <= items[1].x + (items[1].width * items[1].scaleX) and y >= items[1].y and y <= items[1].y + (items[1].height * items[1].scaleY) then
                print("Computer Clicked") -- debug
                infoBoxVisible = false
                currentScene = "terminal"
            end
        end

        --Check if Manual was clicked
        if not somethingOpen then
            if x >= items[2].x and x <= items[2].x + (items[2].width * items[2].scaleX) and y >= items[2].y and y <= items[2].y + (items[2].height * items[2].scaleY) then
                print("Manual Clicked") -- debug
                if not manual.isOpen then
                    infoBoxVisible = false
                    somethingOpen = true
                    manual.isOpen = true
                    roomScene.drawInfo("Your trusty Computer Manual. All the commands you know are in here!")
                end
            end
        end

        if manual.isOpen then
            -- Check if Manual X was clicked
            if x >= manual.sprites.xButton.position.x
                and x <= manual.sprites.xButton.position.x + (manual.sprites.xButton.image:getWidth() * manual.sprites.xButton.scaleX)
                and y >= manual.sprites.xButton.position.y
                and y <= manual.sprites.xButton.position.y + (manual.sprites.xButton.image:getHeight() * manual.sprites.xButton.scaleY) then
                somethingOpen = false
                manual.isOpen = false
            end
            -- Check if Manual left was clicked
            if x >= manual.sprites.leftButton.position.x
                and x <= manual.sprites.leftButton.position.x + (manual.sprites.leftButton.image:getWidth() * manual.sprites.leftButton.scaleX)
                and y >= manual.sprites.leftButton.position.y
                and y <= manual.sprites.leftButton.position.y + (manual.sprites.leftButton.image:getHeight() * manual.sprites.leftButton.scaleY) then
                if manual.currentPage > 1 then
                    manual.currentPage = manual.currentPage - 1
                end
            end
            -- Check if Manual right was clicked
            if x >= manual.sprites.rightButton.position.x
                and x <= manual.sprites.rightButton.position.x + (manual.sprites.rightButton.image:getWidth() * manual.sprites.rightButton.scaleX)
                and y >= manual.sprites.rightButton.position.y
                and y <= manual.sprites.rightButton.position.y + (manual.sprites.rightButton.image:getHeight() * manual.sprites.rightButton.scaleY) then
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
                if x >= items[3].x and x <= items[3].x + (items[3].width * items[3].scaleX) and y >= items[3].y and y <= items[3].y + (items[3].height * items[3].scaleY) then
                    if day == 1 then
                        print("Cat clicked")  -- debug
                        roomScene.drawInfo("This is Muffin! You've been with him ever since you can remember.")
                    else                      -- after this the note is here instead!
                        print("Note clicked") -- debug
                        roomScene.drawInfo("'YOUR FELINE HAS BEEN TAKEN AS PER A NEW RULE \n\n - THE AI'")
                    end
                end
                -- was nintendo switch clicked?
                if x >= items[4].x and x <= items[4].x + (items[4].width * items[4].scaleX) and y >= items[4].y and y <= items[4].y + (items[4].height * items[4].scaleY) then
                    print("Switch Clicked") -- debug
                    roomScene.drawInfo(
                        "Your Nintedo Switch. You love playing 'Super Mario Brothers - The Movie - The Game' on this!")
                end
                -- was bubble clicked?
                if x >= bubble.x and x <= bubble.x + (bubble.image:getWidth() * bubble.scale) and y>= bubble.y and y<= bubble.y + (bubble.image:getHeight() * bubble.scale) then
                    if day == 1 then
                        roomScene.drawInfo("'Ugh, another day in this claustrophopic world. The system seems buggy though, better report that to stay out of any trouble.'")
                    else
                        roomScene.drawInfo("'Ugh, another - wait... Muffin?? WHERE ARE YOU!?!?!'")
                    end
                end
            end
        end
    end
end

--create text for clock with time of day and day info
function roomScene.drawTime()
    local period = (gameHours >= 12) and "PM" or "AM"
    timeText = love.graphics.newText(love.graphics.getFont(),
        { { 0, 0, 0 }, string.format("%02d:%02d %s", gameHours, gameMinutes, period) })
    dayText = love.graphics.newText(love.graphics.getFont(), { { 0, 0, 0 }, string.format("Day: %02d", day) })
end

-- draw little info box about a clickable item! disappears after 3 secs
function roomScene.drawInfo(text)
    infoBoxVisible = true
    infoBoxTimer = 0
    infoBoxText = love.graphics.newText(love.graphics.getFont(), { { 0, 0, 0 }, string.format("%s", text) })
    infoBoxText:setf({ { 0, 0, 0 }, string.format("%s", text) }, 150, "left")
end

--create text for manual book
function roomScene.drawManualText(page)
    manualText = love.graphics.newText(love.graphics.getFont(), { { 0, 0, 0 }, string.format("%s", manual.pages[page]) })
    manualText:setf({ { 0, 0, 0 }, string.format("%s", manual.pages[page]) }, 120, "left")
    manualPageText = love.graphics.newText(love.graphics.getFont(),
        { { 0, 0, 0 }, string.format("%02d / %02d", page, manual.pageCount) })
end

-- essentially a coroutine to make info box disappear after some time (its called in update())
function roomScene.updateInfoBox(dt)
    if infoBoxVisible then
        infoBoxTimer = infoBoxTimer + dt
        if infoBoxTimer > 6 then
            infoBoxVisible = false
            infoBoxTimer = 0
        end
    end
end

-- mini lerp helper
function roomScene.lerp(a, b, t)
    return a + (b - a) * t
end

-- background gradient
function roomScene.getInterpolatedColor(hour, minute)
    local time = hour + minute / 60 -- Current time as a float

    if time >= 8 and time <= 18 then
        -- Phase 1: Day to Evening (8:00 AM to 6:00 PM)
        local t = (time - 8) / 10
        return {
            roomScene.lerp(colors.day[1], colors.evening[1], t),
            roomScene.lerp(colors.day[2], colors.evening[2], t),
            roomScene.lerp(colors.day[3], colors.evening[3], t)
        }
    elseif time > 18 and time <= 23.9833 then
        -- Phase 2: Evening to Night (6:00 PM to 11:59 PM)
        local t = (time - 18) / 6
        return {
            roomScene.lerp(colors.evening[1], colors.night[1], t),
            roomScene.lerp(colors.evening[2], colors.night[2], t),
            roomScene.lerp(colors.evening[3], colors.night[3], t)
        }
    else
        --default to night color
        return colors.night
    end
end

-- End room functions


return roomScene
