
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

add_lib(thirdparty-scene-lib
	OBJECT
	PARENT_LIB
		scene-lib
	COMPONENTS
		global-env
)

# Thirdparty code
set(__THIRDPARTY_MISC_DIR "${GODOT_SOURCE_DIR}/thirdparty/misc")
target_sources_from_path(thirdparty-scene-lib PRIVATE "${__THIRDPARTY_MISC_DIR}"
    # C++ sources
    "easing_equations.cpp"
    # C sources
    "mikktspace.c"
)

target_glob_sources(scene-lib PRIVATE "*.cpp")

add_subdirectory(main)
add_subdirectory(gui)
add_subdirectory(3d)
add_subdirectory(2d)
add_subdirectory(animation)
add_subdirectory(audio)
add_subdirectory(resources)
add_subdirectory(debugger)
