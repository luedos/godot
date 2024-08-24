add_env(vhacd-env
	COMPONENTS
		modules-env
)

add_lib(vhacd-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		vhacd-env
		global-warnings-env
)
target_glob_sources(vhacd-lib PRIVATE "*.cpp")

add_lib(thirdparty-vhacd-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		vhacd-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_VHACD_PATH "${ENGINE_SOURCE_DIR}/thirdparty/vhacd")
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

target_include_directories(vhacd-env INTERFACE "${__THIRDPARTY_VHACD_PATH}/inc")