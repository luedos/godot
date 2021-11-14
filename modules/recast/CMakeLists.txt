
add_env(recast-env
	COMPONENTS
		modules-env
)

add_module_lib(recast-lib
	COMPONENTS
		recast-env
		warnings-env
)

if(GODOT_BUILTIN_RECAST)	

	set(__THIRDPARTY_RECAST_PATH "${GODOT_SOURCE_DIR}/thirdparty/recastnavigation/Recast")

	target_include_directories(recast-env INTERFACE "${__THIRDPARTY_RECAST_PATH}/Include")

	add_module_lib(thirdparty-recast-lib
		OBJECT
		PARENT_LIB
			recast-lib
		COMPONENTS
			recast-env
	)
	target_sources_from_path(thirdparty-recast-lib PRIVATE "${__THIRDPARTY_RECAST_PATH}/Source"
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
target_glob_sources(recast-lib PRIVATE "*.cpp")

