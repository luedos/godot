
add_lib(multiplayer-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(multiplayer-lib PRIVATE "*.cpp")

if (EDITOR_BUILD)
	target_glob_sources(multiplayer-lib PRIVATE "editor/*.cpp")
endif()