# This is simple clone of scons methods.py.
# Because methods.py imports some unnecessary for cmake scons modules, and we can't really change scons functions, 
# we can't just use methods.py directly, and so need to create this code duplicate of some functions,
# which we will invoke from cmake.

import contextlib
import os
import subprocess
from collections import OrderedDict
from io import StringIO, TextIOWrapper
from pathlib import Path
from typing import Generator, Optional

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

def get_version_info(module_version_string=""):
    build_name = "custom_build"
    if os.getenv("BUILD_NAME") is not None:
        build_name = str(os.getenv("BUILD_NAME"))

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
        "website": str(version.website),
        "docs_branch": str(version.docs),
    }

    # For dev snapshots (alpha, beta, RC, etc.) we do not commit status change to Git,
    # so this define provides a way to override it without having to modify the source.
    if os.getenv("GODOT_VERSION_STATUS") is not None:
        version_info["status"] = str(os.getenv("GODOT_VERSION_STATUS"))

    # Parse Git hash if we're in a Git repo.
    githash = ""
    gitfolder = ".git"

    if os.path.isfile(".git"):
        with open(".git", "r", encoding="utf-8") as file:
            module_folder = file.readline().strip()
        if module_folder.startswith("gitdir: "):
            gitfolder = module_folder[8:]

    if os.path.isfile(os.path.join(gitfolder, "HEAD")):
        with open(os.path.join(gitfolder, "HEAD"), "r", encoding="utf8") as file:
            head = file.readline().strip()
        if head.startswith("ref: "):
            ref = head[5:]
            # If this directory is a Git worktree instead of a root clone.
            parts = gitfolder.split("/")
            if len(parts) > 2 and parts[-2] == "worktrees":
                gitfolder = "/".join(parts[0:-2])
            head = os.path.join(gitfolder, ref)
            packedrefs = os.path.join(gitfolder, "packed-refs")
            if os.path.isfile(head):
                with open(head, "r", encoding="utf-8") as file:
                    githash = file.readline().strip()
            elif os.path.isfile(packedrefs):
                # Git may pack refs into a single file. This code searches .git/packed-refs file for the current ref's hash.
                # https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-pack-refs.html
                for line in open(packedrefs, "r", encoding="utf-8").read().splitlines():
                    if line.startswith("#"):
                        continue
                    (line_hash, line_ref) = line.split(" ")
                    if ref == line_ref:
                        githash = line_hash
                        break
        else:
            githash = head

    version_info["git_hash"] = githash
    # Fallback to 0 as a timestamp (will be treated as "unknown" in the engine).
    version_info["git_timestamp"] = 0

    # Get the UNIX timestamp of the build commit.
    if os.path.exists(".git"):
        try:
            version_info["git_timestamp"] = subprocess.check_output(
                ["git", "log", "-1", "--pretty=format:%ct", "--no-show-signature", githash]
            ).decode("utf-8")
        except (subprocess.CalledProcessError, OSError):
            # `git` not found in PATH.
            pass

    print(version_info)

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

def generate_copyright_header(filename: str) -> str:
    MARGIN = 70
    TEMPLATE = """\
/**************************************************************************/
/*  %s*/
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/
"""
    filename = filename.split("/")[-1].ljust(MARGIN)
    if len(filename) > MARGIN:
        print(f'WARNING: Filename "{filename}" too large for copyright header.')
    return TEMPLATE % filename


@contextlib.contextmanager
def generated_wrapper(
    path,  # FIXME: type with `Union[str, Node, List[Node]]` when pytest conflicts are resolved
    guard: Optional[bool] = None,
    prefix: str = "",
    suffix: str = "",
) -> Generator[TextIOWrapper, None, None]:
    """
    Wrapper class to automatically handle copyright headers and header guards
    for generated scripts. Meant to be invoked via `with` statement similar to
    creating a file.

    - `path`: The path of the file to be created. Can be passed a raw string, an
    isolated SCons target, or a full SCons target list. If a target list contains
    multiple entries, produces a warning & only creates the first entry.
    - `guard`: Optional bool to determine if a header guard should be added. If
    unassigned, header guards are determined by the file extension.
    - `prefix`: Custom prefix to prepend to a header guard. Produces a warning if
    provided a value when `guard` evaluates to `False`.
    - `suffix`: Custom suffix to append to a header guard. Produces a warning if
    provided a value when `guard` evaluates to `False`.
    """

    # Handle unfiltered SCons target[s] passed as path.
    if not isinstance(path, str):
        if isinstance(path, list):
            if len(path) > 1:
                print_warning(
                    "Attempting to use generated wrapper with multiple targets; "
                    f"will only use first entry: {path[0]}"
                )
            path = path[0]
        if not hasattr(path, "get_abspath"):
            raise TypeError(f'Expected type "str", "Node" or "List[Node]"; was passed {type(path)}.')
        path = path.get_abspath()

    path = str(path).replace("\\", "/")
    if guard is None:
        guard = path.endswith((".h", ".hh", ".hpp", ".inc"))
    if not guard and (prefix or suffix):
        print_warning(f'Trying to assign header guard prefix/suffix while `guard` is disabled: "{path}".')

    header_guard = ""
    if guard:
        if prefix:
            prefix += "_"
        if suffix:
            suffix = f"_{suffix}"
        split = path.split("/")[-1].split(".")
        header_guard = (f"{prefix}{split[0]}{suffix}.{'.'.join(split[1:])}".upper()
                .replace(".", "_").replace("-", "_").replace(" ", "_").replace("__", "_"))  # fmt: skip

    with open(path, "wt", encoding="utf-8", newline="\n") as file:
        file.write(generate_copyright_header(path))
        file.write("\n/* THIS FILE IS GENERATED. EDITS WILL BE LOST. */\n\n")

        if guard:
            file.write(f"#ifndef {header_guard}\n")
            file.write(f"#define {header_guard}\n\n")

        with StringIO(newline="\n") as str_io:
            yield str_io
            file.write(str_io.getvalue().strip() or "/* NO CONTENT */")

        if guard:
            file.write(f"\n\n#endif // {header_guard}")

        file.write("\n")
