
add_env(opus-env
	COMPONENTS
		modules-env
)

add_module_lib(opus-lib
	COMPONENTS
		opus-env
		warnings-env
)


if(GODOT_BUILTIN_OPUS)

	add_lib(thirdparty-opus-lib 
		OBJECT
		PARENT_LIB
			opus-lib
		COMPONENTS
			opus-env
	)

	set(__THIRDPARTY_OPUS_PATH "${GODOT_SOURCE_DIR}/thirdparty/opus")

	target_sources(thirdparty-opus-lib PRIVATE
 # Sync with opus_sources.mk
		"${__THIRDPARTY_OPUS_PATH}/opus.c"
		"${__THIRDPARTY_OPUS_PATH}/opus_decoder.c"
		"${__THIRDPARTY_OPUS_PATH}/opus_encoder.c"
		"${__THIRDPARTY_OPUS_PATH}/opus_multistream.c"
		"${__THIRDPARTY_OPUS_PATH}/opus_multistream_encoder.c"
		"${__THIRDPARTY_OPUS_PATH}/opus_multistream_decoder.c"
		"${__THIRDPARTY_OPUS_PATH}/repacketizer.c"
		"${__THIRDPARTY_OPUS_PATH}/analysis.c"
		"${__THIRDPARTY_OPUS_PATH}/mlp.c"
		"${__THIRDPARTY_OPUS_PATH}/mlp_data.c"
		# Sync with libopusfile Makefile.am
		"${__THIRDPARTY_OPUS_PATH}/info.c"
		"${__THIRDPARTY_OPUS_PATH}/internal.c"
		"${__THIRDPARTY_OPUS_PATH}/opusfile.c"
		"${__THIRDPARTY_OPUS_PATH}/stream.c"
		# Sync with celt_sources.mk
		"${__THIRDPARTY_OPUS_PATH}/celt/bands.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/celt.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/celt_encoder.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/celt_decoder.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/cwrs.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/entcode.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/entdec.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/entenc.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/kiss_fft.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/laplace.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/mathops.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/mdct.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/modes.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/pitch.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/celt_lpc.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/quant_bands.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/rate.c"
		"${__THIRDPARTY_OPUS_PATH}/celt/vq.c"
		# "${__THIRDPARTY_OPUS_PATH}/celt/arm/arm_celt_map.c"
		# "${__THIRDPARTY_OPUS_PATH}/celt/arm/armcpu.c"
		# "${__THIRDPARTY_OPUS_PATH}/celt/arm/celt_ne10_fft.c"
		# "${__THIRDPARTY_OPUS_PATH}/celt/arm/celt_ne10_mdct.c"
		# "${__THIRDPARTY_OPUS_PATH}/celt/arm/celt_neon_intr.c"
		# Sync with silk_sources.mk
		"${__THIRDPARTY_OPUS_PATH}/silk/CNG.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/code_signs.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/init_decoder.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_core.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_frame.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_parameters.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_indices.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_pulses.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decoder_set_fs.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/dec_API.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/enc_API.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/encode_indices.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/encode_pulses.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/gain_quant.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/interpolate.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/LP_variable_cutoff.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_decode.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NSQ.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NSQ_del_dec.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/PLC.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/shell_coder.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_gain.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_LTP.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_NLSF_CB_NB_MB.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_NLSF_CB_WB.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_other.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_pitch_lag.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/tables_pulses_per_block.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/VAD.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/control_audio_bandwidth.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/quant_LTP_gains.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/VQ_WMat_EC.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/HP_variable_cutoff.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_encode.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_VQ.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_unpack.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_del_dec_quant.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/process_NLSFs.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_LR_to_MS.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_MS_to_LR.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/check_control_input.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/control_SNR.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/init_encoder.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/control_codec.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/A2NLSF.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/ana_filt_bank_1.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/biquad_alt.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/bwexpander_32.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/bwexpander.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/debug.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/decode_pitch.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/inner_prod_aligned.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/lin2log.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/log2lin.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/LPC_analysis_filter.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/LPC_inv_pred_gain.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/table_LSF_cos.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF2A.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_stabilize.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/NLSF_VQ_weights_laroia.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/pitch_est_tables.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_down2_3.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_down2.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_private_AR2.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_private_down_FIR.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_private_IIR_FIR.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_private_up2_HQ.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/resampler_rom.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/sigm_Q15.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/sort.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/sum_sqr_shift.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_decode_pred.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_encode_pred.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_find_predictor.c"
		"${__THIRDPARTY_OPUS_PATH}/silk/stereo_quant_pred.c"
	)

	if(GODOT_PLATFORM STREQUAL "android" 
		OR GODOT_PLATFORM STREQUAL "iphone"
		OR GODOT_PLATFORM STREQUAL "javascript")

		target_compile_definitions(opus-env INTERFACE "FIXED_POINT")

		target_sources(thirdparty-opus-lib PRIVATE
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/LTP_analysis_filter_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/LTP_scale_ctrl_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/corrMatrix_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/encode_frame_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/find_LPC_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/find_LTP_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/find_pitch_lags_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/find_pred_coefs_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/noise_shape_analysis_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/prefilter_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/process_gains_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/regularize_correlations_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/residual_energy16_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/residual_energy_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/solve_LS_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/warped_autocorrelation_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/apply_sine_window_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/autocorr_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/burg_modified_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/k2a_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/k2a_Q16_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/pitch_analysis_core_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/vector_ops_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/schur64_FIX.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/fixed/schur_FIX.c"
		)

	else()

		target_sources(thirdparty-opus-lib PRIVATE
			"${__THIRDPARTY_OPUS_PATH}/silk/float/apply_sine_window_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/corrMatrix_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/encode_frame_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/find_LPC_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/find_LTP_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/find_pitch_lags_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/find_pred_coefs_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/LPC_analysis_filter_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/LTP_analysis_filter_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/LTP_scale_ctrl_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/noise_shape_analysis_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/prefilter_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/process_gains_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/regularize_correlations_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/residual_energy_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/solve_LS_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/warped_autocorrelation_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/wrappers_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/autocorrelation_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/burg_modified_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/bwexpander_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/energy_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/inner_product_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/k2a_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/levinsondurbin_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/LPC_inv_pred_gain_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/pitch_analysis_core_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/scale_copy_vector_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/scale_vector_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/schur_FLP.c"
			"${__THIRDPARTY_OPUS_PATH}/silk/float/sort_FLP.c"
		)

	endif()


	if(GODOT_BUILTIN_LIBOGG)

		target_include_directories(opus-env INTERFACE "${GODOT_SOURCE_DIR}/thirdparty/libogg")

	endif()

	target_compile_definitions(opus-env INTERFACE "HAVE_CONFIG_H")

	target_include_directories(opus-env INTERFACE
		"${__THIRDPARTY_OPUS_PATH}"
		"${__THIRDPARTY_OPUS_PATH}/celt"
		"${__THIRDPARTY_OPUS_PATH}/opus"
		"${__THIRDPARTY_OPUS_PATH}/silk"
		"${__THIRDPARTY_OPUS_PATH}/silk/fixed"
		"${__THIRDPARTY_OPUS_PATH}/silk/float"
	)

	if(GODOT_PLATFORM STREQUAL "android")
		if(GODOT_ANDROID_ARCH STREQUAL "armv7")
			target_compile_definitions(opus-env INTERFACE "OPUS_ARM_OPT")
		elseif(GODOT_ANDROID_ARCH STREQUAL "arm64v8")
			target_compile_definitions(opus-env INTERFACE "OPUS_ARM64_OPT")
		endif()
	elseif(GODOT_PLATFORM STREQUAL "iphone")
		if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm")
			target_compile_definitions(opus-env INTERFACE "OPUS_ARM_OPT")
		elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
			target_compile_definitions(opus-env INTERFACE "OPUS_ARM64_OPT")
		endif()
	elseif(GODOT_PLATFORM STREQUAL "android")
		if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
			target_compile_definitions(opus-env INTERFACE "OPUS_ARM64_OPT")
		endif()
	endif()

endif()

target_sources(opus-lib PRIVATE "register_types.cpp")

