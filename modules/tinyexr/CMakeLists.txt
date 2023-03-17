
add_env(tinyexr-env
	COMPONENTS
		modules-env
)

add_module_lib(tinyexr-lib
	COMPONENTS
		tinyexr-env
		warnings-env
)

# Thirdparty source files
# Not unbundled for now as they are not commonly available as shared library

set(__THIRDPARTY_TINYEXR_PATH "${GODOT_SOURCE_DIR}/thirdparty/tinyexr")

add_module_lib(thirdparty-tinyexr-lib
	OBJECT
	PARENT_LIB
		tinyexr-lib
	COMPONENTS
		tinyexr-env
)

target_sources_from_path(thirdparty-tinyexr-lib PRIVATE "${__THIRDPARTY_TINYEXR_PATH}"
	"tinyexr.cc"
)

target_include_directories(tinyexr-env INTERFACE "${__THIRDPARTY_TINYEXR_PATH}")
target_compile_definitions(tinyexr-env INTERFACE "TINYEXR_USE_THREAD")
# miniz is an external dependency, we could add it but we can instead rely
# on our existing bundled zlib.
target_compile_definitions(tinyexr-env INTERFACE "TINYEXR_USE_MINIZ=0")

target_glob_sources(tinyexr-lib PRIVATE "*.cpp")

