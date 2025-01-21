-- filesystem utils.lua
local fsutils = {}

---function fsutils.toTerminalPath(path)
---    local _game_dir = directories.game_dir
---
---    -- print(_game_dir .. "-> # " .. #_game_dir)
---    -- print(path)
---    local termPath = path:sub(#_game_dir + 1)
---    -- print("[fsutils] termPath: " .. termPath)
---
---    local slashIndex = termPath:find("/")
---    if slashIndex then
---        termPath = termPath:sub(slashIndex + 1)
---    end
---
---    return termPath .. "/"
---end

function fsutils.toRealPath(path)
    if connectionState == 'kelly' then
        return directories.dirKelly .. path
    elseif connectionState == 'ai' then
        return directories.dirAI .. path
    else
        return "no available path state"
    end
end

function fsutils.toGameRelativePath(path)
    if connectionState == 'kelly' then
        return "game_fs/kelly" .. path
    elseif connectionState == 'ai' then
        return "game_fs/ai" .. path
    else
        return "no available realtive path state"
    end
end

function fsutils.extract(file)
    if file == '_index_.gamefile' then return nil end
    local isGameFile = file:find("%.gamefile$")
    if isGameFile then
        return file:sub(1, -10)
    else
        return file
    end
end

function fsutils.handlePathPart(pathPart)
    if pathPart == '.' then
        -- do absoluuutely nothing
    elseif pathPart == '..' then
        if termcwd == '/' then return end
        -- terminal:println(termcwd)
        local parentDir = termcwd:match("/([^/]+)$")
        print(parentDir)
        if parentDir then
            termcwd = termcwd:sub(1, -1*#parentDir -2)
        end
    else
        local potcwd = termcwd .. "/" .. pathPart
        if fsutils.isGameDirectory(potcwd) then
            termcwd = potcwd
            return -- else do nothing lol
        else
            terminal:println("Directory not found!")
        end
    end
end

function fsutils.isGameDirectory(potentialPath)
    local files = love.filesystem.getDirectoryItems(fsutils.toGameRelativePath(potentialPath))
        for _, file in ipairs(files) do
            if file == "_index_.gamefile" then return true end
        end
    return false
end

return fsutils