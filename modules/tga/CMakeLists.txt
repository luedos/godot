
add_lib(tga-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(tga-lib PRIVATE "*.cpp")
