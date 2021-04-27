# TODO: make those tests in the future to be created as actual cmake tests
if(GODOT_BUILD_TOOLS)

	add_lib(tests-lib
		EXCLUDE_FROM_ALL
		COMPONENTS
			global-env
			warnings-env
	)
	register_global_lib(tests-lib)

	target_glob_sources(tests-lib PRIVATE "*.cpp") 

endif()