-- duktape bindings
-- wrapper for Duktape DLL

local dll = "./src/runtime/duktape/bin/"
local ffi = zune.ffi
local platform = zune.platform

local libname
if platform.os == "windows" then
	libname = "libduktape.dll"
elseif platform.os == "linux" then
	libname = "libduktape.so"
elseif platform.os == "macos" then
	libname = "libduktape.dylib"
end

local duk_lib = ffi.dlopen(dll .. libname, {
	-- Heap management
	duk_create_heap = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	duk_destroy_heap = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},

	-- Stack operations
	duk_get_top = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	duk_set_top = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_pop = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	duk_pop_n = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_dup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_remove = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	-- Push operations
	duk_push_undefined = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	duk_push_null = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	duk_push_boolean = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_push_number = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.double },
	},
	duk_push_int = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_push_string = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	duk_push_lstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	duk_push_object = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	duk_push_array = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},

	-- Type checking
	duk_is_undefined = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_null = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_boolean = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_number = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_object = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_array = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_is_function = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	-- Get operations
	duk_get_boolean = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_get_number = {
		returns = ffi.types.double,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_get_int = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_get_string = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_get_lstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	duk_require_lstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	duk_to_string = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	-- Property operations
	duk_get_prop_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	duk_put_prop_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	duk_get_prop_index = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	duk_put_prop_index = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u32 },
	},
	duk_del_prop_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},

	-- Global object
	duk_push_global_object = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	duk_get_global_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	duk_put_global_string = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	-- Evaluation
	duk_eval_raw = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.u32 },
	},

	-- Function calls
	duk_call = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_pcall = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	-- Error handling
	duk_safe_to_lstring = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	duk_safe_to_stacktrace = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},

	-- Misc
	duk_get_length = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_json_encode = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	duk_json_decode = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
})

-- Duktape constants
local DUK_COMPILE_EVAL = bit32.lshift(1, 3)
local DUK_COMPILE_SAFE = bit32.lshift(1, 6)
local DUK_COMPILE_NORESULT = bit32.lshift(1, 7)
local DUK_COMPILE_NOSOURCE = bit32.lshift(1, 8)
local DUK_COMPILE_STRLEN = bit32.lshift(1, 9)
local DUK_COMPILE_NOFILENAME = bit32.lshift(1, 10)

local DuktapeVM = {}
DuktapeVM.__index = DuktapeVM

function DuktapeVM.new()
	local self = setmetatable({}, DuktapeVM)

	-- Create heap with default allocators (all NULL pointers)
	self.ctx = duk_lib.duk_create_heap(ffi.null, ffi.null, ffi.null, ffi.null, ffi.null)
	if self.ctx == ffi.null then
		error("Failed to create Duktape heap")
	end

	return self
end

