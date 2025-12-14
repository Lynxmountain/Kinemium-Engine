-- python bindings
-- wrapper for Python 3.14 DLL

local dll = "./src/runtime/python/bin/"
local ffi = zune.ffi
local platform = zune.platform

local libname
if platform.os == "windows" then
	libname = "python3.dll"
elseif platform.os == "linux" then
	libname = "python3.so"
elseif platform.os == "macos" then
	libname = "python3.dylib"
end

local py_lib = ffi.dlopen(dll .. libname, {
	Py_Initialize = {
		returns = ffi.types.void,
		args = {},
	},
	Py_InitializeEx = {
		returns = ffi.types.void,
		args = { ffi.types.i32 },
	},
	Py_Finalize = {
		returns = ffi.types.void,
		args = {},
	},
	Py_IsInitialized = {
		returns = ffi.types.i32,
		args = {},
	},

	-- Reference counting
	Py_IncRef = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	Py_DecRef = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},

	-- Execution
	PyRun_SimpleString = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},
	PyRun_String = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer, ffi.types.pointer },
	},

	-- Error handling
	PyErr_Occurred = {
		returns = ffi.types.pointer,
		args = {},
	},
	PyErr_Print = {
		returns = ffi.types.void,
		args = {},
	},
	PyErr_Clear = {
		returns = ffi.types.void,
		args = {},
	},
	PyErr_Fetch = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	-- Import system
	PyImport_AddModule = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	PyImport_ImportModule = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	PyModule_GetDict = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	-- Type checking
	PyBool_FromLong = {
		returns = ffi.types.pointer,
		args = { ffi.types.i64 },
	},
	PyLong_FromLong = {
		returns = ffi.types.pointer,
		args = { ffi.types.i64 },
	},
	PyLong_AsLong = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer },
	},
	PyFloat_FromDouble = {
		returns = ffi.types.pointer,
		args = { ffi.types.double },
	},
	PyFloat_AsDouble = {
		returns = ffi.types.double,
		args = { ffi.types.pointer },
	},
	PyUnicode_FromString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	PyUnicode_AsUTF8 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	-- Dict operations
	PyDict_New = {
		returns = ffi.types.pointer,
		args = {},
	},
	PyDict_SetItemString = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	PyDict_GetItemString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	PyDict_Keys = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	PyDict_Next = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	-- List operations
	PyList_New = {
		returns = ffi.types.pointer,
		args = { ffi.types.i64 },
	},
	PyList_SetItem = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i64, ffi.types.pointer },
	},
	PyList_GetItem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i64 },
	},
	PyList_Size = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer },
	},
	PyList_Append = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	-- Object operations
	PyObject_GetAttrString = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	PyObject_SetAttrString = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	PyObject_Call = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	PyObject_Str = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	PyObject_IsTrue = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer },
	},

	-- Tuple operations
	PyTuple_New = {
		returns = ffi.types.pointer,
		args = { ffi.types.i64 },
	},
	PyTuple_SetItem = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i64, ffi.types.pointer },
	},
	PyTuple_GetItem = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i64 },
	},
	PyTuple_Size = {
		returns = ffi.types.i64,
		args = { ffi.types.pointer },
	},

	-- GIL operations
	PyGILState_Ensure = {
		returns = ffi.types.i32,
		args = {},
	},
	PyGILState_Release = {
		returns = ffi.types.void,
		args = { ffi.types.i32 },
	},

	-- Eval
	PyEval_GetBuiltins = {
		returns = ffi.types.pointer,
		args = {},
	},
	PyEval_GetGlobals = {
		returns = ffi.types.pointer,
		args = {},
	},
	PyEval_GetLocals = {
		returns = ffi.types.pointer,
		args = {},
	},

	-- None singleton access
	_Py_NoneStruct = {
		returns = ffi.types.pointer,
		args = {},
	},
})

-- Python execution modes
local Py_eval_input = 258
local Py_file_input = 257
local Py_single_input = 256

local PythonVM = {}
PythonVM.__index = PythonVM

