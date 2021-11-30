
add_module_lib(minimp3-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_include_directories(minimp3-lib SYSTEM PRIVATE "${GODOT_SOURCE_DIR}/thirdparty/minimp3")
target_glob_sources(minimp3-lib PRIVATE "*.cpp")
