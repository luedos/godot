
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

# FIXME: Needed in editor/editor_themes.cpp for now, but ideally there
# shouldn't be a dependency on modules/ and its own 3rd party deps.
target_include_directories(global-env INTERFACE "${__THIRDPARTY_SVG_PATH}")
target_compile_definitions(global-env INTERFACE "SVG_ENABLED")

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
