
add_env(cvtt-env
	COMPONENTS
		modules-env
)

add_module_lib(cvtt-lib
	COMPONENTS
		cvtt-env
		warnings-env
)

add_module_lib(thirdparty-cvtt-lib
	OBJECT
	PARENT_LIB
		cvtt-lib
	COMPONENTS
		cvtt-env	
)

set(__THIRDPARTY_CVTT_PATH "${GODOT_SOURCE_DIR}/thirdparty/cvtt")

target_include_directories(cvtt-env INTERFACE "${__THIRDPARTY_CVTT_PATH}")

target_sources_from_path(thirdparty-cvtt-lib PRIVATE "${__THIRDPARTY_CVTT_PATH}"
	"ConvectionKernels.cpp"
)

target_glob_sources(cvtt-lib PRIVATE "*.cpp")