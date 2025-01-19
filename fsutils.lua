-- filesystem utils.lua
local fsutils = {}

function fsutils.navigate(path, filesystem)
    local current = filesystem
    for _, segment in ipairs(path) do
        if current[segment] and isDirectory(current[segment]) then
            current = current[segment].files
        else
            return nil, "Path not found or not a directory."
        end
    end
    return current
end


return fsutils
