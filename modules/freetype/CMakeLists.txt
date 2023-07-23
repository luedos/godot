add_env(freetype-env
	COMPONENTS
		modules-env
)

add_lib(freetype-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		freetype-env
		global-warnings-env
)
target_glob_sources(freetype-lib PRIVATE "*.cpp")

if (godot_builtin_freetype)
	add_lib(thirdparty-freetype-lib
		PARENT_LIB
			modules-lib
		COMPONENTS
			freetype-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_FREETYPE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/freetype")
	target_sources_from_path(thirdparty-freetype-lib PRIVATE "${__THIRDPARTY_FREETYPE_PATH}"
		"src/autofit/autofit.c"
		"src/base/ftbase.c"
		"src/base/ftbbox.c"
		"src/base/ftbdf.c"
		"src/base/ftbitmap.c"
		"src/base/ftcid.c"
		"src/base/ftdebug.c"
		"src/base/ftfstype.c"
		"src/base/ftgasp.c"
		"src/base/ftglyph.c"
		"src/base/ftgxval.c"
		"src/base/ftinit.c"
		"src/base/ftmm.c"
		"src/base/ftotval.c"
		"src/base/ftpatent.c"
		"src/base/ftpfr.c"
		"src/base/ftstroke.c"
		"src/base/ftsynth.c"
		"src/base/ftsystem.c"
		"src/base/fttype1.c"
		"src/base/ftwinfnt.c"
		"src/bdf/bdf.c"
		"src/bzip2/ftbzip2.c"
		"src/cache/ftcache.c"
		"src/cff/cff.c"
		"src/cid/type1cid.c"
		"src/gxvalid/gxvalid.c"
		"src/gzip/ftgzip.c"
		"src/lzw/ftlzw.c"
		"src/otvalid/otvalid.c"
		"src/pcf/pcf.c"
		"src/pfr/pfr.c"
		"src/psaux/psaux.c"
		"src/pshinter/pshinter.c"
		"src/psnames/psnames.c"
		"src/raster/raster.c"
		"src/sdf/sdf.c"
		"src/svg/svg.c"
		"src/smooth/smooth.c"
		"src/truetype/truetype.c"
		"src/type1/type1.c"
		"src/type42/type42.c"
		"src/winfonts/winfnt.c"
	)

	if (godot_brotli)
		target_compile_definitions(freetype-env INTERFACE "FT_CONFIG_OPTION_USE_BROTLI")
	endif()

	if (godot_platform STREQUAL "uwp")
		# Include header for UWP to fix build issues
		# Globally too, as freetype is used in scene (see bottom)
		target_compile_options(global-env INTERFACE "/FI" "\"modules/freetype/uwpdef.h\"")
	endif()

	# Also needed in main env for scene/
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_FREETYPE_PATH}/include")

	target_compile_definitions(freetype-env INTERFACE
		"FT2_BUILD_LIBRARY"
		"FT_CONFIG_OPTION_USE_PNG"
		"FT_CONFIG_OPTION_SYSTEM_ZLIB"
	)

	if (godot_editor_build)
		target_compile_definitions(freetype-env INTERFACE "ZLIB_DEBUG")
	endif()

	set(__SFNT_SOURCE "${__THIRDPARTY_FREETYPE_PATH}/src/sfnt/sfnt.c")
	if (godot_platform STREQUAL "web")
		set_source_files_properties("${__SFNT_SOURCE}" PROPERTIES COMPILE_OPTIONS "-U__OPTIMIZE__")
	endif()
	target_sources(thirdparty-freetype-lib PRIVATE "${__SFNT_SOURCE}")

	# Needs to be appended to arrive after libscene in the linker call,
	add_link_dependencies(scene-lib thirdparty-freetype-lib)
endif()