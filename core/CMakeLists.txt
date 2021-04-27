
execute_python_method(gen_methods generate_encryption_key_header
	PYTHON_ARGS 
		STR_ENV_VAR "SCRIPT_AES256_ENCRYPTION_KEY"
)

add_lib(core-lib
	COMPONENTS
		global-env
		warnings-env
)
register_global_lib(core-lib)
add_lib(thirdparty-core-lib 
	OBJECT
	PARENT_LIB 
		core-lib
	COMPONENTS
		global-env	
)

# Misc thirdparty code: header paths are hardcoded, we don't need to append
# to the include path (saves a few chars on the compiler invocation for touchy MSVC...)

# Here we assume, that godot project will be build as standalone, so thirdparty folder will be in the source directory. 
# Usually this is true, but if another is the case, this will lead to some problems.
#TODO: Think of the solution for this.  
target_sources_from_path(thirdparty-core-lib PRIVATE "${GODOT_SOURCE_DIR}/thirdparty/misc"
	# C sources
	"fastlz.c"
	"smaz.c"
	# C++ sources
	"hq2x.cpp"
	"pcg.cpp"
	"triangulator.cpp"
	"clipper.cpp"
)

if(GODOT_BUILTIN_ZLIB)
	set(__THIRDPARTY_ZLIB_DIR "${GODOT_SOURCE_DIR}/thirdparty/zlib")

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

	target_compile_definitions(thirdparty-core-lib PRIVATE $<${IS_DEBUG_GEN_EXPR}:ZLIB_DEBUG>)	
endif()

# Minizip library, could be unbundled in theory
# However, our version has some custom modifications, so it won't compile with the system one
target_sources_from_path(thirdparty-core-lib PRIVATE "${GODOT_SOURCE_DIR}/thirdparty/minizip"
	"ioapi.c"
	"unzip.c"
	"zip.c"
)

# Zstd library, can be unbundled in theory
# though we currently use some private symbols
# https://github.com/godotengine/godot/issues/17374
if(GODOT_BUILTIN_ZSTD)
	set(__THIRDPARTY_ZSTD_DIR "${GODOT_SOURCE_DIR}/thirdparty/zstd")

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
		"decompress/huf_decompress.c"
		"decompress/zstd_ddict.c"
		"decompress/zstd_decompress_block.c"
		"decompress/zstd_decompress.c"
	)

	# Needs to be available in main env too
	target_include_directories(global-env INTERFACE "${__THIRDPARTY_ZSTD_DIR}")
	# Also needed in main env includes will trigger warnings
	target_compile_definitions(global-env INTERFACE "ZSTD_STATIC_LINKING_ONLY")		

	# only needed in the thirdparty
	target_include_directories(thirdparty-core-lib PRIVATE 
		"${__THIRDPARTY_ZSTD_DIR}/common"
	)
endif()

target_glob_sources(core-lib PRIVATE "*.cpp")

# Certificates
set(__CERTIFICATES_FILE_HEADER "${GODOT_SOURCE_DIR}/core/io/certs_compressed.gen.h")

add_python_generator_command(core_builders cmake_make_certs_header
	TARGET_FILES "${__CERTIFICATES_FILE_HEADER}"
	SOURCE_FILES "${GODOT_SOURCE_DIR}/thirdparty/certs/ca-certificates.crt"
	PYTHON_ARGS
		STR_VAR "system_certs_path=GODOT_SYSTEM_CERTS_PATH"
		BOOL_VAR "is_builtin_certs=GODOT_BUILTIN_CERTS"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)

# Make binders
set(__MAKE_BINDERS_FILES 
	"${CMAKE_CURRENT_SOURCE_DIR}/method_bind.gen.inc" 
	"${CMAKE_CURRENT_SOURCE_DIR}/method_bind_ext.gen.inc" 
	"${CMAKE_CURRENT_SOURCE_DIR}/method_bind_free_func.gen.inc"
)

add_python_generator_command(make_binders cmake_run
	TARGET_FILES ${__MAKE_BINDERS_FILES}
	SOURCES_DEPENDENT_TARGET core-lib 
)

# Authors
set(__AUTHORS_FILE_HEADER "${GODOT_SOURCE_DIR}/core/authors.gen.h")

add_python_generator_command(core_builders cmake_make_authors_header
	TARGET_FILES "${__AUTHORS_FILE_HEADER}"
	SOURCE_FILES "${GODOT_SOURCE_DIR}/AUTHORS.md"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)

# Donors
set(__DONORS_FILE_HEADER "${GODOT_SOURCE_DIR}/core/donors.gen.h")

add_python_generator_command(core_builders cmake_make_donors_header
	TARGET_FILES "${__DONORS_FILE_HEADER}"
	SOURCE_FILES "${GODOT_SOURCE_DIR}/DONORS.md"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)

# License
set(__LICENSE_FILE_HEADER "${GODOT_SOURCE_DIR}/core/license.gen.h")

add_python_generator_command(core_builders cmake_make_license_header
	TARGET_FILES "${__LICENSE_FILE_HEADER}"
	SOURCE_FILES 
		"${GODOT_SOURCE_DIR}/COPYRIGHT.txt"
		"${GODOT_SOURCE_DIR}/LICENSE.txt"
	SOURCES_DEPENDENT_TARGET core-lib 
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)

add_custom_target(core-gen 
	DEPENDS
		${__CERTIFICATES_FILE_HEADER}
		${__MAKE_BINDERS_FILES}
		${__AUTHORS_FILE_HEADER}
		${__DONORS_FILE_HEADER}
		${__LICENSE_FILE_HEADER}
)
add_dependencies(core-lib core-gen)

add_subdirectory(os)
add_subdirectory(math)
add_subdirectory(crypto)
add_subdirectory(io)
add_subdirectory(bind)
