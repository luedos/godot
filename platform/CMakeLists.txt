
set(__REG_API_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/register_platform_apis.gen.cpp")

execute_python_method(platform_api_builders cmake_create_reg_api_source
	PYTHON_ARGS
		STR_VAR "output_file=__REG_API_SOURCE"
		ARR_VAR "platform_apis_vector=PLATFORMS_APIS"
	ACTION_CACHE_NAME "create_reg_api_source"
	DEPENDENT_FILES "${__REG_API_SOURCE}"
)

set(__PLATFORM_SOURCES "${__REG_API_SOURCE}")
foreach (__PLATFORM_ID IN LISTS PLATFORMS_APIS)
	list(APPEND __PLATFORM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/${__PLATFORM_ID}/api/api.cpp")
endforeach()

add_lib(platform-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
	SOURCES
		"${__PLATFORM_SOURCES}"
)