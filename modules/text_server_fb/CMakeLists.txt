
add_lib(text-server-fb-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)

if ("svg" IN_LIST MODULES_LIST)
	target_include_directories(text-server-fb-lib PRIVATE
		"${ENGINE_SOURCE_DIR}/thirdparty/thorvg/inc"
		"${ENGINE_SOURCE_DIR}/thirdparty/thorvg/src/lib"
	)
endif()

if (godot_builtin_msdfgen AND "msdfgen" IN_LIST MODULES_LIST)
	target_include_directories(text-server-fb-lib PRIVATE
		"${ENGINE_SOURCE_DIR}/thirdparty/msdfgen"
	)
endif()

if (godot_builtin_freetype AND "freetype" IN_LIST MODULES_LIST)
	target_include_directories(text-server-fb-lib PRIVATE
		"${ENGINE_SOURCE_DIR}/thirdparty/freetype/include"
	)
	target_compile_definitions(text-server-fb-lib PRIVATE "FT_CONFIG_OPTION_USE_BROTLI")
endif()

target_glob_sources(text-server-fb-lib PRIVATE "*.cpp")