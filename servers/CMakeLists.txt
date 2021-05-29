
add_lib(servers-lib
	COMPONENTS
		global-env
		warnings-env
	DEPENDENCIES
		core-lib
)

register_global_lib(servers-lib)

target_glob_sources(servers-lib PRIVATE "*.cpp")

add_subdirectory(arvr)
add_subdirectory(camera)
add_subdirectory(physics)
add_subdirectory(physics_2d)
add_subdirectory(visual)
add_subdirectory(audio)