# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)

	# Thirdparty dependency OpenImage Denoise includes oneDNN library
	# and the version we use only supports x86_64.
	# It's also only relevant for tools build and desktop platforms,
	# as doing lightmap generation and denoising on Android or HTML5
	# would be a bit far-fetched.
	# Note: oneDNN doesn't support ARM64, OIDN needs updating to the latest version
	set(__SUPPORTED_PLATFORM FALSE)
	if(GODOT_PLATFORM MATCHES "(x11|osx|windows|server)")
		set(__SUPPORTED_PLATFORM TRUE)
	endif()

	set(__SUPPORTED_BITS FALSE)
	if(PROCESSOR_BITS EQUAL 64)
		set(__SUPPORTED_BITS TRUE)
	endif()

	string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" __HOST_PROCESSOR_ARCHITECTURE)
	set(__SUPPORTED_ARCH FALSE)
	if(NOT PROCESSOR_IS_ARM AND NOT PROCESSOR_IS_RISCV)
		set(__SUPPORTED_ARCH TRUE)
	endif()

	# Hack to disable on Linux arm64. This won't work well for cross-compilation (checks
    # host, not target) and would need a more thorough fix by refactoring our arch and
    # bits-handling code.
	if(GODOT_PLATFORM STREQUAL "x11" AND NOT __HOST_PROCESSOR_ARCHITECTURE MATCHES "(amd64|x86_64)")
		set(__SUPPORTED_ARCH FALSE)
	endif()

	if (GODOT_BUILD_TOOLS AND __SUPPORTED_PLATFORM AND __SUPPORTED_ARCH AND __SUPPORTED_BITS)
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()