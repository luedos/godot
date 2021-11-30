
add_lib(webxr-lib 
	COMPONENTS
		modules-env
		warnings-env
)

if(GODOT_PLATFORM STREQUAL "javascript")
	#TODO: Actially implement function target_add_js_library
	# This function basically should add input files input target_link_libraries as '--js-library "<library>"'
	target_add_js_library(global-libs-list "native/library_godot_webxr.js")
	#TODO: Actially implement function target_add_js_externs
	# This function basically should add input files input target_add_js_externs
	# to the env variable EMCC_CLOSURE_ARGS as '--externs "<library>"' 
	# (probably.. this is at least what scons is doing, but I'm not sure this will work for cmake,
	# and I fear, I would need to write some custom solution, if I ever come back to porting
	# javascript platform to cmake..)
	target_add_js_externs(global-libs-list "native/webxr.externs.js")
endif()

target_glob_sources(webxr-lib PRIVATE "*.cpp")
