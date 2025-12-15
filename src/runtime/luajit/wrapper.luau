-- luajit bindings
-- similar to lua but has some tweaks
-- can run libraries (no shit)

local dll = "./src/runtime/luajit/bin/"
local ffi = zune.ffi
local platform = zune.platform

local libname
if platform.os == "windows" then
	libname = "luajit.dll"
elseif platform.os == "linux" then
	libname = "luajit.so"
elseif platform.os == "macos" then
	libname = "luajit.dylib"
end

local funcs = {
	luaL_newstate = {
		returns = ffi.types.pointer,
		args = {},
	},
	lua_close = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	luaL_openlibs = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},

	luaL_loadstring = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	luaL_loadbufferx = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	lua_pcall = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32, ffi.types.i32 },
	},

	lua_gettop = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	lua_settop = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_type = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_typename = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_pushvalue = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	lua_pushnil = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	lua_pushnumber = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.double },
	},
	lua_pushinteger = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i64 },
	},
	lua_pushlstring = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	lua_pushstring = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	lua_pushboolean = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_pushlightuserdata = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	lua_pushcclosure = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},

	lua_tonumberx = {
		returns = ffi.types.double,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	lua_tointegerx = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	lua_tolstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	lua_toboolean = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_tocfunction = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_touserdata = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_topointer = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	lua_isnumber = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_isstring = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_iscfunction = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_isuserdata = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	lua_gettable = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_settable = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_getfield = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	lua_setfield = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	lua_rawgeti = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	lua_rawseti = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	lua_createtable = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	lua_getmetatable = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_setmetatable = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	lua_rawget = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_rawset = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_objlen = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_rawequal = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},

	lua_next = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	lua_concat = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	luaL_checktype = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	luaL_checklstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	luaL_checknumber = {
		returns = ffi.types.double,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	luaL_checkinteger = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	luaL_optlstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},
	luaL_optnumber = {
		returns = ffi.types.double,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.double },
	},
	luaL_optinteger = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i64 },
	},
	luaL_error = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	luaL_ref = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	luaL_unref = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	luaL_loadfilex = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
}

local lua_lib = ffi.dlopen(dll .. libname, funcs)

local LUA_TNIL = 0
local LUA_TBOOLEAN = 1
local LUA_TLIGHTUSERDATA = 2
local LUA_TNUMBER = 3
local LUA_TSTRING = 4
local LUA_TTABLE = 5
local LUA_TFUNCTION = 6
local LUA_TUSERDATA = 7
local LUA_TTHREAD = 8

local LUA_OK = 0
local LUA_YIELD = 1
local LUA_ERRRUN = 2
local LUA_ERRSYNTAX = 3
local LUA_ERRMEM = 4
local LUA_ERRERR = 5

local LuaVM = {}
LuaVM.__index = LuaVM

local LUA_GLOBALSINDEX = -10002
local LUA_ENVIRONINDEX = -10001
local LUA_REGISTRYINDEX = -10000

-- Helper functions for macros (not real exported functions)
local function lua_getglobal(L, name_ptr)
	lua_lib.lua_getfield(L, LUA_GLOBALSINDEX, name_ptr)
end

local function lua_setglobal(L, name_ptr)
	lua_lib.lua_setfield(L, LUA_GLOBALSINDEX, name_ptr)
end

function LuaVM.new()
	local self = setmetatable({}, LuaVM)
	self.L = lua_lib.luaL_newstate()

	if self.L == nil then
		error("Failed to create Lua state")
	end

	lua_lib.luaL_openlibs(self.L)

	return self
end

function LuaVM:_absindex(index: number): number
	if index > 0 or index <= LUA_REGISTRYINDEX then
		return index
	else
		return lua_lib.lua_gettop(self.L) + index + 1
	end
end

