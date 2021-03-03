
add_env(freetype-env
	COMPONENTS
		modules-env
)

add_module_lib(freetype-lib
	COMPONENTS
		freetype-env
		warnings-env
)

if(GODOT_BUILTIN_FREETYPE)
	set(__THIRDPARTY_FREETYPE_PATH "${GODOT_SOURCE_DIR}/thirdparty/freetype")

	if (GODOT_PLATFORM STREQUAL "uwp")
		# Include header for UWP to fix build issues
		# Not actually adding it here, because it will be added to the global-env ->modules-env -> freetype-env
		# target_compile_options(freetype-env INTERFACE "/FI" '"modules/freetype/uwpdef.h"')
		# Globally too, as freetype is used in scene (see bottom)
		target_compile_options(global-env INTERFACE "/FI" '"modules/freetype/uwpdef.h"')
	endif()

	# Not actually adding it here, because it will be added to the global-env ->modules-env -> freetype-env
	# target_include_directories(freetype-env INTERFACE "${__THIRDPARTY_FREETYPE_PATH}/include")
	# Also needed in main env for scene/
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_FREETYPE_PATH}/include")

	target_compile_definitions(freetype-env INTERFACE 
		"FT2_BUILD_LIBRARY"
		"FT_CONFIG_OPTION_USE_PNG"
		$<${IS_DEBUG_GEN_EXPR}:ZLIB_DEBUG>
	)

	if (GODOT_BUILTIN_LIBPNG)
		target_include_directories(freetype-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libpng")
	endif()

	add_lib(thirdparty-freetype-lib
		OBJECT
		PARENT_LIB
			freetype-lib
		COMPONENTS
			freetype-env
	)

	if(GODOT_PLATFORM STREQUAL "javascript")
		add_lib(tmp-freetype-lib
			OBJECT
			PARENT_LIB
				freetype-lib
			COMPONENTS
				freetype-env
		)

		target_compile_options(tmp-freetype-lib PRIVATE "-U__OPTIMIZE__")

		target_sources(tmp-freetype-lib PRIVATE "${__THIRDPARTY_FREETYPE_PATH}/src/sfnt/sfnt.c")
	else()
		target_sources(thirdparty-freetype-lib PRIVATE "${__THIRDPARTY_FREETYPE_PATH}/src/sfnt/sfnt.c")
	endif()

	target_sources(thirdparty-freetype-lib PRIVATE
        "${__THIRDPARTY_FREETYPE_PATH}/src/autofit/autofit.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftbase.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftbbox.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftbdf.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftbitmap.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftcid.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftdebug.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftfstype.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftgasp.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftglyph.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftgxval.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftinit.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftmm.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftotval.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftpatent.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftpfr.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftstroke.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftsynth.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftsystem.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/fttype1.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/base/ftwinfnt.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/bdf/bdf.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/bzip2/ftbzip2.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/cache/ftcache.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/cff/cff.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/cid/type1cid.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/gxvalid/gxvalid.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/gzip/ftgzip.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/lzw/ftlzw.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/otvalid/otvalid.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/pcf/pcf.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/pfr/pfr.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/psaux/psaux.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/pshinter/pshinter.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/psnames/psnames.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/raster/raster.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/smooth/smooth.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/truetype/truetype.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/type1/type1.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/type42/type42.c"
        "${__THIRDPARTY_FREETYPE_PATH}/src/winfonts/winfnt.c"
	)

endif()

# Godot source files
target_glob_sources(freetype-lib PRIVATE "*.cpp")
# Used in scene/, needs to be in main env
target_compile_definitions(global-env INTERFACE 
	"FREETYPE_ENABLED"
)
