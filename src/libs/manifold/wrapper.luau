local dll = "./src/libs/manifold/bin/"
local ffi = zune.ffi
local platform = zune.platform

local fileFormat = ".dll"

local bindings = require("./bindings")

local libname
if platform.os == "windows" then
	libname = "libmanifoldc.dll"
	fileFormat = ".dll"
elseif platform.os == "linux" then
	libname = "libmanifoldc.so"
	fileFormat = ".so"
elseif platform.os == "macos" then
	libname = "libmanifoldc.dylib"
	fileFormat = ".dylib"
end

if platform == "windows" then
	pcall(function()
		ffi.dlopen(dll .. "libmanifold" .. fileFormat, {})
	end)
end

print(dll .. libname)
local manifoldCSG: typeof(bindings.funcs) = ffi.dlopen(dll .. libname, bindings.funcs)

return {
	lib = manifoldCSG,
	structs = bindings.structs,
}
