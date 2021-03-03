
add_env(ws-env
	COMPONENTS
		modules-env
)

add_module_lib(ws-lib
	COMPONENTS
		ws-env
		warnings-env
)

if(GODOT_BUILTIN_WSLAY AND NOT GODOT_PLATFORM STREQUAL "javascript")	

	set(__THIRDPARTY_WSLAY_PATH "${GODOT_SOURCE_DIR}/thirdparty/wslay")

	target_include_directories(ws-env INTERFACE "${__THIRDPARTY_WSLAY_PATH}/includes")
	target_compile_definitions(ws-env INTERFACE "HAVE_CONFIG_H")

	if(GODOT_PLATFORM MATCHES "(windows|uwp)")
		target_compile_definitions(ws-env INTERFACE "HAVE_WINSOCK2_H")
	else()
		target_compile_definitions(ws-env INTERFACE "HAVE_NETINET_IN_H")
	endif()

	add_lib(thirdparty-ws-lib
		OBJECT
		PARENT_LIB
			ws-lib
		COMPONENTS
			ws-env	
		SOURCES
        	"${__THIRDPARTY_WSLAY_PATH}/wslay_net.c"
        	"${__THIRDPARTY_WSLAY_PATH}/wslay_event.c"
        	"${__THIRDPARTY_WSLAY_PATH}/wslay_queue.c"
        	"${__THIRDPARTY_WSLAY_PATH}/wslay_stack.c"
        	"${__THIRDPARTY_WSLAY_PATH}/wslay_frame.c"
	)
endif()

target_glob_sources(ws-lib PRIVATE "*.cpp")
