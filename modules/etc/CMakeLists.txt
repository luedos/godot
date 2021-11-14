
add_env(etc-env
	COMPONENTS
		modules-env
)

add_module_lib(etc-lib
	COMPONENTS
		etc-env
		warnings-env
)

set(__THIRDPARTY_ETC_PATH "${GODOT_SOURCE_DIR}/thirdparty/etc2comp")

target_include_directories(etc-env INTERFACE "${__THIRDPARTY_ETC_PATH}")

add_module_lib(thirdparty-etc-lib
	OBJECT
	PARENT_LIB
		etc-lib
	COMPONENTS
		etc-env
)

# Thirdparty source files
# Not unbundled so far since not widespread as shared library
target_sources_from_path(thirdparty-etc-lib PRIVATE "${__THIRDPARTY_ETC_PATH}"
	"EtcBlock4x4.cpp"
	"EtcBlock4x4Encoding.cpp"
	"EtcBlock4x4Encoding_ETC1.cpp"
	"EtcBlock4x4Encoding_R11.cpp"
	"EtcBlock4x4Encoding_RG11.cpp"
	"EtcBlock4x4Encoding_RGB8A1.cpp"
	"EtcBlock4x4Encoding_RGB8.cpp"
	"EtcBlock4x4Encoding_RGBA8.cpp"
	"Etc.cpp"
	"EtcDifferentialTrys.cpp"
	"EtcFilter.cpp"
	"EtcImage.cpp"
	"EtcIndividualTrys.cpp"
	"EtcMath.cpp"
	"EtcSortedBlockList.cpp"
)

# Godot source files
target_glob_sources(etc-lib PRIVATE "*.cpp")
