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
	# common
	"src/common/tvgCompressor.cpp"
	"src/common/tvgLines.cpp"
	"src/common/tvgMath.cpp"
	"src/common/tvgStr.cpp"
	# SVG parser
	"src/loaders/svg/tvgSvgCssStyle.cpp"
	"src/loaders/svg/tvgSvgLoader.cpp"
	"src/loaders/svg/tvgSvgPath.cpp"
	"src/loaders/svg/tvgSvgSceneBuilder.cpp"
	"src/loaders/svg/tvgSvgUtil.cpp"
	"src/loaders/svg/tvgXmlParser.cpp"
	"src/loaders/raw/tvgRawLoader.cpp"
	# image loaders
	"src/loaders/external_png/tvgPngLoader.cpp"
	"src/loaders/jpg/tvgJpgd.cpp"
	"src/loaders/jpg/tvgJpgLoader.cpp"
	# renderer common
	"src/renderer/tvgAccessor.cpp"
	# "src/renderer/tvgAnimation.cpp"
	"src/renderer/tvgCanvas.cpp"
	"src/renderer/tvgFill.cpp"
	# "src/renderer/tvgGlCanvas.cpp"
	"src/renderer/tvgInitializer.cpp"
	"src/renderer/tvgLoader.cpp"
	"src/renderer/tvgPaint.cpp"
	"src/renderer/tvgPicture.cpp"
	"src/renderer/tvgRender.cpp"
	# "src/renderer/tvgSaver.cpp"
	"src/renderer/tvgScene.cpp"
	"src/renderer/tvgShape.cpp"
	"src/renderer/tvgSwCanvas.cpp"
	"src/renderer/tvgTaskScheduler.cpp"
	"src/renderer/tvgText.cpp"
	# "src/renderer/tvgWgCanvas.cpp"
	# renderer sw_engine
	"src/renderer/sw_engine/tvgSwFill.cpp"
	"src/renderer/sw_engine/tvgSwImage.cpp"
	"src/renderer/sw_engine/tvgSwMath.cpp"
	"src/renderer/sw_engine/tvgSwMemPool.cpp"
	"src/renderer/sw_engine/tvgSwRaster.cpp"
	"src/renderer/sw_engine/tvgSwRenderer.cpp"
	"src/renderer/sw_engine/tvgSwRle.cpp"
	"src/renderer/sw_engine/tvgSwShape.cpp"
	"src/renderer/sw_engine/tvgSwStroke.cpp"
)

if (godot_module_webp_enabled)
	target_sources(thirdparty-thorvg-lib PRIVATE "${__THIRDPARTY_THORVG_PATH}/src/loaders/external_webp/tvgWebpLoader.cpp")
	target_compile_definitions(thirdparty-thorvg-lib PRIVATE "THORVG_WEBP_LOADER_SUPPORT")
endif()

target_compile_definitions(svg-env INTERFACE "TVG_STATIC")

target_include_directories(svg-env INTERFACE "${__THIRDPARTY_THORVG_PATH}/inc")
target_include_directories(thirdparty-thorvg-lib PRIVATE
	"${__THIRDPARTY_THORVG_PATH}/src/common"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/svg"
	"${__THIRDPARTY_THORVG_PATH}/src/renderer"
	"${__THIRDPARTY_THORVG_PATH}/src/renderer/sw_engine"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/raw"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/external_png"
	"${__THIRDPARTY_THORVG_PATH}/src/loaders/jpg"
)

# Also requires libpng headers
if (godot_builtin_libpng)
	target_include_directories(thirdparty-thorvg-lib PRIVATE
		"${ENGINE_SOURCE_DIR}/thirdparty/libpng"
	)
endif()

if (godot_module_webp_enabled)
	target_include_directories(thirdparty-thorvg-lib PRIVATE "${__THIRDPARTY_THORVG_PATH}/src/loaders/external_webp")
	if (godot_builtin_libwebp)
		target_include_directories(thirdparty-thorvg-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/libwebp/src")
	endif()
endif()