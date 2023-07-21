add_env(etcpak-env
	COMPONENTS
		modules-env
)

add_lib(etcpak-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		etcpak-env
		global-warnings-env
)
target_glob_sources(etcpak-lib PRIVATE "*.cpp")

add_lib(thirdparty-etcpak-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		etcpak-env
		thirdparty-warnings-env
)
set(__THIRDPARTY_ETCPAK_PATH "${ENGINE_SOURCE_DIR}/thirdparty/etcpak")
target_sources_from_path(thirdparty-etcpak-lib PRIVATE "${__THIRDPARTY_ETCPAK_PATH}"
	"Dither.cpp"
	"ProcessDxtc.cpp"
	"ProcessRGB.cpp"
	"Tables.cpp"
)

target_include_directories(etcpak-env INTERFACE "${__THIRDPARTY_ETCPAK_PATH}")