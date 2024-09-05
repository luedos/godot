add_env(mbedtls-env
	COMPONENTS
		global-env
)

add_lib(mbedtls-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		mbedtls-env
		global-warnings-env
)

add_dependencies(mbedtls-lib core-crypto-lib)

target_glob_sources(mbedtls-lib PRIVATE "*.cpp")

if (godot_builtin_mbedtls)
	add_lib(thirdparty-mbedtls-lib
		OBJECT
		PARENT_LIB
			modules-lib
		COMPONENTS
			mbedtls-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_MBEDTLS_PATH "${ENGINE_SOURCE_DIR}/thirdparty/mbedtls")
	target_sources_from_path(thirdparty-mbedtls-lib PRIVATE "${__THIRDPARTY_MBEDTLS_PATH}/library"
		"aes.c"
		"aesce.c"
		"aesni.c"
		"aria.c"
		"asn1parse.c"
		"asn1write.c"
		"base64.c"
		"bignum.c"
		"bignum_core.c"
		"bignum_mod_raw.c"
		"camellia.c"
		"ccm.c"
		"chacha20.c"
		"chachapoly.c"
		"cipher.c"
		"cipher_wrap.c"
		"cmac.c"
		"constant_time.c"
		"ctr_drbg.c"
		"debug.c"
		"des.c"
		"dhm.c"
		"ecdh.c"
		"ecdsa.c"
		"ecjpake.c"
		"ecp.c"
		"ecp_curves.c"
		"entropy.c"
		"entropy_poll.c"
		"error.c"
		"gcm.c"
		"hkdf.c"
		"hmac_drbg.c"
		"md.c"
		"md5.c"
		"memory_buffer_alloc.c"
		"mps_reader.c"
		"mps_trace.c"
		"net_sockets.c"
		"nist_kw.c"
		"oid.c"
		"padlock.c"
		"pem.c"
		"pk.c"
		"pk_ecc.c"
		"pk_wrap.c"
		"pkcs12.c"
		"pkcs5.c"
		"pkcs7.c"
		"pkparse.c"
		"pkwrite.c"
		"platform.c"
		"platform_util.c"
		"poly1305.c"
		"ripemd160.c"
		"rsa.c"
		"rsa_alt_helpers.c"
		"sha1.c"
		"sha3.c"
		"sha256.c"
		"sha512.c"
		"ssl_cache.c"
		"ssl_ciphersuites.c"
		"ssl_client.c"
		"ssl_cookie.c"
		"ssl_debug_helpers_generated.c"
		"ssl_msg.c"
		"ssl_ticket.c"
		"ssl_tls.c"
		"ssl_tls12_client.c"
		"ssl_tls12_server.c"
		"ssl_tls13_client.c"
		"ssl_tls13_generic.c"
		"ssl_tls13_keys.c"
		"ssl_tls13_server.c"
		"threading.c"
		"timing.c"
		"version.c"
		"version_features.c"
		"x509.c"
		"x509_create.c"
		"x509_crl.c"
		"x509_crt.c"
		"x509_csr.c"
		"x509write.c"
		"x509write_crt.c"
		"x509write_csr.c"
	)

	target_include_directories(mbedtls-env INTERFACE "${__THIRDPARTY_MBEDTLS_PATH}/include")
	target_compile_definitions(mbedtls-env INTERFACE
		MBEDTLS_CONFIG_FILE="thirdparty/mbedtls/include/godot_module_mbedtls_config.h"
	)
endif()

if (godot_tests)
	target_compile_definitions(mbedtls-env INTERFACE "TESTS_ENABLED")
	target_glob_sources(mbedtls-lib PRIVATE "tests/*.cpp")

	if (godot_disable_exceptions)
		target_compile_definitions(mbedtls-env INTERFACE "DOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS")
	endif()
endif()