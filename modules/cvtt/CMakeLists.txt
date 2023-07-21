add_env(cvtt-env
	COMPONENTS
		global-env
)

add_lib(cvtt-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		cvtt-env
		global-warnings-env
)
target_glob_sources(cvtt-lib PRIVATE "*.cpp")

add_lib(thirdparty-cvtt-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		cvtt-env
		thirdparty-warnings-env
)
set(__THIRDPARTY_CVTT_PATH "${ENGINE_SOURCE_DIR}/thirdparty/cvtt")
target_sources_from_path(thirdparty-cvtt-lib PRIVATE "${__THIRDPARTY_CVTT_PATH}"
	"ConvectionKernels_API.cpp"
	"ConvectionKernels_ETC.cpp"
	"ConvectionKernels_BC67.cpp"
	"ConvectionKernels_IndexSelector.cpp"
	"ConvectionKernels_BC6H_IO.cpp"
	"ConvectionKernels_S3TC.cpp"
	"ConvectionKernels_BC7_PrioData.cpp"
	"ConvectionKernels_SingleFile.cpp"
	"ConvectionKernels_BCCommon.cpp"
	"ConvectionKernels_Util.cpp"
)

target_include_directories(cvtt-env INTERFACE "${__THIRDPARTY_CVTT_PATH}")