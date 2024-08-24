
target_glob_sources(drivers-lib PRIVATE "*.cpp")
target_compile_definitions(global-env INTERFACE "XAUDIO2_ENABLED")
target_link_libraries(global-env INTERFACE "xaudio2_8.lib")