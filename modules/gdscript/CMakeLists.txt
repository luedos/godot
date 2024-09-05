
add_lib(gdscript-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(gdscript-lib PRIVATE "*.cpp")

if (EDITOR_BUILD)
	target_glob_sources(gdscript-lib PRIVATE "editor/*.cpp")
	add_subdirectory("editor/script_templates")

	if (godot_module_jsonrpc_enabled AND godot_module_websocket_enabled)
		target_glob_sources(gdscript-lib PRIVATE "language_server/*.cpp")
	else()
        # Using a define in the disabled case, to avoid having an extra define
        # in regular builds where all modules are enabled.
        # Also needed in main env to unexpose --lsp-port option.
		target_compile_definitions(global-env PRIVATE "GDSCRIPT_NO_LSP")
	endif()
endif()

if (godot_tests)
	target_compile_definitions(gdscript-lib PRIVATE "TESTS_ENABLED")
	target_glob_sources(gdscript-lib PRIVATE "tests/*.cpp")
endif()