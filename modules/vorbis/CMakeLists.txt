add_env(vorbis-env
	COMPONENTS
		modules-env
)

add_lib(vorbis-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		vorbis-env
		global-warnings-env
)
target_glob_sources(vorbis-lib PRIVATE "*.cpp")

if (godot_builtin_libvorbis)
	add_lib(thirdparty-vorbis-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			vorbis-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_VORBIS_PATH "${ENGINE_SOURCE_DIR}/thirdparty/libvorbis")
	target_sources_from_path(thirdparty-vorbis-lib PRIVATE "${__THIRDPARTY_VORBIS_PATH}"
		# "analysis.c"
		# "barkmel.c"
		"bitrate.c"
		"block.c"
		"codebook.c"
		"envelope.c"
		"floor0.c"
		"floor1.c"
		"info.c"
		"lookup.c"
		"lpc.c"
		"lsp.c"
		"mapping0.c"
		"mdct.c"
		"psy.c"
		# "psytune.c"
		"registry.c"
		"res0.c"
		"sharedbook.c"
		"smallft.c"
		"synthesis.c"
		# "tone.c"
		# "vorbisenc.c"
		"vorbisfile.c"
		"window.c"
	)

	target_include_directories(vorbis-env INTERFACE "${__THIRDPARTY_VORBIS_PATH}")

	if (godot_builtin_libogg)
		target_include_directories(vorbis-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/libogg")
	endif()
endif()