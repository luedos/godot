add_env(tinyexr-env
	COMPONENTS
		modules-env
)

add_lib(tinyexr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		tinyexr-env
		global-warnings-env
)
target_glob_sources(tinyexr-lib PRIVATE "*.cpp")

add_lib(thirdparty-tinyexr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		tinyexr-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_TINYEXR_PATH "${ENGINE_SOURCE_DIR}/thirdparty/tinyexr")
target_sources_from_path(thirdparty-tinyexr-lib PRIVATE "${__THIRDPARTY_TINYEXR_PATH}"
	"tinyexr.cc"
)

target_include_directories(tinyexr-env INTERFACE "${__THIRDPARTY_NOISE_PATH}")
target_compile_definitions(tinyexr-env INTERFACE
	"TINYEXR_USE_THREAD"
	"TINYEXR_USE_MINIZ=0"
)