function PythonVM.new()
	local self = setmetatable({}, PythonVM)

	-- Initialize Python with signal handling disabled
	py_lib.Py_InitializeEx(0)

	if py_lib.Py_IsInitialized() == 0 then
		error("Failed to initialize Python")
	end

	-- Force Python stdout/stderr to be unbuffered
	local init_code = [[
import sys
sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)
print("Python initialized successfully", flush=True)
]]

	local init_buf = buffer.fromstring(init_code .. "\0")
	local main_module = py_lib.PyImport_AddModule(buffer.fromstring("__main__"))
	if main_module == nil then
		error("Failed to get __main__ module")
	end

	self.globals = py_lib.PyModule_GetDict(main_module)
	if self.globals == nil then
		error("Failed to get globals dict")
	end

	self.locals = self.globals

	-- Execute initialization code
	local init_result = py_lib.PyRun_String(init_buf, Py_file_input, self.globals, self.locals)
	if init_result == nil then
		print("Warning: Failed to configure Python output buffering")
		py_lib.PyErr_Print()
		py_lib.PyErr_Clear()
	else
		py_lib.Py_DecRef(init_result)
	end

	-- Get None from builtins
	local builtins = py_lib.PyEval_GetBuiltins()
	if builtins == nil then
		error("Failed to get builtins")
	end

	local none_name = buffer.fromstring("None")
	self.none = py_lib.PyDict_GetItemString(builtins, none_name)

	if self.none == nil then
		error("Failed to get None from builtins")
	end

	py_lib.Py_IncRef(self.none)

	return self
end

function PythonVM:execute(code: string): (boolean, any, string?)
	local code_buf = buffer.fromstring(code .. "\0")

	py_lib.PyErr_Clear()

	-- 🔒 ACQUIRE GIL
	local gil = py_lib.PyGILState_Ensure()

	local result = py_lib.PyRun_String(code_buf, Py_file_input, self.globals, self.locals)

	-- 🔓 RELEASE GIL
	py_lib.PyGILState_Release(gil)

	if result == nil then
		local err_msg = self:_getError()
		return false, nil, err_msg or "Python execution error"
	end

	local ret = self:_pyToLua(result)
	py_lib.Py_DecRef(result)

	return true, ret, nil
end

