-- filesystem utils.lua
local fsutils = {}

function fsutils.navigate(path, filesystem)
    local current = filesystem
    for _, segment in ipairs(path) do
        if current[segment] and isDirectory(current[segment]) then
            current = current[segment]
        else
            return nil, "Path not found or not a directory."
        end
    end
    return current
end

function fsutils.splitPaths(path)
    local pathParts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(pathParts, part)
    end
    return pathParts
end


return fsutils
