
add_lib(bmp-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(bmp-lib PRIVATE "*.cpp")