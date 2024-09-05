# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	# Godot only uses it in the editor, but ANGLE depends on it and we had
	# to remove the copy from prebuilt ANGLE libs to solve symbol clashes.
	if (EDITOR_BUILD OR NOT "${godot_angle_libs}" STREQUAL "")
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()