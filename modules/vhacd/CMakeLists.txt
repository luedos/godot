
add_env(vhacd-env
	COMPONENTS
		modules-env
)

add_module_lib(vhacd-lib
	COMPONENTS
		vhacd-env
		warnings-env
)

set(__THIRDPARTY_VHACD_PATH "${GODOT_SOURCE_DIR}/thirdparty/vhacd")

target_include_directories(vhacd-env INTERFACE "${__THIRDPARTY_VHACD_PATH}/inc")

add_lib(thirdparty-vhacd-lib
	OBJECT
	PARENT_LIB
		vhacd-lib
	COMPONENTS
		vhacd-env	
	SOURCES
	    "${__THIRDPARTY_VHACD_PATH}/src/vhacdManifoldMesh.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/FloatMath.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/vhacdMesh.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/vhacdICHull.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/vhacdVolume.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/VHACD-ASYNC.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/btAlignedAllocator.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/vhacdRaycastMesh.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/VHACD.cpp"
	    "${__THIRDPARTY_VHACD_PATH}/src/btConvexHullComputer.cpp"
)

target_glob_sources(vhacd-lib PRIVATE "*.cpp")
