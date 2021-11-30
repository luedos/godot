get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set_string_option(GODOT_TARGET_WIN_VERSION "0x0601" DESCRIPTION "Targeted Windows version, >= 0x0601 (Windows 7)")
	set_bool_option(GODOT_USE_STATIC_CPP TRUE DESCRIPTION "Link MinGW/MSVC C++ runtime libraries statically.")
	set_bool_option(GODOT_USE_ASAN FALSE DESCRIPTION "Use address sanitizer (ASAN).")
endfunction()

function(${__PLATFORM_NAME}_get_platform_name __OUTPUT)
	set("${__OUTPUT}" "Windows" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_is_platform_active __OUTPUT)
	set("${__OUTPUT}" true PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_can_platform_build __OUTPUT)

	#TODO: retest all scons logic (like Cross-compiling with MinGW-w64 is not supported),
	# because I'm not sure If this will be the case for cmake, or if cmake will not find this by it's own
	set("${__OUTPUT}" true PARENT_SCOPE)

endfunction()

# set(IS_OPTIMIZED_GEN_EXPR      $<CONFIG:Release,MinSizeRel,RelWithDebInfo>)
# set(IS_RELEASE_GEN_EXPR        $<CONFIG:Release,MinSizeRel>)
# set(IS_DEBUG_INFO_GEN_EXPR     $<CONFIG:Debug,RelWithDebInfo>)
# set(IS_DEBUG_GEN_EXPR          $<CONFIG:Debug>)
# set(IS_OPT_DEBUG_GEN_EXPR      $<CONFIG:RelWithDebInfo>)

function(${__PLATFORM_NAME}_configure_platform)
	
	target_include_directories(global-env INTERFACE "${GODOT_SOURCE_DIR}/platform/windows")

	if(MSVC)

		#TODO: need to do exctensive testing for all these options, because I'm sure that half of them cmake sets by default
		target_link_options(global-env INTERFACE 
			$<${IS_RELEASE_GEN_EXPR}:/SUBSYSTEM:WINDOWS;/ENTRY:mainCRTStartup;/OPT:REF>
			$<${IS_OPT_DEBUG_GEN_EXPR}:/SUBSYSTEM:CONSOLE;/OPT:REF>
			$<${IS_DEBUG_GEN_EXPR}:/SUBSYSTEM:CONSOLE>
			$<${IS_DEBUG_INFO_GEN_EXPR}:/DEBUG>
			"/STACK:8388608"
		)

		target_compile_options(global-env INTERFACE
			$<$<CONFIG:Release>:/O2>
			$<$<CONFIG:MinSizeRel>:/O1>
			$<${IS_DEBUG_INFO_GEN_EXPR}:/Zi;/FS>
			$<${IS_OPT_DEBUG_GEN_EXPR}:/O2>
			$<${IS_DEBUG_GEN_EXPR}:/Od;/EHsc>
			"/Gd"
			"/GR"
			"/nologo"
			# Force to use Unicode encoding
			"/utf-8"
			# assume all sources are C++
			$<$<COMPILE_LANGUAGE:CXX>:/TP>
		)

		if(GODOT_USE_STATIC_CPP)
			target_compile_options(global-env INTERFACE "/MT")
		else()
			target_compile_options(global-env INTERFACE "/MD")
		endif()

		if(MSVC_VERSION GREATER_EQUAL "1910") # vs2015 and later
			target_compile_options(global-env INTERFACE
			)
		endif()

		target_compile_definitions(global-env INTERFACE		
			"WINDOWS_ENABLED"
			"OPENGL_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"TYPED_METHOD_BIND"
			"WIN32"
			"MSVC"
			"WINVER=${GODOT_TARGET_WIN_VERSION}"
			"_WIN32_WINNT=${GODOT_TARGET_WIN_VERSION}"
			"NOMINMAX" # disable bogus min/max WinDef.h macros
		)

		if(PROCESSOR_BITS EQUAL 64)
			target_compile_definitions(global-env INTERFACE	"_WIN64")
		endif()

		target_link_libraries(global-env INTERFACE
			"winmm"
			"opengl32"
			"dsound"
			"kernel32"
			"ole32"
			"oleaut32"
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
		)

		if(GODOT_USE_LTO)
			target_compile_options(global-env INTERFACE "/GL")
			target_link_options("/LTCG")
		endif()

		if(GODOT_USE_ASAN)
			target_link_options(global-env INTERFACE "/INFERASANLIBS")
			target_compile_options(global-env INTERFACE "/fsanitize=address")
		endif()

		if(PROCESSOR_BITS EQUAL 64)
			# If building for 64bit architecture, disable assembly optimisations for 32 bit builds (theora as of writing)... vc compiler for 64bit can not compile _asm
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC false)
		else()
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC true)
		endif()
	
	else()
		
		target_link_options(global-env INTERFACE 
			$<${IS_RELEASE_GEN_EXPR}:-Wl$<COMMA>--subsystem$<COMMA>windows>			
			"-Wl,--stack,8388608"
			"-Wl,--nxcompat" # DEP protection. Not enabling ASLR for now, Mono crashes.
		)
		if(GODOT_USE_STATIC_CPP)
			if(PROCESSOR_BITS EQUAL 32)
				target_link_options(global-env INTERFACE 
					"-static"
					"-static-libgcc"
					"-static-libstdc++"
				)
			else()
				target_link_options(global-env INTERFACE 
					"-static"
				)
			endif()
		endif()

		target_compile_options(global-env INTERFACE
			$<$<CONFIG:Release>:-msse2;$<IF:$<EQUAL:${PROCESSOR_BITS},64>,-O3,-O2>>
			$<$<CONFIG:MinSizeRel>:-Os>
			$<${IS_OPT_DEBUG_GEN_EXPR}:-O2;-g2>
			$<${IS_DEBUG_GEN_EXPR}:-g3>
			"-mwindows"			
		)

		if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
			set(GODOT_SPLIT_LIBMODULES TRUE PARENT_SCOPE)
		endif()


		if(GODOT_USE_LTO)
			if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang" 
				AND GODOT_LTO_JOBS_COUNT MATCHES "^[0-9]+$" # check that GODOT_LTO_JOBS_COUNT is a valid number
				AND GODOT_LTO_JOBS_COUNT GREATER "1")
				target_compile_options(global-env INTERFACE "-flto")
				target_link_options(global-env INTERFACE "-flto=${GODOT_LTO_JOBS_COUNT}")
			else()
				if(GODOT_USE_THINLTO)
					target_compile_options(global-env INTERFACE "-flto=thin")
					target_link_options(global-env INTERFACE "-flto=thin")
				else()
					target_compile_options(global-env INTERFACE "-flto")
					target_link_options(global-env INTERFACE "-flto")
				endif()
			endif()
		endif()

		target_compile_definitions(global-env INTERFACE		
			"WINDOWS_ENABLED"
			"OPENGL_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"WINVER=${GODOT_TARGET_WIN_VERSION}"
			"_WIN32_WINNT=${GODOT_TARGET_WIN_VERSION}"
			"MINGW_ENABLED"
			"MINGW_HAS_SECURE_API=1"
		)

		target_link_libraries(global-env INTERFACE
			"mingw32"
			"opengl32"
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
			"dinput8"
			"dxguid"
			"ksuser"
			"imm32"
			"bcrypt"
			"avrt"
			"uuid"
			"dwmapi"
		)

		set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_GCC TRUE)
	endif()

endfunction()
