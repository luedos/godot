add_env(navigation-env
	COMPONENTS
		global-env
)

add_lib(navigation-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		navigation-env
		global-warnings-env
)
target_glob_sources(navigation-lib PRIVATE "*.cpp")

if (godot_editor_build)
	target_glob_sources(navigation-lib PRIVATE "editor/*.cpp")
endif()

if (godot_builtin_recastnavigation)
	add_lib(thirdparty-recastnavigation-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			navigation-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_RECASTNAVIGATION_PATH "${ENGINE_SOURCE_DIR}/thirdparty/recastnavigation/Recast")
	target_sources_from_path(thirdparty-recastnavigation-lib PRIVATE "${__THIRDPARTY_RECASTNAVIGATION_PATH}"
		"Source/Recast.cpp"
		"Source/RecastAlloc.cpp"
		"Source/RecastArea.cpp"
		"Source/RecastAssert.cpp"
		"Source/RecastContour.cpp"
		"Source/RecastFilter.cpp"
		"Source/RecastLayers.cpp"
		"Source/RecastMesh.cpp"
		"Source/RecastMeshDetail.cpp"
		"Source/RecastRasterization.cpp"
		"Source/RecastRegion.cpp"
	)

	target_include_directories(navigation-env INTERFACE "${__THIRDPARTY_RECASTNAVIGATION_PATH}/Include")
endif()

if (godot_builtin_rvo2_2d)
	add_lib(thirdparty-rvo2-2d-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			navigation-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_RVO2_2D_PATH "${ENGINE_SOURCE_DIR}/thirdparty/rvo2/rvo2_2d")
	target_sources_from_path(thirdparty-rvo2-2d-lib PRIVATE "${__THIRDPARTY_RVO2_2D_PATH}"
		"Agent2d.cpp"
		"Obstacle2d.cpp"
		"KdTree2d.cpp"
		"RVOSimulator2d.cpp"
	)

	target_include_directories(navigation-env INTERFACE "${__THIRDPARTY_RVO2_2D_PATH}")
endif()

if (godot_builtin_rvo2_3d)
	add_lib(thirdparty-rvo2-3d-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			navigation-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_RVO2_3D_PATH "${ENGINE_SOURCE_DIR}/thirdparty/rvo2/rvo2_3d")
	target_sources_from_path(thirdparty-rvo2-3d-lib PRIVATE "${__THIRDPARTY_RVO2_3D_PATH}"
		"Agent3d.cpp"
		"KdTree3d.cpp"
		"RVOSimulator3d.cpp"
	)

	target_include_directories(navigation-env INTERFACE "${__THIRDPARTY_RVO2_3D_PATH}")
endif()
