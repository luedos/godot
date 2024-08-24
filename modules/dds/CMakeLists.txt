
add_lib(dds-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(dds-lib PRIVATE "*.cpp")
