
add_env(vorbis-env
	COMPONENTS
		modules-env
)

add_module_lib(vorbis-lib
	COMPONENTS
		vorbis-env
		warnings-env
)

# Only kept to build the thirdparty library used by the theora and webm
# modules. We now use stb_vorbis for AudioStreamOGGVorbis.

if(GODOT_BUILTIN_LIBVORBIS)	

	set(__THIRDPARTY_VORBIS_PATH "${GODOT_SOURCE_DIR}/thirdparty/libvorbis")

	target_include_directories(vorbis-env INTERFACE "${__THIRDPARTY_VORBIS_PATH}")
	if(GODOT_BUILTIN_LIBOGG)
		target_include_directories(vorbis-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libogg")
	endif()	
	define_module_dependencies(vorbis-lib 
		ogg-lib
	)

	add_module_lib(thirdparty-vorbis-lib
		OBJECT
		PARENT_LIB
			vorbis-lib
		COMPONENTS
			vorbis-env
	)
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
endif()

target_glob_sources(vorbis-lib PRIVATE "*.cpp")
