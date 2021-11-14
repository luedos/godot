get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set_bool_option(GODOT_USE_THINLTO               FALSE   DESCRIPTION "Use ThinLTO")
	set_bool_option(GODOT_USE_STATIC_CPP            FALSE   DESCRIPTION "Link libgcc and libstdc++ statically for better portability")
	set_bool_option(GODOT_USE_UBSAN                 FALSE   DESCRIPTION "Use LLVM/GCC compiler undefined behavior sanitizer (UBSAN)")
	set_bool_option(GODOT_USE_ASAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler address sanitizer (ASAN))")
	set_bool_option(GODOT_USE_LSAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler leak sanitizer (LSAN))")
	set_bool_option(GODOT_USE_TSAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler thread sanitizer (TSAN))")
	set_bool_option(GODOT_PULSEAUDIO                TRUE    DESCRIPTION "Detect and use PulseAudio")
	set_bool_option(GODOT_UDEV                      FALSE   DESCRIPTION "Use udev for gamepad connection callbacks")
	set_string_option(GODOT_DEBUG_SYMBOLS           "yes"   ENUM "yes" "no" "full" DESCRIPTION "Add debugging symbols to release builds")
	set_bool_option(GODOT_SEPARATE_DEBUG_SYMBOLS    FALSE   DESCRIPTION "Create a separate file containing debugging symbols")
	set_bool_option(GODOT_TOUCH                     TRUE    DESCRIPTION "Enable touch events")
	set_bool_option(GODOT_EXECINFO                  FALSE   DESCRIPTION "Use libexecinfo on systems where glibc is not available")

endfunction()

function(${__PLATFORM_NAME}_get_platform_name __OUTPUT)
	set("${__OUTPUT}" "X11" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_is_platform_active __OUTPUT)
	set("${__OUTPUT}" true PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_can_platform_build __OUTPUT)

	macro(__check_pkg_config_module __NAME)
		pkg_check_modules("${__NAME}_MODULE" ${__NAME})
		if (NOT ${__NAME}_MODULE_FOUND)
			set("${__OUTPUT}" FALSE PARENT_SCOPE)
			return()
		endif()
	endmacro()

	# pkg-config is required
	if (NOT PKG_CONFIG_FOUND)
		set("${__OUTPUT}" FALSE PARENT_SCOPE)
		return()
	endif()

	__check_pkg_config_module(x11)
	__check_pkg_config_module(xcursor)
	__check_pkg_config_module(xinerama)
	__check_pkg_config_module(xrandr)
	__check_pkg_config_module(xrender)
	__check_pkg_config_module(xi)

	set("${__OUTPUT}" TRUE PARENT_SCOPE)

endfunction()

