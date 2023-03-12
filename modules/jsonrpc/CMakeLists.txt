
add_module_lib(jsonrpc-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(jsonrpc-lib PRIVATE "*.cpp")