function DuktapeVM:execute(code: string): (boolean, any, string?)
	if not code or #code == 0 then
		return false, nil, "Empty code"
	end

	-- Create null-terminated string buffer
	local code_buf = buffer.fromstring(code .. "\0")

	-- Evaluate the code
	local flags =
		bit32.bor(DUK_COMPILE_EVAL, DUK_COMPILE_SAFE, DUK_COMPILE_NOSOURCE, DUK_COMPILE_STRLEN, DUK_COMPILE_NOFILENAME)
	local rc = duk_lib.duk_eval_raw(self.ctx, code_buf, #code, flags)

	if rc ~= 0 then
		-- Error occurred - get error message from stack top
		local len_buf = ffi.alloc(8, 8)
		local err_ptr = duk_lib.duk_safe_to_lstring(self.ctx, -1, len_buf)
		local err_msg = "JavaScript execution error"

		if err_ptr ~= ffi.null then
			local len = len_buf:readu64(0)
			if len > 0 then
				err_msg = buffer.tostring(err_ptr:span(len))
			end
		end

		ffi.free(len_buf)
		duk_lib.duk_pop(self.ctx)
		return false, nil, err_msg
	end

	-- Get result from top of stack
	local result = self:_getStackValue(-1)
	duk_lib.duk_pop(self.ctx)

	return true, result, nil
end

function DuktapeVM:call(funcName: string, ...): (boolean, any)
	local args = { ... }

	-- Get the function from global scope
	local func_name_buf = buffer.fromstring(funcName .. "\0")
	local has_func = duk_lib.duk_get_global_string(self.ctx, func_name_buf)

	if has_func == 0 or duk_lib.duk_is_function(self.ctx, -1) == 0 then
		duk_lib.duk_pop(self.ctx)
		return false, "Function not found: " .. funcName
	end

	-- Push arguments
	for i, arg in ipairs(args) do
		self:_pushValue(arg)
	end

	-- Call function with protected call
	local rc = duk_lib.duk_pcall(self.ctx, #args)

	if rc ~= 0 then
		-- Error occurred
		local len_buf = ffi.alloc(8, 8)
		local err_ptr = duk_lib.duk_safe_to_lstring(self.ctx, -1, len_buf)
		local err_msg = "Function call error"

		if err_ptr ~= ffi.null then
			local len = len_buf:readu64(0)
			if len > 0 then
				err_msg = buffer.tostring(err_ptr:span(len))
			end
		end

		ffi.free(len_buf)
		duk_lib.duk_pop(self.ctx)
		return false, err_msg
	end

	-- Get result
	local result = self:_getStackValue(-1)
	duk_lib.duk_pop(self.ctx)

	return true, result
end

function DuktapeVM:setGlobal(name: string, value: any)
	self:_pushValue(value)
	local name_buf = buffer.fromstring(name .. "\0")
	duk_lib.duk_put_global_string(self.ctx, name_buf)
end

function DuktapeVM:getGlobal(name: string): any
	local name_buf = buffer.fromstring(name .. "\0")
	local has_prop = duk_lib.duk_get_global_string(self.ctx, name_buf)

	if has_prop == 0 then
		duk_lib.duk_pop(self.ctx)
		return nil
	end

	local result = self:_getStackValue(-1)
	duk_lib.duk_pop(self.ctx)
	return result
end

function DuktapeVM:_pushValue(value: any)
	local t = type(value)

	if t == "nil" then
		duk_lib.duk_push_null(self.ctx)
	elseif t == "boolean" then
		duk_lib.duk_push_boolean(self.ctx, value and 1 or 0)
	elseif t == "number" then
		-- Use int for integers in range, otherwise use double
		if math.floor(value) == value and value >= -2147483648 and value <= 2147483647 then
			duk_lib.duk_push_int(self.ctx, math.floor(value))
		else
			duk_lib.duk_push_number(self.ctx, value)
		end
	elseif t == "string" then
		local str_buf = buffer.fromstring(value)
		duk_lib.duk_push_lstring(self.ctx, str_buf, #value)
	elseif t == "table" then
		-- Check if it's an array-like table
		local is_array = true
		local max_index = 0
		local count = 0

		for k, v in pairs(value) do
			count = count + 1
			if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
				is_array = false
				break
			end
			max_index = math.max(max_index, k)
		end

		-- Only treat as array if indices are contiguous
		if is_array and max_index > 0 and count == max_index then
			-- Create array
			duk_lib.duk_push_array(self.ctx)
			for i = 1, max_index do
				self:_pushValue(value[i])
				duk_lib.duk_put_prop_index(self.ctx, -2, i - 1)
			end
		else
			-- Create object
			duk_lib.duk_push_object(self.ctx)
			for k, v in pairs(value) do
				local key_buf = buffer.fromstring(tostring(k) .. "\0")
				self:_pushValue(v)
				duk_lib.duk_put_prop_string(self.ctx, -2, key_buf)
			end
		end
	elseif t == "function" then
		-- Cannot push Lua functions directly, push undefined
		duk_lib.duk_push_undefined(self.ctx)
	else
		-- Unsupported type, push null
		duk_lib.duk_push_null(self.ctx)
	end
end

function DuktapeVM:_getStackValue(idx: number): any
	-- Normalize negative indices
	if idx < 0 then
		local top = duk_lib.duk_get_top(self.ctx)
		idx = top + idx
	end

	-- Check for undefined/null first
	if duk_lib.duk_is_undefined(self.ctx, idx) ~= 0 then
		return nil
	elseif duk_lib.duk_is_null(self.ctx, idx) ~= 0 then
		return nil
	elseif duk_lib.duk_is_boolean(self.ctx, idx) ~= 0 then
		return duk_lib.duk_get_boolean(self.ctx, idx) ~= 0
	elseif duk_lib.duk_is_number(self.ctx, idx) ~= 0 then
		local num = duk_lib.duk_get_number(self.ctx, idx)
		-- Return as integer if it's a whole number
		if math.floor(num) == num then
			return math.floor(num)
		end
		return num
	elseif duk_lib.duk_is_string(self.ctx, idx) ~= 0 then
		local len_buf = ffi.alloc(8, 8)
		local str_ptr = duk_lib.duk_get_lstring(self.ctx, idx, len_buf)

		if str_ptr ~= ffi.null then
			local len = len_buf:readu64(0)
			local result = buffer.tostring(str_ptr:span(len))
			ffi.free(len_buf)
			return result
		end

		ffi.free(len_buf)
		return ""
	elseif duk_lib.duk_is_array(self.ctx, idx) ~= 0 then
		-- Convert array to Lua table
		local result = {}
		local length = duk_lib.duk_get_length(self.ctx, idx)

		for i = 0, length - 1 do
			duk_lib.duk_get_prop_index(self.ctx, idx, i)
			result[i + 1] = self:_getStackValue(-1)
			duk_lib.duk_pop(self.ctx)
		end

		return result
	elseif duk_lib.duk_is_object(self.ctx, idx) ~= 0 then
		-- For general objects, return JSON string representation
		duk_lib.duk_dup(self.ctx, idx)
		local json_ptr = duk_lib.duk_json_encode(self.ctx, -1)
		duk_lib.duk_pop(self.ctx)

		if json_ptr ~= ffi.null then
			local json_str = buffer.tostring(json_ptr:span())
			return json_str
		end

		return "[object Object]"
	end

	return nil
end

function DuktapeVM:close()
	if self.ctx ~= ffi.null then
		duk_lib.duk_destroy_heap(self.ctx)
		self.ctx = ffi.null
	end
end

return {
	DuktapeVM = DuktapeVM,
	ffi = duk_lib,
}
