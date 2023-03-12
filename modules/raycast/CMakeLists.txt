
add_env(raycast-env
	COMPONENTS
		modules-env
)

add_module_lib(raycast-lib
	COMPONENTS
		raycast-env
		warnings-env
)

if(GODOT_BUILTIN_EMBREE)
	add_module_lib(thirdparty-raycast-lib
		OBJECT
		PARENT_LIB
			raycast-lib
		COMPONENTS
			raycast-env	
	)

	set(__THIRDPARTY_PVR_PATH "${GODOT_SOURCE_DIR}/thirdparty/embree")

	target_include_directories(raycast-env INTERFACE "${__THIRDPARTY_PVR_PATH}/include")

	target_sources_from_path(thirdparty-raycast-lib PRIVATE "${__THIRDPARTY_PVR_PATH}"
		"common/sys/sysinfo.cpp"
		"common/sys/alloc.cpp"
		"common/sys/filename.cpp"
		"common/sys/library.cpp"
		"common/sys/thread.cpp"
		"common/sys/string.cpp"
		"common/sys/regression.cpp"
		"common/sys/mutex.cpp"
		"common/sys/condition.cpp"
		"common/sys/barrier.cpp"
		"common/math/constants.cpp"
		"common/simd/sse.cpp"
		"common/lexers/stringstream.cpp"
		"common/lexers/tokenstream.cpp"
		"common/tasking/taskschedulerinternal.cpp"
		"kernels/common/device.cpp"
		"kernels/common/stat.cpp"
		"kernels/common/acceln.cpp"
		"kernels/common/accelset.cpp"
		"kernels/common/state.cpp"
		"kernels/common/rtcore.cpp"
		"kernels/common/rtcore_builder.cpp"
		"kernels/common/scene.cpp"
		"kernels/common/alloc.cpp"
		"kernels/common/geometry.cpp"
		"kernels/common/scene_triangle_mesh.cpp"
		"kernels/geometry/primitive4.cpp"
		"kernels/builders/primrefgen.cpp"
		"kernels/bvh/bvh.cpp"
		"kernels/bvh/bvh_statistics.cpp"
		"kernels/bvh/bvh4_factory.cpp"
		"kernels/bvh/bvh8_factory.cpp"
		"kernels/bvh/bvh_collider.cpp"
		"kernels/bvh/bvh_rotate.cpp"
		"kernels/bvh/bvh_refit.cpp"
		"kernels/bvh/bvh_builder.cpp"
		"kernels/bvh/bvh_builder_morton.cpp"
		"kernels/bvh/bvh_builder_sah.cpp"
		"kernels/bvh/bvh_builder_sah_spatial.cpp"
		"kernels/bvh/bvh_builder_sah_mb.cpp"
		"kernels/bvh/bvh_builder_twolevel.cpp"
		"kernels/bvh/bvh_intersector1_bvh4.cpp"
	)

	target_compile_definitions(raycast-env INTERFACE 
		"EMBREE_TARGET_SSE2"
		"EMBREE_LOWEST_ISA"
		"TASKING_INTERNAL"
		"NDEBUG"
	)

	if(NOT MSVC)

		if(PROCESSOR_IS_X86)
			target_compile_options(raycast-env INTERFACE 
				"-msse2"
				"-mxsave"
			)
		endif()

		if(GODOT_PLATFORM STREQUAL "windows")
			target_compile_options(raycast-env INTERFACE "-mstackrealign")
		endif()

	endif()

	if(GODOT_PLATFORM STREQUAL "windows")
		#TODO: This is very strange code, especially on scons side, 
		# where, at this point, env will basically not affect this module at all..
		# I guess SCons alternative wanted to add this library only to the executable,
		# but should investigate this more.
		if(MSVC)
			target_link_libraries(global-env INTERFACE "psapi.lib")
		else()
			target_link_libraries(global-env INTERFACE "psapi")
		endif()
	endif()

	if(NOT PROCESSOR_IS_X86 OR MSVC)
		target_compile_definitions(thirdparty-raycast-lib PRIVATE
			"__SSE2__"
			"__SSE__"
		)
	endif()

endif()


target_glob_sources(raycast-lib PRIVATE "*.cpp")