

add_module_lib(stb-vorbis-lib
	COMPONENTS
		modules-env
		warnings-env
)

add_module_lib(thirdparty-stb-vorbis-lib
	OBJECT
	PARENT_LIB
		stb-vorbis-lib
	COMPONENTS
		modules-env	
	SOURCES
		"${GODOT_SOURCE_DIR}/thirdparty/misc/stb_vorbis.c"
)

target_glob_sources(stb-vorbis-lib PRIVATE "*.cpp")


