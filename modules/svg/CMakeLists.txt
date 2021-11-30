
add_env(svg-env
	COMPONENTS
		modules-env
)

add_module_lib(svg-lib
	COMPONENTS
		svg-env
		warnings-env
)

set(__THIRDPARTY_SVG_PATH "${GODOT_SOURCE_DIR}/thirdparty/nanosvg")
target_include_directories(svg-env INTERFACE "${__THIRDPARTY_SVG_PATH}")

add_module_lib(thirdparty-svg-lib
	OBJECT
	PARENT_LIB
		svg-lib
	COMPONENTS
		svg-env
)
target_sources_from_path(thirdparty-svg-lib PRIVATE "${__THIRDPARTY_SVG_PATH}"
	"nanosvg.cc"
)

target_glob_sources(svg-lib PRIVATE "*.cpp")
