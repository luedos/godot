
add_custom_target(servers-shaders-gen)

function(collect_rd_shaders __FOLDER)
	file(GLOB __SHADER_INCLUDE_FILES LIST_DIRECTORIES FALSE "${__FOLDER}/*_inc.glsl")
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

collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}")

collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/effects")
collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/environment")
collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/forward_clustered")
collect_rd_shaders("${CMAKE_CURRENT_SOURCE_DIR}/forward_mobile")

add_dependencies(servers-env servers-shaders-gen)