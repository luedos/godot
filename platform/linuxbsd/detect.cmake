get_filename_component(__PLATFORM_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__PLATFORM_NAME}_create_custom_options)
	set_string_option(godot_linker 					"default" DESCRIPTION "Linker program." ENUM "default" "bfd" "gold" "lld" "mold")
	set_bool_option(godot_use_static_cpp            TRUE    DESCRIPTION "Link libgcc and libstdc++ statically for better portability.")
	set_bool_option(godot_use_coverage              FALSE   DESCRIPTION "Test Godot coverage.")
	set_bool_option(godot_use_ubsan                 FALSE   DESCRIPTION "Use LLVM/GCC compiler undefined behavior sanitizer (UBSAN).")
	set_bool_option(godot_use_asan                  FALSE   DESCRIPTION "Use LLVM/GCC compiler address sanitizer (ASAN)).")
	set_bool_option(godot_use_lsan                  FALSE   DESCRIPTION "Use LLVM/GCC compiler leak sanitizer (LSAN)).")
	set_bool_option(godot_use_tsan                  FALSE   DESCRIPTION "Use LLVM/GCC compiler thread sanitizer (TSAN)).")
	set_bool_option(godot_use_msan                  FALSE   DESCRIPTION "Use LLVM/GCC compiler memory sanitizer (MSAN)).")
	set_bool_option(godot_use_sowrap                TRUE    DESCRIPTION "Dynamically load system libraries.")
	set_bool_option(godot_alsa                      TRUE    DESCRIPTION "Use ALSA.")
	set_bool_option(godot_pulseaudio                TRUE    DESCRIPTION "Use PulseAudio.")
	set_bool_option(godot_dbus                      TRUE    DESCRIPTION "Use D-Bus to handle screensaver and portal desktop settings.")
	set_bool_option(godot_speechd                   TRUE    DESCRIPTION "Use Speech Dispatcher for Text-to-Speech support.")
	set_bool_option(godot_fontconfig                TRUE    DESCRIPTION "Use fontconfig for system fonts support.")
	set_bool_option(godot_udev                      TRUE    DESCRIPTION "Use udev for gamepad connection callbacks.")
	set_bool_option(godot_x11                       TRUE    DESCRIPTION "Enable X11 display.")
	set_bool_option(godot_touch                     TRUE    DESCRIPTION "Enable touch events.")
	set_bool_option(godot_execinfo                  FALSE   DESCRIPTION "Use libexecinfo on systems where glibc is not available.")
endfunction()

function(${__PLATFORM_NAME}_get_platform_name __OUTPUT)
	set("${__OUTPUT}" "LinuxBSD" PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_is_platform_active __OUTPUT)
	set("${__OUTPUT}" TRUE PARENT_SCOPE)
endfunction()

