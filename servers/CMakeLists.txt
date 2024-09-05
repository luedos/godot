
add_env(servers-env
	COMPONENTS
		global-env
)

add_lib(servers-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		servers-env
		global-warnings-env
)

add_link_dependencies(servers-lib core-lib)

target_sources(servers-lib PRIVATE
	"audio_server.cpp"
	"camera_server.cpp"
	"display_server.cpp"
	"navigation_server_2d.cpp"
	"navigation_server_3d.cpp"
	"physics_server_2d.cpp"
	"physics_server_2d_wrap_mt.cpp"
	"register_server_types.cpp"
	"rendering_server.cpp"
	"text_server.cpp"
)

add_subdirectory(audio)
add_subdirectory(camera)
add_subdirectory(debugger)
add_subdirectory(display)
add_subdirectory(extensions)
add_subdirectory(movie_writer)
add_subdirectory(navigation)
add_subdirectory(rendering)
add_subdirectory(text)
add_subdirectory(physics_2d)

if (NOT godot_disable_3d)
	add_subdirectory(physics_3d)
	add_subdirectory(xr)

	target_sources(servers-lib PRIVATE
		"physics_server_3d.cpp"
		"physics_server_3d_wrap_mt.cpp"
		"xr_server.cpp"
	)
endif()