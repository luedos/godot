
add_module_lib(fbx-lib
	COMPONENTS 
		modules-env
		warnings-env
)

target_include_directories(fbx-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

if (GODOT_BUILTIN_ZLIB)
	target_include_directories(fbx-lib PRIVATE "${GODOT_SOURCE_DIR}/thirdparty/zlib")
endif()

# Godot's own source files
target_glob_sources(fbx-lib PRIVATE "tools/*.cpp")
target_glob_sources(fbx-lib PRIVATE "data/*.cpp")
target_glob_sources(fbx-lib PRIVATE "fbx_parser/*.cpp")
target_glob_sources(fbx-lib PRIVATE "*.cpp")

