
add_module_lib(lightmapper-rd-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_include_directories(lightmapper-rd-lib PRIVATE "${GODOT_SOURCE_DIR}/thirdparty/embree/include")
target_glob_sources(jlightmapper-rd-lib PRIVATE "*.cpp")
