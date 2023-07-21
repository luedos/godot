
import os

def cmake_make_debug_linuxbsd(target, source):
    os.system("objcopy --only-keep-debug {} {}".format(source[0], target[0]))
    os.system("strip --strip-debug --strip-unneeded {}".format(source[0]))
    os.system("objcopy --add-gnu-debuglink={} {}".format(target[0], source[0]))