function LuaVM:execute(code: string): (boolean, any, string?)
	code = string.gsub(code, "%z+$", "")

	self._temp_buffer = buffer.fromstring(code)

	local load_result = lua_lib.luaL_loadbufferx(self.L, self._temp_buffer, #code, buffer.fromstring("=(execute)"), nil)

	local success = load_result == LUA_OK

	if not success then
		local err_msg = self:_popString()
		self._temp_buffer = nil
		return false, nil, err_msg or "Failed to load Lua code"
	end

	local exec_result = lua_lib.lua_pcall(self.L, 0, 1, 0)

	if exec_result ~= LUA_OK then
		local err_msg = self:_popString()
		self._temp_buffer = nil
		return false, nil, err_msg or "Runtime error in Lua code"
	end

	local ret = self:_getValue(-1)
	lua_lib.lua_settop(self.L, -2)
	self._temp_buffer = nil

	return true, ret, nil
end

function LuaVM:executeFile(filename: string): (boolean, string?)
	local filename_ptr = buffer.fromstring(filename)

	local load_result = lua_lib.luaL_loadfilex(self.L, filename_ptr, nil)

	if load_result ~= LUA_OK then
		local err_msg = self:_popString()
		return false, err_msg or "Failed to load Lua file"
	end

	local exec_result = lua_lib.lua_pcall(self.L, 0, 0, 0)

	if exec_result ~= LUA_OK then
		local err_msg = self:_popString()
		return false, err_msg or "Runtime error in Lua file"
	end

	return true, nil
end

function LuaVM:executeWithResult(code)
	local ok, err = self:execute(code)
	if not ok then
		return false, err
	end

	local result = self:_getValue(-1)
	lua_lib.lua_settop(self.L, -2) -- pop
	return true, result
end

function LuaVM:call(funcName: string, ...): (boolean, any)
	local args = { ... }

	local fname_ptr = buffer.fromstring(funcName)
	lua_getglobal(self.L, fname_ptr)

	local func_type = lua_lib.lua_type(self.L, -1)

	if func_type ~= LUA_TFUNCTION then
		lua_lib.lua_settop(self.L, -2)
		return false, nil
	end

	for _, arg in ipairs(args) do
		self:_pushValue(arg)
	end

	local result = lua_lib.lua_pcall(self.L, #args, 1, 0)

	if result ~= LUA_OK then
		local err_msg = self:_popString()
		error(err_msg or "Error calling Lua function")
	end

	local ret = self:_getValue(-1)
	lua_lib.lua_settop(self.L, -2)

	return true, ret
end

function LuaVM:setGlobal(name: string, value: any)
	self:_pushValue(value)
	local name_ptr = buffer.fromstring(name)
	lua_setglobal(self.L, name_ptr)
end

function LuaVM:getGlobal(name: string): any
	local name_ptr = buffer.fromstring(name)
	lua_getglobal(self.L, name_ptr)
	local value = self:_getValue(-1)
	lua_lib.lua_settop(self.L, -2)
	return value
end

function LuaVM:stackSize(): number
	return lua_lib.lua_gettop(self.L)
end

function LuaVM:clearStack()
	lua_lib.lua_settop(self.L, 0)
end

function LuaVM:_pushValue(value: any)
	local t = type(value)

	if t == "nil" then
		lua_lib.lua_pushnil(self.L)
	elseif t == "boolean" then
		lua_lib.lua_pushboolean(self.L, value and 1 or 0)
	elseif t == "number" then
		-- Check if it's an integer
		if math.floor(value) == value and value >= -2 ^ 53 and value <= 2 ^ 53 then
			lua_lib.lua_pushinteger(self.L, value)
		else
			lua_lib.lua_pushnumber(self.L, value)
		end
	elseif t == "string" then
		local str_ptr = buffer.fromstring(value)
		lua_lib.lua_pushlstring(self.L, str_ptr, #value)
	elseif t == "table" then
		lua_lib.lua_createtable(self.L, 0, 0)
		for k, v in pairs(value) do
			self:_pushValue(k)
			self:_pushValue(v)
			lua_lib.lua_settable(self.L, -3)
		end
	else
		error(`Unsupported type for Lua: {t}`)
	end
end

function LuaVM:_getValue(index: number): any
	local lua_type = lua_lib.lua_type(self.L, index)

	if lua_type == LUA_TNIL then
		return nil
	elseif lua_type == LUA_TBOOLEAN then
		return lua_lib.lua_toboolean(self.L, index) ~= 0
	elseif lua_type == LUA_TNUMBER then
		local val = lua_lib.lua_tonumberx(self.L, index, nil)
		if type(val) == "buffer" then
			return buffer.readf64(val, 0)
		end
		return val
	elseif lua_type == LUA_TSTRING then
		return self:_getString(index)
	elseif lua_type == LUA_TTABLE then
		return self:_getTable(index)
	else
		return nil
	end
end

function LuaVM:_getString(index: number): string?
	local str_ptr = lua_lib.lua_tolstring(self.L, index, nil)
	if str_ptr == nil then
		return nil
	end
	return buffer.tostring(str_ptr:span())
end

function LuaVM:_getTable(index: number): { [any]: any }
	local result = {}
	local abs_index = self:_absindex(index)

	lua_lib.lua_pushnil(self.L)

	while lua_lib.lua_next(self.L, abs_index) ~= 0 do
		local key = self:_getValue(-2)
		local value = self:_getValue(-1)

		if key ~= nil then
			result[key] = value
		end

		lua_lib.lua_settop(self.L, -2)
	end

	return result
end

function LuaVM:_popString(): string?
	local result = self:_getString(-1)
	lua_lib.lua_settop(self.L, -2)
	return result
end

function LuaVM:close()
	if self.L ~= nil then
		lua_lib.lua_close(self.L)
		self.L = nil
	end
end

return {
	LuaVM = LuaVM,

	ffi = lua_lib,

	types = {
		NIL = LUA_TNIL,
		BOOLEAN = LUA_TBOOLEAN,
		LIGHTUSERDATA = LUA_TLIGHTUSERDATA,
		NUMBER = LUA_TNUMBER,
		STRING = LUA_TSTRING,
		TABLE = LUA_TTABLE,
		FUNCTION = LUA_TFUNCTION,
		USERDATA = LUA_TUSERDATA,
		THREAD = LUA_TTHREAD,
	},

	status = {
		OK = LUA_OK,
		YIELD = LUA_YIELD,
		ERRRUN = LUA_ERRRUN,
		ERRSYNTAX = LUA_ERRSYNTAX,
		ERRMEM = LUA_ERRMEM,
		ERRERR = LUA_ERRERR,
	},
}
