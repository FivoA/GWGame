items = {}  -- table with clickable items in room
manual = {} -- code manual

--  scene system table, can be:
-- "menu", "room", "paused", "terminal"
currentScene = "menu"

-- day specific variables
muffinRemoved = false
displayedDaily = false
dailyText = nil
switchDay = false
-- Time system variables
realSecondsPerInGameHour = 5
gameTime = 8 * 3600
gameHours = 8
gameMinutes = 0
timeText = nil
-- day system variables
day = 1
dayText = nil

-- clickable mutex (only one item can be opened at once type shi)
somethingOpen = false

-- info textbox system variables
infoBoxVisible = false
infoBoxTimer = 0
infoBoxText = nil

roomFontSize = 12

-- day to night gradient system variables
colors = {
    day = { 0.843, 0.910, 0.992 },     -- 8:00 AM
    evening = { 0.243, 0.310, 0.412 }, -- 6:00 PM
    night = { 0.031, 0.039, 0.086 }    -- 11:59 PM
}
-- fade effect variables
fadeDuration = 3
fadeTime = 0  -- time since fade started
fading = false
fadeAlpha = 0 -- Alpha value for fade

--manual book text variables
manualPageText = nil
manualText = nil

-- menu timer variable
menuTimer = 0
menuIndex = 1

-- sick pause menu animation variables
lavaLampFrames = {}
currentFrame = 1 -- current frame index
animationTimer = 0
frameDuration = 0.2

-- global terminal holder and variables
terminal = nil
terminalFontSize = 20
terminalFont = love.graphics.newFont(terminalFontSize)
termSepX = 50    -- terminal separator on x axis
termSepY = 50    -- temrinal separator on y axis
termSepLine = 10 --terminal separator between terminal lines
termBG = { 7 / 255, 7 / 255, 7 / 255 }
termFontCol = { 0, 1, 0 }
chatEnabled = false
chatFocussed = false

-- game directory handling
local _system_cwd = love.filesystem.getWorkingDirectory()
local _game_dir = _system_cwd .. "/game_fs"
local _dirKelly = _game_dir .. "/kelly"
local _dirAI = _game_dir .. "/ai"
directories = {
    system_cwd = _system_cwd,
    game_dir = _game_dir,
    dirKelly = _dirKelly,
    dirAI = _dirAI
}

-- print("\nGame Folder is at: " .. directories.game_dir)
-- print("-> Kellys subfolder is at: " .. directories.dirKelly)
-- print("-> AI subfolder is at: " .. directories.dirAI)

-- connectionState holds the current computer state and is used for path stripping
connectionState = 'kelly'
termcwd = "/home/user"
hackedFiles = {}
