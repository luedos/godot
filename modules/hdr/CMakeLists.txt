
add_module_lib(hdr-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(hdr-lib PRIVATE "*.cpp")
