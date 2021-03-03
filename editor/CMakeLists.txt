
function(generate_python_map __OUTPUT __KEYS_VAR __VALUES_SUFFIX)
	set(__PYTHON_DOC_MAP "{")
	set(__FIRST true)
	foreach(__CLASS IN LISTS ${__KEYS_VAR})
		if(NOT __FIRST)
			set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP},")
		else()
			set(__FIRST false)
		endif()

		set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP} '${__CLASS}':'${${__CLASS}${__VALUES_SUFFIX}}'")
	endforeach()

	set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP} }")
	set(${__OUTPUT} "${__PYTHON_DOC_MAP}" PARENT_SCOPE)
endfunction()

# Important note: even if GODOT_BUILD_TOOLS option is true, it still can become false in build time.
# This can happend if we use multiconfigurational generator, which start to build our project in the Release/MinSizeRel mode.
# If this happends, we simply will not include our library into final executable using generator expression.
# So for now, even if we use multiconfigurational generator, we still will create target for our editor library, and worry about using it later.
if(GODOT_BUILD_TOOLS)
	add_lib(editor-lib 
		EXCLUDE_FROM_ALL
		COMPONENTS
			global-env
			warnings-env
	)

	target_link_libraries(global-libs-list INTERFACE $<${IS_TOOLS_GEN_EXPR}:editor-lib>)
	if(MSVC)
		# because visual studio can't define dependency which based on build type, this library will not be build otherwise
		add_dependencies(global-libs-list editor-lib)
	endif()

	set(__REGISTER_EXPORTERS_FILE "register_exporters.gen.cpp")
	target_sources(editor-lib PRIVATE "${__REGISTER_EXPORTERS_FILE}")
	execute_python_method(editor_builders cmake_register_exporters
		PYTHON_ARGS
			STR_VAR "output_file=__REGISTER_EXPORTERS_FILE"
			ARR_VAR "modules=PLATFORMS_EXPORTERS"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	)
	
	foreach(__PLATFORM IN LISTS PLATFORMS_EXPORTERS)
		target_sources(editor-lib PRIVATE "${GODOT_SOURCE_DIR}/platform/${__PLATFORM}/export/export.cpp")
	endforeach()

	file(GLOB __CLASSES_DOCS LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/doc/classes/*.xml")

	# each path in this variable is absolute, and unique, so no need for additional checks 
	foreach(__DOC_PATH IN LISTS CLASSES_DOC_PATHS)
		file(GLOB __TEMP_CLASSES_DOCS "${__DOC_PATH}/*.xml")
		list(APPEND __CLASSES_DOCS ${__TEMP_CLASSES_DOCS})
	endforeach()

	# generating map for the python, from all godot docs.
	generate_python_map(__PYTHON_CLASS_MAP MODULES_CLASSES _CLASS_PATH)
	execute_python_method(editor_builders cmake_make_doc_data_class_path
		PYTHON_ARGS
			STR_VAL "to_path=${GODOT_SOURCE_DIR}/editor/doc"
			RAW_VAR "class_map=__PYTHON_CLASS_MAP"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	)

	set(__GEN_HEADERS "")

	set(__CLASSES_HEADER_FILE "${GODOT_SOURCE_DIR}/editor/doc_data_compressed.gen.h")
	list(APPEND __GEN_HEADERS ${__CLASSES_HEADER_FILE})
	add_python_generator_command(editor_builders cmake_make_doc_header
		SOURCE_FILES ${__CLASSES_DOCS}
		TARGET_FILES "${__CLASSES_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "docs_header"
	)

	# Translations
	set(__TRANSLATION_HEADER_FILE "${GODOT_SOURCE_DIR}/editor/translations.gen.h")
	list(APPEND __GEN_HEADERS ${__TRANSLATION_HEADER_FILE})
	file(GLOB __TRANSLATION_FILES LIST_DIRECTORIES false "${CMAKE_CURRENT_SOURCE_DIR}/translations/*.po")
	add_python_generator_command(editor_builders cmake_make_translations_header
		SOURCE_FILES ${__TRANSLATION_FILES}
		TARGET_FILES "${__TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "translations_header"
	)

    # Fonts
	set(__FONTS_HEADER_FILE "${GODOT_SOURCE_DIR}/editor/builtin_fonts.gen.h")
	list(APPEND __GEN_HEADERS ${__FONTS_HEADER_FILE})

    file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/thirdparty/fonts/*.ttf")
    set(__FONTS_FILES ${__TEMP_FONTS_FILES})
    file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/thirdparty/fonts/*.otf")
    set(__FONTS_FILES ${__FONTS_FILES} ${__TEMP_FONTS_FILES})
	add_python_generator_command(editor_builders cmake_make_fonts_header
		SOURCE_FILES ${__FONTS_FILES}
		TARGET_FILES "${__FONTS_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "fonts_header"
	)

	add_custom_target(editor-gen
		DEPENDS
			${__GEN_HEADERS}
	)
	add_dependencies(editor-lib editor-gen)

	target_glob_sources(editor-lib PRIVATE "*.cpp")

	add_subdirectory(collada)
	add_subdirectory(doc)
	add_subdirectory(fileserver)
	add_subdirectory(icons)
	add_subdirectory(import)
	add_subdirectory(plugins)
endif()
