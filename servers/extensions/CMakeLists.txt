target_sources(servers-lib PRIVATE "physics_server_2d_extension.cpp")

if (NOT godot_disable_3d)
	target_sources(servers-lib PRIVATE "physics_server_3d_extension.cpp")
endif()
