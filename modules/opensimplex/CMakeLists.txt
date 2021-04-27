
add_env(opensimplex-env
	COMPONENTS
		modules-env
)

add_module_lib(opensimplex-lib
	COMPONENTS
		opensimplex-env
		warnings-env
)

set(__THIRDPARTY_OPENSIMPLEX_PATH "${GODOT_SOURCE_DIR}/thirdparty/misc")

target_include_directories(opensimplex-env INTERFACE "${__THIRDPARTY_OPENSIMPLEX_PATH}")

add_module_lib(thirdparty-opensimplex-lib 
	OBJECT
	PARENT_LIB
		opensimplex-lib
	COMPONENTS
		opensimplex-env
)
target_sources_from_path(thirdparty-opensimplex-lib PRIVATE "${__THIRDPARTY_OPENSIMPLEX_PATH}"
	"open-simplex-noise.c"
)

target_glob_sources(opensimplex-lib PRIVATE "*.cpp")

