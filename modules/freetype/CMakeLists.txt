
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

	add_module_lib(thirdparty-freetype-lib
		OBJECT
		PARENT_LIB
			freetype-lib
		COMPONENTS
			freetype-env
	)

	if(GODOT_PLATFORM STREQUAL "javascript")
		add_module_lib(tmp-freetype-lib
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

	target_sources_from_path(thirdparty-freetype-lib PRIVATE "${__THIRDPARTY_FREETYPE_PATH}/src"
		"autofit/autofit.c"
		"base/ftbase.c"
		"base/ftbbox.c"
		"base/ftbdf.c"
		"base/ftbitmap.c"
		"base/ftcid.c"
		"base/ftdebug.c"
		"base/ftfstype.c"
		"base/ftgasp.c"
		"base/ftglyph.c"
		"base/ftgxval.c"
		"base/ftinit.c"
		"base/ftmm.c"
		"base/ftotval.c"
		"base/ftpatent.c"
		"base/ftpfr.c"
		"base/ftstroke.c"
		"base/ftsynth.c"
		"base/ftsystem.c"
		"base/fttype1.c"
		"base/ftwinfnt.c"
		"bdf/bdf.c"
		"bzip2/ftbzip2.c"
		"cache/ftcache.c"
		"cff/cff.c"
		"cid/type1cid.c"
		"gxvalid/gxvalid.c"
		"gzip/ftgzip.c"
		"lzw/ftlzw.c"
		"otvalid/otvalid.c"
		"pcf/pcf.c"
		"pfr/pfr.c"
		"psaux/psaux.c"
		"pshinter/pshinter.c"
		"psnames/psnames.c"
		"raster/raster.c"
		"smooth/smooth.c"
		"truetype/truetype.c"
		"type1/type1.c"
		"type42/type42.c"
		"winfonts/winfnt.c"
	)

	#TODO: need to test this thing:
	# Needs to be appended to arrive after libscene in the linker call,
	# but we don't want it to arrive *after* system libs, so manual hack
	# LIBS contains first SCons Library objects ("SCons.Node.FS.File object")
	# and then plain strings for system library. We insert between the two.

endif()

# Godot source files
target_glob_sources(freetype-lib PRIVATE "*.cpp")
