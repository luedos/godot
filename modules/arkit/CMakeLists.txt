
# (iOS) Build as separate static library
#TODO: Not sure if it's doing anything, but it seems in scones this library also not connecting to anything.. Need more testing on iphone targets.
add_module_lib(arkit-lib 
	EXCLUDE_FROM_ALL
	COMPONENTS
		modules-env
		warnings-env
	OUTPUT_DIR
		"${GODOT_BIN_DIRECTORY}"
	OUTPUT_NAME
		"libgodot_arkit_module"
)

# (iOS) Enable module support
target_compile_options(arkit-lib PRIVATE 
	"-fmodules" 
	"-fcxx-modules"
)
target_glob_sources(arkit-lib PRIVATE "*.cpp")
target_glob_sources(arkit-lib PRIVATE "*.mm")
