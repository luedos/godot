
add_env(upnp-env
	COMPONENTS
		modules-env
)

add_module_lib(upnp-lib
	COMPONENTS
		upnp-env
		warnings-env
)

if(GODOT_BUILTIN_MINIUPNPC)	

	set(__THIRDPARTY_UPNP_PATH "${GODOT_SOURCE_DIR}/thirdparty/miniupnpc")

	target_include_directories(upnp-env INTERFACE "${__THIRDPARTY_UPNP_PATH}")
	target_compile_definitions(upnp-env INTERFACE "MINIUPNP_STATICLIB" "MINIUPNPC_SET_SOCKET_TIMEOUT")

	add_module_lib(thirdparty-upnp-lib
		OBJECT
		PARENT_LIB
			upnp-lib
		COMPONENTS
			upnp-env
	)

	target_sources_from_path(thirdparty-upnp-lib PRIVATE "${__THIRDPARTY_UPNP_PATH}/miniupnpc"
		"igd_desc_parse.c"
		"miniupnpc.c"
		"minixml.c"
		"minisoap.c"
		"minissdpc.c"
		"miniwget.c"
		"upnpcommands.c"
		"upnpdev.c"
		"upnpreplyparse.c"
		"connecthostport.c"
		"portlistingparse.c"
		"receivedata.c"
		"addr_is_reserved.c"
	)

endif()

target_glob_sources(upnp-lib PRIVATE "*.cpp")
