
# Fonts
set(__FONTS_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/builtin_fonts.gen.h")

file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/thirdparty/fonts/*.ttf")
set(__FONTS_FILES ${__TEMP_FONTS_FILES})

file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/thirdparty/fonts/*.otf")
list(APPEND __FONTS_FILES ${__TEMP_FONTS_FILES})

file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/thirdparty/fonts/*.woff")
list(APPEND __FONTS_FILES ${__TEMP_FONTS_FILES})

file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/thirdparty/fonts/*.woff2")
list(APPEND __FONTS_FILES ${__TEMP_FONTS_FILES})

list(SORT __FONTS_FILES)
add_python_generator_command(editor_theme_builders cmake_make_fonts_header
	SOURCE_FILES ${__FONTS_FILES}
	TARGET_FILES "${__FONTS_HEADER_FILE}"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	BY_FILE "fonts_header"
)

add_custom_target(editor-fonts-gen
	DEPENDS
		${__FONTS_HEADER_FILE}
)
add_dependencies(editor-env editor-fonts-gen)

target_glob_sources(editor-lib PRIVATE "*.cpp")