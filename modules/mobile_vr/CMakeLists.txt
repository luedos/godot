
add_module_lib(mobile-vr-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(mobile-vr-lib PRIVATE "*.cpp")
