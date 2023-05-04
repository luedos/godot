get_target_property(__EXTRA_SUFFIX global-env EXTRA_SUFFIX)

add_exe(godot-exe
	COMPONENTS
		global-env
		global-libs-list
	OUTPUT_DIR
		"${godot_bin_directory}"
	OUTPUT_NAME
		"godot${__EXTRA_SUFFIX}${MODULES_VERSION_STRING}"
	SOURCES
		"godot_linuxbsd.cpp"
		"crash_handler_linuxbsd.cpp"
		"os_linuxbsd.cpp"
		"joypad_linux.cpp"
		"freedesktop_portal_desktop.cpp"
		"freedesktop_screensaver.cpp"
)

if (godot_use_sowrap)
	target_sources(godot-exe PRIVATE "xkbcommon-so_wrap.c")
endif()

if (godot_x11)
	add_subdirectory(x11)
endif()

if (godot_speechd)
	target_sources(godot-exe PRIVATE "tts_linux.cpp")
	if (godot_use_sowrap)
		target_sources(godot-exe PRIVATE "speechd-so_wrap.c")
	endif()
endif()

if (godot_fontconfig AND godot_use_sowrap)
	target_sources(godot-exe PRIVATE "fontconfig-so_wrap.c")
endif()

if (godot_udev AND godot_use_sowrap)
	target_sources(godot-exe PRIVATE "libudev-so_wrap.c")
endif()

if (godot_dbus AND godot_use_sowrap)
	target_sources(godot-exe PRIVATE "dbus-so_wrap.c")
endif()

if (godot_debug_symbols AND godot_separate_debug_symbols)
	set(__STRIP_TARGET_ARR $<TARGET_FILE:godot-exe>.debugsymbols)
	set(__STRIP_SOURCE_ARR $<TARGET_FILE:godot-exe>)

	compose_python_method_call(__STRIP_COMMAND cmake_make_debug_linuxbsd FROM_MODULE platform_linuxbsd_builders
		PYTHON_ARGS
			ARR_VAR "target=__STRIP_TARGET_ARR"
			ARR_VAR "source=__STRIP_SOURCE_ARR"
	)

	add_custom_command(TARGET godot-exe POST_BUILD
		COMMAND "python" "-c" "${__STRIP_COMMAND}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		VERBATIM
	)
endif()
