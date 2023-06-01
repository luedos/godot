set(__GDVIRTUAL_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/gdvirtual.gen.inc")
add_python_generator_command(make_virtuals cmake_run
	TARGET_FILES "${__GDVIRTUAL_HEADER}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	CREATE_CUSTOM_TARGET core-object-gen 
)

add_dependencies(core-env core-object-gen)

target_glob_sources(core-lib PRIVATE "*.cpp")