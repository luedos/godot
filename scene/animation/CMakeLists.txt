
add_lib(thirdparty-scene-animation-lib
	OBJECT
	PARENT_LIB
		scene-lib
	COMPONENTS
		global-env
)

target_glob_sources(scene-lib PRIVATE "*.cpp")
