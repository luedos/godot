# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
    # glslang is only needed when Vulkan or Direct3D 12-based renderers are available,
    # as OpenGL doesn't use glslang.
	if (godot_vulkan OR godot_d3d12)
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()