
add_lib(thirdparty-scene-animation-lib
	OBJECT
	PARENT_LIB
		scene-lib
	COMPONENTS
		global-env
	SOURCES
		"${GODOT_SOURCE_DIR}/thirdparty/misc/easing_equations.cpp"
)

target_glob_sources(scene-lib PRIVATE "*.cpp")
