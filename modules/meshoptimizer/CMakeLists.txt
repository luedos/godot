
add_lib(meshoptimizer-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(meshoptimizer-lib PRIVATE "*.cpp")

add_lib(thirdparty-meshoptimizer-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		thirdparty-warnings-env
)
set(__THIRDPARTY_MESHOPTIMIZER_PATH "${ENGINE_SOURCE_DIR}/thirdparty/meshoptimizer")
target_sources_from_path(thirdparty-meshoptimizer-lib PRIVATE "${__THIRDPARTY_MESHOPTIMIZER_PATH}"
	"allocator.cpp"
	"clusterizer.cpp"
	"indexcodec.cpp"
	"indexgenerator.cpp"
	"overdrawanalyzer.cpp"
	"overdrawoptimizer.cpp"
	"simplifier.cpp"
	"spatialorder.cpp"
	"stripifier.cpp"
	"vcacheanalyzer.cpp"
	"vcacheoptimizer.cpp"
	"vertexcodec.cpp"
	"vertexfilter.cpp"
	"vfetchanalyzer.cpp"
	"vfetchoptimizer.cpp"
)