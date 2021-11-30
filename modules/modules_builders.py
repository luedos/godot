"""Functions used to generate source files during build time

All such functions are invoked in a subprocess on Windows to prevent build flakiness.
"""

from platform_methods import subprocess_main

class CMakeEnv:
    pass

def cmake_generate_modules_enabled(target, module_list):
    env = CMakeEnv()
    env.module_list = module_list
    generate_modules_enabled(target, None, env)

def generate_modules_enabled(target, source, env):
    with open(target[0].path, "w") as f:
        for module in env.module_list:
            f.write("#define %s\n" % ("MODULE_" + module.upper() + "_ENABLED"))


if __name__ == "__main__":
    subprocess_main(globals())
