
add_lib(csg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(csg-lib PRIVATE "*.cpp")

if (godot_editor_build)
	target_glob_sources(csg-lib PRIVATE "editor/*.cpp")
endif()