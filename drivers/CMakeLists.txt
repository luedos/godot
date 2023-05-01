
add_lib(drivers-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)

# OS drivers
add_subdirectory(unix)
add_subdirectory(windows)

# Sounds drivers
add_subdirectory("alsa")
add_subdirectory("coreaudio")
add_subdirectory("pulseaudio")

if (godot_platform STREQUAL "windows")
	add_subdirectory(wasapi)
endif()

if (godot_xaudio2)
	add_subdirectory(xaudio2)
endif()

# Midi drivers
add_subdirectory("alsamidi")
add_subdirectory("coremidi")
add_subdirectory("winmidi")

# Graphics drivers
if (godot_vulkan)
	add_subdirectory(vulkan)
endif()

if (godot_opengl3)
	add_subdirectory(gl_context)
	add_subdirectory(gles3)
endif()

# Core dependencies
add_subdirectory(png)

target_glob_sources(drivers-lib PRIVATE "*.cpp")
