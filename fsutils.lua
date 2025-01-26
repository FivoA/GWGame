local fsutils = {}
local lfs = love.filesystem

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

function fsutils.extractFilename(file)
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
        -- print(parentDir)
        if parentDir then
            termcwd = termcwd:sub(1, -1*#parentDir -2)
        end
    else
        local potcwd = termcwd .. "/" .. pathPart
        -- print(fsutils.isGameDirectory(potcwd))
        if fsutils.isGameDirectory(potcwd) then
            termcwd = potcwd
            return -- else do nothing lol
        else
            terminal:println("Directory not found!")
        end
    end
end

function fsutils.isGameDirectory(potentialPath)
    local files = lfs.getDirectoryItems(fsutils.toGameRelativePath(potentialPath))
        for _, file in ipairs(files) do
            -- print(">>> " .. file)
            if file == "_index_.gamefile" then return true end
        end
    return false
end

--- extracts the file content if the current permissions are met
---@param filename string
---@return string content of the file if permissions are met otherwise an error message
function fsutils.extractFileContent(file)
    if not (file .. ".gamefile"):match("([^/]+).gamefile$") then 
        return "This does not seem to be a file."
    end
    
    local fileContent = {}
    local filepath = fsutils.toGameRelativePath(termcwd .. "/" .. file .. ".gamefile")
    -- print("Constructed filepath: " .. filepath)
    -- local fileInfo = lfs.getInfo(filepath)
    -- if not fileInfo then
    --     return "File <" .. file .. "> does not exist or cannot be accessed."
    -- end
    -- print("File info: ", fileInfo)
    local success, iterOrErr = pcall(lfs.lines, filepath)
    if not success then return "File <" .. file .. "> does not exists. " .. iterOrErr end
    for line in iterOrErr do
        table.insert(fileContent, line)
    end
    -- check permissions:
    local perm = fileContent[1]
    table.remove(fileContent, 1)
    if perm == '#readable' then
        return table.concat(fileContent, "\n")
    else
        return "Permission denied!"
    end
end


return fsutils