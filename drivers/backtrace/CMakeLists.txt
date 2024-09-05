
add_env(drivers-backtrace-env
	COMPONENTS
		global-env
)

add_lib(thirdparty-drivers-backtrace-lib
	OBJECT
	PARENT_LIB
		drivers-lib
	COMPONENTS
		drivers-backtrace-env
		thirdparty-warnings-env
)

set(__THIRDPARTY_BACKTRACE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/libbacktrace")
target_sources_from_path(thirdparty-drivers-backtrace-lib PRIVATE "${__THIRDPARTY_BACKTRACE_PATH}"
	"atomic.c"
	"dwarf.c"
	"fileline.c"
	"posix.c"
	"print.c"
	"sort.c"
	"state.c"
	"backtrace.c"
	"simple.c"
	"pecoff.c"
	"read.c"
	"alloc.c"
)

target_include_directories(drivers-backtrace-env INTERFACE "${__THIRDPARTY_BACKTRACE_PATH}")

file(GLOB __BACKTRACE_SOURCES LIST_DIRECTORIES FALSE "*.cpp")
if (NOT "${__BACKTRACE_SOURCES}" STREQUAL "")
	add_lib(dirvers-backtrace-lib
		OBJECT
		PARENT_LIB
			drivers-lib
		COMPONENTS
			drivers-backtrace-env
			global-warnings-env
		SOURCES
			${__BACKTRACE_SOURCES}
	)
endif()
