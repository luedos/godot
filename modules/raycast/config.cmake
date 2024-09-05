# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if (PROCESSOR_ARCH_ALIAS STREQUAL "arm64" AND godot_platform STREQUAL "windows" AND MSVC)
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	elseif (PROCESSOR_ARCH_ALIAS STREQUAL "(x86_64|arm64|wasm32)")
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	elseif (PROCESSOR_ARCH_ALIAS STREQUAL "x86_32" AND godot_platform STREQUAL "windows")
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()