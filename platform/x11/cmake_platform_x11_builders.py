"""Functions used to generate source files during build time

All such functions are invoked in a subprocess on Windows to prevent build flakiness.

"""
import os


def make_debug_x11(target, source):
	target_file = target[0]
	source_file = source[0]
	os.system("objcopy --only-keep-debug {} {}".format(source_file, target_file))
	os.system("strip --strip-debug --strip-unneeded {}".format(source_file))
	os.system("objcopy --add-gnu-debuglink={} {}".format(target_file, source_file))
