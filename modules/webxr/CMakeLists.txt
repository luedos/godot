
if (godot_platform STREQUAL "web")
	target_link_js_libraries(global-libs-list INTERFACE "native/library_godot_webxr.js")
	# Hope this works
	target_compile_options(global-env INTERFACE "--closure-args=\"--externs=${CMAKE_CURRENT_SOURCE_DIR}/native/webxr.externs.js\"")
endif()

add_lib(webxr-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		modules-env
		global-warnings-env
)
target_glob_sources(webxr-lib PRIVATE "*.cpp")
