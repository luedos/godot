target_glob_sources(servers-lib PRIVATE "*.cpp")

add_subdirectory("effects")
add_subdirectory("environment")
add_subdirectory("forward_clustered")
add_subdirectory("forward_mobile")
add_subdirectory("shaders")
add_subdirectory("spirv-reflect")
add_subdirectory("storage_rd")