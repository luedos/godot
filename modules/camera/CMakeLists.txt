
if(GODOT_PLATFORM STREQUAL "windows")
	add_module_lib(camera-lib
		COMPONENTS
			modules-env
			warnings-env
	)
	target_sources(camera-lib PRIVATE 
		"register_types.cpp"
		"camera_win.cpp"
	)
elseif(GODOT_PLATFORM STREQUAL "osx")
	add_module_lib(camera-lib
		COMPONENTS
			modules-env
			warnings-env
	)
	target_sources(camera-lib PRIVATE 
		"register_types.cpp"
		"camera_osx.mm"
	)

endif()
