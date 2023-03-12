
get_target_property(__ALSA global-env ALSA)
if(__ALSA)
	target_sources(drivers-lib PRIVATE "asound-so_wrap.c")
endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")
