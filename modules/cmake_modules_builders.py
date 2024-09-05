
import os
import methods

# Header with MODULE_*_ENABLED defines.
def modules_enabled_builder(target, source):
    with methods.generated_wrapper(target) as file:
        for module in source:
            file.write(f"#define MODULE_{module.upper()}_ENABLED\n")

def register_module_types_builder(target, source):
    modules = source
    mod_inc = "\n".join([f'#include "{p}/register_types.h"' for p in modules.values()])
    mod_init = "\n".join(
        [f"#ifdef MODULE_{n.upper()}_ENABLED\n\tinitialize_{n}_module(p_level);\n#endif" for n in modules.keys()]
    )
    mod_uninit = "\n".join(
        [f"#ifdef MODULE_{n.upper()}_ENABLED\n\tuninitialize_{n}_module(p_level);\n#endif" for n in modules.keys()]
    )
    with methods.generated_wrapper(target) as file:
        file.write(
            f"""\
#include "register_module_types.h"

#include "modules/modules_enabled.gen.h"

{mod_inc}

void initialize_modules(ModuleInitializationLevel p_level) {{
{mod_init}
}}

void uninitialize_modules(ModuleInitializationLevel p_level) {{
{mod_uninit}
}}
"""
        )


def modules_tests_builder(target, source):
    with methods.generated_wrapper(target) as file:
        for header in source:
            file.write('#include "{}"\n'.format(os.path.normpath(header.path).replace("\\", "/")))