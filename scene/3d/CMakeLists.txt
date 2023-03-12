
if (GODOT_DISABLE_3D)
	target_sources_from_path(scene-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
		"spatial.cpp"
		"skeleton.cpp"
		"particles.cpp"
		"visual_instance.cpp"
		"world_environment.cpp"
	)
else()
	target_glob_sources(scene-lib PRIVATE "*.cpp")
endif()

