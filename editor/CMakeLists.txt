
# basically creates a python dict value there keys are classes names, and values are those classes paths
function(__generate_python_class_map __OUTPUT __CLASSES_LIST __VALUES_SUFFIX)

	file(TO_CMAKE_PATH "${ENGINE_SOURCE_DIR}" __ROOT_PATH)
	string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" __REGEX_ROOT_PATH "${__ROOT_PATH}")

	set(__PYTHON_DOC_MAP "{")
	set(__FIRST true)
	foreach(__CLASS IN LISTS ${__CLASSES_LIST})
		if(__FIRST)
			set(__FIRST false)
		else()
			set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP},")
		endif()

		# All classes paths are usually absolute paths, but build in paths we need to make relative
		file(TO_CMAKE_PATH "${${__CLASS}${__VALUES_SUFFIX}}" __CLASS_PATH)
		if(__CLASS_PATH MATCHES "^${__REGEX_ROOT_PATH}.*")
			file(RELATIVE_PATH __CLASS_PATH "${__ROOT_PATH}" "${__CLASS_PATH}")
		endif()

		set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP} '${__CLASS}':'${__CLASS_PATH}'")
	endforeach()

	set(__PYTHON_DOC_MAP "${__PYTHON_DOC_MAP} }")
	set(${__OUTPUT} "${__PYTHON_DOC_MAP}" PARENT_SCOPE)

endfunction()

if(EDITOR_BUILD)
	add_env(editor-env
		COMPONENTS
			global-env
	)

	add_lib(editor-lib 
		EXCLUDE_FROM_ALL
		PARENT_ENV
			global-libs-list
		COMPONENTS
			editor-env
			global-warnings-env
	)

	add_link_dependencies(editor-lib
		core-lib
		scene-lib
		servers-lib
		# This is required because editor is dependent on gles generated headers
		drivers-lib
	)

	add_dependencies(editor-lib 
		# This is required for export icons
		platform-gen
	)

	__generate_python_class_map(__PYTHON_CLASS_MAP "MODULES_DOC_CLASSES;PLATFORMS_DOC_CLASSES" _CLASS_PATH)
	set(__DOC_DATA_CLASS_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/doc_data_class_path.gen.h")
	execute_python_method(editor_builders cmake_doc_data_class_path_builder
		PYTHON_ARGS
			STR_VAR "target=__DOC_DATA_CLASS_HEADER"
			RAW_VAR "source=__PYTHON_CLASS_MAP"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		ACTION_CACHE_NAME "doc_data_class_path_builder"
		DEPENDENT_FILES "${__DOC_DATA_CLASS_HEADER}"
	)

	set(__REGISTER_EXPORTERS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/register_exporters.gen.cpp")
	target_sources(editor-lib PRIVATE "${__REGISTER_EXPORTERS_FILE}")
	execute_python_method(editor_builders cmake_register_exporters_builder
		PYTHON_ARGS
			STR_VAR "target=__REGISTER_EXPORTERS_FILE"
			ARR_VAR "source=PLATFORMS_EXPORTERS"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		ACTION_CACHE_NAME "make_register_exporters"
		DEPENDENT_FILES "${__REGISTER_EXPORTERS_FILE}"
	)
	
	foreach(__PLATFORM IN LISTS PLATFORMS_EXPORTERS)
		target_glob_sources(editor-lib PRIVATE "${ENGINE_SOURCE_DIR}/platform/${__PLATFORM}/export/*.cpp")
	endforeach()

	file(GLOB __CLASSES_DOCS LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/doc/classes/*.xml")

	# each path in this variable is absolute, and unique, so no need for additional checks 
	foreach(__DOC_PATH IN LISTS MODULES_DOC_CLASS_PATHS PLATFORMS_DOC_CLASS_PATHS)
		file(GLOB __TEMP_CLASSES_DOCS LIST_DIRECTORIES FALSE "${__DOC_PATH}/*.xml")
		list(APPEND __CLASSES_DOCS ${__TEMP_CLASSES_DOCS})
	endforeach()

	list(SORT __CLASSES_DOCS)

	set(__GEN_HEADERS)

	set(__CLASSES_HEADER_FILE "${ENGINE_SOURCE_DIR}/editor/doc_data_compressed.gen.h")
	list(APPEND __GEN_HEADERS "${__CLASSES_HEADER_FILE}")
	add_python_generator_command(editor_builders cmake_make_doc_header
		SOURCE_FILES ${__CLASSES_DOCS}
		TARGET_FILES "${__CLASSES_HEADER_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		BY_FILE "docs_header"
	)

	# Editor interface and class reference translations incur a significant size
	# cost for the editor binary (see godot-proposals#3421).
	# To limit it, we only include translations with a high enough completion
	# ratio (20% for the editor UI, 10% for the class reference).
	# Generated with `make include-list` for each resource.

	# Editor translations
	set(__TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/editor_translations.gen.h")
	list(APPEND __GEN_HEADERS "${__TRANSLATION_HEADER_FILE}")
	file(GLOB __TRANSLATIONS_LIST LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/editor/translations/editor/*.po")
	add_python_generator_command(editor_builders cmake_make_editor_translations_header
		SOURCE_FILES ${__TRANSLATIONS_LIST}
		TARGET_FILES "${__TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		BY_FILE "editor_translations_header"
	)

	# Property translations
	set(__TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/property_translations.gen.h")
	list(APPEND __GEN_HEADERS "${__TRANSLATION_HEADER_FILE}")
	file(GLOB __TRANSLATIONS_LIST LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/editor/translations/properties/*.po")
	add_python_generator_command(editor_builders cmake_make_property_translations_header
		SOURCE_FILES ${__TRANSLATIONS_LIST}
		TARGET_FILES "${__TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		BY_FILE "property_translations_header"
	)

	# Documentation translations
	set(__TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/doc_translations.gen.h")
	list(APPEND __GEN_HEADERS "${__TRANSLATION_HEADER_FILE}")
	file(GLOB __TRANSLATIONS_LIST LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/doc/translations/*.po")
	add_python_generator_command(editor_builders cmake_make_doc_translations_header
		SOURCE_FILES ${__TRANSLATIONS_LIST}
		TARGET_FILES "${__TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		BY_FILE "doc_translations_header"
	)

	# Extractable translations
	set(__TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/extractable_translations.gen.h")
	list(APPEND __GEN_HEADERS "${__TRANSLATION_HEADER_FILE}")
	file(GLOB __TRANSLATIONS_LIST LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/editor/translations/extractable/*.po")
	file(GLOB __TEMP_TRANSLATIONS_LIST LIST_DIRECTORIES FALSE "${ENGINE_SOURCE_DIR}/editor/translations/extractable/extractable.pot")
	list(APPEND __TRANSLATIONS_LIST ${__TEMP_TRANSLATIONS_LIST})

	add_python_generator_command(editor_builders cmake_make_extractable_translations_header
		SOURCE_FILES ${__TRANSLATIONS_LIST}
		TARGET_FILES "${__TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		BY_FILE "extractable_translations_header"
	)

	add_custom_target(editor-gen
		DEPENDS
			${__GEN_HEADERS}
	)
	add_dependencies(editor-env editor-gen)

	target_sources(editor-lib PRIVATE ${__REGISTER_EXPORTERS_FILE})
	target_glob_sources(editor-lib PRIVATE "*.cpp")

	add_subdirectory(debugger)
	add_subdirectory(export)
	add_subdirectory(gui)
	add_subdirectory(icons)
	add_subdirectory(import)
	add_subdirectory(plugins)
	add_subdirectory(project_manager)
	add_subdirectory(themes)
endif()
