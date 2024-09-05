
file(GLOB __GL_INCLUDE_FILES LIST_DIRECTORIES FALSE "*_inc.glsl")
file(GLOB __GLSL_FILES LIST_DIRECTORIES FALSE "*.glsl")

list(REMOVE_ITEM __GLSL_FILES ${__GL_INCLUDE_FILES})
set(__GLES_HEADERS "")

foreach (__GLSL IN LISTS __GLSL_FILES)

	normilize_path(__SOURCE_FILE "${__GLSL}" ABSOLUTE)
	set(__TARGET_FILE "${__SOURCE_FILE}.gen.h")
	list(APPEND __GLES_HEADERS "${__TARGET_FILE}")

	add_python_generator_command(gles3_builders cmake_build_gles3_headers
		TARGET_FILES "${__TARGET_FILE}"
		SOURCE_FILES "${__SOURCE_FILE}"
		BUILD_DEPENDENCIES ${__GL_INCLUDE_FILES}
		WORKING_DIR "${ENGINE_SOURCE_DIR}"
	)

endforeach()

add_custom_target(drivers-gles3-shaders-effects-gen
	DEPENDS
		${__GLES_HEADERS}
)

add_dependencies(drivers-env drivers-gles3-shaders-effects-gen)