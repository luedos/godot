add_env(upnp-env
	COMPONENTS
		modules-env
)

add_lib(upnp-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		upnp-env
		global-warnings-env
)
target_glob_sources(upnp-lib PRIVATE "*.cpp")

if (godot_builtin_miniupnpc)
	add_lib(thirdparty-upnp-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			upnp-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_MINIUPNPC_PATH "${ENGINE_SOURCE_DIR}/thirdparty/miniupnpc")
	target_sources_from_path(thirdparty-upnp-lib PRIVATE "${__THIRDPARTY_MINIUPNPC_PATH}/src"
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

	target_include_directories(upnp-env INTERFACE "${__THIRDPARTY_MINIUPNPC_PATH}/include")
	target_compile_definitions(upnp-env INTERFACE
		"MINIUPNP_STATICLIB"
		"MINIUPNPC_SET_SOCKET_TIMEOUT"
	)
endif()