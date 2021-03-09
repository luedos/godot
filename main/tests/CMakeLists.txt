# TODO: make those tests in the future to be created as actual cmake tests
if(GODOT_BUILD_TOOLS)

	add_lib(tests-lib
		EXCLUDE_FROM_ALL
		PARENT_ENV
			global-libs-list
		COMPONENTS
			global-env
			warnings-env
	)

	target_glob_sources(tests-lib PRIVATE "*.cpp") 

endif()