
if(GODOT_PLATFORM STREQUAL "iphone")

	#TODO: again, as arkit lib, it seams this library is not connected to anything at all.. need to test it more on phone targets..
	add_lib(camera-lib
		COMPONENTS
			modules-env
			warnings-env
		OUTPUT_DIR
			"${GODOT_BIN_DIRECTORY}"
		OUTPUT_NAME
			"libgodot_camera_module${EXTRA_SUFFIX}"
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
