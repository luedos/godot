
file(GLOB_RECURSE __TEMPLATE_SOURCES LIST_DIRECTORIES FALSE "*.cs")

add_python_generator_command(template_builders cmake_make_templates
	MODULE_DIR "editor"
	SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/templates.gen.h"
	TARGET_FILES ${__TEMPLATE_SOURCES}
	CREATE_CUSTOM_TARGET editor-template-cs-gen
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating C# templates header."
)

add_dependencies(mono-lib editor-template-cs-gen)