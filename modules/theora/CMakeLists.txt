
add_env(theora-env
	COMPONENTS
		modules-env
)

add_module_lib(theora-lib
	COMPONENTS
		theora-env
		warnings-env
)

if(GODOT_BUILTIN_LIBTHEORA)

	set(__THIRDPARTY_THEORA_PATH "${GODOT_SOURCE_DIR}/thirdparty/libtheora")

	add_module_lib(thirdparty-theora-lib
		OBJECT
		PARENT_LIB
			theora-lib
		COMPONENTS
			theora-env	
		SOURCES
	)

	target_sources_from_path(thirdparty-theora-lib PRIVATE "${__THIRDPARTY_THEORA_PATH}"
		# "analyze.c"
		# "apiwrapper.c"
		"bitpack.c"
		"cpu.c"
		# "decapiwrapper.c"
		"decinfo.c"
		"decode.c"
		"dequant.c"
		# "encapiwrapper.c"
		# "encfrag.c"
		# "encinfo.c"
		# "encode.c"
		# "encoder_disabled.c"
		# "enquant.c"
		# "fdct.c"
		"fragment.c"
		"huffdec.c"
		# "huffenc.c"
		"idct.c"
		"info.c"
		"internal.c"
		# "mathops.c"
		# "mcenc.c"
		"quant.c"
		# "rate.c"
		"state.c"
		# "tokenize.c"
	)

	get_target_property(__X86_LIBTHEORA_OPT_GCC global-env X86_LIBTHEORA_OPT_GCC)
	get_target_property(__X86_LIBTHEORA_OPT_VC global-env X86_LIBTHEORA_OPT_VC)

	if(__X86_LIBTHEORA_OPT_GCC)
		target_sources_from_path(thirdparty-theora-lib PRIVATE "${__THIRDPARTY_THEORA_PATH}"
			# "x86/mmxencfrag.c"
			# "x86/mmxfdct.c"
			"x86/mmxfrag.c"
			"x86/mmxidct.c"
			"x86/mmxstate.c"
			# "x86/sse2fdct.c"
			# "x86/x86enc.c"
			"x86/x86state.c"
		)
	endif()

	if(__X86_LIBTHEORA_OPT_VC)
		target_sources_from_path(thirdparty-theora-lib PRIVATE "${__THIRDPARTY_THEORA_PATH}"
			# "x86_vc/mmxencfrag.c"
			# "x86_vc/mmxfdct.c"
			"x86_vc/mmxfrag.c"
			"x86_vc/mmxidct.c"
			"x86_vc/mmxstate.c"
			# "x86_vc/x86enc.c"
			"x86_vc/x86state.c"
		)
	endif()

	if(__X86_LIBTHEORA_OPT_GCC OR __X86_LIBTHEORA_OPT_VC)
		target_compile_definitions(theora-env INTERFACE "OC_X86_ASM")
	endif()

	target_include_directories(theora-env INTERFACE "${__THIRDPARTY_THEORA_PATH}")
	
	if(GODOT_BUILTIN_LIBOGG)
		target_include_directories(theora-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libogg")
	endif()
	if(GODOT_BUILTIN_LIBVORBIS)
		target_include_directories(theora-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libvorbis")
	endif()
	define_module_dependencies(theora-lib 
		vorbis-lib
		ogg-lib
	)
endif()

target_glob_sources(theora-lib PRIVATE "*.cpp")

