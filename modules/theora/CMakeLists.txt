
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

	add_lib(thirdparty-theora-lib
		OBJECT
		PARENT_LIB
			theora-lib
		COMPONENTS
			theora-env	
		SOURCES
			# "${__THIRDPARTY_THEORA_PATH}/analyze.c"
			# "${__THIRDPARTY_THEORA_PATH}/apiwrapper.c"
			"${__THIRDPARTY_THEORA_PATH}/bitpack.c"
			"${__THIRDPARTY_THEORA_PATH}/cpu.c"
			# "${__THIRDPARTY_THEORA_PATH}/decapiwrapper.c"
			"${__THIRDPARTY_THEORA_PATH}/decinfo.c"
			"${__THIRDPARTY_THEORA_PATH}/decode.c"
			"${__THIRDPARTY_THEORA_PATH}/dequant.c"
			# "${__THIRDPARTY_THEORA_PATH}/encapiwrapper.c"
			# "${__THIRDPARTY_THEORA_PATH}/encfrag.c"
			# "${__THIRDPARTY_THEORA_PATH}/encinfo.c"
			# "${__THIRDPARTY_THEORA_PATH}/encode.c"
			# "${__THIRDPARTY_THEORA_PATH}/encoder_disabled.c"
			# "${__THIRDPARTY_THEORA_PATH}/enquant.c"
			# "${__THIRDPARTY_THEORA_PATH}/fdct.c"
			"${__THIRDPARTY_THEORA_PATH}/fragment.c"
			"${__THIRDPARTY_THEORA_PATH}/huffdec.c"
			# "${__THIRDPARTY_THEORA_PATH}/huffenc.c"
			"${__THIRDPARTY_THEORA_PATH}/idct.c"
			"${__THIRDPARTY_THEORA_PATH}/info.c"
			"${__THIRDPARTY_THEORA_PATH}/internal.c"
			# "${__THIRDPARTY_THEORA_PATH}/mathops.c"
			# "${__THIRDPARTY_THEORA_PATH}/mcenc.c"
			"${__THIRDPARTY_THEORA_PATH}/quant.c"
			# "${__THIRDPARTY_THEORA_PATH}/rate.c"
			"${__THIRDPARTY_THEORA_PATH}/state.c"
			# "${__THIRDPARTY_THEORA_PATH}/tokenize.c"
	)

	get_target_property(__X86_LIBTHEORA_OPT_GCC global-env X86_LIBTHEORA_OPT_GCC)
	get_target_property(__X86_LIBTHEORA_OPT_VC global-env X86_LIBTHEORA_OPT_VC)

	if(__X86_LIBTHEORA_OPT_GCC)
		target_sources(thirdparty-theora-lib PRIVATE
			# "${__THIRDPARTY_THEORA_PATH}/x86/mmxencfrag.c"
			# "${__THIRDPARTY_THEORA_PATH}/x86/mmxfdct.c"
			"${__THIRDPARTY_THEORA_PATH}/x86/mmxfrag.c"
			"${__THIRDPARTY_THEORA_PATH}/x86/mmxidct.c"
			"${__THIRDPARTY_THEORA_PATH}/x86/mmxstate.c"
			# "${__THIRDPARTY_THEORA_PATH}/x86/sse2fdct.c"
			# "${__THIRDPARTY_THEORA_PATH}/x86/x86enc.c"
			"${__THIRDPARTY_THEORA_PATH}/x86/x86state.c"
		)
	endif()

	if(__X86_LIBTHEORA_OPT_VC)
		target_sources(thirdparty-theora-lib PRIVATE
			# "${__THIRDPARTY_THEORA_PATH}/x86_vc/mmxencfrag.c"
			# "${__THIRDPARTY_THEORA_PATH}/x86_vc/mmxfdct.c"
			"${__THIRDPARTY_THEORA_PATH}/x86_vc/mmxfrag.c"
			"${__THIRDPARTY_THEORA_PATH}/x86_vc/mmxidct.c"
			"${__THIRDPARTY_THEORA_PATH}/x86_vc/mmxstate.c"
			# "${__THIRDPARTY_THEORA_PATH}/x86_vc/x86enc.c"
			"${__THIRDPARTY_THEORA_PATH}/x86_vc/x86state.c"
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
endif()

target_glob_sources(theora-lib PRIVATE "*.cpp")

