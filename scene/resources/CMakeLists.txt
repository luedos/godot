
add_lib(thirdparty-scene-resources-lib
	OBJECT
	PARENT_LIB
		scene-lib
	COMPONENTS
		global-env
	SOURCES
		"${GODOT_SOURCE_DIR}/thirdparty/misc/mikktspace.c"
)

target_glob_sources(scene-lib PRIVATE "*.cpp")

add_subdirectory(default_theme)
