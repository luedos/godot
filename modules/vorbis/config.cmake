# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	set(${__OUTPUT} TRUE PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_module_dependencies __REQUIRED_DEPENDENCIES __OPTIONAL_DEPENDENCIES)
	set(${__REQUIRED_DEPENDENCIES} "ogg" PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"AudioStreamOggVorbis"
		"AudioStreamPlaybackOggVorbis"
		"ResourceImporterOggVorbis"
		PARENT_SCOPE
	)
endfunction()

function(${__MODULE_NAME}_get_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
endfunction()