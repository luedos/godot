# This is simple clone of scons methods.py.
# Because methods.py imports some unnecessary for cmake scons modules, and we can't really change scons functions, 
# we can't just use methods.py directly, and so need to create this code duplicate of some functions,
# which we will invoke from cmake.

import os
from collections import OrderedDict

# composes OrderedDict from modules_ids and modules_paths arrays and calls write_modules
def cmake_write_modules(modules_ids, modules_paths):
    from collections import OrderedDict
    length = min(len(modules_ids), len(modules_paths))
    modules_list = OrderedDict()
    for i in range(length):
        name = modules_ids[i]
        path = modules_paths[i]
        modules_list[name] = path

    write_modules(modules_list)

def write_modules(modules):
    includes_cpp = ""
    initialize_cpp = ""
    uninitialize_cpp = ""

    for name, path in modules.items():
        try:
            with open(os.path.join(path, "register_types.h")):
                includes_cpp += '#include "' + path + '/register_types.h"\n'
                initialize_cpp += "#ifdef MODULE_" + name.upper() + "_ENABLED\n"
                initialize_cpp += "\tinitialize_" + name + "_module(p_level);\n"
                initialize_cpp += "#endif\n"
                uninitialize_cpp += "#ifdef MODULE_" + name.upper() + "_ENABLED\n"
                uninitialize_cpp += "\tuninitialize_" + name + "_module(p_level);\n"
                uninitialize_cpp += "#endif\n"
        except OSError:
            pass

    modules_cpp = """// register_module_types.gen.cpp
/* THIS FILE IS GENERATED DO NOT EDIT */
#include "register_module_types.h"

#include "modules/modules_enabled.gen.h"

%s

void initialize_modules(ModuleInitializationLevel p_level) {
%s
}

void uninitialize_modules(ModuleInitializationLevel p_level) {
%s
}
""" % (
        includes_cpp,
        initialize_cpp,
        uninitialize_cpp,
    )

    # NOTE: It is safe to generate this file here, since this is still executed serially
    with open("modules/register_module_types.gen.cpp", "w") as f:
        f.write(modules_cpp)

def write_disabled_classes(class_list):
    f = open("core/disabled_classes.gen.h", "w")
    f.write("/* THIS FILE IS GENERATED DO NOT EDIT */\n")
    f.write("#ifndef DISABLED_CLASSES_GEN_H\n")
    f.write("#define DISABLED_CLASSES_GEN_H\n\n")
    for c in class_list:
        cs = c.strip()
        if cs != "":
            f.write("#define ClassDB_Disable_" + cs + " 1\n")
    f.write("\n#endif\n")


def sort_module_list(module_list, module_dependencies):
    out = OrderedDict()
    deps = {k: v[0] + list(filter(lambda x: x in module_list, v[1])) for k, v in module_dependencies.items()}

    frontier = list(module_list)
    explored = []
    while len(frontier):
        cur = frontier.pop()
        deps_list = deps[cur] if cur in deps else []
        if len(deps_list) and any([d not in explored for d in deps_list]):
            # Will explore later, after its dependencies
            frontier.insert(0, cur)
            continue
        explored.append(cur)

    first = True
    for k in explored:
        if first:
            first = False
        else:
            print(";", end='')

        print(str(k), end='')

