
add_lib(scene-lib
	COMPONENTS
		global-env
		warnings-env
	DEPENDENCIES
		servers-lib
)
if (GODOT_BUILD_TOOLS)
	define_lib_dependencies(scene-lib
		editor-lib
	)
endif()

if (freetype_IS_MODULE_ENABLED)
	if(GODOT_SPLIT_LIBMODULES)
		define_lib_dependencies(scene-lib freetype-lib)
	else()
		define_lib_dependencies(scene-lib modules-lib)
	endif()
endif()

register_global_lib(scene-lib)

target_glob_sources(scene-lib PRIVATE "*.cpp")

add_subdirectory(main)
add_subdirectory(gui)
add_subdirectory(3d)
add_subdirectory(2d)
add_subdirectory(animation)
add_subdirectory(audio)
add_subdirectory(resources)
add_subdirectory(debugger)
