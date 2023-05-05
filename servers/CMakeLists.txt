
add_lib(servers-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)

add_link_dependencies(servers-lib core-lib)

target_glob_sources(servers-lib PRIVATE "*.cpp")

add_subdirectory("xr")
add_subdirectory("camera")
add_subdirectory("physics_3d")
add_subdirectory("physics_2d")
add_subdirectory("rendering")
add_subdirectory("audio")
add_subdirectory("text")
add_subdirectory("debugger")
add_subdirectory("extensions")
add_subdirectory("movie_writer")
add_subdirectory("navigation")