get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set(__D3D12_DEPS_FOLDER "$ENV{LOCALAPPDATA}")
	if (NOT "${__D3D12_DEPS_FOLDER}" STREQUAL "")
		join_paths(__D3D12_DEPS_FOLDER "${__D3D12_DEPS_FOLDER}" "Godot/build_deps")
	else()
		set(__D3D12_DEPS_FOLDER "${ENGINE_SOURCE_DIR}/bin/build_deps")
	endif()

	set_string_option(godot_target_win_version "0x0601" DESCRIPTION "Targeted Windows version, >= 0x0601 (Windows 7).")
	set_string_option(godot_windows_subsystem "gui" DESCRIPTION "Windows subsystem." ENUM "gui" "console")
	set_bool_option(godot_use_static_cpp TRUE DESCRIPTION "Link MinGW/MSVC C++ runtime libraries statically.")
	set_bool_option(godot_use_asan FALSE DESCRIPTION "Use address sanitizer (ASAN).")
	set_bool_option(godot_debug_crt FALSE DESCRIPTION "Compile with MSVC's debug CRT (/MDd).")
	set_bool_option(godot_incremental_link FALSE DESCRIPTION "Use MSVC incremental linking. May increase or decrease build times.")
	set_path_option(godot_angle_libs "" DESCRIPTION "Path to the ANGLE static libraries")
	set_path_option(godot_mesa_libs "${__D3D12_DEPS_FOLDER}/mesa" DESCRIPTION "Path to the MESA/NIR static libraries (required for D3D12).")
	set_path_option(godot_agility_sdk_path "${__D3D12_DEPS_FOLDER}/agility_sdk" DESCRIPTION "Path to the Agility SDK distribution (optional for D3D12).")
	set_bool_option(godot_agility_sdk_multiarch FALSE DESCRIPTION "Whether the Agility SDK DLLs will be stored in arch-specific subdirectories.")
	set_bool_option(godot_use_pix FALSE DESCRIPTION "Use PIX (Performance tuning and debugging for DirectX 12) runtime.")
	set_path_option(godot_pix_path "${__D3D12_DEPS_FOLDER}/pix" DESCRIPTION "Path to the PIX runtime distribution (optional for D3D12).")

endfunction()

function(${__PLATFORM_NAME}_get_platform_name __OUTPUT)
	set("${__OUTPUT}" "Windows" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_platform_supported __OUTPUT)
	set("${__OUTPUT}" "mono" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_platform_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"EditorExportPlatformWindows"
		PARENT_SCOPE
	)
endfunction()

