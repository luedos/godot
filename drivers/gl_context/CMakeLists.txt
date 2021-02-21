
set(__POSSIBLE_PLATFORMS "haiku" "osx" "windows" "x11")

if(GODOT_PLATFORM IN_LIST __POSSIBLE_PLATFORMS)

	add_lib(thirdparty-drivers-glad-lib
		PARENT_LIB
			drivers-lib
		COMPONENTS
			global-env
	)

	set(__THIRDPARTY_GLAD_PATH "${GODOT_SOURCE_DIR}/thirdparty/glad")
	target_include_directories(global-env INTERFACE
		"${__THIRDPARTY_GLAD_PATH}"
	)
	target_compile_definitions(global-env INTERFACE
		"GLAD_ENABLED"
		"GLES_OVER_GL"
	)

	target_sources(thirdparty-drivers-glad-lib PRIVATE
		"${__THIRDPARTY_GLAD_PATH}/glad.c"
	)

endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")
