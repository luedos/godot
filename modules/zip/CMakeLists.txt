
add_lib(zip-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(zip-lib PRIVATE "*.cpp")