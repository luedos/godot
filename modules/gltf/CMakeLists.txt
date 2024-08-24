
add_lib(gltf-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(gltf-lib PRIVATE "*.cpp")
target_glob_sources(gltf-lib PRIVATE "structures/*.cpp")

add_subdirectory(extensions)

if (godot_editor_build)
	target_glob_sources(gltf-lib PRIVATE "editor/*.cpp")
endif()
