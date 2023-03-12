
add_env(regex-env
	COMPONENTS
		modules-env
)

add_module_lib(regex-lib
	COMPONENTS
		regex-env
		warnings-env
)

if(GODOT_BUILTIN_PCRE2)	

	set(__THIRDPARTY_PCRE2_PATH "${GODOT_SOURCE_DIR}/thirdparty/pcre2/src")

	target_include_directories(regex-env INTERFACE "${__THIRDPARTY_PCRE2_PATH}")
	target_compile_definitions(regex-env INTERFACE 
		"PCRE2_STATIC"
		"HAVE_CONFIG_H"
		"SUPPORT_UNICODE"
	)
	if(GODOT_BUILTIN_PCRE2_WITH_JIT)
		target_compile_definitions(regex-env INTERFACE 
			"SUPPORT_JIT"
		)
	endif()

	set(__THIRDPARTY_PCRE2_SOURCES
		"pcre2_auto_possess.c"
		"pcre2_chartables.c"
		"pcre2_compile.c"
		"pcre2_config.c"
		"pcre2_context.c"
		"pcre2_convert.c"
		"pcre2_dfa_match.c"
		"pcre2_error.c"
		"pcre2_extuni.c"
		"pcre2_find_bracket.c"
		"pcre2_jit_compile.c"
		# "pcre2_jit_match.c", "pcre2_jit_misc.c", # these files are included in pcre2_jit_compile.c.
		"pcre2_maketables.c"
		"pcre2_match.c"
		"pcre2_match_data.c"
		"pcre2_newline.c"
		"pcre2_ord2utf.c"
		"pcre2_pattern_info.c"
		"pcre2_script_run.c"
		"pcre2_serialize.c"
		"pcre2_string_utils.c"
		"pcre2_study.c"
		"pcre2_substitute.c"
		"pcre2_substring.c"
		"pcre2_tables.c"
		"pcre2_ucd.c"
		"pcre2_valid_utf.c"
		"pcre2_xclass.c"
	)

	function(prec2_builtin __WIDTH)

		set(__LIB_NAME "thirdparty-pcre2-${__WIDTH}-lib")

		add_module_lib("${__LIB_NAME}"
			OBJECT
			PARENT_LIB
				regex-lib
			COMPONENTS
				regex-env
		)
		target_sources_from_path("${__LIB_NAME}" PRIVATE "${__THIRDPARTY_PCRE2_PATH}"
			${__THIRDPARTY_PCRE2_SOURCES}
		)

		target_compile_definitions("${__LIB_NAME}" PRIVATE "PCRE2_CODE_UNIT_WIDTH=${__WIDTH}")
	endfunction()

	prec2_builtin(16)
	prec2_builtin(32)

endif()

target_compile_definitions(regex-lib PRIVATE "PCRE2_CODE_UNIT_WIDTH=0")
target_glob_sources(regex-lib PRIVATE "*.cpp")

