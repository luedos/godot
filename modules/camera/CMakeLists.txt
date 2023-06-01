
add_lib(camera-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)

if (godot_platform STREQUAL "windows")
	target_sources(camera-lib PRIVATE
		"register_types.cpp"
		"camera_win.cpp"
	)
endif()

if (godot_platform STREQUAL "macos")
	target_sources(camera-lib PRIVATE
		"register_types.cpp"
		"camera_macos.mm"
	)
endif()
