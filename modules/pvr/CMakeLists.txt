
add_env(pvr-env
	COMPONENTS
		modules-env
)

add_module_lib(pvr-lib
	COMPONENTS
		pvr-env
		warnings-env
)

add_lib(thirdparty-pvr-lib
	OBJECT
	PARENT_LIB
		pvr-lib
	COMPONENTS
		pvr-env	
)

# Thirdparty source files
# Not unbundled so far since not widespread as shared library
set(__THIRDPARTY_PVR_PATH "${GODOT_SOURCE_DIR}/thirdparty/pvrtccompressor")

target_include_directories(pvr-env INTERFACE "${__THIRDPARTY_PVR_PATH}")

target_sources(thirdparty-pvr-lib PRIVATE 
	"${__THIRDPARTY_PVR_PATH}/BitScale.cpp"
	"${__THIRDPARTY_PVR_PATH}/MortonTable.cpp"
	"${__THIRDPARTY_PVR_PATH}/PvrTcDecoder.cpp"
	"${__THIRDPARTY_PVR_PATH}/PvrTcEncoder.cpp"
	"${__THIRDPARTY_PVR_PATH}/PvrTcPacket.cpp"
)

target_glob_sources(pvr-lib PRIVATE "*.cpp")