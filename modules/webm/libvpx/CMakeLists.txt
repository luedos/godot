
set(__THIRDPARTY_LIBVPX_PATH "${GODOT_SOURCE_DIR}/thirdparty/libvpx")

set(__LIBVPX_SOURCES
    "vp8/vp8_dx_iface.c"
    "vp8/common/generic/systemdependent.c"
    "vp8/common/alloccommon.c"
    "vp8/common/blockd.c"
    "vp8/common/copy_c.c"
    "vp8/common/debugmodes.c"
    "vp8/common/dequantize.c"
    "vp8/common/entropy.c"
    "vp8/common/entropymode.c"
    "vp8/common/entropymv.c"
    "vp8/common/extend.c"
    "vp8/common/filter.c"
    "vp8/common/findnearmv.c"
    "vp8/common/idct_blk.c"
    "vp8/common/idctllm.c"
    "vp8/common/loopfilter_filters.c"
    "vp8/common/mbpitch.c"
    "vp8/common/modecont.c"
    "vp8/common/quant_common.c"
    "vp8/common/reconinter.c"
    "vp8/common/reconintra.c"
    "vp8/common/reconintra4x4.c"
    "vp8/common/rtcd.c"
    "vp8/common/setupintrarecon.c"
    "vp8/common/swapyv12buffer.c"
    "vp8/common/treecoder.c"
    "vp8/common/vp8_loopfilter.c"
    "vp8/decoder/dboolhuff.c"
    "vp8/decoder/decodeframe.c"
    "vp8/decoder/decodemv.c"
    "vp8/decoder/detokenize.c"
    "vp8/decoder/onyxd_if.c"
    "vp9/vp9_dx_iface.c"
    "vp9/common/vp9_alloccommon.c"
    "vp9/common/vp9_blockd.c"
    "vp9/common/vp9_common_data.c"
    "vp9/common/vp9_debugmodes.c"
    "vp9/common/vp9_entropy.c"
    "vp9/common/vp9_entropymode.c"
    "vp9/common/vp9_entropymv.c"
    "vp9/common/vp9_filter.c"
    "vp9/common/vp9_frame_buffers.c"
    "vp9/common/vp9_idct.c"
    "vp9/common/vp9_loopfilter.c"
    "vp9/common/vp9_mvref_common.c"
    "vp9/common/vp9_pred_common.c"
    "vp9/common/vp9_quant_common.c"
    "vp9/common/vp9_reconinter.c"
    "vp9/common/vp9_reconintra.c"
    "vp9/common/vp9_rtcd.c"
    "vp9/common/vp9_scale.c"
    "vp9/common/vp9_scan.c"
    "vp9/common/vp9_seg_common.c"
    "vp9/common/vp9_thread_common.c"
    "vp9/common/vp9_tile_common.c"
    "vp9/decoder/vp9_decodeframe.c"
    "vp9/decoder/vp9_decodemv.c"
    "vp9/decoder/vp9_decoder.c"
    "vp9/decoder/vp9_detokenize.c"
    "vp9/decoder/vp9_dsubexp.c"
    "vp9/decoder/vp9_dthread.c"
    "vpx/src/vpx_codec.c"
    "vpx/src/vpx_decoder.c"
    "vpx/src/vpx_image.c"
    "vpx/src/vpx_psnr.c"
    "vpx_dsp/bitreader.c"
    "vpx_dsp/bitreader_buffer.c"
    "vpx_dsp/intrapred.c"
    "vpx_dsp/inv_txfm.c"
    "vpx_dsp/loopfilter.c"
    "vpx_dsp/prob.c"
    "vpx_dsp/vpx_convolve.c"
    "vpx_dsp/vpx_dsp_rtcd.c"
    "vpx_mem/vpx_mem.c"
    "vpx_scale/vpx_scale_rtcd.c"
    "vpx_scale/generic/yv12config.c"
    "vpx_scale/generic/yv12extend.c"
    "vpx_util/vpx_thread.c"
)
list(TRANSFORM __LIBVPX_SOURCES PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_MT
    "vp8/decoder/threading.c"
)
list(TRANSFORM __LIBVPX_SOURCES_MT PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_INTRIN_X86
    "vp8/common/x86/filter_x86.c"
    "vp8/common/x86/loopfilter_x86.c"
    "vp8/common/x86/vp8_asm_stubs.c"
    "vpx_dsp/x86/vpx_asm_stubs.c"
)
list(TRANSFORM __LIBVPX_SOURCES_INTRIN_X86 PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_INTRIN_X86_MMX
    "vp8/common/x86/idct_blk_mmx.c"
)
list(TRANSFORM __LIBVPX_SOURCES_INTRIN_X86_MMX PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_INTRIN_X86_SSE2
    "vp8/common/x86/idct_blk_sse2.c"
    "vp9/common/x86/vp9_idct_intrin_sse2.c"
    "vpx_dsp/x86/inv_txfm_sse2.c"
    "vpx_dsp/x86/loopfilter_sse2.c"
)
list(TRANSFORM __LIBVPX_SOURCES_INTRIN_X86_SSE2 PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_INTRIN_X86_SSSE3
    "vpx_dsp/x86/vpx_subpixel_8t_intrin_ssse3.c"
)
list(TRANSFORM __LIBVPX_SOURCES_INTRIN_X86_SSSE3 PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_INTRIN_X86_AVX2
	"vpx_dsp/x86/loopfilter_avx2.c"
	"vpx_dsp/x86/vpx_subpixel_8t_intrin_avx2.c"
)
list(TRANSFORM __LIBVPX_SOURCES_INTRIN_X86_AVX2 PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_X86ASM
    "vp8/common/x86/copy_sse2.asm"
    "vp8/common/x86/copy_sse3.asm"
    "vp8/common/x86/dequantize_mmx.asm"
    "vp8/common/x86/idctllm_mmx.asm"
    "vp8/common/x86/idctllm_sse2.asm"
    "vp8/common/x86/iwalsh_mmx.asm"
    "vp8/common/x86/iwalsh_sse2.asm"
    "vp8/common/x86/loopfilter_sse2.asm"
    "vp8/common/x86/recon_mmx.asm"
    "vp8/common/x86/recon_sse2.asm"
    "vp8/common/x86/subpixel_mmx.asm"
    "vp8/common/x86/subpixel_sse2.asm"
    "vp8/common/x86/subpixel_ssse3.asm"
    "vp8/common/x86/vp8_loopfilter_mmx.asm"
    "vpx_dsp/x86/intrapred_sse2.asm"
    "vpx_dsp/x86/intrapred_ssse3.asm"
    "vpx_dsp/x86/inv_wht_sse2.asm"
    "vpx_dsp/x86/vpx_convolve_copy_sse2.asm"
    "vpx_dsp/x86/vpx_subpixel_8t_sse2.asm"
    "vpx_dsp/x86/vpx_subpixel_8t_ssse3.asm"
    "vpx_dsp/x86/vpx_subpixel_bilinear_sse2.asm"
    "vpx_dsp/x86/vpx_subpixel_bilinear_ssse3.asm"
    "vpx_ports/emms.asm"
)
list(TRANSFORM __LIBVPX_SOURCES_X86ASM PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_X86_64ASM
	"vp8/common/x86/loopfilter_block_sse2_x86_64.asm"
	"vpx_dsp/x86/inv_txfm_ssse3_x86_64.asm"
)
list(TRANSFORM __LIBVPX_SOURCES_X86_64ASM PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_ARM
    "vpx_ports/arm_cpudetect.c"
    "vp8/common/arm/loopfilter_arm.c"
)
list(TRANSFORM __LIBVPX_SOURCES_ARM PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_ARM_NEON
    "vp8/common/arm/neon/bilinearpredict_neon.c"
    "vp8/common/arm/neon/copymem_neon.c"
    "vp8/common/arm/neon/dc_only_idct_add_neon.c"
    "vp8/common/arm/neon/dequant_idct_neon.c"
    "vp8/common/arm/neon/dequantizeb_neon.c"
    "vp8/common/arm/neon/idct_blk_neon.c"
    "vp8/common/arm/neon/idct_dequant_0_2x_neon.c"
    "vp8/common/arm/neon/idct_dequant_full_2x_neon.c"
    "vp8/common/arm/neon/iwalsh_neon.c"
    "vp8/common/arm/neon/loopfiltersimplehorizontaledge_neon.c"
    "vp8/common/arm/neon/loopfiltersimpleverticaledge_neon.c"
    "vp8/common/arm/neon/mbloopfilter_neon.c"
    "vp8/common/arm/neon/shortidct4x4llm_neon.c"
    "vp8/common/arm/neon/sixtappredict_neon.c"
    "vp8/common/arm/neon/vp8_loopfilter_neon.c"
    "vp9/common/arm/neon/vp9_iht4x4_add_neon.c"
    "vp9/common/arm/neon/vp9_iht8x8_add_neon.c"
    "vpx_dsp/arm/idct16x16_1_add_neon.c"
    "vpx_dsp/arm/idct16x16_add_neon.c"
    "vpx_dsp/arm/idct16x16_neon.c"
    "vpx_dsp/arm/idct32x32_1_add_neon.c"
    "vpx_dsp/arm/idct32x32_add_neon.c"
    "vpx_dsp/arm/idct4x4_1_add_neon.c"
    "vpx_dsp/arm/idct4x4_add_neon.c"
    "vpx_dsp/arm/idct8x8_1_add_neon.c"
    "vpx_dsp/arm/idct8x8_add_neon.c"
    "vpx_dsp/arm/intrapred_neon.c"
    "vpx_dsp/arm/loopfilter_16_neon.c"
    "vpx_dsp/arm/loopfilter_4_neon.c"
    "vpx_dsp/arm/loopfilter_8_neon.c"
    "vpx_dsp/arm/loopfilter_neon.c"
    "vpx_dsp/arm/vpx_convolve8_avg_neon.c"
    "vpx_dsp/arm/vpx_convolve8_neon.c"
    "vpx_dsp/arm/vpx_convolve_avg_neon.c"
    "vpx_dsp/arm/vpx_convolve_copy_neon.c"
    "vpx_dsp/arm/vpx_convolve_neon.c"
)
list(TRANSFORM __LIBVPX_SOURCES_ARM_NEON PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_ARM_NEON_GAS
    "vpx_dsp/arm/gas/intrapred_neon_asm.s"
    "vpx_dsp/arm/gas/loopfilter_mb_neon.s"
    "vpx_dsp/arm/gas/save_reg_neon.s"
)
list(TRANSFORM __LIBVPX_SOURCES_ARM_NEON_GAS PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_ARM_NEON_ARMASM_MS
    "vpx_dsp/arm/armasm_ms/intrapred_neon_asm.asm"
    "vpx_dsp/arm/armasm_ms/loopfilter_mb_neon.asm"
    "vpx_dsp/arm/armasm_ms/save_reg_neon.asm"
)
list(TRANSFORM __LIBVPX_SOURCES_ARM_NEON_ARMASM_MS PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")

##############################################################################################

set(__LIBVPX_SOURCES_ARM_NEON_GAS_APPLE
    "vpx_dsp/arm/gas_apple/intrapred_neon_asm.s"
    "vpx_dsp/arm/gas_apple/loopfilter_mb_neon.s"
    "vpx_dsp/arm/gas_apple/save_reg_neon.s"
)
list(TRANSFORM __LIBVPX_SOURCES_ARM_NEON_GAS_APPLE PREPEND "${__THIRDPARTY_LIBVPX_PATH}/")


add_env(libvpx-env
	COMPONENTS
		modules-env
)

add_module_lib(libvpx-lib
	OBJECT
	PARENT_LIB
		webm-lib
	COMPONENTS
		libvpx-env
)

target_include_directories(libvpx-env INTERFACE "${__THIRDPARTY_LIBVPX_PATH}")

inline_if(__WEBM_MULTITHREAD NOT GODOT_PLATFORM STREQUAL "javascript")

set(__CPU_BITS ${PROCESSOR_BITS})

set(__WEBM_CPU_X86 false)
set(__WEBM_CPU_ARM false)

if(GODOT_PLATFORM STREQUAL "uwp")

	#TODO: this is incorrect way of specifying platform
	if(PROCESSOR_IS_ARM)
		set(__WEBM_CPU_ARM true)
	else()
		set(__WEBM_CPU_X86 true)
	endif()

elseif(NOT GODOT_PLATFORM STREQUAL "windows") # Disable for Windows, yasm SIMD optimizations trigger crash (GH-50862).

	inline_if(__IS_X11_OR_SERVER_ARM 
		GODOT_PLATFORM MATCHES "(x11|server)"
		AND (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^arm.*" OR CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^aarch.*") 
	)
	inline_if(__IS_MACOS_X86
		GODOT_PLATFORM STREQUAL "osx"
		AND NOT PROCESSOR_IS_ARM
	)
	inline_if(__IS_IOS_X86
		GODOT_PLATFORM STREQUAL "iphone"
		AND PROCESSOR_IS_X86
	)
	inline_if(__IS_ANDROID_X86 
		GODOT_PLATFORM STREQUAL "android"
		AND GODOT_ANDROID_ARCH MATCHES "^x86.*"
	)
	if(__IS_ANDROID_X86)
		ternary_if(__CPU_BITS 
			"32"
			"64"
			GODOT_ANDROID_ARCH STREQUAL "x86"
		)
	endif()

	inline_if(__WEBM_CPU_X86
		NOT __IS_X11_OR_SERVER_ARM
		AND __CPU_BITS MATCHES "(32|64)" # why the hell is this here??
		AND (
			GODOT_PLATFORM MATCHES "(windows|x11|haiku)"
			OR __IS_MACOS_X86
			OR __IS_ANDROID_X86
			OR __IS_IOS_X86
		)
	)

	inline_if(__WEBM_CPU_ARM
		__IS_X11_OR_SERVER_ARM
		OR (NOT __IS_MACOS_X86 AND GODOT_PLATFORM STREQUAL "osx")
		OR (NOT __IS_IOS_X86 AND GODOT_PLATFORM STREQUAL "iphone")
		OR (NOT __IS_ANDROID_X86 AND GODOT_PLATFORM STREQUAL "android")
	)

endif()

target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES})

