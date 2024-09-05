
target_glob_sources(scene-lib PRIVATE "*.cpp")

add_python_generator_command(default_theme_builders cmake_make_fonts_header
    TARGET_FILES "${CMAKE_CURRENT_SOURCE_DIR}/default_font.gen.h"
    SOURCE_FILES "${ENGINE_SOURCE_DIR}/thirdparty/fonts/OpenSans_SemiBold.woff2"
    WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
    APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
    CREATE_CUSTOM_TARGET default-theme-font-gen
)

add_dependencies(scene-env
    default-theme-font-gen
)

add_subdirectory(icons)