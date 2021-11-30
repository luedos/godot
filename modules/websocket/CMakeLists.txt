
add_env(ws-env
	COMPONENTS
		modules-env
)

add_module_lib(ws-lib
	COMPONENTS
		ws-env
		warnings-env
)

if(GODOT_PLATFORM STREQUAL "javascript")
	#TODO: Actially implement function target_add_js_library
	# This function basically should add input files input target_link_libraries as '--js-library "<library>"'
	target_add_js_library(global-libs-list "library_godot_websocket.js")
endif()

if(GODOT_BUILTIN_WSLAY)	

	set(__THIRDPARTY_WSLAY_PATH "${GODOT_SOURCE_DIR}/thirdparty/wslay")

	target_include_directories(ws-env INTERFACE "${__THIRDPARTY_WSLAY_PATH}/includes")
	target_compile_definitions(ws-env INTERFACE "HAVE_CONFIG_H")

	if(GODOT_PLATFORM MATCHES "(windows|uwp)")
		target_compile_definitions(ws-env INTERFACE "HAVE_WINSOCK2_H")
	else()
		target_compile_definitions(ws-env INTERFACE "HAVE_NETINET_IN_H")
	endif()

	add_module_lib(thirdparty-ws-lib
		OBJECT
		PARENT_LIB
			ws-lib
		COMPONENTS
			ws-env
	)
	target_sources_from_path(thirdparty-ws-lib PRIVATE "${__THIRDPARTY_WSLAY_PATH}"
		"wslay_net.c"
		"wslay_event.c"
		"wslay_queue.c"
		"wslay_stack.c"
		"wslay_frame.c"
	)

endif()

target_glob_sources(ws-lib PRIVATE "*.cpp")
