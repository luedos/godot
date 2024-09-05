
from pathlib import Path
import methods

def cmake_register_platform_apis_builder(target, source, platform_apis):
    platforms = platform_apis
    api_inc = "\n".join([f'#include "{p}/api/api.h"' for p in platforms])
    api_reg = "\n".join([f"\tregister_{p}_api();" for p in platforms])
    api_unreg = "\n".join([f"\tunregister_{p}_api();" for p in platforms])
    with methods.generated_wrapper(str(target[0])) as file:
        file.write(
            f"""\
#include "register_platform_apis.h"

{api_inc}

void register_platform_apis() {{
{api_reg}
}}

void unregister_platform_apis() {{
{api_unreg}
}}
"""
        )


def cmake_export_icon_builder(target, source):
    src_path = Path(str(source[0]))
    src_name = src_path.stem
    platform = src_path.parent.parent.stem
    with open(str(source[0]), "rb") as file:
        svg = "".join([f"\\{hex(x)[1:]}" for x in file.read()])
    with methods.generated_wrapper(str(target[0]), prefix=platform) as file:
        file.write(
            f"""\
static const char *_{platform}_{src_name}_svg = "{svg}";
"""
        )