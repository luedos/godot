
import os

def cmake_make_icu_data(target, source):
    dst = target[0]

    g = open(dst, "w", encoding="utf-8")

    g.write("/* THIS FILE IS GENERATED DO NOT EDIT */\n")
    g.write("/* (C) 2016 and later: Unicode, Inc. and others. */\n")
    g.write("/* License & terms of use: https://www.unicode.org/copyright.html */\n")
    g.write("#ifndef _ICU_DATA_H\n")
    g.write("#define _ICU_DATA_H\n")
    g.write('#include "unicode/utypes.h"\n')
    g.write('#include "unicode/udata.h"\n')
    g.write('#include "unicode/uversion.h"\n')

    f = open(source[0], "rb")
    buf = f.read()

    g.write('extern "C" U_EXPORT const size_t U_ICUDATA_SIZE = ' + str(len(buf)) + ";\n")
    g.write('extern "C" U_EXPORT const unsigned char U_ICUDATA_ENTRY_POINT[] = {\n')
    for i in range(len(buf)):
        g.write("\t" + str(buf[i]) + ",\n")

    g.write("};\n")
    g.write("#endif")