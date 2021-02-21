
#TODO: make those tests in the future to be created as actual cmake tests
add_lib(tests-lib
	EXCLUDE_FROM_ALL
	STANDALONE
	COMPONENTS
		global-env
		warnings-env
)
target_glob_sources(tests-lib PRIVATE "*.cpp")

target_link_libraries(global-libs-list INTERFACE $<${IS_TOOLS_GEN_EXPR}:tests-lib>)