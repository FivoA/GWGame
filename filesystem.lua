Filesystem = {
    root = {
        type = "dir",
        files = {},
        home = {
            type = "dir",
            files = {},
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
                },
                documents = {
                    type = "dir",
                    files = {
                        ["smbtmtg.exe"] = {
                            type = "file",
                            content = "Super Mario Bros - The Movie - The Game\nYou cracked and dumped that from your Nintendo Switch Kelly"
                        }
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
