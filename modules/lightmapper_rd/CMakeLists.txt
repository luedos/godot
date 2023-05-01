
add_lib(lightmapper-rd-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(lightmapper-rd-lib PRIVATE "*.cpp")

set(__GLSL_HEADERS "")

foreach (__GLSL "lm_raster.glsl" "lm_compute.glsl" "lm_blendseams.glsl")
	set(__GLSL "${CMAKE_CURRENT_SOURCE_DIR}/${__GLSL}")
	set(__GLSL_TARGET_HEADER "${__GLSL}.gen.h")
	add_python_generator_command(glsl_builders cmake_build_raw_headers
		SOURCE_FILES "${__GLSL}"
		TARGET_FILES "${__GLSL_TARGET_HEADER}"
		BUILD_DEPENDENCIES "${CMAKE_CURRENT_SOURCE_DIR}/lm_common_inc.glsl"
		APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	)
endforeach()

add_custom_target(lightmapper-rd-gen
	DEPENDS
		${__GLSL_HEADERS}
)

add_dependencies(lightmapper-rd-lib lightmapper-rd-gen)