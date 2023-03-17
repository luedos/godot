
add_env(navigation-env
	COMPONENTS
		modules-env
)

add_module_lib(navigation-lib
	COMPONENTS
		navigation-env
		warnings-env
)

target_glob_sources(navigation-lib PRIVATE "*.cpp")

if (GODOT_BUILTIN_RECAST)
	set(__THIRDPARTY_RECAST_PATH "${GODOT_SOURCE_DIR}/recastnavigation/Recast")
	target_include_directories(navigation-env INTERFACE "${__THIRDPARTY_RECAST_PATH}/Include")

	add_module_lib(thirdparty-navigation-recast-lib 
		OBJECT
		PARENT_LIB
			navigation-lib
		COMPONENTS
			navigation-env
	)
	target_sources_from_path(thirdparty-navigation-recast-lib PRIVATE "${__THIRDPARTY_RECAST_PATH}/Source"
		"Recast.cpp"
		"RecastAlloc.cpp"
		"RecastArea.cpp"
		"RecastAssert.cpp"
		"RecastContour.cpp"
		"RecastFilter.cpp"
		"RecastLayers.cpp"
		"RecastMesh.cpp"
		"RecastMeshDetail.cpp"
		"RecastRasterization.cpp"
		"RecastRegion.cpp"
	)
endif()

if (GODOT_BUILTIN_RVO2)
	set(__THIRDPARTY_RVO2_PATH "${GODOT_SOURCE_DIR}/rvo2")
	target_include_directories(navigation-env INTERFACE "${__THIRDPARTY_RVO2_PATH}")

	add_module_lib(thirdparty-navigation-rvo2-lib 
		OBJECT
		PARENT_LIB
			navigation-lib
		COMPONENTS
			navigation-env
	)
	target_sources_from_path(thirdparty-navigation-rvo2-lib PRIVATE "${__THIRDPARTY_RVO2_PATH}"
		"Agent.cpp"
		"KdTree.cpp"
	)
endif()

