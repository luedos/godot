
add_module_lib(csg-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(csg-lib PRIVATE "*.cpp")

