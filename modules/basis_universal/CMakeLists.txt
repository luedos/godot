add_env(basisu-env
	COMPONENTS
		modules-env
)
target_include_directories(basisu-env SYSTEM INTERFACE "${__THIRDPARTY_BASISU_PATH}")

if (godot_builtin_zstd)
	target_include_directories(basisu-env INTERFACE "${ENGINE_SOURCE_DIR}/thirdparty/zstd")
endif()

if (godot_dev_build)
	target_compile_definitions(basisu-env INTERFACE "BASISU_DEVEL_MESSAGES=1" "BASISD_ENABLE_DEBUG_FLAGS=1")
endif()

add_lib(basisu-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		basisu-env
		global-warnings-env
)
target_glob_sources(basisu-lib PRIVATE "*.cpp")

add_env(thirdparty-basisu-env
	COMPONENTS
		basisu-env
)

set(__THIRDPARTY_BASISU_PATH "${ENGINE_SOURCE_DIR}/thirdparty/basis_universal")
add_lib(thirdparty-basisu-transcoder-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		thirdparty-basisu-env
		thirdparty-warnings-env
	SOURCES
		"${__THIRDPARTY_BASISU_PATH}/transcoder/basisu_transcoder.cpp"
)

if (godot_editor_build)
	target_compile_definitions(thirdparty-basisu-env INTERFACE "BASISU_NO_IMG_LOADERS")
	add_lib(thirdparty-basisu-encoder-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			thirdparty-basisu-env
			thirdparty-warnings-env
	)
	target_sources_from_path(thirdparty-basisu-encoder-lib PRIVATE "${__THIRDPARTY_BASISU_PATH}/encoder"
		"basisu_backend.cpp"
		"basisu_basis_file.cpp"
		"basisu_bc7enc.cpp"
		"basisu_opencl.cpp"
		"basisu_comp.cpp"
		"basisu_enc.cpp"
		"basisu_etc.cpp"
		"basisu_frontend.cpp"
		"basisu_gpu_texture.cpp"
		"basisu_kernels_sse.cpp"
		"basisu_pvrtc1_4.cpp"
		"basisu_resampler.cpp"
		"basisu_resample_filters.cpp"
		"basisu_ssim.cpp"
		"basisu_uastc_enc.cpp"
		"jpgd.cpp"
		"pvpngreader.cpp"
	)
endif()
