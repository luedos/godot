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
target_glob_sources(openxr-lib PRIVATE "*.cpp")
target_glob_sources(openxr-lib PRIVATE "action_map/*.cpp")
target_glob_sources(openxr-lib PRIVATE "scene/*.cpp")

if (godot_platform STREQUAL "android")
	target_sources(openxr-lib PRIVATE "extensions/openxr_android_extension.cpp")
endif()

if (godot_vulkan)
	target_sources(openxr-lib PRIVATE "extensions/openxr_vulkan_extension.cpp")
endif()

if (godot_opengl3)
	target_sources(openxr-lib PRIVATE "extensions/openxr_opengl_extension.cpp")
endif()

target_sources(openxr-lib PRIVATE
	"extensions/openxr_palm_pose_extension.cpp"
	"extensions/openxr_composition_layer_depth_extension.cpp"
	"extensions/openxr_htc_controller_extension.cpp"
	"extensions/openxr_htc_vive_tracker_extension.cpp"
	"extensions/openxr_huawei_controller_extension.cpp"
	"extensions/openxr_hand_tracking_extension.cpp"
	"extensions/openxr_fb_passthrough_extension_wrapper.cpp"
	"extensions/openxr_fb_display_refresh_rate_extension.cpp"
	"extensions/openxr_pico_controller_extension.cpp"
	"extensions/openxr_wmr_controller_extension.cpp"
	"extensions/openxr_ml2_controller_extension.cpp"
)

if (godot_platform STREQUAL "android")
	# may need to set OPENXR_ANDROID_VERSION_SUFFIX
	target_compile_definitions(openxr-env INTERFACE
		"XR_OS_ANDROID"
		"XR_USE_PLATFORM_ANDROID"
		"JSON_USE_EXCEPTION=0"
	)

	# may need to include java parts of the openxr loader
elseif (godot_platform STREQUAL "linuxbsd")
	target_compile_definitions(openxr-env INTERFACE
		"XR_OS_LINUX"
		"HAVE_SECURE_GETENV"
	)

	if (godot_x11)
		target_compile_definitions(openxr-env INTERFACE "XR_USE_PLATFORM_XLIB")
	endif()
elseif (godot_platform STREQUAL "windows")
	target_compile_definitions(openxr-env INTERFACE
		"XR_OS_WINDOWS"
		"NOMINMAX"
		"XR_USE_PLATFORM_WIN32"
	)
endif()

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
		"xr_generated_dispatch_table.c"
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

if (godot_editor_build)
	add_subdirectory(editor)
endif()