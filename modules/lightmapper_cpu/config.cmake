# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# pass, nothing to do here
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if(NOT GODOT_BUILD_TOOLS OR NOT raycast_IS_MODULE_ENABLED)
		set(${__OUTPUT} FALSE PARENT_SCOPE)
		return()
	endif()

	if(GODOT_PLATFORM STREQUAL "android")
		if(CMAKE_ANDROID_ARCH MATCHES "(arm64-v8a|x86_64)")
			set(${__OUTPUT} TRUE PARENT_SCOPE)
		else()
			set(${__OUTPUT} FALSE PARENT_SCOPE)
		endif()
		return()
	endif()

	if(GODOT_PLATFORM MATCHES "(javascript|server)")
		set(${__OUTPUT} FALSE PARENT_SCOPE)
		return()
	endif()

	if(PROCESSOR_BITS EQUAL 32)
		set(${__OUTPUT} FALSE PARENT_SCOPE)
		return()
	endif()

	set(${__OUTPUT} TRUE PARENT_SCOPE)
endfunction()
