

add_lib(drivers-png-lib 
	OBJECT
	PARENT_LIB
		drivers-lib
	COMPONENTS
		drivers-env
		warnings-env
)

if(GODOT_BUILTIN_LIBPNG)
	set(__THIRDPARTY_LIBPNG_PATH "${GODOT_SOURCE_DIR}/thirdparty/libpng")

	# Needed for drivers includes and in platform/javascript
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_LIBPNG_PATH}")

	# Currently .ASM filter_neon.S does not compile on NT.
	#TODO: this variable is defined only in android platform. Don't forget to add it if we will add android platform.
	get_target_property(__NEON_ENABLED global-env NEON_ENABLED)
	if(__NEON_ENABLED AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
		target_compile_definitions(drivers-png-lib PRIVATE "PNG_ARM_NEON_OPT=2")
	else()
		target_compile_definitions(drivers-png-lib PRIVATE "PNG_ARM_NEON_OPT=0")
	endif()

	add_lib(thirdparty-drivers-png-lib
		OBJECT
		PARENT_LIB
			drivers-lib 
		COMPONENTS
			drivers-env
	)

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

	if(__NEON_ENABLED AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
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