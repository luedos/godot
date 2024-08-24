add_env(raycast-env
	COMPONENTS
		modules-env
)

add_lib(raycast-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		raycast-env
		global-warnings-env
)
target_glob_sources(raycast-lib PRIVATE "*.cpp")


if (godot_builtin_embree)
	add_lib(thirdparty-embree-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			raycast-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_EMBREE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/embree")
	target_sources_from_path(thirdparty-embree-lib PRIVATE "${__THIRDPARTY_EMBREE_PATH}"
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
		"kernels/bvh/bvh_intersector_hybrid4_bvh4.cpp"
		"kernels/bvh/bvh_intersector_stream_bvh4.cpp"
		"kernels/bvh/bvh_intersector_stream_filters.cpp"
	)
	
	target_include_directories(raycast-env INTERFACE
		"${__THIRDPARTY_EMBREE_PATH}"
		"${__THIRDPARTY_EMBREE_PATH}/include"
	)

	target_compile_definitions(raycast-env INTERFACE
		"EMBREE_TARGET_SSE2"
		"EMBREE_LOWEST_ISA"
		"TASKING_INTERNAL"
		"NDEBUG" # No assert() even in debug builds.
	)

	if (NOT MSVC)
		if (PROCESSOR_IS_X86_32 OR PROCESSOR_IS_X86_64)
			target_compile_options(raycast-env INTERFACE
				"-msse2"
				"-mxsave"
			)
		endif()

		if (godot_platform STREQUAL "windows")
			target_compile_options(raycast-env INTERFACE
				"-mstackrealign"
			)
		endif()
	endif()

	if (godot_platform STREQUAL "windows")
		target_link_libraries(global-libs-list INTERFACE "psapi")
	endif()

	if (MSVC)
		# Disable bogus warning about intentional struct padding.
		target_compile_options(raycast-env INTERFACE "/wd4324")
	endif()

	if (MSVC)
		target_compile_options(thirdparty-embree-lib PRIVATE "/O2")
	else()
		target_compile_options(thirdparty-embree-lib PRIVATE "-O3")
	endif()

	if (NOT PROCESSOR_IS_X86_64 OR MSVC)
		target_compile_definitions(thirdparty-embree-lib PRIVATE
			"__SSE2__"
			"__SSE__"
		)
	endif()

	if (NOT MSVC)
		if (PROCESSOR_IS_ARM64 AND godot_platform STREQUAL "linuxbsd" AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
			target_compile_options(thirdparty-embree-lib PRIVATE "-flax-vector-conversions")
		endif()

		target_compile_options(thirdparty-embree-lib PRIVATE
			"-fno-strict-overflow"
			"-fno-delete-null-pointer-checks"
			"-fwrapv"
			"-fsigned-char"
			"-fno-strict-aliasing"
			"-fno-tree-vectorize"
			"-fvisibility=hidden"
			"-fvisibility-inlines-hidden"
		)
	endif()

endif()
