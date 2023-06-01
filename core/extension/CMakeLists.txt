set(__EXT_WRAPPERS_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/ext_wrappers.gen.inc")
add_python_generator_command(make_wrappers cmake_run
	TARGET_FILES "${__EXT_WRAPPERS_HEADER}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
)

set(__GDEXTENSION_INTERFACE_DUMP_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/gdextension_interface_dump.gen.h")
add_python_generator_command(make_interface_dumper cmake_run
	TARGET_FILES "${__GDEXTENSION_INTERFACE_DUMP_HEADER}"
	SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/gdextension_interface.h"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
)

add_custom_target(core-extention-gen 
	DEPENDS
		${__EXT_WRAPPERS_HEADER}
		${__GDEXTENSION_INTERFACE_DUMP_HEADER}
)
add_dependencies(core-lib core-extention-gen)

target_glob_sources(core-lib PRIVATE "*.cpp")