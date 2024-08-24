# so functions in the module would not be dependent on folder name at a configuration time.
get_filename_component(__MODULE_NAME "${CMAKE_CURRENT_LIST_DIR}" NAME)

function(${__MODULE_NAME}_configure_module)
	# Prior to .NET Core, we supported these: ["windows", "macos", "linuxbsd", "android", "haiku", "web", "ios"]
	# Eventually support for each them should be added back (except Haiku if not supported by .NET Core)
	assert(
		"Mono module does not currently support building for '${godot_platform}' platform."
		godot_platform MATCHES "(windows|macos|linuxbsd)")
endfunction()

function(${__MODULE_NAME}_get_module_can_build __OUTPUT)
	if (NOT PROCESSOR_ARCH_ALIAS MATCHES "^rv")
		set(${__OUTPUT} TRUE PARENT_SCOPE)
	else()
		set(${__OUTPUT} FALSE PARENT_SCOPE)
	endif()
endfunction()

function(${__MODULE_NAME}_get_module_dependencies __REQUIRED_DEPENDENCIES __OPTIONAL_DEPENDENCIES)
	set(${__REQUIRED_DEPENDENCIES} "regex" PARENT_SCOPE)
endfunction()

function(${__MODULE_NAME}_get_version_string __OUTPUT)
	set(${__OUTPUT} "mono" PARENT_SCOPE)
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
	# The module is disabled by default. Use godot_module_mono_enabled=yes to enable it.
	set(${__OUTPUT} FALSE PARENT_SCOPE)
endfunction()

