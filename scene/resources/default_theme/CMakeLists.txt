
target_glob_sources(scene-lib PRIVATE "*.cpp")

add_python_generator_command(default_theme_builders cmake_make_fonts_header
	TARGET_FILES "${CMAKE_CURRENT_SOURCE_DIR}/default_font.gen.h"
	SOURCE_FILES "${ENGINE_SOURCE_DIR}/thirdparty/fonts/OpenSans_SemiBold.woff2"
	WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
	CREATE_CUSTOM_TARGET default-theme-font-gen
)

file(GLOB __ICON_SOURCES LIST_DIRECTORIES FALSE "*.svg")
add_python_generator_command(default_theme_builders cmake_make_fonts_header
	TARGET_FILES "${CMAKE_CURRENT_SOURCE_DIR}/default_theme_icons.gen.h"
	SOURCE_FILES ${__ICON_SOURCES}
	WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
	CREATE_CUSTOM_TARGET default-theme-icons-gen
	COMMENT "Generating default project theme icons header."
)

add_dependencies(scene-lib
	default-theme-icons-gen
	default-theme-font-gen
)