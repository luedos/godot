
add_env(enet-env
	COMPONENTS
		modules-env
)

add_module_lib(enet-lib
	COMPONENTS
		enet-env
		warnings-env
)

if(GODOT_BUILTIN_ENET)
	set(__THIRDPARTY_ENET_PATH "${GODOT_SOURCE_DIR}/thirdparty/enet")

	target_include_directories(enet-env INTERFACE "${__THIRDPARTY_ENET_PATH}")	
	target_compile_definitions(enet-env INTERFACE "GODOT_ENET")

	add_module_lib(thirdparty-enet-lib
		OBJECT
		PARENT_LIB
			enet-lib
		COMPONENTS
			enet-env
	)

	target_sources_from_path(thirdparty-enet-lib PRIVATE "${__THIRDPARTY_ENET_PATH}"
		"godot.cpp"
		"callbacks.c"
		"compress.c"
		"host.c"
		"list.c"
		"packet.c"
		"peer.c"
		"protocol.c"
	)

endif()

target_glob_sources(enet-lib PRIVATE "*.cpp")