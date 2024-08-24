add_env(ogg-env
	COMPONENTS
		modules-env
)

add_lib(ogg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		ogg-env
		global-warnings-env
)
target_glob_sources(ogg-lib PRIVATE "*.cpp")

if (godot_builtin_libogg)
	add_lib(thirdparty-ogg-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			ogg-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_OGG_PATH "${ENGINE_SOURCE_DIR}/thirdparty/libogg")
	target_sources_from_path(thirdparty-ogg-lib PRIVATE "${__THIRDPARTY_OGG_PATH}"
		"bitwise.c"
		"framing.c"
	)

	target_include_directories(ogg-env INTERFACE "${__THIRDPARTY_OGG_PATH}")
endif()