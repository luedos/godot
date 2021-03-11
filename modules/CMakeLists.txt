
add_env(modules-env 
	COMPONENTS
		global-env
)

add_lib(modules-lib 
	PARENT_ENV
		global-libs-list
	COMPONENTS
		modules-env
		warnings-env
)

add_dependencies(modules-env core-gen) # many modules dependent on the core gen headers

#TODO: Not sure where this file is came from. Need to research this more in the future.
target_sources(modules-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/register_module_types.gen.cpp")

# Basically a wrapper around add_lib
# If 'GODOT_SPLIT_LIBMODULES' global option is off, creates object library, and connect it to the modules-lib directly ('PARENT_LIB' option is ignored).
function(add_module_lib __NAME)

	assert_if_empty(__NAME)

	set(__OPTIONS_ARGS
		""
	)
	set(__ONE_VALUE_ARGS
		PARENT_LIB
		OUTPUT_DIR
		OUTPUT_NAME
	)
	set(__MULTI_VALUE_ARGS 
		COMPONENTS
		ENVS_CLONE
		LIBS_CLONE
		SOURCES
	)
	cmake_parse_arguments(PARSE_ARGV 1 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	set(__FORWARD_ARGS "")

	macro(forward_arg __ARG __ARGS_LIST)
		if(NOT "${__ARGS_${__ARG}}" STREQUAL "")
			list(APPEND ${__ARGS_LIST} ${__ARG} ${__ARGS_${__ARG}})
		endif()
	endmacro()
	
	# if we are not spliting libmodules, then we want only object files, not libraries.
	# Because of that we will generate only object libraries, and automatically connect them to the modules-lib.	
	if(NOT GODOT_SPLIT_LIBMODULES)
		list(APPEND __FORWARD_ARGS OBJECT)
		set(__ARGS_PARENT_LIB modules-lib)
	endif()

	# if no parent library was defined yet, using modules-lib as a default
	if("${__ARGS_PARENT_LIB}" STREQUAL "")
		set(__ARGS_PARENT_LIB modules-lib)
	endif()

	forward_arg(PARENT_LIB __FORWARD_ARGS)
	forward_arg(COMPONENTS __FORWARD_ARGS)
	forward_arg(ENVS_CLONE __FORWARD_ARGS)
	forward_arg(LIBS_CLONE __FORWARD_ARGS)
	forward_arg(OUTPUT_DIR __FORWARD_ARGS)
	forward_arg(OUTPUT_NAME __FORWARD_ARGS)
	forward_arg(SOURCES __FORWARD_ARGS)

	add_lib("${__NAME}" ${__FORWARD_ARGS})

endfunction()

foreach(__MODULE_ID IN LISTS MODULES_LIST)

	if(__MODULE_ID IN_LIST DISABLED_MODULES)
		continue()
	endif()

  	string(TOUPPER "${__MODULE_ID}" __MODULE_ID_UPPER)
	target_compile_definitions(modules-env INTERFACE "MODULE_${__MODULE_ID_UPPER}_ENABLED")
	
	add_subdirectory("${${__MODULE_ID}_MODULE_PATH}")

endforeach()
