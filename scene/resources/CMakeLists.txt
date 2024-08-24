
add_lib(thirdparty-misc-lib
	OBJECT
	PARENT_LIB
		scene-lib
	COMPONENTS
		global-env
		thirdparty-warnings-env
	SOURCES
		"${ENGINE_SOURCE_DIR}/thirdparty/misc/mikktspace.c"
)

target_glob_sources(scene-lib PRIVATE "*.cpp")

add_subdirectory(default_theme)