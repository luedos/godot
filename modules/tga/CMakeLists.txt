
add_module_lib(tga-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(tga-lib PRIVATE "*.cpp")

