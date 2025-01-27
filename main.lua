require("globalVariables")
local menuScene = require("menuScene")
local pauseScene = require("pauseScene")
local roomScene = require("roomScene")
local terminalScene = require("terminalScene")

local screenWidth, screenHeight = love.window.getDesktopDimensions()
local sX, sY, scale, bgX, bgY -- Declare these globally to calculate later in love.load()

-- Function to calculate item positions relative to background
local function calculateRelativePosition(bgX, bgY, bgWidth, bgHeight, relX, relY)
    local absoluteX = bgX + (bgWidth * relX)
    local absoluteY = bgY + (bgHeight * relY)
    return absoluteX, absoluteY
end

function love.load() -- done once on game start up, load all assets and resources
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

        -- Calculate scale and positions after loading bg
        sX = screenWidth / bg:getWidth()
        sY = screenHeight / bg:getHeight()
        scale = math.min(sX, sY)
    
        bgX = (screenWidth - (bg:getWidth() * scale)) / 2
        bgY = (screenHeight - (bg:getHeight() * scale)) / 2
    
    local itemsRelative = {
        {
            image = { computer, computerHovered },
            relX = 0.48,
            relY = 0.38,
            scale = 1
        },
        {
            image = { manual, manualHovered },
            relX = 0.36,
            relY = 0.4,
            scale = 1
        },
        {
            image = { muffin, muffinHovered },
            relX = 0.45,
            relY = 0.5,
            scale = 1
        },
        {
            image = { switch, switchHovered },
            relX = 0.58,
            relY = 0.475,
            scale = 1
        }
    }
    for _, item in ipairs(itemsRelative) do
        local x, y = calculateRelativePosition(bgX, bgY, bg:getWidth() * scale, bg:getHeight() * scale, item.relX, item.relY)
        table.insert(items, {
            image = {item.image[1], item.image[2]},
            width = item.image[1]:getWidth(),
            height = item.image[1]:getHeight(),
            x = x,
            y = y,
            rot = 0,
            scaleX = item.scale * scale,
            scaleY = item.scale * scale,
            isHovered = false
        })
    end

    --music
    backgroundMusic = love.audio.newSource("assets/sounds/bgmusic.wav", "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:play()
    backgroundMusic:setVolume(0.05)

    --base Rendering Settings
    love.graphics.setColor(1, 1, 1) -- sets no tint on rendered stuff
    love.graphics.setNewFont(roomFontSize)

    -- in-game objects
    -- code-manual
    local xN, yN = calculateRelativePosition(bgX, bgY, bg:getWidth() * scale, bg:getHeight() * scale, -0.2, 0.3)
    manual = {
        isOpen = false,
        position = {
            x =  xN,
            y = yN
        },
        pages = {
            "Command: Exists the terminal\n\nTo use: exit",
            "Command: Change Directory\n\nTo use: cd <availible subdirectory> or cd .. (this goes to parent directory)",
            "Command: Lists all files subdirectories\n\nTo use: ls",
            "Command: Report an Incident to AI Government to recieve support\n\nTo use: report <message>",
            "Command: Check if a support agent is availible after report and ready to talk\n\nTo use: talk"
        }, -- we can dynamically add new pages for new terminal commands here!
        currentPage = 1,
        pageCount = 5,
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
    local xN, yN = calculateRelativePosition(bgX, bgY, bg:getWidth() * scale, bg:getHeight() * scale, 0.4, 0.07)
    dailyBanner = love.graphics.newImage("assets/images/dailyBanner.png")
    dailyX = {
        image = love.graphics.newImage("assets/images/xButton.png"),
        x = xN,
        y = yN,
        scaleX = 0.06 *scale,
        scaleY = 0.06 *scale
    }



    love.graphics.setNewFont(14)
    terminalScene.load()
end

function love.draw()
    if currentScene == "room" then
        roomScene.drawRoom()
    elseif currentScene == "paused" then
        pauseScene.drawPause()
    elseif currentScene == "terminal" then
        terminalScene.draw()
    else
        menuScene.drawMenu()
    end
end

function love.update(dt)
    if currentScene == "room" then
        roomScene.updateRoom(dt)
    elseif currentScene == "paused" then
        pauseScene.updatePause(dt)
    elseif currentScene == "terminal" then
        terminalScene.update(dt)
    else
        menuScene.updateMenu(dt)
    end
end

function love.mousepressed(x, y, button, istouch)
    if currentScene == "room" then
        roomScene.mousePressRoom(x, y, button, istouch)
    elseif currentScene == "paused" then
        pauseScene.mousePressPause(x, y, button, istouch)
    else
        menuScene.mousePressMenu(x, y, button, istouch)
    end
end

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
    switchDay = false -- reset day switch, can set again like this on day 2!
end

-- game closing / playing
function love.keypressed(key)
    -- if in terminalScene then pass key handling to terminalScene
    if currentScene == "terminal" then
        terminalScene.keypressed(key)
        return
    end

    if key == 'escape' then
        if (currentScene == "room") then
            currentScene = "paused"
        else
            love.event.quit() -- only instant quit from main menu or pause menu
        end
    elseif key == 'space' and (currentScene == "menu" or currentScene == "paused") then
        currentScene = "room"
    end
end

function displayDailyHelpMsg(day)
    if day == 1 then
        drawInfoBig(
            "'Good mrrrning, citizen 3857! \nFor optimal vegetation, make mAKE sure to do your daily 50 push up---s-, water your room plants if you have any, and remember dwhakjbd!\nAs always, if anything si wrng, reprot it to us!1!'")
    elseif day == 2 then
        drawInfoBig(
            "Gr0ood mirnnngi, citienze 3857! \nFro otmpial vegetionat, mAkE srue to ddo yuor dilya 50 phus--ups, wtare yuor roOmn plantz (iff u hAvE anY), aNd rmemebre dwahkajdb!\nAs aalwys, if enytihng si wRng, repprot ti ot uss!1!!")
    else
        drawInfoBig("You're not supposed to be here tbh, dont know how you got here...")
    end
end

-- draw big info about something! disappears after confirmation through click!
function drawInfoBig(text)
    local bigFont = love.graphics.newFont(16)
    dailyText = love.graphics.newText(bigFont, { { 0, 0, 0 }, string.format("%s", text) })
    dailyText:setf({ { 0, 0, 0 }, string.format("%s", text) }, 300, "center")
end

-- End General Functions
