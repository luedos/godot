
add_env(xatlas-unwrap-env
	COMPONENTS
		modules-env
)

add_module_lib(xatlas-unwrap-lib
	TOOLS_DEPENDENT
	COMPONENTS
		xatlas-unwrap-env
		warnings-env
)

if(GODOT_BUILTIN_XATLAS)	

	set(__THIRDPARTY_XATLAS_PATH "${GODOT_SOURCE_DIR}/thirdparty/xatlas")

	target_include_directories(xatlas-unwrap-env INTERFACE "${__THIRDPARTY_XATLAS_PATH}")

	add_lib(thirdparty-xatlas-unwrap-lib
		OBJECT
		PARENT_LIB
			xatlas-unwrap-lib
		COMPONENTS
			xatlas-unwrap-env	
		SOURCES
			"${__THIRDPARTY_XATLAS_PATH}/xatlas.cpp"
	)
endif()

target_glob_sources(xatlas-unwrap-lib PRIVATE "*.cpp")
