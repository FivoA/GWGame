package.cpath = package.cpath .. "; ./lib/lua/5.1/lfs.dll"
print("Set cpath")

local lfs = require("lfs")

print(lfs.currentdir())