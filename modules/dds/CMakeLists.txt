
add_module_lib(dds-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(dds-lib PRIVATE "*.cpp")