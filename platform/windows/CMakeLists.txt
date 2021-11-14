
add_exe(godot-exe
	COMPONENTS
		global-env
		global-libs-list
	OUTPUT_DIR
		"${GODOT_BIN_DIRECTORY}"
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