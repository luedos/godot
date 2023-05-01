add_env(jpg-env
	COMPONENTS
		global-env
)

add_lib(jpg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		jpg-env
		global-warnings-env
)
target_glob_sources(jpg-lib PRIVATE "*.cpp")

add_lib(thirdparty-jpg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		jpg-env
		thirdparty-warnings-env
)
set(__THIRDPARTY_JPG_PATH "${ENGINE_SOURCE_DIR}/thirdparty/jpeg-compressor")
target_sources_from_path(thirdparty-jpg-lib PRIVATE "${__THIRDPARTY_JPG_PATH}"
	"jpgd.cpp"
	"jpge.cpp"
)

target_include_directories(jpg-env INTERFACE "${__THIRDPARTY_JPG_PATH}")