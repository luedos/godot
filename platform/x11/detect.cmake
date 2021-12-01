get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set_bool_option(GODOT_USE_LLD					FALSE	DESCRIPTION "Use the LLD linker")
	set_bool_option(GODOT_USE_THINLTO               FALSE   DESCRIPTION "Use ThinLTO")
	set_bool_option(GODOT_USE_STATIC_CPP            TRUE    DESCRIPTION "Link libgcc and libstdc++ statically for better portability")
	set_bool_option(GODOT_USE_UBSAN                 FALSE   DESCRIPTION "Use LLVM/GCC compiler undefined behavior sanitizer (UBSAN)")
	set_bool_option(GODOT_USE_ASAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler address sanitizer (ASAN))")
	set_bool_option(GODOT_USE_LSAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler leak sanitizer (LSAN))")
	set_bool_option(GODOT_USE_TSAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler thread sanitizer (TSAN))")
	set_bool_option(GODOT_USE_MSAN                  FALSE   DESCRIPTION "Use LLVM/GCC compiler memory sanitizer (MSAN))")
	set_bool_option(GODOT_PULSEAUDIO                TRUE    DESCRIPTION "Detect and use PulseAudio")
	set_bool_option(GODOT_UDEV                      TRUE    DESCRIPTION "Use udev for gamepad connection callbacks")
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

	macro(__check_pkg_config_module __NAME __ERROR_MESSAGE)
		pkg_check_modules("${__NAME}_MODULE" ${__NAME})
		if (NOT ${__NAME}_MODULE_FOUND)
			set("${__OUTPUT}" FALSE PARENT_SCOPE)
			if(NOT "${__ERROR_MESSAGE}" STREQUAL "")
				message("${__ERROR_MESSAGE}")
			endif()
			return()
		endif()
	endmacro()

	# pkg-config is required
	if (NOT PKG_CONFIG_FOUND)
		set("${__OUTPUT}" FALSE PARENT_SCOPE)
		message("Error: pkg-config not found. Aborting.")
		return()
	endif()

	__check_pkg_config_module(x11 "Error: X11 libraries not found. Aborting.")
	__check_pkg_config_module(xcursor "Error: Xcursor library not found. Aborting.")
	__check_pkg_config_module(xinerama "Error: Xinerama library not found. Aborting.")
	__check_pkg_config_module(xext "Error: Xext library not found. Aborting.")
	__check_pkg_config_module(xrandr "Error: XrandR library not found. Aborting.")
	__check_pkg_config_module(xrender "Error: XRender library not found. Aborting.")
	__check_pkg_config_module(xi "Error: Xi library not found. Aborting.")

	set("${__OUTPUT}" TRUE PARENT_SCOPE)

endfunction()

