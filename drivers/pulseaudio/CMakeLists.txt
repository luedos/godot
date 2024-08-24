
if (godot_pulseaudio AND godot_use_sowrap)
	target_sources(drivers-lib PRIVATE "pulse-so_wrap.c")
endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")