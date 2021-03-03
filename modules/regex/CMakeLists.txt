
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
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_auto_possess.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_chartables.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_compile.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_config.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_context.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_convert.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_dfa_match.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_error.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_extuni.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_find_bracket.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_jit_compile.c"
		# "pcre2_jit_match.c", "pcre2_jit_misc.c", # these files are included in pcre2_jit_compile.c.
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_maketables.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_match.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_match_data.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_newline.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_ord2utf.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_pattern_info.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_script_run.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_serialize.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_string_utils.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_study.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_substitute.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_substring.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_tables.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_ucd.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_valid_utf.c"
		"${__THIRDPARTY_PCRE2_PATH}/pcre2_xclass.c"
	)

	function(prec2_builtin __WIDTH)

		set(__LIB_NAME "thirdparty-pcre2-${__WIDTH}-lib")

		add_lib("${__LIB_NAME}"
			OBJECT
			PARENT_LIB
				regex-lib
			COMPONENTS
				regex-env	
			SOURCES
				${__THIRDPARTY_PCRE2_SOURCES}
		)

		target_compile_definitions("${__LIB_NAME}" PRIVATE "PCRE2_CODE_UNIT_WIDTH=${__WIDTH}")
	endfunction()

	prec2_builtin(16)
	prec2_builtin(32)

endif()

target_compile_definitions(regex-lib PRIVATE "PCRE2_CODE_UNIT_WIDTH=0")
target_glob_sources(regex-lib PRIVATE "*.cpp")

