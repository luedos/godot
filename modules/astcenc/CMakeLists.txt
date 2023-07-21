add_env(astcenc-env
	COMPONENTS
		modules-env
)

add_lib(astcenc-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		astcenc-env
		global-warnings-env
)
target_glob_sources(astcenc-lib PRIVATE "*.cpp")

add_lib(thirdparty-astcenc-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		astcenc-env
		thirdparty-warnings-env
)
set(__THIRDPARTY_ASTCENC_PATH "${ENGINE_SOURCE_DIR}/thirdparty/astcenc")
target_sources_from_path(thirdparty-astcenc-lib PRIVATE "${__THIRDPARTY_ASTCENC_PATH}"
	"astcenc_averages_and_directions.cpp"
	"astcenc_block_sizes.cpp"
	"astcenc_color_quantize.cpp"
	"astcenc_color_unquantize.cpp"
	"astcenc_compress_symbolic.cpp"
	"astcenc_compute_variance.cpp"
	"astcenc_decompress_symbolic.cpp"
	"astcenc_diagnostic_trace.cpp"
	"astcenc_entry.cpp"
	"astcenc_find_best_partitioning.cpp"
	"astcenc_ideal_endpoints_and_weights.cpp"
	"astcenc_image.cpp"
	"astcenc_integer_sequence.cpp"
	"astcenc_mathlib.cpp"
	"astcenc_mathlib_softfloat.cpp"
	"astcenc_partition_tables.cpp"
	"astcenc_percentile_tables.cpp"
	"astcenc_pick_best_endpoint_format.cpp"
	"astcenc_quantization.cpp"
	"astcenc_symbolic_physical.cpp"
	"astcenc_weight_align.cpp"
	"astcenc_weight_quant_xfer_tables.cpp"
)

target_include_directories(astcenc-env INTERFACE "${__THIRDPARTY_ASTCENC_PATH}")