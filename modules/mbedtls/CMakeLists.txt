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
		"aesni.c"
		"arc4.c"
		"aria.c"
		"asn1parse.c"
		"asn1write.c"
		"base64.c"
		"bignum.c"
		"blowfish.c"
		"camellia.c"
		"ccm.c"
		"certs.c"
		"chacha20.c"
		"chachapoly.c"
		"cipher.c"
		"cipher_wrap.c"
		"cmac.c"
		"ctr_drbg.c"
		"constant_time.c"
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
		"havege.c"
		"hkdf.c"
		"hmac_drbg.c"
		"md2.c"
		"md4.c"
		"md5.c"
		"md.c"
		"memory_buffer_alloc.c"
		"mps_reader.c"
		"mps_trace.c"
		"net_sockets.c"
		"nist_kw.c"
		"oid.c"
		"padlock.c"
		"pem.c"
		"pk.c"
		"pkcs11.c"
		"pkcs12.c"
		"pkcs5.c"
		"pkparse.c"
		"pk_wrap.c"
		"pkwrite.c"
		"platform.c"
		"platform_util.c"
		"poly1305.c"
		"ripemd160.c"
		"rsa.c"
		"rsa_internal.c"
		"sha1.c"
		"sha256.c"
		"sha512.c"
		"ssl_cache.c"
		"ssl_ciphersuites.c"
		"ssl_cli.c"
		"ssl_cookie.c"
		"ssl_msg.c"
		"ssl_srv.c"
		"ssl_ticket.c"
		"ssl_tls.c"
		"ssl_tls13_keys.c"
		"threading.c"
		"timing.c"
		"version.c"
		"version_features.c"
		"x509.c"
		"x509_create.c"
		"x509_crl.c"
		"x509_crt.c"
		"x509_csr.c"
		"x509write_crt.c"
		"x509write_csr.c"
		"xtea.c"
	)

	target_include_directories(mbedtls-env INTERFACE "${__THIRDPARTY_MBEDTLS_PATH}/include")
	target_compile_definitions(mbedtls-env INTERFACE
		MBEDTLS_CONFIG_FILE="thirdparty/mbedtls/include/godot_module_mbedtls_config.h"
	)
endif()

if (godot_tests)
	target_compile_definitions(mbedtls-env INTERFACE "TESTS_ENABLED")
	target_glob_sources(mbedtls-lib PRIVATE "tests/*.cpp")
endif()