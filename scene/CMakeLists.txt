
add_lib(scene-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		warnings-env
)

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
