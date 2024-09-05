
add_lib(jsonrpc-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(jsonrpc-lib PRIVATE "*.cpp")

if (godot_tests)
	target_compile_definitions(jsonrpc-lib PRIVATE "TESTS_ENABLED")
	target_glob_sources(jsonrpc-lib PRIVATE "tests/*.cpp")

	if (godot_disable_exceptions)
		target_compile_definitions(jsonrpc-lib PRIVATE "DOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS")
	endif()
endif()