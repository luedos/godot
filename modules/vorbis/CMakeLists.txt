
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

	add_lib(thirdparty-vorbis-lib
		OBJECT
		PARENT_LIB
			vorbis-lib
		COMPONENTS
			vorbis-env	
		SOURCES
			# "${__THIRDPARTY_VORBIS_PATH}/analysis.c"
			# "${__THIRDPARTY_VORBIS_PATH}/barkmel.c"
			"${__THIRDPARTY_VORBIS_PATH}/bitrate.c"
			"${__THIRDPARTY_VORBIS_PATH}/block.c"
			"${__THIRDPARTY_VORBIS_PATH}/codebook.c"
			"${__THIRDPARTY_VORBIS_PATH}/envelope.c"
			"${__THIRDPARTY_VORBIS_PATH}/floor0.c"
			"${__THIRDPARTY_VORBIS_PATH}/floor1.c"
			"${__THIRDPARTY_VORBIS_PATH}/info.c"
			"${__THIRDPARTY_VORBIS_PATH}/lookup.c"
			"${__THIRDPARTY_VORBIS_PATH}/lpc.c"
			"${__THIRDPARTY_VORBIS_PATH}/lsp.c"
			"${__THIRDPARTY_VORBIS_PATH}/mapping0.c"
			"${__THIRDPARTY_VORBIS_PATH}/mdct.c"
			"${__THIRDPARTY_VORBIS_PATH}/psy.c"
			# "${__THIRDPARTY_VORBIS_PATH}/psytune.c"
			"${__THIRDPARTY_VORBIS_PATH}/registry.c"
			"${__THIRDPARTY_VORBIS_PATH}/res0.c"
			"${__THIRDPARTY_VORBIS_PATH}/sharedbook.c"
			"${__THIRDPARTY_VORBIS_PATH}/smallft.c"
			"${__THIRDPARTY_VORBIS_PATH}/synthesis.c"
			# "${__THIRDPARTY_VORBIS_PATH}/tone.c"
			# "${__THIRDPARTY_VORBIS_PATH}/vorbisenc.c"
			"${__THIRDPARTY_VORBIS_PATH}/vorbisfile.c"
			"${__THIRDPARTY_VORBIS_PATH}/window.c"
	)
endif()

target_glob_sources(vorbis-lib PRIVATE "*.cpp")
