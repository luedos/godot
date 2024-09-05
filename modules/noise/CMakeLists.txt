add_env(noise-env
	COMPONENTS
		modules-env
)

add_lib(noise-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		noise-env
		global-warnings-env
)
target_glob_sources(noise-lib PRIVATE "*.cpp")
target_glob_sources(noise-lib PRIVATE "editor/*.cpp")

set(__THIRDPARTY_NOISE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/noise")
target_include_directories(noise-env INTERFACE "${__THIRDPARTY_NOISE_PATH}")