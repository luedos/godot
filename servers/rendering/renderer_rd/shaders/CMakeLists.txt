
add_custom_target(servers-shaders-gen)

function(collect_rd_shaders)
	file(GLOB __SHADER_INCLUDE_FILES LIST_DIRECTORIES FALSE "*_inc.glsl")
	file(GLOB __SHADER_FILES LIST_DIRECTORIES FALSE "*.glsl")
	list(REMOVE_ITEM __SHADER_FILES ${__SHADER_INCLUDE_FILES})

	foreach (__GLSL IN LISTS ARGN)

		normilize_path(__SOURCE_FILE "${__GLSL}" ABSOLUTE)
		set(__TARGET_FILE "${__SOURCE_FILE}.gen.h")

		add_python_generator_command(glsl_builders cmake_build_rd_headers
			TARGET_FILES "${__TARGET_FILE}"
			SOURCE_FILES "${__SOURCE_FILE}"
			BUILD_DEPENDENCIES ${__SHADER_INCLUDE_FILES}
			WORKING_DIR "${ENGINE_SOURCE_DIR}"
		)

		add_dependencies(servers-shaders-gen "${__TARGET_FILE}")
	endforeach()

endfunction()

collect_rd_shaders()

add_subdirectory("effects")
add_subdirectory("environment")
add_subdirectory("forward_clustered")
add_subdirectory("forward_mobile")

add_dependencies(servers-lib servers-shaders-gen)