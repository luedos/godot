
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

	add_module_lib(thirdparty-mbed-lib 
		OBJECT
		PARENT_LIB
			mbed-lib
		COMPONENTS
			mbed-env
		SOURCES
	)
	target_sources_from_path(thirdparty-mbed-lib PRIVATE "${__THIRDPARTY_MBED_PATH}/library"
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
		"md_wrap.c"
		"memory_buffer_alloc.c"
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
		"ssl_srv.c"
		"ssl_ticket.c"
		"ssl_tls.c"
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

endif()
