
add_env(servers-renderer-effects-env
	COMPONENTS
		servers-env
)

add_lib(servers-renderer-effects-lib
	OBJECT
	PARENT_LIB
		servers-lib
	COMPONENTS
		servers-renderer-effects-env
		global-warnings-env
)

add_lib(thirdparty-amd-fsr-lib
	OBJECT
	PARENT_LIB
		servers-lib
	COMPONENTS
		servers-renderer-effects-env
		thirdparty-warnings-env
)

set(__AMD_FSR_PATH "${ENGINE_SOURCE_DIR}/thirdparty/amd-fsr2")
target_sources_from_path(thirdparty-amd-fsr-lib PRIVATE "${__AMD_FSR_PATH}"
	"ffx_assert.cpp"
	"ffx_fsr2.cpp"
)

target_include_directories(servers-renderer-effects-env INTERFACE "${__AMD_FSR_PATH}")
# This flag doesn't actually control anything GCC specific in FSR2. It determines
# if symbols should be exported, which is not required for Godot.
target_compile_definitions(servers-renderer-effects-env INTERFACE "FFX_GCC")

target_glob_sources(servers-renderer-effects-lib PRIVATE "*.cpp")