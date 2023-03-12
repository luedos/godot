
add_module_lib(gdscript-lib
	COMPONENTS
		modules-env
		warnings-env
	DEPENDENCIES
		core-lib
)

target_glob_sources(gdscript-lib PRIVATE "*.cpp")

if(GODOT_BUILD_TOOLS)
	target_glob_sources(gdscript-lib PRIVATE "editor/*.cpp")

	if(jsonrpc_IS_MODULE_ENABLED AND websocket_IS_MODULE_ENABLED)
		target_glob_sources(gdscript-lib PRIVATE "language_server/*.cpp")
	else()
		target_compile_definitions(gdscript-lib PRIVATE "GDSCRIPT_NO_LSP")
	endif()

endif()