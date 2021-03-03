
add_lib(servers-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		warnings-env
)
target_glob_sources(servers-lib PRIVATE "*.cpp")

add_subdirectory(arvr)
add_subdirectory(camera)
add_subdirectory(physics)
add_subdirectory(physics_2d)
add_subdirectory(visual)
add_subdirectory(audio)
