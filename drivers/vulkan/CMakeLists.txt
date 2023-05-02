

set(__THIRDPARTY_VULKAN_PATH "${ENGINE_SOURCE_DIR}/thirdparty/vulkan")
set(__THIRDPARTY_VOLK_PATH "${ENGINE_SOURCE_DIR}/thirdparty/volk")

target_include_directories(global-env INTERFACE 
	"${__THIRDPARTY_VULKAN_PATH}"
	"${__THIRDPARTY_VULKAN_PATH}/include"
)

if (godot_use_volk)
	target_compile_definitions(global-env INTERFACE "USE_VOLK")
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_VOLK_PATH}")
endif()

if (godot_platform STREQUAL "android")
	target_compile_definitions(global-env INTERFACE "VK_USE_PLATFORM_ANDROID_KHR")
elseif (godot_platform STREQUAL "ios")
	target_compile_definitions(global-env INTERFACE "VK_USE_PLATFORM_IOS_MVK")
elseif (godot_platform STREQUAL "linuxbsd" AND godot_x11)
	target_compile_definitions(global-env INTERFACE "VK_USE_PLATFORM_XLIB_KHR")
elseif (godot_platform STREQUAL "macos")
	target_compile_definitions(global-env INTERFACE "VK_USE_PLATFORM_MACOS_MVK")
elseif (godot_platform STREQUAL "windows")
	target_compile_definitions(global-env INTERFACE "VK_USE_PLATFORM_WIN32_KHR")
endif()

add_env(thirdparty-vma-env
	COMPONENTS
		global-env
)

add_lib(thirdparty-vma-lib
	OBJECT
	PARENT_LIB
		drivers-lib
	COMPONENTS
		thirdparty-vma-env
		thirdparty-warnings-env
	SOURCES
		"${__THIRDPARTY_VULKAN_PATH}/vk_mem_alloc.cpp"
)

if (godot_use_volk)
	target_compile_definitions(thirdparty-vma-env INTERFACE "VMA_STATIC_VULKAN_FUNCTIONS=1")

	add_lib(thirdparty-volk-lib
		OBJECT
		PARENT_LIB
			drivers-lib
		COMPONENTS
			thirdparty-vma-env
			thirdparty-warnings-env
		SOURCES
			"${__THIRDPARTY_VOLK_PATH}/volk.c"
	)
elseif (godot_platform STREQUAL "android")
	# Our current NDK version only provides old Vulkan headers,
	# so we have to limit VMA.
	target_compile_definitions(thirdparty-vma-env INTERFACE "VMA_VULKAN_VERSION=1000000")
elseif (godot_platform MATCHES "(macos|ios)")
	# MoltenVK supports only Vulkan 1.1 API, limit VMA to the same version.
	target_compile_definitions(thirdparty-vma-env INTERFACE "VMA_VULKAN_VERSION=1001000")
endif()

target_glob_sources(drivers-lib PRIVATE "*.cpp")