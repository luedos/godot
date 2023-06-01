
add_env(drivers-png-env
	COMPONENTS
		global-env
)

add_lib(drivers-png-lib 
	OBJECT
	PARENT_LIB
		drivers-lib
	COMPONENTS
		drivers-png-env
		global-warnings-env
)

if (godot_builtin_libpng)
	add_lib(thirdparty-drivers-png-lib
		OBJECT
		PARENT_LIB
			drivers-lib 
		COMPONENTS
			drivers-png-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_LIBPNG_PATH "${ENGINE_SOURCE_DIR}/thirdparty/libpng")
	target_sources_from_path(thirdparty-drivers-png-lib PRIVATE "${__THIRDPARTY_LIBPNG_PATH}"
		"png.c"
		"pngerror.c"
		"pngget.c"
		"pngmem.c"
		"pngpread.c"
		"pngread.c"
		"pngrio.c"
		"pngrtran.c"
		"pngrutil.c"
		"pngset.c"
		"pngtrans.c"
		"pngwio.c"
		"pngwrite.c"
		"pngwtran.c"
		"pngwutil.c"
	)

	# Needed for drivers includes and in platform/web.
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_LIBPNG_PATH}")

	inline_if(__USE_NEON godot_platform STREQUAL "android" AND PROCESSOR_IS_ARM32 AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
	if (__USE_NEON)
		target_compile_definitions(drivers-png-env INTERFACE "PNG_ARM_NEON_OPT=2")
	else()
		target_compile_definitions(drivers-png-env INTERFACE "PNG_ARM_NEON_OPT=0")
	endif()

	if (__USE_NEON)
		#TODO: add support for the S_compiler.
		# Biggest problem here is that s_compiler is different from regular compiler.. somewhy..
		# reserach possibility to add new languages into cmake (and add specific compilers to those languages)
		# https://cmake.org/pipermail/cmake/2011-November/047512.html
		# https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake
		
		target_sources_from_path(thirdparty-drivers-png-lib PRIVATE "${__THIRDPARTY_LIBPNG_PATH}"
			"arm/arm_init.c"
			"arm/filter_neon_intrinsics.c"
			"arm/filter_neon.S"
			"arm/palette_neon_intrinsics.c"
		)
		set_property(SOURCE "${__THIRDPARTY_LIBPNG_PATH}/arm/filter_neon.S" PROPERTY LANGUAGE C)
	endif()

endif()

target_glob_sources(drivers-png-lib PRIVATE "*.cpp")