
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
target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.cpp")

if (godot_platform MATCHES "(macos|ios)")
	target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.mm")
	target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.m")
elseif (godot_platform STREQUAL "android")
	target_glob_sources(mono-lib PRIVATE "mono_gd/android_mono_config.gen.cpp")
endif()

if (godot_editor_build)
	# This is basically build_scripts.mono_configure.configure
	assert(
		"Mono module does not currently support building for '${godot_platform}' platform for editor builds."
		godot_platform MATCHES "(windows|macos|linuxbsd|uwp|haiku)"
	)
	target_compile_definitions(mono-lib PRIVATE "GD_MONO_HOT_RELOAD")


	target_glob_sources(mono-lib PRIVATE "editor/*.cpp")
	add_subdirectory("editor/script_templates")
endif()
