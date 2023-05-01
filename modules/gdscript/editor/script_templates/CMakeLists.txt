

file(GLOB_RECURSE __TEMPLATE_SOURCES LIST_DIRECTORIES FALSE "*.gd")

add_python_generator_command(template_builders cmake_make_templates
	MODULE_DIR "editor"
	TARGET_FILES "${CMAKE_CURRENT_SOURCE_DIR}/templates.gen.h"
	SOURCE_FILES ${__TEMPLATE_SOURCES}
	CREATE_CUSTOM_TARGET editor-template-gd-gen
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating GDScript templates header."
)

add_dependencies(gdscript-lib editor-template-gd-gen)