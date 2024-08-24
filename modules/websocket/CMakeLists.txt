if (godot_platform STREQUAL "web")
	target_link_js_libraries(global-libs-list INTERFACE "library_godot_websocket.js")
endif()

add_env(websocket-env
	COMPONENTS
		modules-env
)

add_lib(websocket-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		websocket-env
		global-warnings-env
)
target_glob_sources(websocket-lib PRIVATE "*.cpp")
if (godot_editor_build)
	target_glob_sources(websocket-lib PRIVATE "editor/*.cpp")
endif()

if (godot_builtin_wslay)
	add_lib(thirdparty-wslay-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			websocket-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_WSLAY_PATH "${ENGINE_SOURCE_DIR}/thirdparty/wslay")
	target_sources_from_path(thirdparty-wslay-lib PRIVATE "${__THIRDPARTY_WSLAY_PATH}"
		"wslay_net.c"
		"wslay_event.c"
		"wslay_queue.c"
		"wslay_frame.c"
	)

	target_include_directories(websocket-env INTERFACE "${__THIRDPARTY_WSLAY_PATH}")
	target_compile_definitions(websocket-env INTERFACE "HAVE_CONFIG_H")

	if (godot_platform MATCHES "(windows|uwp)")
		target_compile_definitions(websocket-env INTERFACE "HAVE_WINSOCK2_H")
	else()
		target_compile_definitions(websocket-env INTERFACE "HAVE_NETINET_IN_H")
	endif()
endif()