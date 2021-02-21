
if (GODOT_DISABLE_3D)
	target_sources(scene-lib PRIVATE 
		"${CMAKE_CURRENT_SOURCE_DIR}/spatial.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/skeleton.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/particles.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/visual_instance.cpp"
		"${CMAKE_CURRENT_SOURCE_DIR}/world_environment.cpp"
	)
else()
	target_glob_sources(scene-lib PRIVATE "*.cpp")
endif()

