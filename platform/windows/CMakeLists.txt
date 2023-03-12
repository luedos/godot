
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
		"godot_windows.cpp"
		"context_gl_windows.cpp"
		"crash_handler_windows.cpp"
		"os_windows.cpp"
		"key_mapping_windows.cpp"
		"joypad_windows.cpp"
		"power_windows.cpp"
		"windows_terminal_logger.cpp"
		"godot_res.rc"
)