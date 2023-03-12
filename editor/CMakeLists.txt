
# basically creates a python dict value there keys are classes names, and values are those classes paths
function(__generate_python_class_map __OUTPUT __CLASSES_LIST __VALUES_SUFFIX)

	file(TO_CMAKE_PATH "${GODOT_SOURCE_DIR}" __ROOT_PATH)
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

if(GODOT_BUILD_TOOLS)
	add_lib(editor-lib 
		EXCLUDE_FROM_ALL
		COMPONENTS
			global-env
			warnings-env
		DEPENDENCIES
			core-lib
			scene-lib
	)
	register_global_lib(editor-lib)

	set(__REGISTER_EXPORTERS_FILE "register_exporters.gen.cpp")
	target_sources(editor-lib PRIVATE "${__REGISTER_EXPORTERS_FILE}")
	execute_python_method(editor_builders cmake_register_exporters
		PYTHON_ARGS
			STR_VAR "output_file=__REGISTER_EXPORTERS_FILE"
			ARR_VAR "modules=PLATFORMS_EXPORTERS"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	)
	
	foreach(__PLATFORM IN LISTS PLATFORMS_EXPORTERS)
		target_glob_sources(editor-lib PRIVATE "${GODOT_SOURCE_DIR}/platform/${__PLATFORM}/export/*.cpp")
	endforeach()

	file(GLOB __CLASSES_DOCS LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/doc/classes/*.xml")

	# each path in this variable is absolute, and unique, so no need for additional checks 
	foreach(__DOC_PATH IN LISTS CLASSES_DOC_PATHS)
		file(GLOB __TEMP_CLASSES_DOCS "${__DOC_PATH}/*.xml")
		list(APPEND __CLASSES_DOCS ${__TEMP_CLASSES_DOCS})
	endforeach()

	list(SORT __CLASSES_DOCS)
	# generating map for the python, from all godot docs.
	__generate_python_class_map(__PYTHON_CLASS_MAP MODULES_CLASSES _CLASS_PATH)
	execute_python_method(editor_builders cmake_make_doc_data_class_path
		PYTHON_ARGS
			STR_VAL "to_path=${GODOT_SOURCE_DIR}/editor/doc"
			RAW_VAR "class_map=__PYTHON_CLASS_MAP"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	)

	set(__GEN_HEADERS)

	set(__CLASSES_HEADER_FILE "${GODOT_SOURCE_DIR}/editor/doc_data_compressed.gen.h")
	list(APPEND __GEN_HEADERS ${__CLASSES_HEADER_FILE})
	add_python_generator_command(editor_builders cmake_make_doc_header
		SOURCE_FILES ${__CLASSES_DOCS}
		TARGET_FILES "${__CLASSES_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "docs_header"
	)
	
	# Editor interface and class reference translations incur a significant size
	# cost for the editor binary (see godot-proposals#3421).
	# To limit it, we only include translations with a high enough completion
	# ratio (30% for the editor UI, 10% for the class reference).
	# Generated with `make include-list` for each resource.
	# Note: In 3.x, we also exclude languages that depend on complex text
	# layouts to be displayed properly: ar,bn,fa,he,hi,ml,si,ta,te,ur.

	# Editor translations
	set(__EDITOR_TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/editor_translations.gen.h")
	set(__EDITOR_TRANSLATION_FILES 
		"bg;ca;cs;de;el;eo;es_AR;es;fi;fr;gl;hu;id;it;ja;ko;lv;ms;nb;nl;pl;pt_BR;pt;ro;ru;sk;sv;th;tr;uk;vi;zh_CN;zh_TW"
	)
	list(TRANSFORM __EDITOR_TRANSLATION_FILES APPEND ".po")
	list(TRANSFORM __EDITOR_TRANSLATION_FILES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/translations/")
	list(APPEND __GEN_HEADERS ${__EDITOR_TRANSLATION_HEADER_FILE})
	add_python_generator_command(editor_builders cmake_make_editor_translations_header
		SOURCE_FILES ${__EDITOR_TRANSLATION_FILES}
		TARGET_FILES "${__EDITOR_TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "editor_translations_header"
	)

	# Documentation translations
	set(__DOC_TRANSLATION_HEADER_FILE "${CMAKE_CURRENT_SOURCE_DIR}/doc_translations.gen.h")
	set(__DOC_TRANSLATION_FILES 
		"de;es;fr;ja;zh_CN"
	)
	list(TRANSFORM __DOC_TRANSLATION_FILES APPEND ".po")
	list(TRANSFORM __DOC_TRANSLATION_FILES PREPEND "${GODOT_SOURCE_DIR}/doc/translations/")
	list(APPEND __GEN_HEADERS ${__DOC_TRANSLATION_HEADER_FILE})
	add_python_generator_command(editor_builders cmake_make_doc_translations_header
		SOURCE_FILES ${__DOC_TRANSLATION_FILES}
		TARGET_FILES "${__DOC_TRANSLATION_HEADER_FILE}"
		APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
		BY_FILE "doc_translations_header"
	)

	# Fonts
	set(__FONTS_HEADER_FILE "${GODOT_SOURCE_DIR}/editor/builtin_fonts.gen.h")
	list(APPEND __GEN_HEADERS ${__FONTS_HEADER_FILE})

	file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/thirdparty/fonts/*.ttf")
	set(__FONTS_FILES ${__TEMP_FONTS_FILES})
	file(GLOB __TEMP_FONTS_FILES LIST_DIRECTORIES false "${GODOT_SOURCE_DIR}/thirdparty/fonts/*.otf")
	list(APPEND __FONTS_FILES ${__TEMP_FONTS_FILES})
	list(SORT __FONTS_FILES)
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
