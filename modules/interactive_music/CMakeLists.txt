
add_lib(interactive-music-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)

target_glob_sources(interactive-music-lib PRIVATE "*.cpp")
if (EDITOR_BUILD)
	target_glob_sources(interactive-music-lib PRIVATE "editor/*.cpp")
endif()
