target_sources(godot-exe PRIVATE
	"display_server_x11.cpp"
	"key_mapping_x11.cpp"
)

if (godot_use_sowrap)
	target_sources(godot-exe PRIVATE
		"dynwrappers/xlib-so_wrap.c"
		"dynwrappers/xcursor-so_wrap.c"
		"dynwrappers/xinerama-so_wrap.c"
		"dynwrappers/xinput2-so_wrap.c"
		"dynwrappers/xrandr-so_wrap.c"
		"dynwrappers/xrender-so_wrap.c"
		"dynwrappers/xext-so_wrap.c"
	)
endif()

if (godot_vulkan)
	target_sources(godot-exe PRIVATE "vulkan_context_x11.cpp")
endif()

if (godot_opengl3)
	target_compile_definitions(global-env INTERFACE "GLAD_GLX_NO_X11")
	target_sources(godot-exe PRIVATE
		"gl_manager_x11.cpp"
		"detect_prime_x11.cpp"
		"${ENGINE_SOURCE_DIR}/thirdparty/glad/glx.c"
	)
endif()