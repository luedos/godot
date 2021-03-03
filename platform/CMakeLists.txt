
set(__PLATFORM_API_FILES "")
foreach(__PLATFORM IN LISTS PLATFORMS_APIS)
	list(APPEND __PLATFORM_API_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${__PLATFORM}/api/api.cpp")
endforeach()
set(__REG_API_FILE "${CMAKE_CURRENT_SOURCE_DIR}/register_platform_apis.gen.cpp")

execute_python_method(reg_api_generator generate_reg_apis
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
	PYTHON_ARGS
		STR_VAR "to_file=__REG_API_FILE"
		ARR_VAR "platform_apis=PLATFORMS_APIS"
)

add_lib(platform-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		warnings-env
)

target_sources(platform-lib PRIVATE
	${__PLATFORM_API_FILES}
	"${__REG_API_FILE}"
)
