Filesystem = {
    root = {
        home = {
            user = {
                type = "dir",
                files = {
                    ["file1.txt"] = {
                        type = "file",
                        content = "This is file1 content."
                    },
                    ["file2.txt"] = {
                        type = "file",
                        content = "Another file content."
                    }
                }
            }
        }
    }
}

function isDirectory(entry)
    return type(entry) == "table" and entry.type == "dir"
end

function isFile(entry)
    return type(entry) == "table" and entry.type == "file"
end
