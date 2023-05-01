
add_lib(mobilevr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(mobilevr-lib PRIVATE "*.cpp")