function(${__PLATFORM_NAME}_configure_platform)
	
	target_compile_options(global-env INTERFACE
		$<${IS_OPTIMIZED_GEN_EXPR}:$<$<STREQUAL:${GODOT_DEBUG_SYMBOLS},yes>:-g1>$<$<STREQUAL:${GODOT_DEBUG_SYMBOLS},full>:-g2>>
		$<${IS_DEBUG_GEN_EXPR}:-g3>
	)
	target_compile_definitions(global-env INTERFACE
		$<${IS_DEBUG_INFO_GEN_EXPR}:DEBUG_ENABLED>
	)
	target_link_options(global-env INTERFACE
		$<${IS_DEBUG_GEN_EXPR}:-rdynamic>
	)

	if (GODOT_USE_UBSAN)
		target_compile_options(global-env INTERFACE "-fsanitize=undefined")
		target_link_options(global-env INTERFACE "-fsanitize=undefined")
	endif()

	if (GODOT_USE_ASAN)
		target_compile_options(global-env INTERFACE "-fsanitize=address")
		target_link_options(global-env INTERFACE "-fsanitize=address")
	endif()

	if (GODOT_USE_LSAN)
		target_compile_options(global-env INTERFACE "-fsanitize=leak")
		target_link_options(global-env INTERFACE "-fsanitize=leak")
	endif()

	if (GODOT_USE_TSAN)
		target_compile_options(global-env INTERFACE "-fsanitize=thread")
		target_link_options(global-env INTERFACE "-fsanitize=thread")
	endif()

	target_compile_options(global-env INTERFACE "-pipe")
	target_link_options(global-env INTERFACE "-pipe")
	
	if ((CMAKE_CXX_COMPILER_ID MATCHES Clang AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4)
		OR (CMAKE_CXX_COMPILER_ID MATCHES GNU AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 6))
	
		target_compile_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fpie>)
		target_link_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-no-pie>)
	endif()

	if ((CMAKE_C_COMPILER_ID MATCHES Clang AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4)
		OR (CMAKE_C_COMPILER_ID MATCHES GNU AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 6))
	
		target_compile_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:C>:-fpie>)
		target_link_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:C>:-no-pie>)
	endif()

	target_append_pkg_config(global-env INTERFACE 
		ALL 
		x11 xcursor xinerama xrandr xrender xi
	)

	if (GODOT_TOUCH)
		target_compile_definitions(global-env INTERFACE "TOUCH_ENABLED")
	endif()

	if(GODOT_BUILTIN_FREETYPE OR GODOT_BUILTIN_LIBPNG OR GODOT_BUILTIN_ZLIB)
		set(GODOT_BUILTIN_FREETYPE  TRUE CACHE BOOL "" FORCE)
		set(GODOT_BUILTIN_LIBPNG    TRUE CACHE BOOL "" FORCE)
		set(GODOT_BUILTIN_ZLIB      TRUE CACHE BOOL "" FORCE)
	endif()

	if (NOT GODOT_BUILTIN_LIBPNG)
		target_append_pkg_config(global-env INTERFACE ALL freetype2)
	endif()

	if (NOT GODOT_BUILTIN_LIBPNG)
		target_append_pkg_config(global-env INTERFACE ALL libpng16)
	endif()

	if (NOT GODOT_BUILTIN_BULLET)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED bullet>2.89)
	endif()

	if (NOT GODOT_BUILTIN_ENET)
		target_append_pkg_config(global-env INTERFACE ALL libenet)
	endif()
	
	if (NOT GODOT_BUILTIN_SQUISH)
		target_append_pkg_config(global-env INTERFACE ALL libsquish)
	endif()

	if (NOT GODOT_BUILTIN_ZSTD)
		target_append_pkg_config(global-env INTERFACE ALL libzstd)
	endif()

	if(NOT GODOT_BUILTIN_LIBTHEORA)
		set(GODOT_BUILTIN_LIBOGG    FALSE CACHE BOOL "" FORCE)
		set(GODOT_BUILTIN_LIBVORBIS FALSE CACHE BOOL "" FORCE)
		target_append_pkg_config(global-env INTERFACE ALL theora theoradec)
	elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86_64|x86|i386|i586)")
		set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_GCC TRUE)
	endif()

	if(NOT GODOT_BUILTIN_LIBVPX)
		target_append_pkg_config(global-env INTERFACE ALL vpx)
	endif()

	if(NOT GODOT_BUILTIN_LIBVORBIS)
		set(GODOT_BUILTIN_LIBOGG FALSE CACHE BOOL "" FORCE)
		target_append_pkg_config(global-env INTERFACE ALL vorbis vorbisfile)
	endif()

	if(NOT GODOT_BUILTIN_LIBOGG)
		target_append_pkg_config(global-env INTERFACE ALL ogg)
	endif()

	if(NOT GODOT_BUILTIN_LIBWEBP)
		target_append_pkg_config(global-env INTERFACE ALL libwebp)
	endif()

	if(NOT GODOT_BUILTIN_MBEDTLS)
		# mbedTLS does not provide a pkgconfig config yet. See https://github.com/ARMmbed/mbedtls/issues/228
		target_link_libraries(global-env INTERFACE 
			"mbedtls"
			"mbedcrypto"
			"mbedx509"
		)
	endif()

	if(NOT GODOT_BUILTIN_WSLAY)
		target_append_pkg_config(global-env INTERFACE ALL libwslay)
	endif()

	if(NOT GODOT_BUILTIN_MINIUPNPC)
		# No pkgconfig file so far, hardcode default paths.
		target_include_directories(global-env INTERFACE "/usr/include/miniupnpc")
		target_link_libraries(global-env INTERFACE "miniupnpc")
	endif()
	
	# On Linux wchar_t should be 32-bits
	# 16-bit library shouldn't be required due to compiler optimisations
	if (NOT GODOT_BUILTIN_PREC2)
		target_append_pkg_config(global-env INTERFACE ALL libpcre2-32)      
	endif()

	check_pkg_exist(__ALSA_EXIST alsa)
	if(__ALSA_EXIST)
		message(STATUS "Enabling ALSA")
		target_compile_definitions(global-env INTERFACE 
			"ALSA_ENABLED" 
			"ALSAMIDI_ENABLED"
		)
		target_append_pkg_config(global-env INTERFACE ALL_LDFLAGS
			alsa
		)
	else()
		message(STATUS "ALSA libraries not found, disabling driver")
	endif()

	if (GODOT_PULSEAUDIO)
		check_pkg_exist(__PULSE_EXIST libpulse)
		if (__PULSE_EXIST)
			message(STATUS "Enabling PulseAudio")
			target_compile_definitions(global-env INTERFACE 
				"PULSEAUDIO_ENABLED" 
			)
			target_append_pkg_config(global-env INTERFACE ALL
				libpulse
			)
		else()
			message(STATUS "PulseAudio development libraries not found, disabling driver")
		endif()
	endif()

	if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		target_compile_definitions(global-env INTERFACE "JOYDEV_ENABLED")
	
		if (GODOT_UDEV)
			check_pkg_exist(__UDEV_EXIST libudev)
			if (__UDEV_EXIST)
				message(STATUS "Enabling udev support")
				target_compile_definitions(global-env INTERFACE 
					"UDEV_ENABLED" 
				)
				target_append_pkg_config(global-env INTERFACE ALL
					libudev
				)				
			else()
				message(STATUS "libudev development libraries not found, disabling udev support")
			endif()
		endif()
	endif()

	if (NOT GODOT_BUILTIN_ZLIB)
		target_append_pkg_config(global-env INTERFACE ALL
			zlib
		)	
	endif()

	target_include_directories(global-env INTERFACE "${GODOT_SOURCE_DIR}/platform/x11")
	target_compile_definitions(global-env INTERFACE
		"X11_ENABLED"
		"UNIX_ENABLED"
		"OPENGL_ENABLED"
		"GLES_ENABLED"
	)
	target_link_libraries(global-env INTERFACE 
		"GL"
		"pthread"
	)

	if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		target_link_libraries(global-env INTERFACE "dl")
	endif()

	if (CMAKE_HOST_SYSTEM_NAME MATCHES "BSD")
		set(GODOT_EXECINFO TRUE CACHE BOOL "" FORCE)
	endif()

	if (GODOT_EXECINFO)
		target_link_libraries(global-env INTERFACE "execinfo")
	endif()

	if (NOT GODOT_BUILD_TOOLS)
		#TODO: make use of template binaries
	endif()

	if (NOT CMAKE_SYSTEM_PROCESSOR STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
		if (CMAKE_SIZEOF_VOID_P EQUAL 8)
			target_compile_options(global-env INTERFACE "-m64")
			target_link_options(global-env INTERFACE "-m64")
		else()
			target_compile_options(global-env INTERFACE "-m32")
			target_link_options(global-env INTERFACE "-m32")
		endif()
	endif()

	if (GODOT_USE_STATIC_CPP)
		target_link_options(global-env INTERFACE 
			"-static-libgcc"
			"-static-libstdc++"
		)
	endif()

endfunction()


function(${__PLATFORM_NAME}_get_program_suffix __OUTPUT)

	set(__RET "x11")

	if (GODOT_USE_UBSAN OR GODOT_USE_ASAN OR GODOT_USE_LSAN OR GODOT_USE_TSAN)
		set(__RET "${__RET}.s")
	endif()

	set("${__OUTPUT}" "${__RET}" PARENT_SCOPE)

endfunction()