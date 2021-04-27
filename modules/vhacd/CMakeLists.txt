
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

add_module_lib(thirdparty-vhacd-lib
	OBJECT
	PARENT_LIB
		vhacd-lib
	COMPONENTS
		vhacd-env
)
target_sources_from_path(thirdparty-vhacd-lib PRIVATE "${__THIRDPARTY_VHACD_PATH}"
	"src/vhacdManifoldMesh.cpp"
	"src/FloatMath.cpp"
	"src/vhacdMesh.cpp"
	"src/vhacdICHull.cpp"
	"src/vhacdVolume.cpp"
	"src/VHACD-ASYNC.cpp"
	"src/btAlignedAllocator.cpp"
	"src/vhacdRaycastMesh.cpp"
	"src/VHACD.cpp"
	"src/btConvexHullComputer.cpp"
)

target_glob_sources(vhacd-lib PRIVATE "*.cpp")
