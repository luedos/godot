
add_lib(scene-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)

add_link_dependencies(scene-lib servers-lib)

target_glob_sources(scene-lib PRIVATE "*.cpp")

add_subdirectory("main")
add_subdirectory("gui")

if (NOT godot_disable_3d)
    add_subdirectory("3d")
endif()

add_subdirectory("2d")
add_subdirectory("animation")
add_subdirectory("audio")
add_subdirectory("resources")
add_subdirectory("debugger")
add_subdirectory("theme")