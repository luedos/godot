"""Functions used to generate source files during build time

All such functions are invoked in a subprocess on Windows to prevent build flakiness.
"""

from platform_methods import subprocess_main

class CMakeEnv:
    pass

def cmake_generate_modules_enabled(target, module_list):
    # This is copy of generate_modules_enabled, with main difference that module_list is not provided from environment
    # and that target are not an array of scons objects, and instead simple string path
    with open(target, "w") as f:
        for module in module_list:
            f.write("#define %s\n" % ("MODULE_" + module.upper() + "_ENABLED"))

def generate_modules_enabled(target, source, env):
    with open(target[0].path, "w") as f:
        for module in env.module_list:
            f.write("#define %s\n" % ("MODULE_" + module.upper() + "_ENABLED"))


if __name__ == "__main__":
    subprocess_main(globals())
