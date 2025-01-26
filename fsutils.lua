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
function fsutils.extractFileContent(filename)
    if not (filename .. ".gamefile"):match("([^/]+).gamefile$") then 
        return "This does not seem to be a file."
    end
    
    local fileContent = {}
    local filepath = fsutils.toGameRelativePath(termcwd .. "/" .. filename .. ".gamefile")
    local success, iterOrErr = pcall(lfs.lines, filepath)
    if not success then
        print(iterOrErr)
        return "File <" .. filename .. "> does not exists. "
    end
    for line in iterOrErr do
        table.insert(fileContent, line)
    end
    -- check permissions:
    local perm = fileContent[1]
    table.remove(fileContent, 1)
    if perm == '#readable' then
        return table.concat(fileContent, '\n')
    elseif string.find(perm, '#hackable') then
        if hackedFiles[filename] ~= nil and hackedFiles[filename] == -1 then
            return table.concat(fileContent, '\n')
        elseif hackedFiles[filename] ~= nil and hackedFiles[filename] ~= -1 then
            local out = {}
            -- print(table.concat(fileContent, '\n'))
            for i=1, #fileContent do
                local gibberishLine = {}
                -- print("// " .. fileContent[i])
                for j=1, #fileContent[i] do
                    table.insert(gibberishLine, string.char(math.random(33, 126)))
                end
                table.insert(out, table.concat(gibberishLine))
            end
            return table.concat(out, '\n')
        else
            return "Encrytped file content detected! Use scan for more info."
        end
    else
        return "Permission denied!"
    end
end

---extracts the file permissions for the give gamefile name
---@param filename string
---@return string the file permission string from the first line of the file or the error message that occured while trying to open the file
function fsutils.extractFilePermission(filename)
    if not (filename .. ".gamefile"):match("([^/]+).gamefile$") then 
        return "This does not seem to be a file."
    end
    local fileContent = {}
    local filepath = fsutils.toGameRelativePath(termcwd .. "/" .. filename .. ".gamefile")
    local success, iterOrErr = pcall(lfs.lines, filepath)
    if not success then return "File <" .. filename .. "> does not exists. " .. iterOrErr end
    for line in iterOrErr do
        table.insert(fileContent, line)
    end
    return fileContent[1]
end

function fsutils.isGameFile(filename)
    if not (filename .. ".gamefile"):match("([^/]+).gamefile$") then 
        return false
    end
    local filepath = fsutils.toGameRelativePath(termcwd .. "/" .. filename .. ".gamefile")
    local success, iterOrErr = pcall(lfs.lines, filepath)
    if not success then return false
    else return true end
end

return fsutils