
add_env(recast-env
	COMPONENTS
		modules-env
)

add_module_lib(recast-lib
	TOOLS_DEPENDENT
	COMPONENTS
		recast-env
		warnings-env
)

if(GODOT_BUILTIN_RECAST)	

	set(__THIRDPARTY_RECAST_PATH "${GODOT_SOURCE_DIR}/thirdparty/recastnavigation/Recast")

	target_include_directories(recast-env INTERFACE "${__THIRDPARTY_RECAST_PATH}/Include")

	add_lib(thirdparty-recast-lib
		OBJECT
		PARENT_LIB
			recast-lib
		COMPONENTS
			recast-env	
		SOURCES
			"${__THIRDPARTY_RECAST_PATH}/Source/Recast.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastAlloc.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastArea.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastAssert.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastContour.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastFilter.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastLayers.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastMesh.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastMeshDetail.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastRasterization.cpp"
			"${__THIRDPARTY_RECAST_PATH}/Source/RecastRegion.cpp"
	)
endif()
target_glob_sources(recast-lib PRIVATE "*.cpp")

