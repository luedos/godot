
add_custom_target(servers-shaders-gen)

function(__collect_rd_shaders __FOLDER)

	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS ADDITIONAL_INCLUDE_GLOB_EXPRESSION)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	file(GLOB __SHADER_INCLUDE_FILES LIST_DIRECTORIES FALSE "${__FOLDER}/*_inc.glsl")
	foreach (__INCLUDE_EXPRESSION IN LISTS __ARGS_ADDITIONAL_INCLUDE_GLOB_EXPRESSION)
		file(GLOB __TEMP_SHADER_INCLUDE_FILES LIST_DIRECTORIES FALSE "${__INCLUDE_EXPRESSION}")
		list(APPEND __SHADER_INCLUDE_FILES ${__TEMP_SHADER_INCLUDE_FILES})
	endforeach()

	file(GLOB __SHADER_FILES LIST_DIRECTORIES FALSE "${__FOLDER}/*.glsl")
	list(REMOVE_ITEM __SHADER_FILES ${__SHADER_INCLUDE_FILES})

	foreach (__GLSL IN LISTS __SHADER_FILES)

		normilize_path(__SOURCE_FILE "${__GLSL}" ABSOLUTE)
		set(__TARGET_FILE "${__SOURCE_FILE}.gen.h")

		add_python_generator_command(glsl_builders cmake_build_rd_headers
			TARGET_FILES "${__TARGET_FILE}"
			SOURCE_FILES "${__SOURCE_FILE}"
			BUILD_DEPENDENCIES ${__SHADER_INCLUDE_FILES}
			WORKING_DIR "${ENGINE_SOURCE_DIR}"
			SOURCES_DEPENDENT_TARGET servers-shaders-gen
		)

	endforeach()

endfunction()

__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}")

__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/effects")
__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/environment")
__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/forward_clustered")
__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/forward_mobile")

__collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/effects/fsr2" 
	ADDITIONAL_INCLUDE_GLOB_EXPRESSION
		"${ENGINE_SOURCE_DIR}/thirdparty/amd-fsr2/shaders/*.h"
		"${ENGINE_SOURCE_DIR}/thirdparty/amd-fsr2/shaders/*.glsl"
)

add_dependencies(servers-env servers-shaders-gen)