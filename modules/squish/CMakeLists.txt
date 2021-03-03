
add_env(squish-env
	COMPONENTS
		modules-env
)

add_module_lib(squish-lib
	COMPONENTS
		squish-env
		warnings-env
)

if(GODOT_BUILTIN_SQUISH)	

	set(__THIRDPARTY_SQUISH_PATH "${GODOT_SOURCE_DIR}/thirdparty/squish")

	target_include_directories(squish-env INTERFACE "${__THIRDPARTY_SQUISH_PATH}")

	add_lib(thirdparty-squish-lib
		OBJECT
		PARENT_LIB
			squish-lib
		COMPONENTS
			squish-env	
		SOURCES
			"${__THIRDPARTY_SQUISH_PATH}/alpha.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/clusterfit.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/colourblock.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/colourfit.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/colourset.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/maths.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/rangefit.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/singlecolourfit.cpp"
			"${__THIRDPARTY_SQUISH_PATH}/squish.cpp"
	)
endif()

target_glob_sources(squish-lib PRIVATE "*.cpp")
