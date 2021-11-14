
#TODO: This is a little bit of a crutch, but I haven't found a better solution yet. 
# In theory we want something like custom builders like in scons, but we don't have those in cmake.
# Because of what, for now, we will simply hardcode usage of a python script.
# In the future we could do something like defining a custom function in top level directory..

if(NOT GODOT_PLATFORM STREQUAL "server")
	set(__GLES2_FILES
		"copy.glsl"
		# 'resolve.glsl'
		"canvas.glsl"
		"canvas_shadow.glsl"
		"scene.glsl"
		"cubemap_filter.glsl"
		"cube_to_dp.glsl"
		# 'blend_shape.glsl'
		# 'screen_space_reflection.glsl'
		"effect_blur.glsl"
		# 'subsurf_scattering.glsl'
		# 'ssao.glsl'
		# 'ssao_minify.glsl'
		# 'ssao_blur.glsl'
		# 'exposure.glsl'
		"tonemap.glsl"
		# 'particles.glsl'
		"lens_distorted.glsl"
	)

	set(__GLES2_HEADERS "")

	foreach(__GLES2 IN LISTS __GLES2_FILES)
		set(__TARGET_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${__GLES2}.gen.h")
		add_python_generator_command(gles_builders cmake_build_gles2_headers
			TARGET_FILES "${__TARGET_FILE}"
			SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${__GLES2}"
			WORKING_DIR "${GODOT_SOURCE_DIR}"
		)

		list(APPEND __GLES2_HEADERS "${__TARGET_FILE}")

	endforeach()

	add_custom_target(drivers-gles2-shaders-gen
		DEPENDS
			${__GLES2_HEADERS}
	)

	add_dependencies(drivers-lib drivers-gles2-shaders-gen)

endif()