
get_target_property(__EXTRA_SUFFIX global-env EXTRA_SUFFIX)
get_target_property(__MODULE_VERSION_STRING global-env MODULE_VERSION_STRING)

add_exe(godot-exe
	COMPONENTS
		global-env
		global-libs-list
	OUTPUT_DIR
		"${GODOT_BIN_DIRECTORY}"
	OUTPUT_NAME
		"godot${__EXTRA_SUFFIX}${__MODULE_VERSION_STRING}"
	SOURCES
		"godot_x11.cpp"
		"context_gl_x11.cpp"
		"crash_handler_x11.cpp"
		"os_x11.cpp"
		"key_mapping_x11.cpp"
		"joypad_linux.cpp"
		"power_x11.cpp"
		"detect_prime.cpp"
)

if(GODOT_UDEV)
	target_sources(godot-exe PRIVATE "libudev-so_wrap.c")
endif()

set(__STRIP_TARGET_ARR $<TARGET_FILE:godot-exe>.debugsymbols)
set(__STRIP_SOURCE_ARR $<TARGET_FILE:godot-exe>)

compose_python_method_call(__STRIP_COMMAND make_debug_x11 FROM_MODULE cmake_platform_x11_builders
	PYTHON_ARGS
		ARR_VAR "target=__STRIP_TARGET_ARR"
		ARR_VAR "source=__STRIP_SOURCE_ARR"
)

add_custom_command(TARGET godot-exe POST_BUILD
	COMMAND "python" "-c" "${__STRIP_COMMAND}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	VERBATIM
)