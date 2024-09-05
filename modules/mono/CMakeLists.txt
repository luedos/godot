
add_lib(mono-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)

target_glob_sources(mono-lib PRIVATE "*.cpp")
target_glob_sources(mono-lib PRIVATE "glue/*.cpp")
target_glob_sources(mono-lib PRIVATE "mono_gd/*.cpp")
target_glob_sources(mono-lib PRIVATE "utils/*.cpp")

if (EDITOR_BUILD)
	# This is basically build_scripts.mono_configure.configure
	assert(
		"Mono module does not currently support building for '${godot_platform}' platform."
		"mono" IN_LIST PLATFORM_SUPPORTS
	)
	target_compile_definitions(mono-lib PRIVATE "GD_MONO_HOT_RELOAD")


	target_glob_sources(mono-lib PRIVATE "editor/*.cpp")
	add_subdirectory("editor/script_templates")
endif()
