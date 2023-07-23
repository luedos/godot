
execute_python_method(gen_methods generate_encryption_key_header
	PYTHON_ARGS 
		STR_ENV_VAR "SCRIPT_AES256_ENCRYPTION_KEY"
	ACTION_CACHE_NAME "generate_encryption_key_header"
	DEPENDENT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/script_encryption_key.gen.cpp"
)

add_env(core-env
	COMPONENTS
		global-env
)

add_lib(core-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		core-env
		global-warnings-env
)

add_lib(thirdparty-core-lib 
	OBJECT
	PARENT_LIB 
		core-lib
	COMPONENTS
		core-env
		thirdparty-warnings-env
)

# Misc thirdparty code: header paths are hardcoded, we don't need to append
# to the include path (saves a few chars on the compiler invocation for touchy MSVC...)
target_sources_from_path(thirdparty-core-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/misc"
	# C sources
	"fastlz.c"
	"r128.c"
	"smaz.c"
	# C++ sources
	"pcg.cpp"
	"polypartition.cpp"
	"clipper.cpp"
	"smolv.cpp"
)

if (godot_brotli AND godot_builtin_brotli)
	set(__THIRDPARTY_BROTLI_DIR "${ENGINE_SOURCE_DIR}/thirdparty/brotli")

	target_sources_from_path(thirdparty-core-lib PRIVATE "${__THIRDPARTY_BROTLI_DIR}"
		"common/constants.c"
		"common/context.c"
		"common/dictionary.c"
		"common/platform.c"
		"common/shared_dictionary.c"
		"common/transform.c"
		"dec/bit_reader.c"
		"dec/decode.c"
		"dec/huffman.c"
		"dec/state.c"
	)

	target_include_directories(global-env INTERFACE "${__THIRDPARTY_BROTLI_DIR}/include")

	if (godot_use_ubsan OR godot_use_asan OR godot_use_tsan OR godot_use_lsan OR godot_use_msan)
		target_compile_definitions(thirdparty-core-lib PRIVATE "BROTLI_BUILD_PORTABLE")
	endif()
endif()

if (godot_builtin_zlib)
	set(__THIRDPARTY_ZLIB_DIR "${ENGINE_SOURCE_DIR}/thirdparty/zlib")

	target_sources_from_path(thirdparty-core-lib PRIVATE "${__THIRDPARTY_ZLIB_DIR}"
		"adler32.c"
		"compress.c"
		"crc32.c"
		"deflate.c"
		"infback.c"
		"inffast.c"
		"inflate.c"
		"inftrees.c"
		"trees.c"
		"uncompr.c"
		"zutil.c"
	)

	# Needs to be available in main env too
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_ZLIB_DIR}")

	if (godot_dev_build)
		target_compile_definitions(thirdparty-core-lib PRIVATE ZLIB_DEBUG)
	endif()
endif()

# Minizip library, could be unbundled in theory
# However, our version has some custom modifications, so it won't compile with the system one
target_sources_from_path(thirdparty-core-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/minizip"
	"ioapi.c"
	"unzip.c"
	"zip.c"
)

