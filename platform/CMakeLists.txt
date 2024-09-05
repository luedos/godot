
add_lib(platform-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)

add_custom_target(platform-gen)
add_dependencies(platform-lib platform-gen)

foreach (__PLATFORM IN LISTS PLATFORMS_EXPORTERS)
	file(GLOB __ICON_FILES LIST_DIRECTORIES FALSE "${__PLATFORM}/export/*.svg")
	foreach (__ICON IN LISTS __ICON_FILES)
		string(REPLACE ".svg" "_svg.gen.h" __ICON_GEN "${__ICON}")
		add_python_generator_command(platform_builders cmake_export_icon_builder
			SOURCE_FILES "${__ICON}"
			TARGET_FILES "${__ICON_GEN}"
			SOURCES_DEPENDENT_TARGET platform-gen
			APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
		)
	endforeach()
endforeach()

set(__REG_API_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/register_platform_apis.gen.cpp")
add_python_generator_command(platform_builders cmake_register_platform_apis_builder
	TARGET_FILES "${__REG_API_SOURCE}"
	PYTHON_ARGS
		ARR_VAR "platform_apis=PLATFORMS_APIS"
	SOURCES_DEPENDENT_TARGET platform-lib
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
)

foreach (__PLATFORM_ID IN LISTS PLATFORMS_APIS)
	target_sources(platform-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/${__PLATFORM_ID}/api/api.cpp")
endforeach()
