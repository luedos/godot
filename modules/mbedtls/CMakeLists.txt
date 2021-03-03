
add_env(mbed-env
	COMPONENTS
		modules-env
)


add_module_lib(mbed-lib
	COMPONENTS
		mbed-env
		warnings-env
)

target_glob_sources(mbed-lib PRIVATE "*.cpp")

if(GODOT_BUILTIN_MBEDTLS)

	set(__THIRDPARTY_MBED_PATH "${GODOT_SOURCE_DIR}/thirdparty/mbedtls")
	target_include_directories(mbed-env INTERFACE "${__THIRDPARTY_MBED_PATH}/include")

	add_lib(thirdparty-mbed-lib 
		OBJECT
		PARENT_LIB
			mbed-lib
		COMPONENTS
			mbed-env
		SOURCES
			"${__THIRDPARTY_MBED_PATH}/library/aes.c"
			"${__THIRDPARTY_MBED_PATH}/library/aesni.c"
			"${__THIRDPARTY_MBED_PATH}/library/arc4.c"
			"${__THIRDPARTY_MBED_PATH}/library/aria.c"
			"${__THIRDPARTY_MBED_PATH}/library/asn1parse.c"
			"${__THIRDPARTY_MBED_PATH}/library/asn1write.c"
			"${__THIRDPARTY_MBED_PATH}/library/base64.c"
			"${__THIRDPARTY_MBED_PATH}/library/bignum.c"
			"${__THIRDPARTY_MBED_PATH}/library/blowfish.c"
			"${__THIRDPARTY_MBED_PATH}/library/camellia.c"
			"${__THIRDPARTY_MBED_PATH}/library/ccm.c"
			"${__THIRDPARTY_MBED_PATH}/library/certs.c"
			"${__THIRDPARTY_MBED_PATH}/library/chacha20.c"
			"${__THIRDPARTY_MBED_PATH}/library/chachapoly.c"
			"${__THIRDPARTY_MBED_PATH}/library/cipher.c"
			"${__THIRDPARTY_MBED_PATH}/library/cipher_wrap.c"
			"${__THIRDPARTY_MBED_PATH}/library/cmac.c"
			"${__THIRDPARTY_MBED_PATH}/library/ctr_drbg.c"
			"${__THIRDPARTY_MBED_PATH}/library/debug.c"
			"${__THIRDPARTY_MBED_PATH}/library/des.c"
			"${__THIRDPARTY_MBED_PATH}/library/dhm.c"
			"${__THIRDPARTY_MBED_PATH}/library/ecdh.c"
			"${__THIRDPARTY_MBED_PATH}/library/ecdsa.c"
			"${__THIRDPARTY_MBED_PATH}/library/ecjpake.c"
			"${__THIRDPARTY_MBED_PATH}/library/ecp.c"
			"${__THIRDPARTY_MBED_PATH}/library/ecp_curves.c"
			"${__THIRDPARTY_MBED_PATH}/library/entropy.c"
			"${__THIRDPARTY_MBED_PATH}/library/entropy_poll.c"
			"${__THIRDPARTY_MBED_PATH}/library/error.c"
			"${__THIRDPARTY_MBED_PATH}/library/gcm.c"
			"${__THIRDPARTY_MBED_PATH}/library/havege.c"
			"${__THIRDPARTY_MBED_PATH}/library/hkdf.c"
			"${__THIRDPARTY_MBED_PATH}/library/hmac_drbg.c"
			"${__THIRDPARTY_MBED_PATH}/library/md2.c"
			"${__THIRDPARTY_MBED_PATH}/library/md4.c"
			"${__THIRDPARTY_MBED_PATH}/library/md5.c"
			"${__THIRDPARTY_MBED_PATH}/library/md.c"
			"${__THIRDPARTY_MBED_PATH}/library/md_wrap.c"
			"${__THIRDPARTY_MBED_PATH}/library/memory_buffer_alloc.c"
			"${__THIRDPARTY_MBED_PATH}/library/net_sockets.c"
			"${__THIRDPARTY_MBED_PATH}/library/nist_kw.c"
			"${__THIRDPARTY_MBED_PATH}/library/oid.c"
			"${__THIRDPARTY_MBED_PATH}/library/padlock.c"
			"${__THIRDPARTY_MBED_PATH}/library/pem.c"
			"${__THIRDPARTY_MBED_PATH}/library/pk.c"
			"${__THIRDPARTY_MBED_PATH}/library/pkcs11.c"
			"${__THIRDPARTY_MBED_PATH}/library/pkcs12.c"
			"${__THIRDPARTY_MBED_PATH}/library/pkcs5.c"
			"${__THIRDPARTY_MBED_PATH}/library/pkparse.c"
			"${__THIRDPARTY_MBED_PATH}/library/pk_wrap.c"
			"${__THIRDPARTY_MBED_PATH}/library/pkwrite.c"
			"${__THIRDPARTY_MBED_PATH}/library/platform.c"
			"${__THIRDPARTY_MBED_PATH}/library/platform_util.c"
			"${__THIRDPARTY_MBED_PATH}/library/poly1305.c"
			"${__THIRDPARTY_MBED_PATH}/library/ripemd160.c"
			"${__THIRDPARTY_MBED_PATH}/library/rsa.c"
			"${__THIRDPARTY_MBED_PATH}/library/rsa_internal.c"
			"${__THIRDPARTY_MBED_PATH}/library/sha1.c"
			"${__THIRDPARTY_MBED_PATH}/library/sha256.c"
			"${__THIRDPARTY_MBED_PATH}/library/sha512.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_cache.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_ciphersuites.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_cli.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_cookie.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_srv.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_ticket.c"
			"${__THIRDPARTY_MBED_PATH}/library/ssl_tls.c"
			"${__THIRDPARTY_MBED_PATH}/library/threading.c"
			"${__THIRDPARTY_MBED_PATH}/library/timing.c"
			"${__THIRDPARTY_MBED_PATH}/library/version.c"
			"${__THIRDPARTY_MBED_PATH}/library/version_features.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509_create.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509_crl.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509_crt.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509_csr.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509write_crt.c"
			"${__THIRDPARTY_MBED_PATH}/library/x509write_csr.c"
			"${__THIRDPARTY_MBED_PATH}/library/xtea.c"
	)

endif()
