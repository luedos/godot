add_env(openxr-env
	COMPONENTS
		modules-env
)

add_lib(openxr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		openxr-env
		global-warnings-env
	DEPENDENCIES
		servers-shaders-gen
)

# Khronos OpenXR loader

# Needs even for build against shared library, at least the defines used in public headers.
if (godot_platform STREQUAL "android")
	target_compile_definitions(openxr-env INTERFACE "XR_OS_ANDROID" "XR_USE_PLATFORM_ANDROID" "JSON_USE_EXCEPTION=0")
elseif (godot_platform STREQUAL "linuxbsd")
	target_compile_definitions(openxr-env INTERFACE "XR_OS_LINUX")

	if (godot_x11)
		target_compile_definitions(openxr-env INTERFACE "XR_USE_PLATFORM_XLIB")
	endif()

	if (godot_wayland)
		target_compile_definitions(openxr-env INTERFACE "XR_USE_PLATFORM_WAYLAND")
	endif()

	# FIXME: Review what needs to be set for Android and macOS.
	target_compile_definitions(openxr-env INTERFACE "HAVE_SECURE_GETENV")
elseif (godot_platform STREQUAL "windows")
	target_compile_definitions(openxr-env INTERFACE "XR_OS_WINDOWS" "NOMINMAX" "XR_USE_PLATFORM_WIN32")
elseif (godot_platform STREQUAL "macos")
	target_compile_definitions(openxr-env INTERFACE "XR_OS_APPLE")
	# There does not seem to be a XR_USE_PLATFORM_XYZ for Apple
endif()

if (godot_builtin_openxr)
	add_lib(thirdparty-openxr-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			openxr-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_OPENXR_PATH "${ENGINE_SOURCE_DIR}/thirdparty/openxr")
	target_include_directories(openxr-env INTERFACE
		"${__THIRDPARTY_OPENXR_PATH}"
		"${__THIRDPARTY_OPENXR_PATH}/include"
		"${__THIRDPARTY_OPENXR_PATH}/src"
		"${__THIRDPARTY_OPENXR_PATH}/src/common"
		"${__THIRDPARTY_OPENXR_PATH}/src/external/jsoncpp/include"
	)

	target_compile_definitions(thirdparty-openxr-lib PRIVATE "DISABLE_STD_FILESYSTEM")
	if (godot_disable_exceptions)
		target_compile_definitions(thirdparty-openxr-lib PRIVATE
			"XRLOADER_DISABLE_EXCEPTION_HANDLING"
			"JSON_USE_EXCEPTION=0"
		)
	endif()

	target_include_directories(thirdparty-openxr-lib PRIVATE
		"${__THIRDPARTY_OPENXR_PATH}/src/loader"
	)

	target_sources_from_path(thirdparty-openxr-lib PRIVATE "${__THIRDPARTY_OPENXR_PATH}/src/external/jsoncpp/src/lib_json"
		"json_reader.cpp"
		"json_value.cpp"
		"json_writer.cpp"
	)

	if (NOT godot_platform STREQUAL "android")
		# On Android the openxr_loader is provided by separate plugins for each device
		# Build the engine using object files
		target_sources_from_path(thirdparty-openxr-lib PRIVATE "${__THIRDPARTY_OPENXR_PATH}/src"
			"xr_generated_dispatch_table_core.c"
			"common/filesystem_utils.cpp"
			"common/object_info.cpp"
			"loader/api_layer_interface.cpp"
			"loader/loader_core.cpp"
			"loader/loader_instance.cpp"
			"loader/loader_logger_recorders.cpp"
			"loader/loader_logger.cpp"
			"loader/manifest_file.cpp"
			"loader/runtime_interface.cpp"
			"loader/xr_generated_loader.cpp"
		)
	endif()
endif()

target_glob_sources(openxr-lib PRIVATE "*.cpp")

add_subdirectory(action_map)
add_subdirectory(extensions)
add_subdirectory(scene)

if (EDITOR_BUILD)
	add_subdirectory(editor)
endif()