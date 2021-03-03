
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

	add_lib(thirdparty-upnp-lib
		OBJECT
		PARENT_LIB
			upnp-lib
		COMPONENTS
			upnp-env	
		SOURCES
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/miniupnpc.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/upnpcommands.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/miniwget.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/upnpdev.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/igd_desc_parse.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/minissdpc.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/minisoap.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/minixml.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/connecthostport.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/receivedata.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/portlistingparse.c"
			"${__THIRDPARTY_UPNP_PATH}/miniupnpc/upnpreplyparse.c"
	)
endif()

target_glob_sources(upnp-lib PRIVATE "*.cpp")
