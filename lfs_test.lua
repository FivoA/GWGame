package.cpath = package.cpath .. ";./lib/lua/5.4/lfs.dll"

local lfs = require("lfs")

print(lfs.currentdir())
