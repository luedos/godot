"""Functions used to generate source files during build time

All such functions are invoked in a subprocess on Windows to prevent build flakiness.

"""
import os
import os.path
from platform_methods import subprocess_main
from compat import encode_utf8, byte_to_str, open_utf8


def cmake_make_doc_header(target, source):
    make_doc_header(target, sorted(source), None)

def make_doc_header(target, source, env):

    dst = target[0]
    g = open_utf8(dst, "w")
    buf = ""
    docbegin = ""
    docend = ""
    for src in source:
        if not src.endswith(".xml"):
            continue
        with open_utf8(src, "r") as f:
            content = f.read()
        buf += content

    buf = encode_utf8(docbegin + buf + docend)
    decomp_size = len(buf)
    import zlib

    buf = zlib.compress(buf)

    g.write("/* THIS FILE IS GENERATED DO NOT EDIT */\n")
    g.write("#ifndef _DOC_DATA_RAW_H\n")
    g.write("#define _DOC_DATA_RAW_H\n")
    g.write("static const int _doc_data_compressed_size = " + str(len(buf)) + ";\n")
    g.write("static const int _doc_data_uncompressed_size = " + str(decomp_size) + ";\n")
    g.write("static const unsigned char _doc_data_compressed[] = {\n")
    for i in range(len(buf)):
        g.write("\t" + byte_to_str(buf[i]) + ",\n")
    g.write("};\n")

    g.write("#endif")

    g.close()


def cmake_make_fonts_header(target, source):
    make_fonts_header(target, sorted(source), None)

def make_fonts_header(target, source, env):

    dst = target[0]

    g = open_utf8(dst, "w")

    g.write("/* THIS FILE IS GENERATED DO NOT EDIT */\n")
    g.write("#ifndef _EDITOR_FONTS_H\n")
    g.write("#define _EDITOR_FONTS_H\n")

    # saving uncompressed, since freetype will reference from memory pointer
    xl_names = []
    for i in range(len(source)):
        with open(source[i], "rb") as f:
            buf = f.read()

        name = os.path.splitext(os.path.basename(source[i]))[0]

        g.write("static const int _font_" + name + "_size = " + str(len(buf)) + ";\n")
        g.write("static const unsigned char _font_" + name + "[] = {\n")
        for j in range(len(buf)):
            g.write("\t" + byte_to_str(buf[j]) + ",\n")

        g.write("};\n")

    g.write("#endif")

    g.close()


def cmake_make_translations_header(target, source, category):
    make_translations_header(target, source, None, category)

def make_translations_header(target, source, env, category):

    dst = target[0]

    g = open_utf8(dst, "w")

    g.write("/* THIS FILE IS GENERATED DO NOT EDIT */\n")
    g.write("#ifndef _{}_TRANSLATIONS_H\n".format(category.upper()))
    g.write("#define _{}_TRANSLATIONS_H\n".format(category.upper()))

    import zlib
    import os.path

    sorted_paths = sorted(source, key=lambda path: os.path.splitext(os.path.basename(path))[0])

    xl_names = []
    for i in range(len(sorted_paths)):
        with open(sorted_paths[i], "rb") as f:
            buf = f.read()
        decomp_size = len(buf)
        buf = zlib.compress(buf)
        name = os.path.splitext(os.path.basename(sorted_paths[i]))[0]

        g.write("static const unsigned char _{}_translation_{}_compressed[] = {{\n".format(category, name))
        for j in range(len(buf)):
            g.write("\t" + byte_to_str(buf[j]) + ",\n")

        g.write("};\n")

        xl_names.append([name, len(buf), str(decomp_size)])

    g.write("struct {}TranslationList {{\n".format(category.capitalize()))
    g.write("\tconst char* lang;\n")
    g.write("\tint comp_size;\n")
    g.write("\tint uncomp_size;\n")
    g.write("\tconst unsigned char* data;\n")
    g.write("};\n\n")
    g.write("static {}TranslationList _{}_translations[] = {{\n".format(category.capitalize(), category))
    for x in xl_names:
        g.write(
            '\t{{ "{}", {}, {}, _{}_translation_{}_compressed }},\n'.format(x[0], str(x[1]), str(x[2]), category, x[0])
        )
    g.write("\t{NULL, 0, 0, NULL}\n")
    g.write("};\n")

    g.write("#endif")

    g.close()

def cmake_register_exporters(output_file, modules):
    from compat import open_utf8
    # Register exporters
    reg_exporters_inc = '#include "register_exporters.h"\n'
    reg_exporters = "void register_exporters() {\n"
    for e in modules:
        reg_exporters += "\tregister_" + e + "_exporter();\n"
        reg_exporters_inc += '#include "platform/' + e + '/export/export.h"\n'
    reg_exporters += "}\n"

    # NOTE: It is safe to generate this file here, since this is still executed serially
    with open_utf8(output_file, "w") as f:
        f.write(reg_exporters_inc)
        f.write(reg_exporters)

def cmake_make_doc_data_class_path(to_path, class_map):
    # NOTE: It is safe to generate this file here, since this is still executed serially
    g = open_utf8(os.path.join(to_path, "doc_data_class_path.gen.h"), "w")
    g.write("static const int _doc_data_class_path_count = " + str(len(class_map)) + ";\n")
    g.write("struct _DocDataClassPath { const char* name; const char* path; };\n")

    g.write("static const _DocDataClassPath _doc_data_class_paths[" + str(len(class_map) + 1) + "] = {\n")
    for c in sorted(class_map):
        g.write('\t{"' + c + '", "' + class_map[c] + '"},\n')
    g.write("\t{NULL, NULL}\n")
    g.write("};\n")

    g.close()

def make_editor_translations_header(target, source, env):
    make_translations_header(target, source, env, "editor")


def make_doc_translations_header(target, source, env):
    make_translations_header(target, source, env, "doc")


if __name__ == "__main__":
    subprocess_main(globals())
