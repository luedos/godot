
file(GLOB __ICON_SOURCES LIST_DIRECTORIES FALSE "*.svg")
add_python_generator_command(default_theme_icons_builders cmake_make_default_theme_icons_action
    TARGET_FILES "${ENGINE_SOURCE_DIR}/scene/theme/default_theme_icons.gen.h"
    SOURCE_FILES ${__ICON_SOURCES}
    WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
    APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
    CREATE_CUSTOM_TARGET default-theme-icons-gen
    COMMENT "Generating default project theme icons header."
)

add_dependencies(scene-env
    default-theme-icons-gen
)