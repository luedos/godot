
file(GLOB __ICON_FILES LIST_DIRECTORIES false "*.svg") 

foreach(__ICON_PATH IN LISTS MODULES_ICONS_PATHS)
	# In theory __ICON_PATH is allways full path without a slash in the end
	file(GLOB __TEMP_ICON_FILES LIST_DIRECTORIES false "${__ICON_PATH}/*.svg")
	set(__ICON_FILES ${__ICON_FILES} ${__TEMP_ICON_FILES})
endforeach()

# If I understand correctly, scons Alias is basiacaly a custom target, so we will do the next thing:
set(__ICONS_HEADER "${GODOT_SOURCE_DIR}/editor/editor_icons.gen.h")


add_python_generator_command(editor_icons_builders cmake_make_editor_icons_action
	SOURCE_FILES ${__ICON_FILES}
	TARGET_FILES "${__ICONS_HEADER}"
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	BY_FILE "icons"
)

add_custom_target(editor-icons-gen
	DEPENDS ${__ICONS_HEADER}
)

# I'am not sure if we need to, because I'm not sure if scons intended to build this custom target, but why the hell he will do it otherwise, right?
add_dependencies(editor-lib editor-icons-gen)