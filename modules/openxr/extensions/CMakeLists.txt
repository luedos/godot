
target_glob_sources(openxr-lib PRIVATE "*.cpp")

if (godot_platform STREQUAL "android")
	target_sources(openxr-lib PRIVATE "platform/openxr_android_extension.cpp")
endif()

if (godot_vulkan)
	target_sources(openxr-lib PRIVATE "platform/openxr_vulkan_extension.cpp")
endif()

if (godot_opengl3 AND NOT godot_platform STREQUAL "macos")
	target_sources(openxr-lib PRIVATE "platform/openxr_opengl_extension.cpp")
endif()