
# Order matters here. Higher index controller database files write on top of lower index database files.
set(__CONTROLLER_DATABASES_SOURCES
	"${CMAKE_CURRENT_SOURCE_DIR}/gamecontrollerdb.txt"
    "${CMAKE_CURRENT_SOURCE_DIR}/godotcontrollerdb.txt"
)

set(__DEFAULT_CONTROLLER_MAPPING_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/default_controller_mappings.gen.cpp")

add_python_generator_command(input_builders cmake_make_default_controller_mappings
	TARGET_FILES ${__DEFAULT_CONTROLLER_MAPPING_SOURCE}
	SOURCE_FILES ${__CONTROLLER_DATABASES_SOURCES}
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating default controller mappings."
)

add_custom_target(core-input-gen 
	DEPENDS
		${__DEFAULT_CONTROLLER_MAPPING_SOURCE}
)
add_dependencies(core-lib core-input-gen)

target_glob_sources(core-lib PRIVATE "*.cpp")