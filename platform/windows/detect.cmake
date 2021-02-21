get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

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

function(${__PLATFORM_NAME}_configure_platform)
	
	target_include_directories(global-env INTERFACE "${GODOT_SOURCE_DIR}/platform/windows")

	if(MSVC)
		
	else()
	endif()


	if(MSVC)

		#TODO: need to do exctensive testing for all these options, because I'm sure that half of them cmake sets by default
		target_link_options(global-env INTERFACE 
			$<$<CONFIG:Release,MinSizeRel>:
				"/SUBSYSTEM:WINDOWS"
				"/ENTRY:mainCRTStartup"
				"/OPT:REF"
			>
			$<$<CONFIG:RelWithDebInfo,ToolsRelWithDebInfo>:
				"/SUBSYSTEM:CONSOLE"
				"/OPT:REF"
			>
			$<$<CONFIG:Debug,ToolsDebug>:
				"/SUBSYSTEM:CONSOLE"
				"/DEBUG"
			>
			"/STACK:8388608"
		)

		target_compile_options(global-env INTERFACE
			$<$<CONFIG:Release>:
				"/O2"
			>
			$<$<CONFIG:MinSizeRel>:
				"/O1"
			>
			$<$<CONFIG:RelWithDebInfo,ToolsRelWithDebInfo>:
				"/O2"
			>
			$<$<CONFIG:Debug,ToolsDebug>:
				"/Z7"
				"/Od"
				"/EHsc"
			>
			"/MT"
			"/Gd"
			"/GR"
			"/nologo"
			$<$<COMPILE_LANGUAGE:CXX>: # assume all sources are C++
				"/TP"
			>
		)

		if(MSVC_VERSION GREATER_EQUAL "1910") # vs2015 and later
			target_compile_options(global-env INTERFACE
				"/utf-8"
			)
		endif()

		target_compile_definitions(global-env INTERFACE
			$<$<CONFIG:RelWithDebInfo,ToolsRelWithDebInfo,Debug,ToolsDebug>:
				"DEBUG_ENABLED"
			>			
			"WINDOWS_ENABLED"
			"OPENGL_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			"TYPED_METHOD_BIND"
			# those ones (in theory) sould be defined by default
			"WIN32"
			"MSVC"
			# "WINVER="
			# "_WIN32_WINNT="
			"NOMINMAX" # disable bogus min/max WinDef.h macros
		)

		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			target_compile_definitions(global-env INTERFACE
				"_WIN64"
			)
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

		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			# If building for 64bit architecture, disable assembly optimisations for 32 bit builds (theora as of writing)... vc compiler for 64bit can not compile _asm
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC false)
		else()
			set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_VC true)
		endif()
	
	else()
		
		target_link_options(global-env INTERFACE 
			$<$<CONFIG:Release,MinSizeRel>:				
				"-Wl,--subsystem,windows"
			>
			$<IF:
				$<EQUAL:${CMAKE_SIZEOF_VOID_P},4>,
				"-static" "-static-libgcc" "-static-libstdc++",
				"-static"
			>			
			"-Wl,--stack,8388608"
		)

		target_compile_options(global-env INTERFACE
			$<$<CONFIG:Release>:
				"-msse2"
				$<IF:
					$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,
					"-O3",
					"-O2"
				>
			>
			$<$<CONFIG:MinSizeRel>:
				"-Os"
			>
			$<$<CONFIG:RelWithDebInfo,ToolsRelWithDebInfo>:
				"-O2"
				"-g2"
			>
			$<$<CONFIG:Debug,ToolsDebug>:
				"-g3"
			>
			"-mwindows"			
		)

		target_compile_definitions(global-env INTERFACE
			$<$<CONFIG:RelWithDebInfo,ToolsRelWithDebInfo,Debug,ToolsDebug>:
				"DEBUG_ENABLED"
			>			
			"WINDOWS_ENABLED"
			"OPENGL_ENABLED"
			"WASAPI_ENABLED"
			"WINMIDI_ENABLED"
			# those ones (in theory) sould be defined by default
			# "WINVER="
			# "_WIN32_WINNT="
			"NOMINMAX" # disable bogus min/max WinDef.h macros
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

		set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_GCC false)
	endif()

endfunction()






function(${__PLATFORM_NAME}_configure_module)
	# does nothing
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if (GODOT_PLATFORM STREQUAL "iphone")
		set(${__OUTPUT} true PARENT_SCOPE)
	else()
		set(${__OUTPUT} false PARENT_SCOPE)
	endif()
endfunction()