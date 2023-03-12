
add_module_lib(webrtc-lib
	COMPONENTS
		modules-env
		warnings-env
)

if(gdnative_IS_MODULE_ENABLED)	
	target_compile_definitions(webrtc-lib PRIVATE "WEBRTC_GDNATIVE_ENABLED")
	target_include_directories(webrtc-lib PRIVATE "${gdnative_MODULE_PATH}/include")
	define_module_dependencies(webrtc-lib 
		gdnative-lib
	)
endif()

if(GODOT_PLATFORM STREQUAL "javascript")
	#TODO: Actially implement function target_add_js_library
	# This function basically should add input files input target_link_libraries as '--js-library "<library>"'
	target_add_js_library(global-libs-list "library_godot_webrtc.js")
endif()

target_glob_sources(webrtc-lib PRIVATE "*.cpp")
