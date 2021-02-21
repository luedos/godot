
if(GODOT_PLATFORM STREQUAL "iphone")

	add_module_lib(camera-lib
		EXCLUDE_FROM_ALL
		COMPONENTS
			modules-lib
			warnings-lib
	)

	target_compile_options(camera-lib PRIVATE
		"-fmodules"
		"-fcxx-modules"
	)

	target_sources(camera-lib PRIVATE 
		"register_types.cpp"
		"camera_ios.mm"
	)

elseif(GODOT_PLATFORM STREQUAL "windows")

	add_module_lib(camera-lib
		COMPONENTS
			modules-lib
			warnings-lib
	)

	target_sources(camera-lib PRIVATE 
		"register_types.cpp"
		"camera_win.mm"
	)

elseif(GODOT_PLATFORM STREQUAL "osx")

	add_module_lib(camera-lib
		COMPONENTS
			modules-lib
			warnings-lib
	)
	
	target_sources(camera-lib PRIVATE 
		"register_types.cpp"
		"camera_osx.mm"
	)
endif()
