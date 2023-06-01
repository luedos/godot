
add_lib(minimp3-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(minimp3-lib PRIVATE "*.cpp")

# Treat minimp3 headers as system headers to avoid raising warnings.
target_include_directories(minimp3-lib SYSTEM PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/minimp3")