if(__WEBM_MULTITHREAD)
	target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_MT})
endif()

if(__WEBM_CPU_X86)

	find_program(YASM_EXE NAMES yasm)
	if(YASM_EXE STREQUAL "YASM_EXE-NOTFOUND")
		set(__WEBM_CPU_X86 false)
		message(WARNING "YASM is necessary for WebM SIMD optimizations.")
	endif()

endif()

if(NOT __WEBM_CPU_X86 AND NOT __WEBM_CPU_ARM AND NOT GODOT_PLATFORM STREQUAL "windows")
	message(STATUS "WebM SIMD optimizations are disabled. Check if your CPU architecture, CPU bits or platform are supported!")
endif()

if(__WEBM_CPU_X86)

	if(GODOT_PLATFORM MATCHES "(windows|uwp)")
		set(__ASM_FORMAT "win")
	elseif(GODOT_PLATFORM MATCHES "(osx|iphone)")
		set(__ASM_FORMAT "macho")
	else()
		set(__ASM_FORMAT "elf")
	endif()

	set(__ASM_FORMAT "${__ASM_FORMAT}${__CPU_BITS}")

	if(__CPU_BITS EQUAL 32)
		set(__ASM_CPU "X86_32")
	elseif(__CPU_BITS EQUAL 64)
		set(__ASM_CPU "X86_64")
	endif()

	target_compile_definitions(libvpx-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:WEBM_X86ASM>)

	# we are doing this dirty way (god I hope this works)
	foreach(__SOURCE_FILE IN LISTS 
		__LIBVPX_SOURCES_X86ASM 
		__LIBVPX_SOURCES_X86_64ASM
	)
		
		get_filename_component(__FILE_NAME "${__SOURCE_FILE}" NAME_WE)
		set(__OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${__FILE_NAME}.o")

		# theoretically MAIN_DEPENDENCY will force building of this file with this command, and not with defined compiler
		add_custom_command(
			OUTPUT "${__OUTPUT_FILE}"
			MAIN_DEPENDENCY "${__SOURCE_FILE}"
			COMMAND ${YASM_EXE} 
			ARGS 
				"-I${__THIRDPARTY_LIBVPX_PATH}" 
				-f "${__ASM_FORMAT}"
				-D "${__ASM_CPU}"
				-o "${__OUTPUT_FILE}" 
				"${__SOURCE_FILE}"
			VERBATIM
		)

	endforeach()

	#TODO: Dont forget to use "osxcross" then it will be implemented with osx platforms 
	set(__IS_CLANG_OR_GCC_GEN_EXPR 
        $<OR:$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>,$<COMPILE_LANG_AND_ID:C,GNU,Clang,AppleClang>,$<COMPILE_LANG_AND_ID:OBJCXX,GNU,Clang,AppleClang>,$<COMPILE_LANG_AND_ID:OBJC,GNU,Clang,AppleClang>>)

	inline_if(__IS_CPU_32_BITS __CPU_BITS EQUAL 32)

	add_module_lib(libvpx-mmx-lib OBJECT PARENT_LIB webm-lib COMPONENTS libvpx-env)
	target_compile_options(libvpx-mmx-lib PRIVATE $<$<AND:$<BOOL:${__IS_CPU_32_BITS}>,${__IS_CLANG_OR_GCC_GEN_EXPR}>:-mmmx>)
	target_sources(libvpx-mmx-lib PRIVATE ${__LIBVPX_SOURCES_INTRIN_X86_MMX})

	add_module_lib(libvpx-sse2-lib OBJECT PARENT_LIB webm-lib COMPONENTS libvpx-env)
	target_compile_options(libvpx-sse2-lib PRIVATE $<$<AND:$<BOOL:${__IS_CPU_32_BITS}>,${__IS_CLANG_OR_GCC_GEN_EXPR}>:-msse2>)
	target_sources(libvpx-sse2-lib PRIVATE ${__LIBVPX_SOURCES_INTRIN_X86_SSE2})

	add_module_lib(libvpx-ssse3-lib OBJECT PARENT_LIB webm-lib COMPONENTS libvpx-env)
	target_compile_options(libvpx-ssse3-lib PRIVATE $<${__IS_CLANG_OR_GCC_GEN_EXPR}:-mssse3>)
	target_sources(libvpx-ssse3-lib PRIVATE ${__LIBVPX_SOURCES_INTRIN_X86_SSSE3})

	add_module_lib(libvpx-avx2-lib OBJECT PARENT_LIB webm-lib COMPONENTS libvpx-env)
	target_compile_options(libvpx-avx2-lib PRIVATE $<${__IS_CLANG_OR_GCC_GEN_EXPR}:-mavx2>)
	target_sources(libvpx-ssse3-lib PRIVATE ${__LIBVPX_SOURCES_INTRIN_X86_AVX2})

	target_sources(libvpx-lib PRIVATE 
		${__LIBVPX_SOURCES_INTRIN_X86} 
		${__LIBVPX_SOURCES_X86ASM}
	)
	if(__CPU_BITS EQUAL 64)
		target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_X86_64ASM})
	endif()

