
if (godot_alsa AND godot_use_sowrap)
	target_sources(drivers-lib PRIVATE "asound-so_wrap.c")
endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")