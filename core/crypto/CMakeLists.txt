
add_env(core-crypto-env
	COMPONENTS
		core-env
)

add_lib(core-crypto-lib
	OBJECT
	PARENT_LIB
		core-lib
	COMPONENTS
		core-crypto-env
		global-warnings-env
)

if (godot_builtin_mbedtls OR NOT godot_module_mbedtls_enabled)
	# Use our headers for builtin or if the module is not going to be compiled.
	# We decided not to depend on system mbedtls just for these few files that can
	# be easily extracted.
	target_include_directories(core-crypto-env INTERFACE
		"${ENGINE_SOURCE_DIR}/thirdparty/mbedtls/include"
	)
endif()

# MbedTLS core functions (for CryptoCore).
# If the mbedtls module is compiled we don't need to add the .c files with our
# custom config since they will be built by the module itself.
# Only if the module is not enabled, we must compile here the required sources
# to make a "light" build with only the necessary mbedtls files.
if(NOT godot_module_mbedtls_enabled)

	add_lib(thirdparty-core-crypto-lib
		OBJECT
		PARENT_LIB
			core-lib
		COMPONENTS
			core-crypto-env
			thirdparty-warnings-env
	)

	target_compile_definitions(core-crypto-env PRIVATE 
		MBEDTLS_CONFIG_FILE="thirdparty/mbedtls/include/godot_core_mbedtls_config.h"
	)
	target_sources_from_path(thirdparty-core-crypto-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/mbedtls/library"
		"aes.c"
		"base64.c"
		"constant_time.c"
		"ctr_drbg.c"
		"entropy.c"
		"md5.c"
		"sha1.c"
		"sha256.c"
		"godot_core_mbedtls_platform.c"
	)
elseif(godot_builtin_mbedtls)
	target_compile_definitions(core-crypto-env INTERFACE 
		MBEDTLS_CONFIG_FILE="thirdparty/mbedtls/include/godot_module_mbedtls_config.h"
	)
endif()

if (godot_module_mbedtls_enabled)
	# If MbedTLS is actually enabled, we are defining dependency on it, 
	# MbedTLS's sources will be part of it)
	add_link_dependencies(core-lib mbedtls-lib)
endif()

target_glob_sources(core-crypto-lib PRIVATE "*.cpp")