add_env(msdfgen-env
	COMPONENTS
		modules-env
)

add_lib(msdfgen-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		msdfgen-env
		global-warnings-env
)
target_glob_sources(msdfgen-lib PRIVATE "*.cpp")

if (godot_builtin_msdfgen)
	add_lib(thirdparty-msdfgen-lib
		PARENT_ENV
			global-libs-list
		COMPONENTS
			msdfgen-env
			thirdparty-warnings-env
	)
	set(__THIRDPARTY_MSDFGEN_PATH "${ENGINE_SOURCE_DIR}/thirdparty/msdfgen")
	target_sources_from_path(thirdparty-msdfgen-lib PRIVATE "${__THIRDPARTY_MSDFGEN_PATH}"
		"core/Contour.cpp"
		"core/EdgeHolder.cpp"
		"core/MSDFErrorCorrection.cpp"
		"core/Projection.cpp"
		"core/Scanline.cpp"
		"core/Shape.cpp"
		"core/SignedDistance.cpp"
		"core/Vector2.cpp"
		"core/contour-combiners.cpp"
		"core/edge-coloring.cpp"
		"core/edge-segments.cpp"
		"core/edge-selectors.cpp"
		"core/equation-solver.cpp"
		"core/msdf-error-correction.cpp"
		"core/msdfgen.cpp"
		"core/rasterization.cpp"
		"core/render-sdf.cpp"
		"core/sdf-error-estimation.cpp"
		"core/shape-description.cpp"
	)

	target_include_directories(msdfgen-env INTERFACE 
		"${__THIRDPARTY_MSDFGEN_PATH}"
		"${ENGINE_SOURCE_DIR}/thirdparty/freetype/include"
		"${ENGINE_SOURCE_DIR}/thirdparty/nanosvg"
	)
	
	# Needs to be appended to arrive after libscene in the linker call,
	add_link_dependencies(scene-lib thirdparty-msdfgen-lib)
endif()
