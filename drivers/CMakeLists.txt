
add_lib(drivers-lib
	STANDALONE
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		warnings-env
)

# OS drivers
add_subdirectory(unix) #TODO: implement
add_subdirectory(windows) #TODO: implement

# Sounds drivers
add_subdirectory(alsa) #TODO: implement
add_subdirectory(coreaudio) #TODO: implement
add_subdirectory(pulseaudio) #TODO: implement

if(GODOT_PLATFORM STREQUAL "windows")
	add_subdirectory(wasapi) #TODO: implement
endif()

if(GODOT_XAUDIO2)
	add_subdirectory(xaudio2) #TODO: implement
endif()

# Midi drivers
add_subdirectory(alsamidi) #TODO: implement
add_subdirectory(coremidi) #TODO: implement
add_subdirectory(winmidi) #TODO: implement

# Graphics drivers
if(NOT GODOT_PLATFORM STREQUAL "server")
	add_subdirectory(gles3) #TODO: implement
	add_subdirectory(gles2) #TODO: implement
	add_subdirectory(gl_context) #TODO: implement
else()
	add_subdirectory(dummy) #TODO: implement
endif()

# Core dependencies
add_subdirectory(png) #TODO: implement

target_glob_sources(drivers-lib PRIVATE "*.cpp")