function(${__PLATFORM_NAME}_get_platform_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
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

	target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}/platform/windows")

	# To match other platforms
	set(__STACK_SIZE "8388608")

	if (MSVC)
		if (godot_target STREQUAL "template_release")
			target_link_options(global-env INTERFACE "/ENTRY:mainCRTStartup")
		endif()

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

		if (NOT godot_incremental_link)
			target_link_options(global-env INTERFACE "/INCREMENTAL:NO")
		endif()

		if(PROCESSOR_IS_X86_32)
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC TRUE)
		endif()

		target_compile_options(global-env INTERFACE
			"/fp:strict"
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

		if (godot_target_win_version LESS 0x0601)
			message(FATAL_ERROR "`godot_target_win_version` should be 0x0601 or higher (Windows 7).")
		endif()

		target_compile_definitions(global-env INTERFACE
			"WINDOWS_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"TYPED_METHOD_BIND"
			"WIN32"
			"WINVER=${godot_target_win_version}"
			"_WIN32_WINNT=${godot_target_win_version}"
			# disable bogus min/max WinDef.h macros
			"NOMINMAX"
		)

		if (PROCESSOR_IS_X86_64)
			target_compile_definitions(global-env INTERFACE "_WIN64")
		endif()

		set(__PREBUILT_LIB_EXTRA_SUFFIX "")
		if (godot_use_asan)
			target_property(APPEND_STR global-env EXTRA_SUFFIX ".san")
			target_compile_options(global-env INTERFACE "/fsanitize=address")
			target_link_options(global-env INTERFACE "/INFERASANLIBS")
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
			"Crypt32"
			"Avrt"
			"dwmapi"
			"dwrite"
			"wbemuuid"
			"ntdll"
		)

		if (DEBUG_FEATURES)
			target_link_libraries(global-env INTERFACE "psapi" "dbghelp")
		endif()

		if (godot_vulkan)
			target_compile_definitions(global-env INTERFACE "VULKAN_ENABLED" "RD_ENABLED")
			if (NOT godot_use_volk)
				target_link_libraries(global-env INTERFACE "vulkan")
			endif()
		endif()

		if (godot_d3d12)
			if (NOT EXISTS "${godot_mesa_libs}")
				message(FATAL_ERROR 
					"The Direct3D 12 rendering driver requires dependencies to be installed.\n\
					You can install them by running `python misc\\scripts\\install_d3d12_sdk_windows.py`.\n\
					See the documentation for more information:\n\t\
					https://docs.godotengine.org/en/latest/contributing/development/compiling/compiling_for_windows.html"
	            )
			endif()

			target_compile_definitions(global-env INTERFACE "D3D12_ENABLED" "RD_ENABLED")
			target_link_libraries(global-env INTERFACE "dxgi" "dxguid" "version")
			if (godot_target STREQUAL "template_release")
				target_compile_options(global-env INTERFACE /bigobj)
			endif()

			if (NOT PROCESSOR_ARCH_ALIAS MATCHES "(x86_64|arm64)" OR "${godot_pix_path}" STREQUAL "" OR NOT EXISTS "${godot_pix_path}")
				set_parent_var(godot_use_pix FALSE)
			endif()

			if (godot_use_pix)
				if (PROCESSOR_IS_ARM64)
					set(__ARCH_SUBDIR "arm64")
				else()
					set(__ARCH_SUBDIR "x64")
				endif()

				join_paths(__PIX_LIB_PATH "${godot_pix_path}" "bin/${__ARCH_SUBDIR}")
				target_link_directories(global-env INTERFACE "${__PIX_LIB_PATH}")
				target_link_libraries(global-env INTERFACE "WinPixEventRuntime")
			endif()

			join_paths(__MESA_LIB_PATH "${godot_mesa_libs}" "bin")
			target_link_directories(global-env INTERFACE "${__MESA_LIB_PATH}")
			target_link_libraries(global-env INTERFACE "libNIR.windows.${PROCESSOR_ARCH_ALIAS}${__PREBUILT_LIB_EXTRA_SUFFIX}")
		endif()

		if (godot_opengl3)
			target_compile_definitions(global-env INTERFACE "GLES3_ENABLED")
			if (NOT "${godot_angle_libs}" STREQUAL "")
				target_compile_definitions(global-env INTERFACE "EGL_STATIC")
				target_link_directories(global-env INTERFACE "${godot_angle_libs}")
				target_link_libraries(global-env INTERFACE
					"libANGLE.windows.${PROCESSOR_ARCH_ALIAS}${__PREBUILT_LIB_EXTRA_SUFFIX}"
					"libEGL.windows.${PROCESSOR_ARCH_ALIAS}${__PREBUILT_LIB_EXTRA_SUFFIX}"
					"libGLES.windows.${PROCESSOR_ARCH_ALIAS}${__PREBUILT_LIB_EXTRA_SUFFIX}"
					"dxgi"
					"d3d9"
					"d3d11"
				)
			endif()
			target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/angle/include")
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

		target_link_options(global-env INTERFACE
			"/STACK:${__STACK_SIZE}"
			"/NATVIS:platform\\windows\\godot.natvis"
		)

	else()
		if (NOT PROCESSOR_IS_ARM64 AND godot_target STREQUAL "template_release")
			target_compile_options(global-env INTERFACE "-msse2")
		endif()

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

		target_compile_options(global-env INTERFACE "-ffp-contract=off")

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

		if (godot_target_win_version LESS 0x0601)
			message(FATAL_ERROR "`godot_target_win_version` should be 0x0601 or higher (Windows 7).")
		endif()

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
			"crypt32"
			"avrt"
			"uuid"
			"dwmapi"
			"dwrite"
			"wbemuuid"
			"ntdll"
		)

		if (DEBUG_FEATURES)
			target_link_libraries(global-env INTERFACE "psapi" "dbghelp")
		endif()

		if (godot_vulkan)
			target_compile_definitions(global-env INTERFACE "VULKAN_ENABLED")
			if (godot_use_volk)
				target_link_libraries(global-env INTERFACE "vulkan")
			endif()
		endif()

		if (godot_d3d12)
			if (NOT EXISTS "${godot_mesa_libs}")
				message(FATAL_ERROR
					"The Direct3D 12 rendering driver requires dependencies to be installed.\n\
					You can install them by running `python misc\\scripts\\install_d3d12_sdk_windows.py`.\n\
					See the documentation for more information:\n\t\
					https://docs.godotengine.org/en/latest/contributing/development/compiling/compiling_for_windows.html"
				)
			endif()

			target_compile_definitions(global-env INTERFACE "D3D12_ENABLED" "RD_ENABLED")
			target_link_libraries(global-env INTERFACE "dxgi" "dxguid")
			
			if (NOT PROCESSOR_ARCH_ALIAS MATCHES "(x86_64|arm64)" OR "${godot_pix_path}" STREQUAL "" OR NOT EXISTS "${godot_pix_path}")
				set_parent_var(godot_use_pix FALSE)
			endif()
			
			if (godot_use_pix)
				if (PROCESSOR_IS_ARM64)
					set(__ARCH_SUBDIR "arm64")
				else()
					set(__ARCH_SUBDIR "x64")
				endif()

				join_paths(__PIX_LIB_PATH "${godot_pix_path}" "bin/${__ARCH_SUBDIR}")
				target_link_directories(global-env INTERFACE "${__PIX_LIB_PATH}")
				target_link_libraries(global-env INTERFACE "WinPixEventRuntime")
			endif()

			join_paths(__MESA_LIB_PATH "${godot_mesa_libs}" "bin")
			target_link_directories(global-env INTERFACE "${__MESA_LIB_PATH}")
			target_link_libraries(global-env INTERFACE
				"libNIR.windows.${PROCESSOR_ARCH_ALIAS}"
				# Mesa dependency.
				"version"
			)

		endif()

		if (godot_opengl3)
			target_compile_definitions(global-env INTERFACE "GLES3_ENABLED")
			if (NOT "${godot_angle_libs}" STREQUAL "")
				target_compile_definitions(global-env INTERFACE "EGL_STATIC")
				target_link_directories(global-env INTERFACE "${godot_angle_libs}")
				target_link_libraries(global-env INTERFACE
					"EGL.windows.${PROCESSOR_ARCH_ALIAS}"
					"GLES.windows.${PROCESSOR_ARCH_ALIAS}"
					"ANGLE.windows.${PROCESSOR_ARCH_ALIAS}"
					"dxgi"
					"d3d9"
					"d3d11"
				)
			endif()
			target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/angle/include")
		endif()

		target_compile_definitions(global-env INTERFACE
			"MINGW_ENABLED"
			"MINGW_HAS_SECURE_API=1"
		)

	endif()
endfunction()