
if (godot_platform STREQUAL "web")
	target_link_js_libraries(global-libs-list INTERFACE "library_godot_webrtc.js")
endif()

add_lib(webrtc-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(webrtc-lib PRIVATE "*.cpp")
