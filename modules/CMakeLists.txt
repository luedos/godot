
add_env(modules-env
	COMPONENTS
		global-env
)

add_lib(modules-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		modules-env
		global-warnings-env
	SOURCES
		"register_module_types.gen.cpp"
)

add_link_dependencies(modules-lib core-lib)

set(__MODULES_TEST_HEADERS "")
foreach(__MODULE_ID IN LISTS MODULES_LIST)

	add_subdirectory("${${__MODULE_ID}_MODULE_PATH}" "${CMAKE_CURRENT_BINARY_DIR}/modules/${__MODULE_ID}")

	file(GLOB __TEMP_MODULES_TESTS_HEADERS LIST_DIRECTORIES FALSE "${${__MODULE_ID}_MODULE_PATH}/tests/*.h")
	list(SORT __TEMP_MODULES_TESTS_HEADERS)
	list(APPEND __MODULES_TEST_HEADERS ${__TEMP_MODULES_TESTS_HEADERS})

endforeach()

set(__MODULES_ENABLED_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/modules_enabled.gen.h")
add_python_generator_command(modules_builders cmake_generate_modules_enabled
	TARGET_FILES "${__MODULES_ENABLED_HEADER}"
	PYTHON_ARGS
		ARR_VAR "module_list=MODULES_LIST"
	BY_FILE "modules_enabled_header_gen"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	CREATE_CUSTOM_TARGET modules-enabled-header-gen
	COMMENT "Generating enabled modules header."
)

add_dependencies(modules-lib modules-enabled-header-gen)

if (godot_tests)
	add_python_generator_command(modules_builders cmake_generate_modules_tests
		TARGET_FILES "${CMAKE_CURRENT_SOURCE_DIR}/modules_tests.gen.h"
		SOURCE_FILES ${__MODULES_TEST_HEADERS}
		BY_FILE "modules_tests_header_gen"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		CREATE_CUSTOM_TARGET modules-tests-header-gen
		COMMENT "Generating modules tests header."
	)
	add_dependencies(modules-lib modules-tests-header-gen)
endif()