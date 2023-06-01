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
		"godot_windows.cpp"
		"crash_handler_windows.cpp"
		"os_windows.cpp"
		"display_server_windows.cpp"
		"key_mapping_windows.cpp"
		"joypad_windows.cpp"
		"tts_windows.cpp"
		"windows_terminal_logger.cpp"
		"vulkan_context_win.cpp"
		"gl_manager_windows.cpp"
		# In theory resource file should be automatically handled by cmake
		"godot_res.rc"
)

if (godot_windows_subsystem STREQUAL "gui")
	add_exe(godot-wrap-exe
		COMPONENTS
			global-env
			global-libs-list
		OUTPUT_DIR
			"${godot_bin_directory}"
		OUTPUT_NAME
			"godot${__EXTRA_SUFFIX}${MODULES_VERSION_STRING}.console"
		SOURCES
			"console_wrapper_windows.cpp"
			# In theory resource file should be automatically handled by cmake
			"godot_res_wrap.rc"
	)

	if (MSVC)
		target_link_options(godot-wrap-exe PRIVATE "/SUBSYSTEM:CONSOLE")
	else()
		target_link_options(godot-wrap-exe PRIVATE "-Wl,--subsystem,console")
	endif()

	target_link_libraries(godot-wrap-exe PRIVATE "version")
endif()

if (NOT MSVC)
	if (godot_debug_symbols AND godot_separate_debug_symbols)
		set(__STRIP_TARGET_ARR $<TARGET_FILE:godot-exe>.debugsymbols)
		set(__STRIP_SOURCE_ARR $<TARGET_FILE:godot-exe>)

		compose_python_method_call(__STRIP_COMMAND cmake_make_debug_mingw FROM_MODULE platform_windows_builders
			PYTHON_ARGS
				ARR_VAR "target=__STRIP_TARGET_ARR"
				ARR_VAR "source=__STRIP_SOURCE_ARR"
		)

		add_custom_command(TARGET godot-exe POST_BUILD
			COMMAND "python" "-c" "${__STRIP_COMMAND}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			VERBATIM
		)

		if (godot_windows_subsystem STREQUAL "gui")
			set(__STRIP_TARGET_ARR $<TARGET_FILE:godot-wrap-exe>.debugsymbols)
			set(__STRIP_SOURCE_ARR $<TARGET_FILE:godot-wrap-exe>)

			compose_python_method_call(__STRIP_COMMAND cmake_make_debug_mingw FROM_MODULE platform_windows_builders
				PYTHON_ARGS
					ARR_VAR "target=__STRIP_TARGET_ARR"
					ARR_VAR "source=__STRIP_SOURCE_ARR"
			)

			add_custom_command(TARGET godot-wrap-exe POST_BUILD
				COMMAND "python" "-c" "${__STRIP_COMMAND}"
				WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
				VERBATIM
			)
		endif()
	endif()
endif()