
add_lib(hdr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(hdr-lib PRIVATE "*.cpp")
