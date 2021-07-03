
add_lib(core-crypto-lib
	OBJECT
	PARENT_LIB
		core-lib
	COMPONENTS
		global-env
		warnings-env
)

if (GODOT_BUILTIN_MBEDTLS OR NOT mbedtls_IS_MODULE_ENABLED)
	# Use our headers for builtin or if the module is not going to be compiled.
	# We decided not to depend on system mbedtls just for these few files that can
	# be easily extracted.
	target_include_directories(core-crypto-lib PRIVATE
		"${GODOT_SOURCE_DIR}/thirdparty/mbedtls/include"
	)
endif()

if(NOT mbedtls_IS_MODULE_ENABLED)

	add_lib(thirdparty-core-crypto-lib
		OBJECT
		PARENT_LIB
			core-lib
		COMPONENTS
			global-env
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
	if (GODOT_SPLIT_LIBMODULES)
		define_lib_dependencies(core-lib mbed-lib)
	else()
		define_lib_dependencies(core-lib modules-lib)
	endif()
endif()

target_glob_sources(core-crypto-lib PRIVATE "*.cpp")