add_env(enet-env
	COMPONENTS
		modules-env
)

add_lib(enet-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		enet-env
		global-warnings-env
)
target_glob_sources(enet-lib PRIVATE "*.cpp")

if (godot_builtin_enet)
	add_lib(thirdparty-enet-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			enet-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_ENET_PATH "${ENGINE_SOURCE_DIR}/thirdparty/enet")
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

	target_include_directories(enet-env INTERFACE "${__THIRDPARTY_ASTCENC_PATH}")
	target_compile_definitions(enet-env INTERFACE "GODOT_ENET")
endif()
