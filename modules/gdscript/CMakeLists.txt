
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

	inline_if(__IS_JSCONPC_AND_WEBSOCKET 
		jsonrpc_IS_MODULE_ENABLED AND websocket_IS_MODULE_ENABLED
	)
	if(__IS_JSCONPC_AND_WEBSOCKET)
		target_glob_sources(gdscript-lib PRIVATE "language_server/*.cpp")
	else()
		target_compile_definitions(gdscript-lib PRIVATE "GDSCRIPT_NO_LSP")
	endif()

endif()