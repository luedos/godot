
add_env(core-crypto-env
	COMPONENTS
		global-env
)

add_lib(core-crypto-lib
	OBJECT
	PARENT_LIB
		core-lib
	COMPONENTS
		core-crypto-env
		warnings-env
)

if (GODOT_BUILTIN_MBEDTLS OR NOT mbedtls_IS_MODULE_ENABLED)
	# Use our headers for builtin or if the module is not going to be compiled.
	# We decided not to depend on system mbedtls just for these few files that can
	# be easily extracted.
	target_include_directories(core-crypto-env INTERFACE
		"${GODOT_SOURCE_DIR}/thirdparty/mbedtls/include"
	)
endif()

# MbedTLS core functions (for CryptoCore).
# If the mbedtls module is compiled we don't need to add the .c files with our
# custom config since they will be built by the module itself.
# Only if the module is not enabled, we must compile here the required sources
# to make a "light" build with only the necessary mbedtls files.
if(NOT mbedtls_IS_MODULE_ENABLED)

	add_lib(thirdparty-core-crypto-lib
		OBJECT
		PARENT_LIB
			core-lib
		COMPONENTS
			core-crypto-env
	)

	target_compile_definitions(thirdparty-core-crypto-lib PRIVATE 
		MBEDTLS_CONFIG_FILE="thirdparty/mbedtls/include/godot_core_mbedtls_config.h"
	)
	set(__THIRDPARTY_MBEDTLS_DIR "${GODOT_SOURCE_DIR}/thirdparty/mbedtls/library")
	target_sources_from_path(thirdparty-core-crypto-lib PRIVATE "${__THIRDPARTY_MBEDTLS_DIR}"
		"aes.c"
		"base64.c"
		"md5.c"
		"sha1.c"
		"sha256.c"
		"godot_core_mbedtls_platform.c"
	)
else()
	# If MbedTLS is actually enabled, we are defining dependency on it,
	# or on modules-lib (in case if GODOT_SPLIT_LIBMODULES=FALSE 
	# MbedTLS's sources will be part of it) 
	if (GODOT_SPLIT_LIBMODULES)
		define_lib_dependencies(core-lib mbed-lib)
	else()
		define_lib_dependencies(core-lib modules-lib)
	endif()
endif()

target_glob_sources(core-crypto-lib PRIVATE "*.cpp")