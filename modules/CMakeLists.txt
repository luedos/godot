
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

function(add_module_lib __NAME)

	set(__OPTIONS_ARGS 
		TOOLS_DEPENDENT # Is module is dependent on tools generation. If it does, and tools are not building, this module will not be included in the libraries list
		EXCLUDE_FROM_ALL 
	)
	set(__ONE_VALUE_ARGS
		PARENT_ENV # env this library will link to
		PARENT_LIB # lib this library will link to
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

	if (__ARGS_EXCLUDE_FROM_ALL OR GODOT_SPLIT_LIBMODULES)
		list(APPEND __FORWARD_ARGS "EXCLUDE_FROM_ALL")
	endif()

	macro(forward_arg __ARG __ARGS_LIST)
		if(NOT "${__ARGS_${__ARG}}" STREQUAL "")
			list(APPEND ${__ARGS_LIST} ${__ARG} ${__ARGS_${__ARG}})
		endif()
	endmacro()

	# forward_arg(PARENT_ENV __FORWARD_ARGS)
	# forward_arg(PARENT_LIB __FORWARD_ARGS)
	forward_arg(COMPONENTS __FORWARD_ARGS)
	forward_arg(ENVS_CLONE __FORWARD_ARGS)
	forward_arg(LIBS_CLONE __FORWARD_ARGS)
	forward_arg(OUTPUT_DIR __FORWARD_ARGS)
	forward_arg(OUTPUT_NAME __FORWARD_ARGS)
	forward_arg(SOURCES __FORWARD_ARGS)

	add_lib("${__NAME}" ${__FORWARD_ARGS})

	if (NOT __ARGS_EXCLUDE_FROM_ALL)
		if (__ARGS_TOOLS_DEPENDENT)
			set(__NAME $<${IS_TOOLS_GEN_EXPR}:${__NAME}>)
		endif()
		# adding our newly created target to others
		target_link_libraries(modules-lib PRIVATE ${__NAME})
	endif()

endfunction()

foreach(__MODULE_ID IN LISTS MODULES_LIST)

	if(__MODULE_ID IN_LIST DISABLED_MODULES)
		continue()
	endif()

  	string(TOUPPER "${__MODULE_ID}" __MODULE_ID_UPPER)
	target_compile_definitions(modules-env INTERFACE "MODULE_${__MODULE_ID_UPPER}_ENABLED")
	
	add_subdirectory("${${__MODULE_ID}_MODULE_PATH}")

endforeach()
