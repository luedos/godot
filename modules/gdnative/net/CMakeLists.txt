
add_module_lib(gdnative-net-lib
	OBJECT
	PARENT_LIB
		gdnative-lib
	COMPONENTS
		gdnative-env
		warnings-env
)

if(webrtc_IS_MODULE_ENABLED)
	target_compile_definitions(gdnative-net-lib PRIVATE "WEBRTC_GDNATIVE_ENABLED")
endif()

target_glob_sources(gdnative-net-lib PRIVATE "*.cpp")
