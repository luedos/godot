
add_env(jpg-env
	COMPONENTS
		modules-env
)

add_module_lib(jpg-lib
	COMPONENTS
		jpg-env
		warnings-env
)

add_module_lib(thirdparty-jpg-lib
	OBJECT
	PARENT_LIB
		jpg-lib
	COMPONENTS
		jpg-env
)

set(__THIRDPARTY_JPG_PATH "${GODOT_SOURCE_DIR}/thirdparty/jpeg-compressor")
target_sources_from_path(thirdparty-jpg-lib PRIVATE "${__THIRDPARTY_JPG_PATH}"
	"jpgd.cpp"
)

target_include_directories(jpg-env INTERFACE "${__THIRDPARTY_JPG_PATH}")

target_glob_sources(jpg-lib PRIVATE "*.cpp")
