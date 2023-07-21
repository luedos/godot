
def cmake_create_reg_api_source(output_file, platform_apis_vector):
    # Register platform-exclusive APIs
    reg_apis_inc = '#include "register_platform_apis.h"\n'
    reg_apis = "void register_platform_apis() {\n"
    unreg_apis = "void unregister_platform_apis() {\n"
    for platform in platform_apis_vector:
        reg_apis += "\tregister_" + platform + "_api();\n"
        unreg_apis += "\tunregister_" + platform + "_api();\n"
        reg_apis_inc += '#include "' + platform + '/api/api.h"\n'
    reg_apis_inc += "\n"
    reg_apis += "}\n\n"
    unreg_apis += "}\n"

    # NOTE: It is safe to generate this file here, since this is still execute serially
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(reg_apis_inc)
        f.write(reg_apis)
        f.write(unreg_apis)