
target_glob_sources(core-lib PRIVATE "*.cpp")

if (GODOT_BUILD_TOOLS)
	define_lib_dependencies(core-lib 
		editor-lib
	)
endif()