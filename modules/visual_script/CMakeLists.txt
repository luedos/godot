
add_module_lib(vs-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(vs-lib PRIVATE "*.cpp")

