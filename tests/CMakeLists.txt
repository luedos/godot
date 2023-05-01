
add_lib(tests-lib
	PARENT_ENV
		global-libs-list
	COMPONENTS
		global-env
		global-warnings-env
)

target_glob_sources(tests-lib PRIVATE "*.cpp")

# We must disable the THREAD_LOCAL entirely in doctest to prevent crashes on debugging
# Since we link with /MT thread_local is always expired when the header is used
# So the debugger crashes the engine and it causes weird errors
# Explained in https://github.com/onqtam/doctest/issues/401
if (godot_platform STREQUAL "windows")
	target_compile_definitions(tests-lib PRIVATE "DOCTEST_THREAD_LOCAL")
endif()

# Increase number of addressable sections in object files
# due to doctest's heavy use of templates and macros.
if (MSVC)
	target_compile_options(tests-lib PRIVATE "/bigobj")
endif()