
add_module_lib(bmp-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(bmp-lib PRIVATE "*.cpp")