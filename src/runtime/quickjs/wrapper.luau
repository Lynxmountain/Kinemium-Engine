-- quickjs.lua
-- Accurate QuickJS FFI wrapper for Windows x64 (NaN-boxing)

local ffi = zune.ffi
local platform = zune.platform

-- =========================================================
-- Library name
-- =========================================================

local libname
if platform.os == "windows" then
	libname = "libquickjs.dll"
elseif platform.os == "linux" then
	libname = "libquickjs.so"
elseif platform.os == "macos" then
	libname = "libquickjs.dylib"
end

local funcs = {
	JS_NewRuntime = {
		returns = ffi.types.pointer,
		args = {},
	},

	JS_FreeRuntime = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},

	JS_NewContext = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	JS_FreeContext = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},

	JS_Eval = {
		returns = ffi.types.u64,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.pointer,
			ffi.types.i32,
		},
	},

	JS_GetException = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer },
	},

	JS_ToCStringLen2 = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer, -- size_t*
			ffi.types.u64,
			ffi.types.i32,
		},
	},

	JS_FreeCString = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	JS_GetGlobalObject = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer },
	},

	JS_NewObject = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer },
	},

	JS_NewStringLen = {
		returns = ffi.types.u64,
		args = {
			ffi.types.pointer, -- JSContext*
			ffi.types.pointer, -- const char*
			ffi.types.u64, -- size_t len
		},
	},

	JS_SetPropertyStr = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.pointer,
			ffi.types.u64,
		},
	},

	JS_NewCFunction2 = {
		returns = ffi.types.u64,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
			ffi.types.i32,
		},
	},

	__JS_FreeValue = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u64 },
	},
}

local function JS_IsException(val)
	return bit32.rshift(val, 48) == 0x7FF8
end

local js = ffi.dlopen("./src/runtime/quickjs/bin/" .. libname, funcs)

local JS_EVAL_TYPE_GLOBAL = 0

local JSVM = {}
JSVM.__index = JSVM

function JSVM.new()
	local self = setmetatable({}, JSVM)

	self.rt = js.JS_NewRuntime()
	if self.rt == nil then
		error("Failed to create QuickJS runtime")
	end

	self.ctx = js.JS_NewContext(self.rt)
	if self.ctx == nil then
		js.JS_FreeRuntime(self.rt)
		error("Failed to create QuickJS context")
	end

	return self
end

function JSVM:eval(code, filename)
	code = string.gsub(code, "%z+$", "")

	local fname = filename or "eval.js"

	self._code_buf = buffer.fromstring(code)
	self._file_buf = buffer.fromstring(fname)

	local val = js.JS_Eval(self.ctx, self._code_buf, #code, self._file_buf, JS_EVAL_TYPE_GLOBAL)

	if JS_IsException(val) then
		local exc = js.JS_GetException(self.ctx)

		local len = ffi.new("size_t[1]")
		local msg_ptr = js.JS_ToCStringLen2(self.ctx, len, exc, 0)
		local msg = buffer.tostring(msg_ptr:span(len[0]))

		js.JS_FreeCString(self.ctx, msg_ptr)
		js.__JS_FreeValue(self.ctx, exc)
		js.__JS_FreeValue(self.ctx, val)

		return false, msg
	end

	local str_ptr = js.JS_ToCString(self.ctx, val)
	local result = nil

	if str_ptr ~= nil then
		result = buffer.tostring(str_ptr:span())
		js.JS_FreeCString(self.ctx, str_ptr)
	end

	js.JS_FreeValue(self.ctx, val)

	self._code_buf = nil
	self._file_buf = nil

	return true, result
end

function JSVM:setGlobal(name, value)
	print("ook setting globals")
	local global = js.JS_GetGlobalObject(self.ctx)

	print(2)

	local key_buf = buffer.fromstring(name)

	print(3)
	local val_buf = buffer.fromstring(tostring(value))
	print(4)
	local jsval = js.JS_NewStringLen(self.ctx, val_buf)
	print(5)
	js.JS_SetPropertyStr(self.ctx, global, key_buf, jsval)
	print(6)
	js.JS_FreeValue(self.ctx, global)
	print(7)
end

function JSVM:_pushJSValue(value)
	local t = type(value)

	if t == "string" then
		local buf = buffer.fromstring(value)
		return js.JS_NewStringLen(self.ctx, buf, #value)
	elseif t == "number" then
		return js.JS_Eval(
			self.ctx,
			buffer.fromstring(tostring(value)),
			#tostring(value),
			buffer.fromstring("eval_number"),
			JS_EVAL_TYPE_GLOBAL
		)
	elseif t == "boolean" then
		local s = value and "true" or "false"
		return js.JS_Eval(self.ctx, buffer.fromstring(s), #s, buffer.fromstring("eval_bool"), JS_EVAL_TYPE_GLOBAL)
	elseif t == "table" then
		local obj = js.JS_NewObject(self.ctx)
		for k, v in pairs(value) do
			local key = buffer.fromstring(tostring(k))
			local val = self:_pushJSValue(v)
			js.JS_SetPropertyStr(self.ctx, obj, key, val)
			-- free val after setting
			js.__JS_FreeValue(self.ctx, val)
		end
		return obj
	elseif t == "function" then
		-- Wrap Lua function as JS function
		local cb = ffi.closure({
			returns = ffi.types.u64,
			args = { ffi.types.pointer, ffi.types.u64, ffi.types.i32, ffi.types.pointer },
		}, function(ctx, this_val, argc, argv)
			-- simple: pass first arg as string
			local arg = ""
			if argc > 0 then
				local str_ptr = js.JS_ToCString(ctx, argv[0])
				if str_ptr ~= nil then
					arg = ffi.string(str_ptr)
					js.JS_FreeCString(ctx, str_ptr)
				end
			end
			value(arg)
			return js.JS_Eval(
				ctx,
				buffer.fromstring("undefined"),
				#"undefined",
				buffer.fromstring("luaFn"),
				JS_EVAL_TYPE_GLOBAL
			)
		end)
		return js.JS_NewCFunction2(self.ctx, cb, buffer.fromstring("luaFn"), 1, 0, 0)
	end

	-- fallback
	return js.JS_Eval(
		self.ctx,
		buffer.fromstring("undefined"),
		#"undefined",
		buffer.fromstring("undefined"),
		JS_EVAL_TYPE_GLOBAL
	)
end

function JSVM:setGlobals(tbl)
	local global = js.JS_GetGlobalObject(self.ctx)

	for k, v in pairs(tbl) do
		local key = buffer.fromstring(tostring(k))
		local val = self:_pushJSValue(v)
		js.JS_SetPropertyStr(self.ctx, global, key, val)
		js.__JS_FreeValue(self.ctx, val)
	end

	js.__JS_FreeValue(self.ctx, global)
end

function JSVM:close()
	if self.ctx ~= nil then
		js.JS_FreeContext(self.ctx)
		self.ctx = nil
	end

	if self.rt ~= nil then
		js.JS_FreeRuntime(self.rt)
		self.rt = nil
	end
end

return {
	JSVM = JSVM,
	ffi = js,
}
