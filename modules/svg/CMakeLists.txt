add_env(svg-env
	COMPONENTS
		modules-env
)

add_lib(svg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		svg-env
		global-warnings-env
)
target_glob_sources(svg-lib PRIVATE "*.cpp")

add_lib(thirdparty-thorvg-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		svg-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_THORVG_PATH "${ENGINE_SOURCE_DIR}/thirdparty/thorvg")
target_sources_from_path(thirdparty-thorvg-lib PRIVATE "${__THIRDPARTY_THORVG_PATH}"
	"src/lib/sw_engine/tvgSwFill.cpp"
	"src/lib/sw_engine/tvgSwImage.cpp"
	"src/lib/sw_engine/tvgSwMath.cpp"
	"src/lib/sw_engine/tvgSwMemPool.cpp"
	"src/lib/sw_engine/tvgSwRaster.cpp"
	"src/lib/sw_engine/tvgSwRenderer.cpp"
	"src/lib/sw_engine/tvgSwRle.cpp"
	"src/lib/sw_engine/tvgSwShape.cpp"
	"src/lib/sw_engine/tvgSwStroke.cpp"
	"src/lib/tvgAccessor.cpp"
	"src/lib/tvgBezier.cpp"
	"src/lib/tvgCanvas.cpp"
	"src/lib/tvgFill.cpp"
	"src/lib/tvgGlCanvas.cpp"
	"src/lib/tvgInitializer.cpp"
	"src/lib/tvgLinearGradient.cpp"
	"src/lib/tvgLoader.cpp"
	"src/lib/tvgLzw.cpp"
	"src/lib/tvgPaint.cpp"
	"src/lib/tvgPicture.cpp"
	"src/lib/tvgRadialGradient.cpp"
	"src/lib/tvgRender.cpp"
	"src/lib/tvgSaver.cpp"
	"src/lib/tvgScene.cpp"
	"src/lib/tvgShape.cpp"
	"src/lib/tvgSwCanvas.cpp"
	"src/lib/tvgTaskScheduler.cpp"
	"src/loaders/external_png/tvgPngLoader.cpp"
	"src/loaders/jpg/tvgJpgd.cpp"
	"src/loaders/jpg/tvgJpgLoader.cpp"
	"src/loaders/raw/tvgRawLoader.cpp"
	"src/loaders/svg/tvgSvgCssStyle.cpp"
	"src/loaders/svg/tvgSvgLoader.cpp"
	"src/loaders/svg/tvgSvgPath.cpp"
	"src/loaders/svg/tvgSvgSceneBuilder.cpp"
	"src/loaders/svg/tvgSvgUtil.cpp"
	"src/loaders/svg/tvgXmlParser.cpp"
	"src/loaders/tvg/tvgTvgBinInterpreter.cpp"
	"src/loaders/tvg/tvgTvgLoader.cpp"
	"src/savers/tvg/tvgTvgSaver.cpp"
)

target_include_directories(svg-env INTERFACE "${__THIRDPARTY_THORVG_PATH}/inc")
target_include_directories(thirdparty-thorvg-lib PRIVATE
	"${__THIRDPARTY_THORVG_PATH}/src/lib"
	"${__THIRDPARTY_THORVG_PATH}/src/lib/sw_engine"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/external_png"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/jpg"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/raw"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/svg"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/tvg"
	"${__THIRDPARTY_THORVG_PATH}/src/savers/tvg"
)

# Also requires libpng headers
if (godot_builtin_libpng)
	target_include_directories(thirdparty-thorvg-lib PRIVATE
		"${ENGINE_SOURCE_DIR}/thirdparty/libpng"
	)
endif()