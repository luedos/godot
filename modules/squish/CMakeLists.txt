
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

	add_module_lib(thirdparty-squish-lib
		OBJECT
		PARENT_LIB
			squish-lib
		COMPONENTS
			squish-env
	)
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

endif()

target_glob_sources(squish-lib PRIVATE "*.cpp")
