
if (godot_platform MATCHES "(haiku|macos|windows|linuxbsd)")
	add_lib(thirdparty-drivers-glad-lib
		OBJECT
		PARENT_LIB
			drivers-lib
		COMPONENTS
			global-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_GLAD_PATH "${ENGINE_SOURCE_DIR}/thirdparty/glad")
	target_sources_from_path(thirdparty-drivers-glad-lib PRIVATE "${__THIRDPARTY_GLAD_PATH}"
		"gl.c"
	)

	# Treat glad headers as system headers to avoid raising warnings.
	target_include_directories(global-env SYSTEM INTERFACE "${__THIRDPARTY_GLAD_PATH}")
	target_compile_definitions(global-env INTERFACE "GLAD_ENABLED" "GLES_OVER_GL")
endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")