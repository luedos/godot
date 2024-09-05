
import cmake_methods as methods

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
        f.write('#include "core/config/project_settings.h"\nuint8_t script_encryption_key[32]={' + txt + "};\n")

# Generate disabled classes
def disabled_class_builder(target, source):
    with methods.generated_wrapper(target[0]) as file:
        for c in source:
            cs = c.strip()
            if cs != "":
                file.write(f"#define ClassDB_Disable_{cs} 1\n")

# Generate version info
def version_info_builder(target, source, version_info):
    with methods.generated_wrapper(target[0]) as file:
        file.write(
            """\
#define VERSION_SHORT_NAME "{short_name}"
#define VERSION_NAME "{name}"
#define VERSION_MAJOR {major}
#define VERSION_MINOR {minor}
#define VERSION_PATCH {patch}
#define VERSION_STATUS "{status}"
#define VERSION_BUILD "{build}"
#define VERSION_MODULE_CONFIG "{module_config}"
#define VERSION_WEBSITE "{website}"
#define VERSION_DOCS_BRANCH "{docs_branch}"
#define VERSION_DOCS_URL "https://docs.godotengine.org/en/" VERSION_DOCS_BRANCH
""".format(**version_info)
        )

# Generate version hash
def version_hash_builder(target, source, version_info):
    with methods.generated_wrapper(target[0]) as file:
        file.write(
            """\
#include "core/version.h"

const char *const VERSION_HASH = "{git_hash}";
const uint64_t VERSION_TIMESTAMP = {git_timestamp};
""".format(**version_info)
        )

# Generate AES256 script encryption key
def encryption_key_builder(target, source):
    gdkey = source[0]
    try:
        gdkey = ", ".join([str(int(f"{a}{b}", 16)) for a, b in zip(gdkey[0::2], gdkey[1::2])])
    except Exception:
        methods.print_error(
            f'Invalid AES256 encryption key, not 64 hexadecimal characters: "{gdkey}".\n'
            "Unset `SCRIPT_AES256_ENCRYPTION_KEY` in your environment "
            "or make sure that it contains exactly 64 hexadecimal characters."
        )
        Exit(255)

    with methods.generated_wrapper(target[0]) as file:
        file.write(
            f"""\
#include "core/config/project_settings.h"

uint8_t script_encryption_key[32] = {{
    {gdkey}
}};"""
        )