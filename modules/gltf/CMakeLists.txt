
add_module_lib(gltf-lib
	COMPONENTS
		modules-env
		warnings-env
)

# I really interested why this is done in scons, 
# considering all files in the same folder anyway,
# but ok..
target_include_directories(gltf-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

target_glob_sources(gltf-lib PRIVATE "*.cpp")