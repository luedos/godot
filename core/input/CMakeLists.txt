
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
	CREATE_CUSTOM_TARGET core-input-gen
	COMMENT "Generating default controller mappings."
)

add_dependencies(core-lib core-input-gen)

set_source_files_properties("${__DEFAULT_CONTROLLER_MAPPING_SOURCE}"
	TARGET_DIRECTORY core-lib
	PROPERTIES GENERATED TRUE
)

file(GLOB __SOURCES LIST_DIRECTORIES FALSE "*.cpp")
append_file_to_list_unique(__SOURCES "${__DEFAULT_CONTROLLER_MAPPING_SOURCE}")

target_sources(core-lib PRIVATE ${__SOURCES})