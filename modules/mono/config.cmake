# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)

	set(__AVAILABLE_PLATFORMS "windows" "osx" "x11" "server" "android" "haiku" "javascript" "iphone")

	if(NOT GODOT_PLATFORM IN_LIST __AVAILABLE_PLATFORMS)
		message(FATAL_ERROR "This module does not currently support building for this platform (${GODOT_PLATFORM}).")
	endif()

	set_target_properties(global-env PROPERTIES USE_PTRCALL true)

	if(GODOT_PLATFORM STREQUAL "iphone" OR GODOT_PLATFORM STREQUAL "javascript")
		set(__DEFUALT_MONO_STATIC true)
	else()
		set(__DEFUALT_MONO_STATIC false)
	endif()

	if(GODOT_PLATFORM STREQUAL "javascript")
		set(__DEFAULT_MONO_BUNDLES_ZLIB true)
	else()
		set(__DEFAULT_MONO_BUNDLES_ZLIB false)
	endif()

	set_path_option(GODOT_MONO_PREFIX "" DESCRIPTION "Path to the mono installation directory for the target platform and architecture.")
	set_bool_option(GODOT_MONO_STATIC ${__DEFUALT_MONO_STATIC} DESCRIPTION "Statically link mono.")
	set_bool_option(GODOT_MONO_GLUE true DESCRIPTION "Build with the mono glue sources.")
	set_bool_option(GODOT_BUILD_CIL true DESCRIPTION "Build C# solutions.")
	set_bool_option(GODOT_COPY_MONO_ROOT false DESCRIPTION "Make a copy of the mono installation directory to bundle with the editor.")
	set_bool_option(GODOT_MONO_BUNDLES_ZLIB ${__DEFAULT_MONO_BUNDLES_ZLIB} DESCRIPTION "Statically link mono.")

	if(GODOT_MONO_BUNDLES_ZLIB)
		# Mono may come with zlib bundled for WASM or on newer version when built with MinGW.
		message(STATUS "This Mono runtime comes with zlib bundled. Disabling 'builtin_zlib'...")
		set(GODOT_BUILTIN_ZLIB false PARENT_SCOPE)
		target_include_directories(global-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/zlib")
	endif()

endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	set(${__OUTPUT} true PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_doc_classes __OUTPUT)
	set(${__OUTPUT}
		"CSharpScript"
		"GodotSharp"
		PARENT_SCOPE
	)
endfunction()

function(${__MODULE_NAME}_get_doc_relative_path __OUTPUT)
	set(${__OUTPUT} "doc_classes" PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_is_module_enabled __OUTPUT)
	# The module is disabled by default. Use mono_IS_MODULE_ENABLED=true to enable it.
	set(${__OUTPUT} false PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_version_string __OUTPUT)
	set(${__OUTPUT} "mono" PARENT_SCOPE)
endfunction()