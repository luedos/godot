get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set_string_option(godot_target_win_version "0x0601" DESCRIPTION "Targeted Windows version, >= 0x0601 (Windows 7).")
	set_string_option(godot_windows_subsystem "gui" DESCRIPTION "Windows subsystem." ENUM "gui" "console")
	set_bool_option(godot_use_static_cpp TRUE DESCRIPTION "Link MinGW/MSVC C++ runtime libraries statically.")
	set_bool_option(godot_use_asan FALSE DESCRIPTION "Use address sanitizer (ASAN).")
	set_bool_option(godot_debug_crt FALSE DESCRIPTION "Compile with MSVC's debug CRT (/MDd).")
endfunction()

function(${__PLATFORM_NAME}_get_platform_name __OUTPUT)
	set("${__OUTPUT}" "Windows" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_is_platform_active __OUTPUT)
	set("${__OUTPUT}" TRUE PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_can_platform_build __OUTPUT)

	if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
		set("${__OUTPUT}" TRUE PARENT_SCOPE)
		return()
	endif()

	if (MINGW)
		set("${__OUTPUT}" TRUE PARENT_SCOPE)
		return()
	endif()

	set("${__OUTPUT}" FALSE PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_configure_platform)

	target_include_directories(global-env INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")

	# To match other platforms
	set(__STACK_SIZE "8388608")

	if (MSVC)
		target_link_options(global-env INTERFACE $<${IS_RELEASE_GEN_EXPR}:/ENTRY:mainCRTStartup>)
		if (godot_windows_subsystem)
			target_link_options(global-env INTERFACE "/SUBSYSTEM:WINDOWS")
		else()
			target_link_options(global-env INTERFACE "/SUBSYSTEM:CONSOLE")
			target_compile_definitions(global-env INTERFACE "WINDOWS_SUBSYSTEM_CONSOLE")
		endif()

		if (godot_debug_crt)
			# Always use dynamic runtime, static debug CRT breaks thread_local.
			target_compile_options(global-env INTERFACE "/MDd")
		elseif (godot_use_static_cpp)
			target_compile_options(global-env INTERFACE "/MT")
		else()
			target_compile_options(global-env INTERFACE "/MD")
		endif()

		if(PROCESSOR_IS_X86_32)
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC TRUE)
		endif()

		target_compile_options(global-env INTERFACE
			"/Gd"
			"/GR"
			"/nologo"
			# Force to use Unicode encoding.
			"/utf-8"
			# assume all sources are C++
			$<$<COMPILE_LANGUAGE:CXX>:/TP>
			# Once it was thought that only debug builds would be too large,
			# but this has recently stopped being true. See the mingw function
			# for notes on why this shouldn't be enabled for gcc
			"/bigobj"
		)

		target_compile_definitions(global-env INTERFACE
			"WINDOWS_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"TYPED_METHOD_BIND"
			"WIN32"
			"MSVC"
			"WINVER=${godot_target_win_version}"
			"_WIN32_WINNT=${godot_target_win_version}"
			# disable bogus min/max WinDef.h macros
			"NOMINMAX"
		)

		if (PROCESSOR_IS_X86_64)
			target_compile_definitions(global-env INTERFACE "_WIN64")
		endif()

		target_link_libraries(global-env INTERFACE
			"winmm"
			"dsound"
			"kernel32"
			"ole32"
			"oleaut32"
			"sapi"
			"user32"
			"gdi32"
			"IPHLPAPI"
			"Shlwapi"
			"wsock32"
			"Ws2_32"
			"shell32"
			"advapi32"
			"dinput8"
			"dxguid"
			"imm32"
			"bcrypt"
			"Avrt"
			"dwmapi"
			"dwrite"
			"wbemuuid"
		)

		if (godot_vulkan)
			target_compile_definitions(global-env INTERFACE "VULKAN_ENABLED")
			if (NOT godot_use_volk)
				target_link_libraries(global-env INTERFACE "vulkan")
			endif()
		endif()

		if (godot_opengl3)
			target_compile_definitions(global-env INTERFACE "GLES3_ENABLED")
			target_link_libraries(global-env INTERFACE "opengl32")
		endif()

		if (godot_lto STREQUAL "auto")
			set_parent_var(godot_lto "none")
		endif()

		if (NOT godot_lto STREQUAL "none")
			assert(
				"ThinLTO is only compatible with LLVM, use `use_llvm=yes` or `lto=full`."
				NOT godot_lto STREQUAL "thin"
			)

			target_compile_options(global-env INTERFACE "/GL")
			target_link_options(global-env INTERFACE "/LTCG")
		endif()

		if (godot_use_asan)
			target_property(APPEND_STR global-env EXTRA_SUFFIX ".san")
			target_link_options(global-env INTERFACE "/INFERASANLIBS")
			target_compile_options(global-env INTERFACE "/fsanitize=address")
		endif()

		target_link_options(global-env INTERFACE "/STACK:${__STACK_SIZE}")

	else()
		target_compile_options(global-env INTERFACE $<${IS_RELEASE_GEN_EXPR}:-msse2>)

		if (godot_dev_build)
			target_compile_options(global-env INTERFACE "-Wa,-mbig-obj")
		endif()

		if (godot_windows_subsystem STREQUAL "gui")
			target_link_options(global-env INTERFACE "-Wl,--subsystem,windows")
		else()
			target_link_options(global-env INTERFACE "-Wl,--subsystem,console")
			target_compile_definitions(global-env INTERFACE "WINDOWS_SUBSYSTEM_CONSOLE")
		endif()

		if (godot_use_static_cpp)
			target_link_options(global-env INTERFACE "-static")
			if (PROCESSOR_IS_X86_32)
				target_link_options(global-env INTERFACE "-static-libgcc" "-static-libstdc++")
			endif()
		endif()

		if (PROCESSOR_IS_X86_32 OR PROCESSOR_IS_X86_64)
			target_property(SET global-env X86_LIBTHEORA_OPT_GCC TRUE)
		endif()

		if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_property(APPEND_STR global-env EXTRA_SUFFIX ".llvm")
		endif()

		if (godot_lto STREQUAL "auto")
			set_parent_var(godot_lto "full")
		endif()

		if (NOT godot_lto STREQUAL "none")
			if (godot_lto STREQUAL "thin")
				assert(
					"ThinLTO is only compatible with LLVM, use clang compiler or `lto=full'."
					CMAKE_CXX_COMPILER_ID MATCHES "Clang"
				)

				target_compile_options(global-env INTERFACE "-flto=thin")
				target_link_options(global-env INTERFACE "-flto=thin")
			elseif (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang"
				AND godot_lto_jobs_count MATCHES "^[0-9]+$"
				AND godot_lto_jobs_count GREATER "1")

				target_compile_options(global-env INTERFACE "-flto")
				target_link_options(global-env INTERFACE "-flto=${godot_lto_jobs_count}")
			else()
				target_compile_options(global-env INTERFACE "-flto")
				target_link_options(global-env INTERFACE "-flto")
			endif()
		endif()

		target_link_options(global-env INTERFACE "-Wl,--stack,${__STACK_SIZE}")

		if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_compile_options(global-env INTERFACE "-mwindows")
		endif()

		target_compile_definitions(global-env INTERFACE
			"WINDOWS_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"WINVER=${godot_target_win_version}"
			"_WIN32_WINNT=${godot_target_win_version}"
		)

		target_link_libraries(global-env INTERFACE
			"mingw32"
			"dsound"
			"ole32"
			"d3d9"
			"winmm"
			"gdi32"
			"iphlpapi"
			"shlwapi"
			"wsock32"
			"ws2_32"
			"kernel32"
			"oleaut32"
			"sapi"
			"dinput8"
			"dxguid"
			"ksuser"
			"imm32"
			"bcrypt"
			"avrt"
			"uuid"
			"dwmapi"
			"dwrite"
			"wbemuuid"
		)

		if (godot_vulkan)
			target_compile_definitions(global-env INTERFACE "VULKAN_ENABLED")
			if (godot_use_volk)
				target_link_libraries(global-env INTERFACE "vulkan")
			endif()
		endif()

		if (godot_opengl3)
			target_compile_definitions(global-env INTERFACE "GLES3_ENABLED")
			target_link_libraries(global-env INTERFACE "opengl32")
		endif()

		target_compile_definitions(global-env INTERFACE
			"MINGW_ENABLED"
			"MINGW_HAS_SECURE_API=1"
		)

	endif()
endfunction()