
add_module_lib(gltf-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(gltf-lib PRIVATE "*.cpp")