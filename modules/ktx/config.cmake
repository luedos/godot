# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	# Thirdparty dependency OpenImage Denoise includes oneDNN library
	# and the version we use only supports x86_64.
	# It's also only relevant for tools build and desktop platforms,
	# as doing lightmap generation and denoising on Android or Web
	# would be a bit far-fetched.
	if (godot_editor_build AND godot_platform MATCHES "(linuxbsd|macos|windows)" AND PROCESSOR_IS_X86_64)
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()