# TODO: make those tests in the future to be created as actual cmake tests
add_lib(tests-lib
	EXCLUDE_FROM_ALL
	COMPONENTS
		global-env
		warnings-env
)

target_glob_sources(tests-lib PRIVATE "*.cpp") 

target_link_libraries(global-libs-list INTERFACE $<${IS_TOOLS_GEN_EXPR}:tests-lib>)
if(MSVC)
	# because visual studio can't define dependency which based on build type, this library will not be build otherwise
	add_dependencies(global-libs-list tests-lib)
endif()