function PythonVM:call(funcName: string, ...): (boolean, any)
	local args = { ... }

	-- Get the function from globals
	local func_name_buf = buffer.fromstring(funcName)
	local func = py_lib.PyDict_GetItemString(self.globals, func_name_buf)

	if func == nil then
		return false, nil
	end

	-- Create argument tuple
	local py_args = py_lib.PyTuple_New(#args)
	for i, arg in ipairs(args) do
		local py_arg = self:_luaToPy(arg)
		py_lib.PyTuple_SetItem(py_args, i - 1, py_arg) -- Steals reference
	end

	-- Call the function
	local result = py_lib.PyObject_Call(func, py_args, nil)
	py_lib.Py_DecRef(py_args)

	if result == nil then
		local err_msg = self:_getError()
		error(err_msg or "Error calling Python function")
	end

	local ret = self:_pyToLua(result)
	py_lib.Py_DecRef(result)

	return true, ret
end

function PythonVM:setGlobal(name: string, value: any)
	local name_buf = buffer.fromstring(name)
	local py_value = self:_luaToPy(value)
	py_lib.PyDict_SetItemString(self.globals, name_buf, py_value)
	py_lib.Py_DecRef(py_value) -- Dict holds its own reference
end

function PythonVM:getGlobal(name: string): any
	local name_buf = buffer.fromstring(name)
	local py_value = py_lib.PyDict_GetItemString(self.globals, name_buf)

	if py_value == nil then
		return nil
	end

	return self:_pyToLua(py_value)
end

function PythonVM:_luaToPy(value: any): any
	local t = type(value)

	if t == "nil" then
		py_lib.Py_IncRef(self.none)
		return self.none
	end

	if t == "nil" then
		-- Return None - need to get it from the singleton
		local none = py_lib._Py_NoneStruct()
		py_lib.Py_IncRef(none)
		return none
	elseif t == "boolean" then
		local py_bool = py_lib.PyBool_FromLong(value and 1 or 0)
		return py_bool
	elseif t == "number" then
		-- Check if integer
		if math.floor(value) == value and value >= -2 ^ 53 and value <= 2 ^ 53 then
			return py_lib.PyLong_FromLong(value)
		else
			return py_lib.PyFloat_FromDouble(value)
		end
	elseif t == "string" then
		local str_buf = buffer.fromstring(value)
		return py_lib.PyUnicode_FromString(str_buf)
	elseif t == "table" then
		-- Check if it's an array or dict
		local is_array = true
		local max_index = 0

		for k, v in pairs(value) do
			if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
				is_array = false
				break
			end
			max_index = math.max(max_index, k)
		end

		if is_array and max_index > 0 then
			-- Create list
			local py_list = py_lib.PyList_New(max_index)
			for i = 1, max_index do
				local py_val = self:_luaToPy(value[i])
				py_lib.PyList_SetItem(py_list, i - 1, py_val) -- Steals reference
			end
			return py_list
		else
			-- Create dict
			local py_dict = py_lib.PyDict_New()
			for k, v in pairs(value) do
				local py_key = self:_luaToPy(k)
				local py_val = self:_luaToPy(v)
				py_lib.PyDict_SetItemString(py_dict, py_key, py_val)
				py_lib.Py_DecRef(py_key)
				py_lib.Py_DecRef(py_val)
			end
			return py_dict
		end
	else
		error(`Unsupported type for Python: {t}`)
	end
end

function PythonVM:_pyToLua(py_obj)
	print("_pyToLua called")
	if py_obj == nil then
		return nil
	end

	-- Check if it's None first
	print("Object none?")
	if py_obj == self.none then
		return nil
	end

	-- Try string first (most common for your use case)
	print("Object string?")

	local str_ptr = py_lib.PyUnicode_AsUTF8(py_obj)
	if str_ptr ~= nil then
		return buffer.tostring(str_ptr:span())
	else
		py_lib.PyErr_Clear()
	end

	-- Try list
	print("Object list?")

	local list_size = py_lib.PyList_Size(py_obj)
	if list_size >= 0 then
		local t = {}
		for i = 0, list_size - 1 do
			local item = py_lib.PyList_GetItem(py_obj, i)
			t[i + 1] = self:_pyToLua(item)
		end
		return t
	else
		py_lib.PyErr_Clear()
	end

	-- Try int (must come before float to avoid precision loss)
	print("Object int?")

	local int_val = py_lib.PyLong_AsLong(py_obj)
	if py_lib.PyErr_Occurred() == nil then
		return int_val
	else
		py_lib.PyErr_Clear()
	end

	-- Try float
	print("Object float?")

	local float_val = py_lib.PyFloat_AsDouble(py_obj)
	if py_lib.PyErr_Occurred() == nil then
		return float_val
	else
		py_lib.PyErr_Clear()
	end

	-- Try boolean (check this AFTER numbers since bools are a subclass of int in Python)
	-- We need to check the type, not just truthiness
	print("Object bool?")

	local is_true = py_lib.PyObject_IsTrue(py_obj)
	if is_true >= 0 then
		-- This is valid, but we need to actually check if it's a bool type
		-- For now, if all other checks failed and IsTrue works, treat as boolean
		-- This is a fallback and may not be accurate
		return is_true == 1
	end

	-- If we get here, convert to string representation
	print("Object string?")

	local str_obj = py_lib.PyObject_Str(py_obj)
	if str_obj ~= nil then
		local result_str = py_lib.PyUnicode_AsUTF8(str_obj)
		if result_str ~= nil then
			local result = buffer.tostring(result_str:span())
			py_lib.Py_DecRef(str_obj)
			return result
		end
		py_lib.Py_DecRef(str_obj)
	end
	print("Finished")

	return "<unknown Python object>"
end

function PythonVM:_getError(): string?
	if py_lib.PyErr_Occurred() == nil then
		return nil
	end

	-- Get the error as a string
	local err_type = ffi.new("void*[1]")
	local err_value = ffi.new("void*[1]")
	local err_traceback = ffi.new("void*[1]")

	-- Fetch the error (this clears it)
	py_lib.PyErr_Fetch(err_type, err_value, err_traceback)

	if err_value[0] ~= nil then
		local str_obj = py_lib.PyObject_Str(err_value[0])
		if str_obj ~= nil then
			local err_str = py_lib.PyUnicode_AsUTF8(str_obj)
			if err_str ~= nil then
				local result = buffer.tostring(err_str:span())
				py_lib.Py_DecRef(str_obj)

				-- Clean up error objects
				if err_type[0] ~= nil then
					py_lib.Py_DecRef(err_type[0])
				end
				if err_value[0] ~= nil then
					py_lib.Py_DecRef(err_value[0])
				end
				if err_traceback[0] ~= nil then
					py_lib.Py_DecRef(err_traceback[0])
				end

				return result
			end
			py_lib.Py_DecRef(str_obj)
		end
	end

	-- Fallback: just print and clear
	py_lib.PyErr_Print()
	return "Python error occurred (see console)"
end

function PythonVM:close()
	py_lib.Py_Finalize()
end

return {
	PythonVM = PythonVM,
	ffi = py_lib,
}