function(${__PLATFORM_NAME}_configure_platform)
	
	# We will modify extra suffix in this configuration, so, to not repeat getting parameter all the time
	# we will simply get it once, and then set it back at the end of the script.
	get_target_property(__EXTRA_SUFFIX global-env EXTRA_SUFFIX)

	target_compile_options(global-env INTERFACE
		# Optimised for size
		$<$<CONFIG:MinSizeRel>:-Os>
		# Full on release
		$<$<CONFIG:Release>:-O3>

		# Debug symbols
		$<${IS_OPT_DEBUG_GEN_EXPR}:-g2>
		$<${IS_DEBUG_GEN_EXPR}:-g3>

		# Special flag for gdb debugger
		$<${IS_DEBUG_GEN_EXPR}:-ggdb>
	)
	target_link_options(global-env INTERFACE
		$<${IS_DEBUG_GEN_EXPR}:-rdynamic>
	)

	cmake_host_system_information(RESULT __IS_HOST_64BITS QUERY IS_64BIT)
	# Just because I'm random perfectionist, we will transform 1/0 into TRUE/FALSE
	if(__IS_HOST_64BITS EQUAL 1)
		set(__IS_HOST_64BITS TRUE)
	else()
		set(__IS_HOST_64BITS FALSE)
	endif()

	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		# I don't know why this particular suffix is prefix for suffixes.
		set(__EXTRA_SUFFIX ".llvm${__EXTRA_SUFFIX}")
	endif()

	if(PROCESSOR_IS_RISCV)
		target_compile_options(global-env INTERFACE "-march=rv64gc")
	endif()

	if(GODOT_USE_LLD)
		if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_link_options(global-env INTERFACE "-fuse-ld=lld")
			if(GODOT_USE_THINLTO)
                # A convenience so you don't need to write GODOT_USE_LTO too
                # It is mostly a crutch, to rely that this function will be called from main cmake file,
                # and this option actually will be setted in correct scope, but it is also not recomended to use
                # force_set_option, because it will not be seted back, if we reconfigure project with
                # GODOT_USE_THINLTO == FALSE
                set_parent_var(GODOT_USE_LTO TRUE)
			endif()
		else()
			message(FATAL_ERROR "Using LLD with GCC is not supported yet. Try specify the Clang compiler.")
		endif()
	endif()

	if(GODOT_USE_UBSAN OR GODOT_USE_ASAN OR GODOT_USE_LSAN OR GODOT_USE_TSAN OR GODOT_USE_MSAN)
		set(__EXTRA_SUFFIX "${__EXTRA_SUFFIX}.s")

		if (GODOT_USE_UBSAN)
			target_compile_options(global-env INTERFACE "-fsanitize=undefined,shift,shift-exponent,integer-divide-by-zero,unreachable,vla-bound,null,return,signed-integer-overflow,bounds,float-divide-by-zero,float-cast-overflow,nonnull-attribute,returns-nonnull-attribute,bool,enum,vptr,pointer-overflow,builtin")
			if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
				target_compile_options(global-env INTERFACE "-fsanitize=nullability-return,nullability-arg,function,nullability-assign,implicit-integer-sign-change,implicit-signed-integer-truncation,implicit-unsigned-integer-truncation")
			else()
				target_compile_options(global-env INTERFACE "-fsanitize=bounds-strict")
			endif()
		endif()

		target_link_options(global-env INTERFACE "-fsanitize=undefined")

		if (GODOT_USE_ASAN)
			target_compile_options(global-env INTERFACE "-fsanitize=address,pointer-subtract,pointer-compare")
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

		if(GODOT_USE_MSAN)
			target_compile_options(global-env INTERFACE "-fsanitize=memory")
			target_link_options(global-env INTERFACE "-fsanitize=memory")
		endif()
	endif()

	if(GODOT_USE_LTO)
		if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang" 
			AND GODOT_LTO_JOBS_COUNT MATCHES "^[0-9]+$" # check that GODOT_LTO_JOBS_COUNT is a valid number
			AND GODOT_LTO_JOBS_COUNT GREATER "1")
			target_compile_options(global-env INTERFACE "-flto")
			target_link_options(global-env INTERFACE "-flto=${GODOT_LTO_JOBS_COUNT}")
		else()
			if(GODOT_USE_LLD AND GODOT_USE_THINLTO)
				target_compile_options(global-env INTERFACE "-flto=thin")
				target_link_options(global-env INTERFACE "-flto=thin")
			else()
				target_compile_options(global-env INTERFACE "-flto")
				target_link_options(global-env INTERFACE "-flto")
			endif()
		endif()
	endif()

	target_compile_options(global-env INTERFACE "-pipe")
	target_link_options(global-env INTERFACE "-pipe")
	
	if ((CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4)
		OR (CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 6))
	
		target_compile_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fpie>)
		target_link_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-no-pie>)
	endif()

	if ((CMAKE_C_COMPILER_ID MATCHES "Clang" AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4)
		OR (CMAKE_C_COMPILER_ID MATCHES "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 6))
	
		target_compile_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:C>:-fpie>)
		target_link_options(global-env INTERFACE $<$<COMPILE_LANGUAGE:C>:-no-pie>)
	endif()

	target_append_pkg_config(global-env INTERFACE 
		ALL 
		x11 xcursor xinerama xext xrandr xrender xi
	)

	if (GODOT_TOUCH)
		target_compile_definitions(global-env INTERFACE "TOUCH_ENABLED")
	endif()

	if(GODOT_BUILTIN_FREETYPE OR GODOT_BUILTIN_LIBPNG OR GODOT_BUILTIN_ZLIB)
		set_parent_var(GODOT_BUILTIN_FREETYPE  TRUE)
		set_parent_var(GODOT_BUILTIN_LIBPNG    TRUE)
		set_parent_var(GODOT_BUILTIN_ZLIB      TRUE)
	endif()

	if (NOT GODOT_BUILTIN_LIBPNG)
		target_append_pkg_config(global-env INTERFACE ALL freetype2)
	endif()

	if (NOT GODOT_BUILTIN_LIBPNG)
		target_append_pkg_config(global-env INTERFACE ALL libpng16)
	endif()

	if (NOT GODOT_BUILTIN_BULLET)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED bullet>=2.90)
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
		set_parent_var(GODOT_BUILTIN_LIBOGG    FALSE)
		set_parent_var(GODOT_BUILTIN_LIBVORBIS FALSE)
		target_append_pkg_config(global-env INTERFACE ALL theora theoradec)
	elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86_64|AMD64|amd64|x86|i386|i586)")
		set_target_properties(global-env PROPERTIES X86_LIBTHEORA_OPT_GCC TRUE)
	endif()

	if(NOT GODOT_BUILTIN_LIBVPX)
		target_append_pkg_config(global-env INTERFACE ALL vpx)
	endif()

	if(NOT GODOT_BUILTIN_LIBVORBIS)
		set_parent_var(GODOT_BUILTIN_LIBOGG FALSE)
		target_append_pkg_config(global-env INTERFACE ALL vorbis vorbisfile)
	endif()

	if(NOT GODOT_BUILTIN_OPUS)
		set_parent_var(GODOT_BUILTIN_LIBOGG FALSE)
		target_append_pkg_config(global-env INTERFACE ALL opus opusfile)
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

	if(GODOT_BUILD_TOOLS AND NOT GODOT_BUILTIN_EMBREE AND __IS_HOST_64BITS)
		target_link_libraries(global-env INTERFACE "embree3")
	endif()

	check_pkg_exist(__ALSA_EXIST alsa)
	if(__ALSA_EXIST)
		target_compile_definitions(global-env INTERFACE 
			"ALSA_ENABLED" 
			"ALSAMIDI_ENABLED"
		)
		set_target_properties(global-env PROPERTIES ALSA TRUE)
	else()
		message(WARNING "Warning: ALSA libraries not found. Disabling the ALSA audio driver.")
		set_target_properties(global-env PROPERTIES ALSA FALSE)
	endif()

	if (GODOT_PULSEAUDIO)
		check_pkg_exist(__PULSE_EXIST libpulse)
		if (__PULSE_EXIST)
			target_compile_definitions(global-env INTERFACE "PULSEAUDIO_ENABLED")
			target_append_pkg_config(global-env INTERFACE ALL_CFLAGS libpulse)
		else()
			message(WARNING "Warning: PulseAudio development libraries not found. Disabling the PulseAudio audio driver.")
			set_parent_var(GODOT_PULSEAUDIO FALSE)
		endif()
	endif()

	if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		target_compile_definitions(global-env INTERFACE "JOYDEV_ENABLED")
	
		if (GODOT_UDEV)
			check_pkg_exist(__UDEV_EXIST libudev)
			if (__UDEV_EXIST)
				target_compile_definitions(global-env INTERFACE "UDEV_ENABLED")
			else()
				message(WARNING "Warning: libudev development libraries not found. Disabling controller hotplugging support.")
				set_parent_var(GODOT_UDEV FALSE)
			endif()
		endif()
	else()
		set_parent_var(GODOT_UDEV FALSE)
	endif()

	if (NOT GODOT_BUILTIN_ZLIB)
		target_append_pkg_config(global-env INTERFACE ALL zlib)	
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
		set_parent_var(GODOT_EXECINFO TRUE)
	endif()

	if (GODOT_EXECINFO)
		target_link_libraries(global-env INTERFACE "execinfo")
	endif()

	if (NOT GODOT_BUILD_TOOLS)
		#TODO: make use of template binaries
	endif()

	if (__IS_HOST_64BITS AND PROCESSOR_BITS EQUAL 32)
		target_compile_options(global-env INTERFACE "-m32")
		target_link_options(global-env INTERFACE "-m32" "-L/usr/lib/i386-linux-gnu")
	elseif(NOT __IS_HOST_64BITS AND PROCESSOR_BITS EQUAL 64)
		target_compile_options(global-env INTERFACE "-m64")
		target_link_options(global-env INTERFACE "-m64" "-L/usr/lib/i686-linux-gnu")
	endif()

	if (GODOT_USE_STATIC_CPP)
		target_link_options(global-env INTERFACE 
			"-static-libgcc"
			"-static-libstdc++"
		)
	endif()

	#TODO: This is very strange.. In scons version if we are using Clang, and we are not in FreBSD system,
	# we need to link library atomic. I'm definetly not experienced enough to know why, but ok.. 
	# But that is not the strangest thing. 
	# If we are not linking statically, we will simply add atomic as a library to the main environment,
	# but if we are linking statically, we will append "-l:libatomic.a" to the command line which links executable.
	# Because we are not linking anything except executables (static libraries are not linked, they are archived together)
	# this is basically the same... Should definetly ask godot developers at some point about this.
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_HOST_SYSTEM_NAME MATCHES "FreeBSD")
		target_link_libraries(global-env INTERFACE "atomic")
	endif()

	set_target_properties(global-env PROPERTIES EXTRA_SUFFIX "${__EXTRA_SUFFIX}")

endfunction()


function(${__PLATFORM_NAME}_get_program_suffix __OUTPUT)

	set(__RET "x11")

	if (GODOT_USE_UBSAN OR GODOT_USE_ASAN OR GODOT_USE_LSAN OR GODOT_USE_TSAN)
		set(__RET "${__RET}.s")
	endif()

	set("${__OUTPUT}" "${__RET}" PARENT_SCOPE)

endfunction()