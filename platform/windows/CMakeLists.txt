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
		"os_windows.cpp"
		"display_server_windows.cpp"
		"key_mapping_windows.cpp"
		"joypad_windows.cpp"
		"tts_windows.cpp"
		"windows_terminal_logger.cpp"
		"windows_utils.cpp"
		"native_menu_windows.cpp"
		"gl_manager_windows_native.cpp"
		"gl_manager_windows_angle.cpp"
		"wgl_detect_version.cpp"
		"rendering_context_driver_vulkan_windows.cpp"
		# In theory resource file should be automatically handled by cmake
		"godot_res.rc"
)

if (MSVC)
	target_sources(godot-exe PRIVATE "crash_handler_windows_seh.cpp")
else()
	target_sources(godot-exe PRIVATE "crash_handler_windows_signal.cpp")
endif()

set(__COMMON_WIN_WRAP "console_wrapper_windows.cpp")

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
	add_dependencies(godot-wrap-exe godot-exe)
endif()

if (godot_d3d12)
	if (PROCESSOR_IS_X86_32)
		set(__DXC_ARCH_SUBDIR "x86")
		set(__AGILITY_ARCH_SUBDIR "win32")
	elseif(PROCESSOR_IS_X86_64)
		set(__DXC_ARCH_SUBDIR "x64")
		set(__AGILITY_ARCH_SUBDIR "x64")
	elseif(PROCESSOR_IS_ARM32)
		set(__DXC_ARCH_SUBDIR "arm")
		set(__AGILITY_ARCH_SUBDIR "arm")
	elseif(PROCESSOR_IS_ARM64)
		set(__DXC_ARCH_SUBDIR "arm64")
		set(__AGILITY_ARCH_SUBDIR "arm64")
	endif()

	if (NOT "${godot_agility_sdk_path}" STREQUAL "" AND EXISTS "${godot_agility_sdk_path}")
		if (godot_agility_sdk_multiarch)
			set(__TARGET_DIR "${godot_bin_directory}/${PROCESSOR_ARCH_ALIAS}")
		else()
			set(__TARGET_DIR "${godot_bin_directory}")
		endif()

		join_paths(__SOURCE_DIR "${godot_agility_sdk_path}" "build/native/bin/${__AGILITY_ARCH_SUBDIR}")
		normilize_path(__SOURCE_DIR "${__SOURCE_DIR}" ABSOLUTE PARENT_PATH_PREFIX "${ENGINE_SOURCE_DIR}")
		set(__AGILITY_DLL_OUTPUTS "")

		foreach (__AGILITY_DLL IN ITEMS "D3D12Core.dll" "d3d12SDKLayers.dll")
			add_custom_command(
				OUTPUT "${__TARGET_DIR}/${__AGILITY_DLL}"
				COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${__TARGET_DIR}"
				COMMAND "${CMAKE_COMMAND}" "-E" "copy" "-t" "${__TARGET_DIR}" "${__SOURCE_DIR}/${__AGILITY_DLL}"
			)
			list(APPEND __AGILITY_DLL_OUTPUTS "${__TARGET_DIR}/${__AGILITY_DLL}")
		endforeach()

		if (NOT "${__AGILITY_DLL_OUTPUTS}" STREQUAL "")
			add_custom_target(agility-dll-gen DEPENDS ${__AGILITY_DLL_OUTPUTS})
			add_dependencies(godot-exe agility-dll-gen)
		endif()
	endif()

	if (godot_use_pix)
		set(__PIX_DLL "WinPixEventRuntime.dll")
		join_paths(__PIX_PATH "${godot_pix_path}" "bin/${__DXC_ARCH_SUBDIR}")
		normilize_path(__PIX_PATH "${__PIX_PATH}" ABSOLUTE PARENT_PATH_PREFIX "${ENGINE_SOURCE_DIR}")
		
		add_custom_target(pix-dll-gen
			COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${ENGINE_SOURCE_DIR}/bin"
			COMMAND "${CMAKE_COMMAND}" "-E" "copy" "-t" "${ENGINE_SOURCE_DIR}/bin" "${__PIX_PATH}/${__PIX_DLL}"
			BYPRODUCTS "${ENGINE_SOURCE_DIR}/bin/${__PIX_DLL}"
		)
		add_dependencies(godot-exe pix-dll-gen)
	endif()
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