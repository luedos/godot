
file(GLOB __ICON_FILES LIST_DIRECTORIES FALSE "*.svg") 

foreach(__ICON_PATH IN LISTS MODULES_ICONS_PATHS)
	# In theory __ICON_PATH is always absolute path without a slash in the end
	file(GLOB __TEMP_ICON_FILES LIST_DIRECTORIES FALSE "${__ICON_PATH}/*.svg")
	list(APPEND __ICON_FILES ${__TEMP_ICON_FILES})
endforeach()

set(__ICONS_HEADER "${ENGINE_SOURCE_DIR}/editor/editor_icons.gen.h")

add_python_generator_command(editor_icons_builders cmake_make_editor_icons_action
	SOURCE_FILES ${__ICON_FILES}
	TARGET_FILES "${__ICONS_HEADER}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	CREATE_CUSTOM_TARGET editor-icons-gen
	BY_FILE "editor_icons"
	COMMENT "Generating editor icons header."
)

# I'm not sure if we need to, because I'm not sure if scons intended to build this custom target, but why the hell he will do it otherwise, right?
add_dependencies(editor-lib editor-icons-gen)