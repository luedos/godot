
add_lib(jsonrpc-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(jsonrpc-lib PRIVATE "*.cpp")
