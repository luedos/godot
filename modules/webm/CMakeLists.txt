
add_env(webm-env
	COMPONENTS
		modules-env
)

add_module_lib(webm-lib
	COMPONENTS
		webm-env
		warnings-env
	DEPENDENCIES
		ogg-lib
		vorbis-lib
		opus-lib
)

set(__THIRDPARTY_WEBM_PATH "${GODOT_SOURCE_DIR}/thirdparty/libsimplewebm")

target_include_directories(webm-env INTERFACE 
	"${__THIRDPARTY_WEBM_PATH}"
	"${__THIRDPARTY_WEBM_PATH}/libwebm"
)

add_module_lib(thirdparty-webm-lib
	OBJECT
	PARENT_LIB
		webm-lib
	COMPONENTS
		webm-env
)
target_sources_from_path(thirdparty-webm-lib PRIVATE "${__THIRDPARTY_WEBM_PATH}"
	"libwebm/mkvparser/mkvparser.cc"
	"OpusVorbisDecoder.cpp"
	"VPXDecoder.cpp"
	"WebMDemuxer.cpp"
)

if(GODOT_BUILTIN_LIBOGG)
	target_include_directories(webm-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libogg")
endif()

if(GODOT_BUILTIN_LIBVORBIS)
	target_include_directories(webm-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libvorbis")
endif()

if(GODOT_BUILTIN_OPUS)
	target_include_directories(webm-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/opus")
endif()

if(GODOT_BUILTIN_LIBVPX)
	target_include_directories(webm-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libvpx")
	add_subdirectory(libvpx)
endif()

target_glob_sources(webm-lib PRIVATE "*.cpp")
