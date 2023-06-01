add_env(xatlas-env
	COMPONENTS
		modules-env
)

add_lib(xatlas-unwrap-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		xatlas-env
		global-warnings-env
)
target_glob_sources(xatlas-unwrap-lib PRIVATE "*.cpp")

if (godot_builtin_xatlas)
	add_lib(thirdparty-xatlas-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			xatlas-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_XATLAS_PATH "${ENGINE_SOURCE_DIR}/thirdparty/xatlas")
	target_sources_from_path(thirdparty-xatlas-lib PRIVATE "${__THIRDPARTY_XATLAS_PATH}"
		"xatlas.cpp"
	)

	target_include_directories(xatlas-env INTERFACE "${__THIRDPARTY_XATLAS_PATH}")
endif()