import re

# Input C header
header_file = "joltcstructs.h"
output_file = "jolt_funcs.luau"

# Full mapping from C -> Lua FFI types
type_map = {
    "void": "ffi.types.void",
    "bool": "ffi.types.u8",
    "int8_t": "ffi.types.i8",
    "uint8_t": "ffi.types.u8",
    "int16_t": "ffi.types.i16",
    "uint16_t": "ffi.types.u16",
    "int32_t": "ffi.types.i32",
    "uint32_t": "ffi.types.u32",
    "int64_t": "ffi.types.i64",
    "uint64_t": "ffi.types.u64",
    "float": "ffi.types.float",
    "double": "ffi.types.double",
    "char*": "ffi.types.pointer",
    "const char*": "ffi.types.pointer",
    # Add Jolt-specific pointers here
    "JPH_BroadPhaseLayerInterface*": "ffi.types.pointer",
    "JPH_ObjectLayerPairFilter*": "ffi.types.pointer",
    "JPH_JobSystem*": "ffi.types.pointer",
    "JPH_PhysicsSystem*": "ffi.types.pointer",
    "JPH_CollideShapeResult*": "ffi.types.pointer",
}

# Regex to match JPH_CAPI functions
func_pattern = re.compile(
    r"JPH_CAPI\s+(?P<ret>[^\s]+)\s+(?P<name>\w+)\s*\((?P<args>[^\)]*)\);"
)

with open(header_file, "r") as f:
    lines = f.readlines()

funcs = []

for line in lines:
    m = func_pattern.search(line)
    if not m:
        continue

    ret = m.group("ret").strip()
    name = m.group("name").strip()
    args_raw = m.group("args").strip()

    args = []
    if args_raw and args_raw.strip() not in ("void", ""):
        for arg in args_raw.split(","):
            arg_type = arg.strip().rsplit(" ", 1)[0]
            if arg_type == "void":
                continue  # skip void arguments
            lua_type = type_map.get(arg_type, "ffi.types.pointer")
            args.append(lua_type)

    ret_type = type_map.get(ret, "ffi.types.pointer")
    funcs.append(f'    {name} = {{ returns = {ret_type}, args = {{ {", ".join(args)} }} }},')

with open(output_file, "w") as f:
    f.write("local ffi = zune.ffi\n")
    f.write("local funcs = {\n")
    for func in funcs:
        f.write(func + "\n")
    f.write("}\n\nreturn funcs\n")

print(f"Generated {len(funcs)} functions to {output_file}")
