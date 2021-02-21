
file(GLOB __ICON_FILES LIST_DIRECTORIES false "*.svg") 

foreach(__ICON_PATH IN LISTS MODULES_ICONS_PATHS)
	# In theory __ICON_PATH is allways full path without a slash in the end
	file(GLOB __TEMP_ICON_FILES LIST_DIRECTORIES false "${__ICON_PATH}/*.svg")
	set(__ICON_FILES ${__ICON_FILES} ${__TEMP_ICON_FILES})
endforeach()

# If I understand correctly, scons Alias is basiacaly a custom target, so we will do the next thing:
set(__ICONS_HEADER "${GODOT_SOURCE_DIR}/editor/editor_icons.gen.h")
add_custom_target(editor_icons
	BYPRODUCTS "${__ICONS_HEADER}"
	DEPENDS ${__ICON_FILES}
	COMMAND "python" "-c" "import editor_icons_builders; editor_icons_builders.cmake_make_editor_icons_action(['${__ICONS_HEADER}'], str('${__ICON_FILES}').split(';'))"
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# I'am not sure if we need to, because I'm not sure if scons intended to build this custom target, but why the hell he will do it otherwise, right?
add_dependencies(editor-lib editor_icons)