add_env(squish-env
	COMPONENTS
		modules-env
)

add_lib(squish-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		squish-env
		global-warnings-env
)
target_glob_sources(squish-lib PRIVATE "*.cpp")

if (godot_builtin_squish)
	add_lib(thirdparty-squish-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			squish-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_SQUISH_PATH "${ENGINE_SOURCE_DIR}/thirdparty/squish")
	target_sources_from_path(thirdparty-squish-lib PRIVATE "${__THIRDPARTY_SQUISH_PATH}"
		"alpha.cpp"
		"clusterfit.cpp"
		"colourblock.cpp"
		"colourfit.cpp"
		"colourset.cpp"
		"maths.cpp"
		"rangefit.cpp"
		"singlecolourfit.cpp"
		"squish.cpp"
	)

	target_include_directories(squish-env INTERFACE "${__THIRDPARTY_SQUISH_PATH}")
endif()