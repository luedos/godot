
add_env(drivers-env
	COMPONENTS
		global-env
)

add_lib(drivers-lib
	COMPONENTS
		drivers-env
		warnings-env
	DEPENDENCIES
		core-lib
		servers-lib
)
register_global_lib(drivers-lib)

# OS drivers
add_subdirectory(unix)
add_subdirectory(windows)

# Sounds drivers
add_subdirectory(alsa)
add_subdirectory(coreaudio)
add_subdirectory(pulseaudio)

if(GODOT_PLATFORM STREQUAL "windows")
	add_subdirectory(wasapi)
endif()

if(GODOT_XAUDIO2)
	add_subdirectory(xaudio2)
endif()

# Midi drivers
add_subdirectory(alsamidi)
add_subdirectory(coremidi)
add_subdirectory(winmidi)

# Graphics drivers
if(NOT GODOT_PLATFORM STREQUAL "server")
	add_subdirectory(gles3)
	add_subdirectory(gles2)
	add_subdirectory(gles_common)
	add_subdirectory(gl_context)
else()
	add_subdirectory(dummy)
endif()

# Core dependencies
add_subdirectory(png)

target_glob_sources(drivers-lib PRIVATE "*.cpp")
