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
# TODO: Not sure if this is correct, but this is still not fixed in current godot implementation, so just in case..
target_glob_sources(noise-lib PRIVATE "editor/*.cpp")

add_lib(thirdparty-noise-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		noise-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_NOISE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/noise")
target_sources_from_path(thirdparty-noise-lib PRIVATE "${__THIRDPARTY_NOISE_PATH}"
	# Add C++ source files for noise modules here
)

target_include_directories(noise-env INTERFACE "${__THIRDPARTY_NOISE_PATH}")