# Zstd library, can be unbundled in theory
# though we currently use some private symbols
# https://github.com/godotengine/godot/issues/17374
if (godot_builtin_zstd)
	set(__THIRDPARTY_ZSTD_DIR "${ENGINE_SOURCE_DIR}/thirdparty/zstd")
	target_sources_from_path(thirdparty-core-lib PRIVATE "${__THIRDPARTY_ZSTD_DIR}"
		"common/debug.c"
		"common/entropy_common.c"
		"common/error_private.c"
		"common/fse_decompress.c"
		"common/pool.c"
		"common/threading.c"
		"common/xxhash.c"
		"common/zstd_common.c"
		"compress/fse_compress.c"
		"compress/hist.c"
		"compress/huf_compress.c"
		"compress/zstd_compress.c"
		"compress/zstd_double_fast.c"
		"compress/zstd_fast.c"
		"compress/zstd_lazy.c"
		"compress/zstd_ldm.c"
		"compress/zstd_opt.c"
		"compress/zstdmt_compress.c"
		"compress/zstd_compress_literals.c"
		"compress/zstd_compress_sequences.c"
		"compress/zstd_compress_superblock.c"
		"decompress/huf_decompress.c"
		"decompress/zstd_ddict.c"
		"decompress/zstd_decompress_block.c"
		"decompress/zstd_decompress.c"
	)

	if (godot_platform MATCHES "(android|ios|linuxbsd|macos)")
		set(__DECOMPRESS_SOURCE "${__THIRDPARTY_ZSTD_DIR}/decompress/huf_decompress_amd64.S")	
		set_property(SOURCE "${__DECOMPRESS_SOURCE}" PROPERTY LANGUAGE C)
		target_sources(thirdparty-core-lib PRIVATE "${__DECOMPRESS_SOURCE}")
	endif()

	target_include_directories(thirdparty-core-lib PRIVATE "${__THIRDPARTY_ZSTD_DIR}/common")
	
	# Needs to be available in main env too
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_ZSTD_DIR}")
	# Also needed in main env includes will trigger warnings
	target_compile_definitions(global-env INTERFACE "ZSTD_STATIC_LINKING_ONLY")	
endif()

target_glob_sources(core-lib PRIVATE "*.cpp")

# Certificates
set(__CERTIFICATES_FILE_HEADER "${ENGINE_SOURCE_DIR}/core/io/certs_compressed.gen.h")
add_python_generator_command(core_builders cmake_make_certs_header
	TARGET_FILES "${__CERTIFICATES_FILE_HEADER}"
	SOURCE_FILES "${ENGINE_SOURCE_DIR}/thirdparty/certs/ca-certificates.crt"
	PYTHON_ARGS
		STR_VAR "system_certs_path=godot_system_certs_path"
		BOOL_VAR "is_builtin_certs=godot_builtin_certs"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Building ca-certificates header."
)

# Authors
set(__AUTHORS_FILE_HEADER "${ENGINE_SOURCE_DIR}/core/authors.gen.h")
add_python_generator_command(core_builders cmake_make_authors_header
	TARGET_FILES "${__AUTHORS_FILE_HEADER}"
	SOURCE_FILES "${ENGINE_SOURCE_DIR}/AUTHORS.md"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating authors header."
)

# Donors
set(__DONORS_FILE_HEADER "${ENGINE_SOURCE_DIR}/core/donors.gen.h")
add_python_generator_command(core_builders cmake_make_donors_header
	TARGET_FILES "${__DONORS_FILE_HEADER}"
	SOURCE_FILES "${ENGINE_SOURCE_DIR}/DONORS.md"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating donors header."
)

# License
set(__LICENSE_FILE_HEADER "${ENGINE_SOURCE_DIR}/core/license.gen.h")
add_python_generator_command(core_builders cmake_make_license_header
	TARGET_FILES "${__LICENSE_FILE_HEADER}"
	SOURCE_FILES 
		"${ENGINE_SOURCE_DIR}/COPYRIGHT.txt"
		"${ENGINE_SOURCE_DIR}/LICENSE.txt"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${ENGINE_SOURCE_DIR}"
	COMMENT "Generating license header."
)

add_custom_target(core-gen 
	DEPENDS
		${__CERTIFICATES_FILE_HEADER}
		${__AUTHORS_FILE_HEADER}
		${__DONORS_FILE_HEADER}
		${__LICENSE_FILE_HEADER}
)
add_dependencies(core-env core-gen)
add_dependencies(core-env modules-enabled-header-gen)

add_subdirectory("os")
add_subdirectory("math")
add_subdirectory("crypto")
add_subdirectory("io")
add_subdirectory("debugger")
add_subdirectory("input")
add_subdirectory("variant")
add_subdirectory("extension")
add_subdirectory("object")
add_subdirectory("templates")
add_subdirectory("string")
add_subdirectory("config")
add_subdirectory("error")