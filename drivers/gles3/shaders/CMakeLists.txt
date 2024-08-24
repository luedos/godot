set(__GLES3_FILES
	"canvas.glsl"
	"copy.glsl"
	"scene.glsl"
	"sky.glsl"
	"cubemap_filter.glsl"
	"canvas_occlusion.glsl"
	"canvas_sdf.glsl"
	"particles.glsl"
	"particles_copy.glsl"
	"skeleton.glsl"
)

file(GLOB __SHADER_INCLUDE_FILES LIST_DIRECTORIES FALSE "*_inc.glsl")

set(__GLES3_HEADERS "")

foreach (__GLES3 IN LISTS __GLES3_FILES)

	normilize_path(__SOURCE_FILE "${__GLES3}" ABSOLUTE)
	set(__TARGET_FILE "${__SOURCE_FILE}.gen.h")
	list(APPEND __GLES3_HEADERS "${__TARGET_FILE}")

	add_python_generator_command(gles3_builders cmake_build_gles3_headers
		TARGET_FILES "${__TARGET_FILE}"
		SOURCE_FILES "${__SOURCE_FILE}"
		BUILD_DEPENDENCIES ${__SHADER_INCLUDE_FILES}
		WORKING_DIR "${ENGINE_SOURCE_DIR}"
	)
endforeach()

add_custom_target(drivers-gles3-shaders-gen
	DEPENDS
		${__GLES3_HEADERS}
)

add_dependencies(drivers-env drivers-gles3-shaders-gen)