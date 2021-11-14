
add_env(ogg-env
	COMPONENTS
		modules-env
)

add_module_lib(ogg-lib
	COMPONENTS
		ogg-env
		warnings-env
)


if(GODOT_BUILTIN_LIBOGG)

	set(__THIRDPARTY_OGG_PATH "${GODOT_SOURCE_DIR}/thirdparty/libogg")
	target_include_directories(ogg-env INTERFACE "${__THIRDPARTY_OGG_PATH}")

	add_module_lib(thirdparty-ogg-lib
		OBJECT
		PARENT_LIB
			ogg-lib
		COMPONENTS
			ogg-env	
	)
	target_sources_from_path(thirdparty-ogg-lib PRIVATE "${__THIRDPARTY_OGG_PATH}"
		"bitwise.c"
		"framing.c"
	)

endif()

target_glob_sources(ogg-lib PRIVATE "*.cpp")
