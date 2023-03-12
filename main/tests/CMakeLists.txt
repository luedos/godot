# TODO: make those tests in the future to be created as actual cmake tests
add_lib(tests-lib
	COMPONENTS
		global-env
		warnings-env
)
register_global_lib(tests-lib)

target_glob_sources(tests-lib PRIVATE "*.cpp")