elseif(__WEBM_CPU_ARM)

	set(__IS_ASM_GEN_EXPR $<COMPILE_LANGUAGE:ASM,ASM_NASM,ASM_MASM,ASM_ATT>)

	if(GODOT_PLATFORM STREQUAL "iphone")

		target_compile_options(libvpx-env INTERFACE $<${__IS_ASM_GEN_EXPR}:-arch;armv7>)

	elseif((GODOT_PLATFORM STREQUAL "android" AND GODOT_ANDROID_ARCH STREQUAL "armv7")
		OR GODOT_PLATFORM STREQUAL "x11"
		OR GODOT_PLATFORM STREQUAL "server"
	)

		target_compile_options(libvpx-env INTERFACE $<${__IS_ASM_GEN_EXPR}:-mfpu=neon>)

	elseif(GODOT_PLATFORM STREQUAL "uwp")

		foreach(__SOURCE_FILE IN LISTS 
			__LIBVPX_SOURCES_ARM_NEON_ARMASM_MS 
			__LIBVPX_SOURCES_ARM_NEON_GAS_APPLE
			__LIBVPX_SOURCES_ARM_NEON_GAS
		)
			
			get_filename_component(__FILE_NAME "${__SOURCE_FILE}" NAME_WE)
			set(__OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${__FILE_NAME}.o")
	
			# theoretically MAIN_DEPENDENCY will force building of this file with this command, and not with defined compiler
			add_custom_command(
				OUTPUT "${__OUTPUT_FILE}"
				MAIN_DEPENDENCY "${__SOURCE_FILE}"
				COMMAND "armasm"	# hardcoded exe
				ARGS 
					-o "${__OUTPUT_FILE}" 
					"${__SOURCE_FILE}"
				VERBATIM
			)

		endforeach()

	endif()

	target_compile_definitions(libvpx-env INTERFACE $<$<COMPILE_LANGUAGE:CXX>:WEBM_ARMASM>)

	target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_ARM})

	if(GODOT_PLATFORM STREQUAL "android")
		target_include_directories(libvpx-env INTERFACE "${__THIRDPARTY_LIBVPX_PATH}/third_party/android")
		target_sources(libvpx-lib PRIVATE "${__THIRDPARTY_LIBVPX_PATH}/third_party/android/cpu-features.c")
	endif()

	target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_ARM_NEON})

	if(GODOT_PLATFORM STREQUAL "uwp")
		target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_ARM_NEON_ARMASM_MS})
	elseif(GODOT_PLATFORM STREQUAL "iphone")
		target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_ARM_NEON_GAS_APPLE})
	elseif((__IS_X11_OR_SERVER_ARM AND __CPU_BITS EQUAL 32) 
		OR (GODOT_PLATFORM STREQUAL "android" AND NOT GODOT_ANDROID_ARCH STREQUAL "arm64v8"))

		target_sources(libvpx-lib PRIVATE ${__LIBVPX_SOURCES_ARM_NEON_GAS})

	endif()

endif()