def get_version_info(module_version_string="", silent=False):
    build_name = "custom_build"
    if os.getenv("BUILD_NAME") != None:
        build_name = str(os.getenv("BUILD_NAME"))
        if not silent:
            print(f"Using custom build name: '{build_name}'.")

    import version

    version_info = {
        "short_name": str(version.short_name),
        "name": str(version.name),
        "major": int(version.major),
        "minor": int(version.minor),
        "patch": int(version.patch),
        "status": str(version.status),
        "build": str(build_name),
        "module_config": str(version.module_config) + module_version_string,
        "year": int(version.year),
        "website": str(version.website),
        "docs_branch": str(version.docs),
    }

    # For dev snapshots (alpha, beta, RC, etc.) we do not commit status change to Git,
    # so this define provides a way to override it without having to modify the source.
    if os.getenv("GODOT_VERSION_STATUS") != None:
        version_info["status"] = str(os.getenv("GODOT_VERSION_STATUS"))
        if not silent:
            print(f"Using version status '{version_info['status']}', overriding the original '{version.status}'.")

    # Parse Git hash if we're in a Git repo.
    githash = ""
    gitfolder = ".git"

    if os.path.isfile(".git"):
        module_folder = open(".git", "r").readline().strip()
        if module_folder.startswith("gitdir: "):
            gitfolder = module_folder[8:]

    if os.path.isfile(os.path.join(gitfolder, "HEAD")):
        head = open(os.path.join(gitfolder, "HEAD"), "r", encoding="utf8").readline().strip()
        if head.startswith("ref: "):
            ref = head[5:]
            # If this directory is a Git worktree instead of a root clone.
            parts = gitfolder.split("/")
            if len(parts) > 2 and parts[-2] == "worktrees":
                gitfolder = "/".join(parts[0:-2])
            head = os.path.join(gitfolder, ref)
            packedrefs = os.path.join(gitfolder, "packed-refs")
            if os.path.isfile(head):
                githash = open(head, "r").readline().strip()
            elif os.path.isfile(packedrefs):
                # Git may pack refs into a single file. This code searches .git/packed-refs file for the current ref's hash.
                # https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-pack-refs.html
                for line in open(packedrefs, "r").read().splitlines():
                    if line.startswith("#"):
                        continue
                    (line_hash, line_ref) = line.split(" ")
                    if ref == line_ref:
                        githash = line_hash
                        break
        else:
            githash = head

    version_info["git_hash"] = githash

    return version_info

def generate_version_header(module_version_string=""):
    version_info = get_version_info(module_version_string)

    # NOTE: It is safe to generate these files here, since this is still executed serially.

    f = open("core/version_generated.gen.h", "w")
    f.write(
        """/* THIS FILE IS GENERATED DO NOT EDIT */
#ifndef VERSION_GENERATED_GEN_H
#define VERSION_GENERATED_GEN_H
#define VERSION_SHORT_NAME "{short_name}"
#define VERSION_NAME "{name}"
#define VERSION_MAJOR {major}
#define VERSION_MINOR {minor}
#define VERSION_PATCH {patch}
#define VERSION_STATUS "{status}"
#define VERSION_BUILD "{build}"
#define VERSION_MODULE_CONFIG "{module_config}"
#define VERSION_YEAR {year}
#define VERSION_WEBSITE "{website}"
#define VERSION_DOCS_BRANCH "{docs_branch}"
#define VERSION_DOCS_URL "https://docs.godotengine.org/en/" VERSION_DOCS_BRANCH
#endif // VERSION_GENERATED_GEN_H
""".format(
            **version_info
        )
    )
    f.close()

    fhash = open("core/version_hash.gen.cpp", "w")
    fhash.write(
        """/* THIS FILE IS GENERATED DO NOT EDIT */
#include "core/version.h"
const char *const VERSION_HASH = "{git_hash}";
""".format(
            **version_info
        )
    )
    fhash.close()

def generate_export_icons(platform_path, platform_name):
    """
    Generate headers for logo and run icon for the export plugin.
    """
    export_path = platform_path + "/export"
    svg_names = []
    if os.path.isfile(export_path + "/logo.svg"):
        svg_names.append("logo")
    if os.path.isfile(export_path + "/run_icon.svg"):
        svg_names.append("run_icon")

    for name in svg_names:
        svgf = open(export_path + "/" + name + ".svg", "rb")
        b = svgf.read(1)
        svg_str = " /* AUTOGENERATED FILE, DO NOT EDIT */ \n"
        svg_str += " static const char *_" + platform_name + "_" + name + '_svg = "'
        while len(b) == 1:
            svg_str += "\\" + hex(ord(b))[1:]
            b = svgf.read(1)

        svg_str += '";\n'

        svgf.close()

        # NOTE: It is safe to generate this file here, since this is still executed serially.
        wf = export_path + "/" + name + "_svg.gen.h"
        with open(wf, "w") as svgw:
            svgw.write(svg_str)