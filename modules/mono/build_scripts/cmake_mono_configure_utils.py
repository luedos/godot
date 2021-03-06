import os
import os.path
import sys
import subprocess

def find_file_in_dir(directory, names, prefixes=[""], extensions=[""]):
    for extension in extensions:
        if extension and not extension.startswith("."):
            extension = "." + extension
        for prefix in prefixes:
            for curname in names:
                filename = prefix + curname + extension
                if os.path.isfile(os.path.join(directory, filename)):
                    return filename
    return ""

def get_android_out_dir(env):
    return env["android_output_dir"] # will be defiend through cmake

def is_desktop(platform):
    return platform in ["windows", "osx", "x11", "server", "uwp", "haiku"]

def make_template_dir(env, mono_root, output_dir):
    from shutil import rmtree

    platform = env["platform"]
    target = env["target"]

    template_dir_name = ""

    assert is_desktop(platform)

    template_dir_name = "data.mono.%s.%s.%s" % (platform, env["bits"], target)

    template_dir = os.path.join(output_dir, template_dir_name)

    template_mono_root_dir = os.path.join(template_dir, "Mono")

    if os.path.isdir(template_mono_root_dir):
        rmtree(template_mono_root_dir)  # Clean first

    # Copy etc/mono/

    template_mono_config_dir = os.path.join(template_mono_root_dir, "etc", "mono")
    copy_mono_etc_dir(mono_root, template_mono_config_dir, platform)

    # Copy the required shared libraries

    copy_mono_shared_libs(env, mono_root, template_mono_root_dir)


def copy_mono_root_files(env, mono_root, output_dir):
    from glob import glob
    from shutil import copy
    from shutil import rmtree

    if not mono_root:
        raise RuntimeError("Mono installation directory not found")

    editor_mono_root_dir = os.path.join(output_dir, "GodotSharp", "Mono")

    if os.path.isdir(editor_mono_root_dir):
        rmtree(editor_mono_root_dir)  # Clean first

    # Copy etc/mono/

    editor_mono_config_dir = os.path.join(editor_mono_root_dir, "etc", "mono")
    copy_mono_etc_dir(mono_root, editor_mono_config_dir, env["platform"])

    # Copy the required shared libraries

    copy_mono_shared_libs(env, mono_root, editor_mono_root_dir)

    # Copy framework assemblies

    mono_framework_dir = os.path.join(mono_root, "lib", "mono", "4.5")
    mono_framework_facades_dir = os.path.join(mono_framework_dir, "Facades")

    editor_mono_framework_dir = os.path.join(editor_mono_root_dir, "lib", "mono", "4.5")
    editor_mono_framework_facades_dir = os.path.join(editor_mono_framework_dir, "Facades")

    if not os.path.isdir(editor_mono_framework_dir):
        os.makedirs(editor_mono_framework_dir)
    if not os.path.isdir(editor_mono_framework_facades_dir):
        os.makedirs(editor_mono_framework_facades_dir)

    for assembly in glob(os.path.join(mono_framework_dir, "*.dll")):
        copy(assembly, editor_mono_framework_dir)
    for assembly in glob(os.path.join(mono_framework_facades_dir, "*.dll")):
        copy(assembly, editor_mono_framework_facades_dir)


def copy_mono_etc_dir(mono_root, target_mono_config_dir, platform):
    from distutils.dir_util import copy_tree
    from glob import glob
    from shutil import copy

    if not os.path.isdir(target_mono_config_dir):
        os.makedirs(target_mono_config_dir)

    mono_etc_dir = os.path.join(mono_root, "etc", "mono")
    if not os.path.isdir(mono_etc_dir):
        mono_etc_dir = ""
        etc_hint_dirs = []
        if platform != "windows":
            etc_hint_dirs += ["/etc/mono", "/usr/local/etc/mono"]
        if "MONO_CFG_DIR" in os.environ:
            etc_hint_dirs += [os.path.join(os.environ["MONO_CFG_DIR"], "mono")]
        for etc_hint_dir in etc_hint_dirs:
            if os.path.isdir(etc_hint_dir):
                mono_etc_dir = etc_hint_dir
                break
        if not mono_etc_dir:
            raise RuntimeError("Mono installation etc directory not found")

    copy_tree(os.path.join(mono_etc_dir, "2.0"), os.path.join(target_mono_config_dir, "2.0"))
    copy_tree(os.path.join(mono_etc_dir, "4.0"), os.path.join(target_mono_config_dir, "4.0"))
    copy_tree(os.path.join(mono_etc_dir, "4.5"), os.path.join(target_mono_config_dir, "4.5"))
    if os.path.isdir(os.path.join(mono_etc_dir, "mconfig")):
        copy_tree(os.path.join(mono_etc_dir, "mconfig"), os.path.join(target_mono_config_dir, "mconfig"))

    for file in glob(os.path.join(mono_etc_dir, "*")):
        if os.path.isfile(file):
            copy(file, target_mono_config_dir)


def copy_mono_shared_libs(env, mono_root, target_mono_root_dir):
    from shutil import copy

    def copy_if_exists(src, dst):
        if os.path.isfile(src):
            copy(src, dst)

    platform = env["platform"]

    if platform == "windows":
        src_mono_bin_dir = os.path.join(mono_root, "bin")
        target_mono_bin_dir = os.path.join(target_mono_root_dir, "bin")

        if not os.path.isdir(target_mono_bin_dir):
            os.makedirs(target_mono_bin_dir)

        mono_posix_helper_file = find_file_in_dir(
            src_mono_bin_dir, ["MonoPosixHelper"], prefixes=["", "lib"], extensions=[".dll"]
        )
        copy(
            os.path.join(src_mono_bin_dir, mono_posix_helper_file),
            os.path.join(target_mono_bin_dir, "MonoPosixHelper.dll"),
        )

        # For newer versions
        btls_dll_path = os.path.join(src_mono_bin_dir, "libmono-btls-shared.dll")
        if os.path.isfile(btls_dll_path):
            copy(btls_dll_path, target_mono_bin_dir)
    else:
        target_mono_lib_dir = (
            get_android_out_dir(env) if platform == "android" else os.path.join(target_mono_root_dir, "lib")
        )

        if not os.path.isdir(target_mono_lib_dir):
            os.makedirs(target_mono_lib_dir)

        lib_file_names = []
        if platform == "osx":
            lib_file_names = [
                lib_name + ".dylib"
                for lib_name in ["libmono-btls-shared", "libmono-native-compat", "libMonoPosixHelper"]
            ]
        elif is_unix_like(platform):
            lib_file_names = [
                lib_name + ".so"
                for lib_name in [
                    "libmono-btls-shared",
                    "libmono-ee-interp",
                    "libmono-native",
                    "libMonoPosixHelper",
                    "libmono-profiler-aot",
                    "libmono-profiler-coverage",
                    "libmono-profiler-log",
                    "libMonoSupportW",
                ]
            ]

        for lib_file_name in lib_file_names:
            copy_if_exists(os.path.join(mono_root, "lib", lib_file_name), target_mono_lib_dir)