# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if(GODOT_BUILD_TOOLS AND NOT GODOT_PLATFORM MATCHES "(android|ios)")
		set(${__OUTPUT} true PARENT_SCOPE)
	else()
		set(${__OUTPUT} false PARENT_SCOPE)
	endif()
endfunction()
