
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

add_link_dependencies(modules-lib
	core-lib
	servers-lib
)

target_compile_definitions(modules-env INTERFACE "GODOT_MODULE")

set(__MODULES_TEST_HEADERS_LIST "")
foreach(__MODULE_ID IN LISTS MODULES_LIST)

	add_subdirectory("${${__MODULE_ID}_MODULE_PATH}" "${CMAKE_CURRENT_BINARY_DIR}/modules/${__MODULE_ID}")

	if (godot_tests)
		file(GLOB __TEMP_MODULES_TESTS_HEADERS LIST_DIRECTORIES FALSE "${${__MODULE_ID}_MODULE_PATH}/tests/*.h")
		list(SORT __TEMP_MODULES_TESTS_HEADERS)
		list(APPEND __MODULES_TEST_HEADERS_LIST ${__TEMP_MODULES_TESTS_HEADERS})
	endif()
endforeach()

set(__MODULES_ENABLED_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/modules_enabled.gen.h")
execute_python_method(cmake_modules_builders modules_enabled_builder
	PYTHON_ARGS
		STR_VAR "target=__MODULES_ENABLED_HEADER"
		ARR_VAR "source=MODULES_LIST"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	ACTION_CACHE_NAME "generate_modules_enabled"
	DEPENDENT_FILES "${__MODULES_ENABLED_HEADER}"
)

set(__MODULES_DETECTED_PYTHON_MAP "{")
set(__FIRST TRUE)
foreach (__MODULE_ID IN LISTS MODULES_IDS)
	if (__FIRST)
		set (__FIRST FALSE)
	else()
		string(APPEND __MODULES_DETECTED_PYTHON_MAP ",")
	endif()

	string(APPEND __MODULES_DETECTED_PYTHON_MAP "'${__MODULE_ID}':'${${__MODULE_ID}_MODULE_PATH}'")
endforeach()
string(APPEND __MODULES_DETECTED_PYTHON_MAP "}")

set(__MODULES_DETECTED_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/register_module_types.gen.cpp")
execute_python_method(cmake_modules_builders register_module_types_builder
	PYTHON_ARGS
		STR_VAR "target=__MODULES_DETECTED_SOURCE"
		RAW_VAR "source=__MODULES_DETECTED_PYTHON_MAP"
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	ACTION_CACHE_NAME "register_module_types"
	DEPENDENT_FILES "${__MODULES_DETECTED_SOURCE}"
)

if (godot_tests)
	set(__MODULES_TEST_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/modules_tests.gen.h")
	add_python_generator_command(cmake_modules_builders modules_tests_builder
		TARGET_FILES "${__MODULES_TEST_HEADER}"
		SOURCE_FILES ${__MODULES_TEST_HEADERS_LIST}
		BY_FILE "modules_tests_header_gen"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		CREATE_CUSTOM_TARGET modules-tests-header-gen
	)
	add_dependencies(modules-lib modules-tests-header-gen)
endif()