

add_lib(drivers-png-lib 
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
	#TODO: Do not forget that this variable is seted in the android configuration
	if(NEON_ENABLED AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
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

	target_sources(thirdparty-drivers-png-lib PRIVATE
		"${__THIRDPARTY_LIBPNG_PATH}/png.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngerror.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngget.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngmem.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngpread.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngread.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngrio.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngrtran.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngrutil.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngset.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngtrans.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngwio.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngwrite.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngwtran.c"
		"${__THIRDPARTY_LIBPNG_PATH}/pngwutil.c"
	)

	if(NEON_ENABLED AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
		#TODO: add support for the S_compiler.
		# Biggest problem here is that s_compiler is different from regular compiler.. somewhy..
		# reserach possibility to add new languages into cmake (and add specific compilers to those languages)
		# https://cmake.org/pipermail/cmake/2011-November/047512.html
		# https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake
		
		target_sources(thirdparty-drivers-png-lib PRIVATE
			"${__THIRDPARTY_LIBPNG_PATH}/arm/arm_init.c"
			"${__THIRDPARTY_LIBPNG_PATH}/arm/filter_neon_intrinsics.c"
			"${__THIRDPARTY_LIBPNG_PATH}/arm/filter_neon.S"
			"${__THIRDPARTY_LIBPNG_PATH}/arm/palette_neon_intrinsics.c"
		)
		set_property(SOURCE "${__THIRDPARTY_LIBPNG_PATH}/arm/filter_neon.S" PROPERTY LANGUAGE C)
	endif()

endif()

target_glob_sources(drivers-png-lib PRIVATE "*.cpp")