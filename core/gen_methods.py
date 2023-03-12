def generate_encryption_key_header(env_key=""):
    txt = "0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0"
    if env_key != "":
        key = env_key
        ec_valid = True
        if len(key) != 64:
            ec_valid = False
        else:
            txt = ""
            for i in range(len(key) >> 1):
                if i > 0:
                    txt += ","
                txts = "0x" + key[i * 2 : i * 2 + 2]
                try:
                    int(txts, 16)
                except Exception:
                    ec_valid = False
                txt += txts
        if not ec_valid:
            print("Error: Invalid AES256 encryption key, not 64 hexadecimal characters: '" + key + "'.")
            print(
                "Unset 'SCRIPT_AES256_ENCRYPTION_KEY' in your environment "
                "or make sure that it contains exactly 64 hexadecimal characters."
            )
            Exit(255)

    # NOTE: It is safe to generate this file here, since this is still executed serially
    with open("script_encryption_key.gen.cpp", "w") as f:
        f.write('#include "core/project_settings.h"\nuint8_t script_encryption_key[32]={' + txt + "};\n")