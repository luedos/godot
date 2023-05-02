# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	set(${__OUTPUT} TRUE PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_create_custom_options)
	set_bool_option(godot_brotli TRUE DESCRIPTION "Enable Brotli decompressor for WOFF2 fonts support")
endfunction()
