
add_module_lib(gdscript-lib
	COMPONENTS
		modules-env
		warnings-env
)

target_glob_sources(gdscript-lib PRIVATE "*.cpp")

# All this generator expression mumbo jumbo is added because we can't be sure if tools are actually enabled or not (when we are using multiconfgurational generator)

set(__IS_JSCONPC_AND_WEBSOCKET_GEN_EXPR $<AND:$<BOOL:${jsonrpc_IS_MODULE_ENABLED}>,$<BOOL:${websocket_IS_MODULE_ENABLED}>>)

file(GLOB __EDITOR_FILES LIST_DIRECTORIES false "${CMAKE_CURRENT_SOURCE_DIR}/editor/*.cpp")
file(GLOB __LANGUAGE_SERVER_FILES LIST_DIRECTORIES false "${CMAKE_CURRENT_SOURCE_DIR}/language_server/*.cpp")

target_sources(gdscript-lib PRIVATE
	$<${IS_TOOLS_GEN_EXPR}:${__EDITOR_FILES}> # if tools are enabled
)
target_sources(gdscript-lib PRIVATE
	$<$<AND:
		${IS_TOOLS_GEN_EXPR},  # if tools are enabled
		${__IS_JSCONPC_AND_WEBSOCKET_GEN_EXPR}  # and both jsonrpc and websocket modules are enabled
	>: ${__LANGUAGE_SERVER_FILES}> # we are adding language server files
)
target_compile_definitions(gdscript-lib PRIVATE
	$<$<AND:
		${IS_TOOLS_GEN_EXPR},  # if tools are enabled
		$<NOT:${__IS_JSCONPC_AND_WEBSOCKET_GEN_EXPR}>  # and any of jsonrpc and websocket modules are NOT enabled
	>: "GDSCRIPT_NO_LSP"> # adding define
)