function(${__PLATFORM_NAME}_get_can_platform_build __OUTPUT)

	if (NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		# Not sure why godot blocks cross-compiling for linux but ok..
		set("${__OUTPUT}" FALSE PARENT_SCOPE)
		return()
	endif()

	# pkg-config is required
	if (NOT PKG_CONFIG_FOUND)
		set("${__OUTPUT}" FALSE PARENT_SCOPE)
		message("Error: pkg-config not found. Aborting.")
		return()
	endif()

	set("${__OUTPUT}" TRUE PARENT_SCOPE)

endfunction()

function(${__PLATFORM_NAME}_configure_platform)
	
	set(__SUPPORTED_ARCH_LIST "x86_32" "x86_64" "arm32" "arm64" "rv64" "ppc32" "ppc64")
	if (NOT PROCESSOR_ARCH_ALIAS IN_LIST __SUPPORTED_ARCH_LIST)
		message(FATAL_ERROR "Unsupported CPU architecture \"${PROCESSOR_ARCH_ALIAS}\" for Linux / *BSD. Supported architectures are: ${__SUPPORTED_ARCH_LIST}.")
	endif()

	if (godot_dev_build)
		# This is needed for our crash handler to work properly.
		# gdb works fine without it though, so maybe our crash handler could too.
		target_link_options(global-env INTERFACE "-rdynamic")
	endif()

	if (PROCESSOR_ARCH_ALIAS STREQUAL "rv64")
		# G = General-purpose extensions, C = Compression extension (very common).
		target_compile_options(global-env INTERFACE "-march=rv64gc")
	endif()

	if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		target_property(APPEND_STR global-env EXTRA_SUFFIX ".llvm")
	endif()

	if(NOT godot_linker STREQUAL "default")
		message(STATUS "Using linker program: ${godot_linker}")

		set(__LINKER_OPTION "-fuse-ld=${godot_linker}")

		if(godot_linker STREQUAL "mold" AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "12.1")
			
			set(__MOLD_FOUND FALSE)
			foreach(__INSTALL_DIR IN ITEMS "/usr/libexec" "/usr/local/libexec" "/usr/lib" "/usr/local/lib")
				if(EXISTS "${__INSTALL_DIR}/mold/ld")
					set(__LINKER_OPTION "-B${__INSTALL_DIR}/mold")
					set(__MOLD_FOUND TRUE)
					break()
				endif()
			endforeach()
			assert("Couldn't locate mold installation path. Make sure it's installed in /usr or /usr/local." __MOLD_FOUND)
			
		endif()

		target_link_options(global-env INTERFACE "${__LINKER_OPTION}")
	endif()

	if (godot_use_coverage)
		target_compile_options(global-env INTERFACE "-ftest-coverage" "-fprofile-arcs")
		target_link_options(global-env INTERFACE "-ftest-coverage" "-fprofile-arcs")
	endif()

	if (godot_use_ubsan OR godot_use_asan OR godot_use_tsan OR godot_use_lsan OR godot_use_msan)
		target_property(APPEND_STR global-env EXTRA_SUFFIX ".san")
		target_compile_definitions(global-env INTERFACE "SANITIZERS_ENABLED")

		if (godot_use_ubsan)
			target_compile_options(global-env INTERFACE "-fsanitize=undefined,shift,shift-exponent,integer-divide-by-zero,unreachable,vla-bound,null,return,signed-integer-overflow,bounds,float-divide-by-zero,float-cast-overflow,nonnull-attribute,returns-nonnull-attribute,bool,enum,vptr,pointer-overflow,builtin")
			target_link_options(global-env INTERFACE "-fsanitize=undefined")

			if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
				target_compile_options(global-env INTERFACE "-fsanitize=nullability-return,nullability-arg,function,nullability-assign,implicit-integer-sign-change")
			else()
				target_compile_options(global-env INTERFACE "-fsanitize=bounds-strict")
			endif()
		endif()

		if (godot_use_asan)
			target_compile_options(global-env INTERFACE "-fsanitize=address,pointer-subtract,pointer-compare")
			target_link_options(global-env INTERFACE "-fsanitize=address")
		endif()

		if (godot_use_lsan)
			target_compile_options(global-env INTERFACE "-fsanitize=leak")
			target_link_options(global-env INTERFACE "-fsanitize=leak")
		endif()

		if (godot_use_tsan)
			target_compile_options(global-env INTERFACE "-fsanitize=thread")
			target_link_options(global-env INTERFACE "-fsanitize=thread")
		endif()

		if (godot_use_msan AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_compile_options(global-env INTERFACE
				"-fsanitize=memory"
				"-fsanitize-memory-track-origins"
				"-fsanitize-recover=memory"
			)
			target_link_options(global-env INTERFACE "-fsanitize=memory")
		endif()
	endif()

	set(__LTO "${godot_lto}")

	if (godot_lto STREQUAL "auto")
		set(__LTO "${full}")
	endif()

	if (NOT __LTO STREQUAL "none")
		if (__LTO STREQUAL "thin")
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


	target_compile_options(global-env INTERFACE "-pipe")

	if (godot_use_sowrap)
		target_compile_definitions(global-env INTERFACE "SOWRAP_ENABLED")
	endif()

	if (godot_touch)
		target_compile_definitions(global-env INTERFACE "TOUCH_ENABLED")
	endif()

	if ((godot_builtin_freetype OR godot_builtin_libpng OR godot_builtin_zlib OR godot_builtin_graphite OR godot_builtin_harfbuzz)
		AND NOT (godot_builtin_freetype AND godot_builtin_libpng AND godot_builtin_zlib AND godot_builtin_graphite AND godot_builtin_harfbuzz))
	
		message(FATAL_ERROR 
			"These libraries should be either all builtin, or all system provided:\n"
			"freetype, libpng, zlib, graphite, harfbuzz.\n"
			"Please specify `builtin_<name>=no` for all of them, or none."
		)
	endif()

	if (NOT godot_builtin_freetype)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "freetype2")
	endif()

	if (NOT godot_builtin_graphite)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "graphite2")
	endif()

	if (NOT godot_builtin_icu4c)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "icu-i18n" "icu-uc")
	endif()

	if (NOT godot_builtin_harfbuzz)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "harfbuzz" "harfbuzz-icu")
	endif()

	if (NOT godot_builtin_libpng)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libpng16")
	endif()

	if (NOT godot_builtin_enet)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libenet")
	endif()

	if (NOT godot_builtin_squish)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libsquish")
	endif()

	if (NOT godot_builtin_zstd)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libzstd")
	endif()

	# Sound and video libraries
	# Keep the order as it triggers chained dependencies (ogg needed by others, etc.)

	if (NOT godot_builtin_libtheora)
		# Needed to link against system libtheora
		set_parent_var(godot_builtin_libogg FALSE)
		# Needed to link against system libtheora
		set_parent_var(godot_builtin_libvorbis FALSE)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "theora" "theoradec")
	elseif (PROCESSOR_ARCH_ALIAS MATCHES "(x86_64|x86_32)")
		set_target_properties(global-env PROPERTIES "X86_LIBTHEORA_OPT_GCC" TRUE)
	endif()

	if (NOT godot_builtin_libvorbis)
		# Needed to link against system libvorbis
		set_parent_var(godot_builtin_libogg FALSE)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "vorbis" "vorbisfile")
	endif()

	if (NOT godot_builtin_libogg)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "ogg")
	endif()

	if (NOT godot_builtin_libwebp)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libwebp")
	endif()

	if (NOT godot_builtin_mbedtls)
		# mbedTLS does not provide a pkgconfig config yet. See https://github.com/ARMmbed/mbedtls/issues/228
		target_link_libraries(global-env INTERFACE "mbedtls" "mbedcrypto" "mbedx509")
	endif()

	if (NOT godot_builtin_wslay)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libwslay")
	endif()

	if (NOT godot_builtin_miniupnpc)
		# No pkgconfig file so far, hardcode default paths.
		target_include_directories(global-env INTERFACE "/usr/include/miniupnpc")
		target_link_libraries(global-env INTERFACE "miniupnpc")
	endif()

	if (NOT godot_builtin_pcre2)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libpcre2-32")
	endif()

	if (NOT godot_builtin_recastnavigation)
		# No pkgconfig file so far, hardcode default paths.
		target_include_directories(global-env INTERFACE "/usr/include/recastnavigation")
		target_link_libraries(global-env INTERFACE "Recast")
	endif()

	if (NOT godot_builtin_embree)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "embree3")
	endif()

	if (godot_fontconfig)
		if (NOT godot_use_sowrap)
			check_pkg_exist(__FONTCONFIG_EXIST "fontconfig")
			if (__FONTCONFIG_EXIST)
				target_append_pkg_config(global-env INTERFACE ALL REQUIRED "fontconfig")
				target_compile_definitions(global-env INTERFACE "FONTCONFIG_ENABLED")
			else()
				message(WARNING "Warning: fontconfig development libraries not found. Disabling the system fonts support.")
				set_parent_var(godot_fontconfig FALSE)
			endif()
		else()
			target_compile_definitions(global-env INTERFACE "FONTCONFIG_ENABLED")			
		endif()
	endif()

	if (godot_alsa)
		if (NOT godot_use_sowrap)
			check_pkg_exist(__ALSA_EXIST "alsa")
			if (__ALSA_EXIST)
				target_append_pkg_config(global-env INTERFACE ALL REQUIRED "alsa")
				target_compile_definitions(global-env INTERFACE "ALSA_ENABLED" "ALSAMIDI_ENABLED")
			else()
				message(WARNING "Warning: ALSA development libraries not found. Disabling the ALSA audio driver.")
				set_parent_var(godot_alsa FALSE)
			endif()
		else()
			target_compile_definitions(global-env INTERFACE "ALSA_ENABLED" "ALSAMIDI_ENABLED")		
		endif()
	endif()

	if (godot_pulseaudio)
		if (NOT godot_use_sowrap)
			check_pkg_exist(__ALSA_EXIST "libpulse")
			if (__ALSA_EXIST)
				target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libpulse")
				target_compile_definitions(global-env INTERFACE "PULSEAUDIO_ENABLED" "_REENTRANT")
			else()
				message(WARNING "Warning: PulseAudio development libraries not found. Disabling the PulseAudio audio driver.")
				set_parent_var(godot_pulseaudio FALSE)
			endif()
		else()
			target_compile_definitions(global-env INTERFACE "PULSEAUDIO_ENABLED" "_REENTRANT")	
		endif()
	endif()

	if (godot_dbus)
		if (NOT godot_use_sowrap)
			check_pkg_exist(__ALSA_EXIST "dbus-1")
			if (__ALSA_EXIST)
				target_append_pkg_config(global-env INTERFACE ALL REQUIRED "dbus-1")
				target_compile_definitions(global-env INTERFACE "DBUS_ENABLED")
			else()
				message(WARNING "Warning: D-Bus development libraries not found. Disabling screensaver prevention.")
				set_parent_var(godot_dbus FALSE)
			endif()
		else()
				target_compile_definitions(global-env INTERFACE "DBUS_ENABLED")
		endif()
	endif()

	if (godot_speechd)
		if (NOT godot_use_sowrap)
			check_pkg_exist(__ALSA_EXIST "speech-dispatcher")
			if (__ALSA_EXIST)
				target_append_pkg_config(global-env INTERFACE ALL REQUIRED "speech-dispatcher")
				target_compile_definitions(global-env INTERFACE "SPEECHD_ENABLED")
			else()
				message(WARNING "Warning: speech-dispatcher development libraries not found. Disabling text to speech support.")
				set_parent_var(godot_speechd FALSE)
			endif()
		else()
				target_compile_definitions(global-env INTERFACE "SPEECHD_ENABLED")
		endif()
	endif()

	if (NOT godot_use_sowrap)
		check_pkg_exist(__ALSA_EXIST "xkbcommon")
		if (__ALSA_EXIST)
			target_append_pkg_config(global-env INTERFACE ALL REQUIRED "xkbcommon")
			target_compile_definitions(global-env INTERFACE "XKB_ENABLED")
		else()
			message(WARNING "Warning: libxkbcommon development libraries not found. Disabling dead key composition and key label support.")
		endif()
	else()
			target_compile_definitions(global-env INTERFACE "XKB_ENABLED")
	endif()

	if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		target_compile_definitions(global-env INTERFACE "JOYDEV_ENABLED")
		if (godot_udev)
			if (NOT godot_use_sowrap)
				check_pkg_exist(__ALSA_EXIST "libudev")
				if (__ALSA_EXIST)
					target_append_pkg_config(global-env INTERFACE ALL REQUIRED "libudev")
					target_compile_definitions(global-env INTERFACE "UDEV_ENABLED")
				else()
					message(WARNING "Warning: libudev development libraries not found. Disabling controller hotplugging support.")
					set_parent_var(godot_udev FALSE)
				endif()
			else()
				target_compile_definitions(global-env INTERFACE "UDEV_ENABLED")
			endif()
		endif()
	else()
		set_parent_var(godot_udev FALSE)
	endif()

	# Linkflags below this line should typically stay the last ones
	if (NOT godot_builtin_zlib)
		target_append_pkg_config(global-env INTERFACE ALL REQUIRED "zlib")
	endif()

	target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}/platform/linuxbsd")
	if (godot_use_sowrap)
		target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/linuxbsd_headers")
	endif()

	target_compile_definitions(global-env INTERFACE
		"LINUXBSD_ENABLED"
		"UNIX_ENABLED"
		"_FILE_OFFSET_BITS=64"
	)

	if (godot_x11)
		if (NOT godot_use_sowrap)
			target_append_pkg_config(global-env INTERFACE ALL REQUIRED
				"x11"
				"xcursor"
				"xinerama"
				"xext"
				"xrandr"
				"xrender"
				"xi"
			)
		endif()
		target_compile_definitions(global-env INTERFACE "X11_ENABLED")
	endif()

	if (godot_vulkan)
		target_compile_definitions(global-env INTERFACE "VULKAN_ENABLED")

		if (NOT godot_use_volk)
			target_append_pkg_config(global-env INTERFACE ALL REQUIRED "vulkan")
		endif()

		if (NOT godot_builtin_glslang)
			# No pkgconfig file so far, hardcode expected lib name.
			target_link_libraries(global-env INTERFACE "glslang" "SPIRV")
		endif()
	endif()

	if (godot_opengl3)
		target_compile_definitions(global-env INTERFACE "GLES3_ENABLED")
	endif()

	target_link_libraries(global-env INTERFACE "pthread")

	if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		target_link_libraries(global-env INTERFACE "dl")
	endif()

	execute_process(
		COMMAND "${PYTHON_EXECUTABLE}" "-c" "import platform; print(platform.libc_ver()[0], end='')"
		OUTPUT_VARIABLE __LIBC_VER_NAME
	)

	if (NOT godot_execinfo AND NOT __LIBC_VER_NAME STREQUAL "glibc")
		# The default crash handler depends on glibc, so if the host uses
		# a different libc (BSD libc, musl), fall back to libexecinfo.
		message(WARNING "Note: Using `execinfo=yes` for the crash handler as required on platforms where glibc is missing.")
		set_parent_var(godot_execinfo TRUE)
	endif()

	if (godot_execinfo)
		target_link_libraries(global-env INTERFACE "execinfo")
	endif()

	if (NOT godot_editor_build)
		# TODO: add support for export templates
	endif()


	cmake_host_system_information(RESULT __IS_HOST_64BITS QUERY IS_64BIT)
	# Just because I'm random perfectionist, we will transform 1/0 into TRUE/FALSE
	if(__IS_HOST_64BITS EQUAL 1)
		set(__IS_HOST_64BITS TRUE)
	else()
		set(__IS_HOST_64BITS FALSE)
	endif()

	if (__IS_HOST_64BITS AND PROCESSOR_IS_X86_32)
		target_compile_options(global-env INTERFACE "-m32")
		target_link_options(global-env INTERFACE "-m32" "-L/usr/lib/i386-linux-gnu")
	elseif (NOT __IS_HOST_64BITS AND PROCESSOR_IS_X86_64)
		target_compile_options(global-env INTERFACE "-m64")
		target_link_options(global-env INTERFACE "-m64" "-L/usr/lib/i686-linux-gnu")
	endif()


	# Link those statically for portability
	if (godot_use_static_cpp)
		target_link_options(global-env INTERFACE 
			"-static-libgcc"
			"-static-libstdc++"
		)
	endif()

	# TODO: This is very strange.. In scons version if we are using Clang, and we are not in FreeBSD system,
	# we need to link library atomic. I'm definitely not experienced enough to know why, but ok.. 
	# But that is not the strangest thing. 
	# If we are not linking statically, we will simply add atomic as a library to the main environment,
	# but if we are linking statically, we will append "-l:libatomic.a" to the command line which links executable.
	# Because we are not linking anything except executables (static libraries are not linked, they are archived together)
	# this is basically the same... Should definitely ask godot developers at some point about this.
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_HOST_SYSTEM_NAME MATCHES "FreeBSD")
		target_link_libraries(global-env INTERFACE "atomic")
	endif()
endfunction()