
add_module_lib(gridmap-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(gridmap-lib PRIVATE "*.cpp")
