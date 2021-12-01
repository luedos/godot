
add_env(modules-env 
	COMPONENTS
		global-env
)

add_lib(modules-lib
	COMPONENTS
		modules-env
		warnings-env
)
register_global_lib(modules-lib)

add_dependencies(modules-env core-gen) # many modules dependent on the core gen headers

set(__MODULES_ENABLED_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/modules_enabled.gen.h")
execute_python_method(modules_builders cmake_generate_modules_enabled
	PYTHON_ARGS
		STR_VAR "target=__MODULES_ENABLED_HEADER"
		ARR_VAR "module_list=MODULES_LIST"
	APPEND_SYS_PATH "${GODOT_SOURCE_DIR}"
)

target_sources(modules-lib PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/register_module_types.gen.cpp")

function(__check_module_dependencies __LIST)
	set(__RET "")

	foreach(__DEP IN LISTS ${__LIST})
		string(REGEX REPLACE "-lib$" "" __DEP_NAME "${__DEP}")

		# If dependency does not match any of these, then it's module, and if this module is not enabled, we will not add it as a dependency..
		if (NOT __DEP_NAME MATCHES "(core|drivers|scene|servers|platform|main|tests|editor)" 
			AND NOT ${__DEP_NAME}_IS_MODULE_ENABLED)

			continue()	
		endif()

		list(APPEND __RET "${__DEP}")
	endforeach()

	set("${__LIST}" "${__RET}" PARENT_SCOPE)
endfunction()

function(define_module_dependencies __NAME)

	assert_if_empty(__NAME)
	# This function is used for defining dependencies between modules.
	# If we are not spliting lib modules, thats meen where is no need to define dependencies, 
	# because all modules will be connected as OBJECT lib to the modules-lib anyway 
	if (GODOT_SPLIT_LIBMODULES)
		return()
	endif()

	set(__DEPENDENCIES ${ARGN})
	__check_module_dependencies(__DEPENDENCIES)

	if("${__DEPENDENCIES}" STREQUAL "")
		return()
	endif()

	set(__TARGET "${__NAME}")

	get_target_property(__TARGET_TYPE "${__NAME}" TYPE)
	if (__TARGET_TYPE STREQUAL "OBJECT_LIBRARY")
		get_target_property(__PARENT "${__NAME}" MODULE_PARENT)
		if (NOT "${__PARENT}" STREQUAL "")
			set(__TARGET "${__PARENT}")
		endif()
	endif()

	define_lib_dependencies("${__TARGET}" ${__DEPENDENCIES})

endfunction()

# Basically a wrapper around add_lib
# If 'GODOT_SPLIT_LIBMODULES' global option is off, creates object library, and connect it to the modules-lib directly, 'PARENT_LIB' option, in that case, is ignored.
function(add_module_lib __NAME)

	assert_if_empty(__NAME)

	set(__OPTIONS_ARGS
		OBJECT
	)
	set(__ONE_VALUE_ARGS
		PARENT_LIB
		OUTPUT_DIR
		OUTPUT_NAME
	)
	set(__MULTI_VALUE_ARGS 
		COMPONENTS
		DEPENDENCIES
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
	
	set(__PARENT "")

	# if we are not spliting libmodules, then we want only object files, not libraries.
	# Because of that we will generate only object libraries, and automatically connect them to the modules-lib.	
	if(NOT GODOT_SPLIT_LIBMODULES)
		set(__ARGS_OBJECT TRUE)
		# linking this library directly into modules-lib
		set(__PARENT modules-lib)
		list(APPEND __FORWARD_ARGS PARENT_LIB "${__PARENT}")
	# if we are not forced to link everything into modules-lib
	elseif("${__ARGS_PARENT_LIB}" STREQUAL "")
		# if no parent lib was provided, then we want this library be part of the modules-lib interface..
		# we are not linking this library directly into modules-lib, rather we are making it part of the interface. 
		set(__PARENT modules-lib)
		list(APPEND __FORWARD_ARGS PARENT_ENV "${__PARENT}")
	else()
		# if parent lib was provided, then we just set this lib as parent lib.
		set(__PARENT "${__ARGS_PARENT_LIB}")
		list(APPEND __FORWARD_ARGS PARENT_LIB "${__PARENT}")
		# this is not a requirment, but it's desireble that only main modules libs (which are part of the modules-lib interface)
		# are set as static, every other lib, should be object one.. 
		if(NOT __ARGS_OBJECT)
			message(WARNING "Module library '${__NAME}' (which is linked to the '${__ARGS_PARENT_LIB}' library) is not marked as OBJECT.")
		endif()

	endif()

	if(__ARGS_OBJECT)
		list(APPEND __FORWARD_ARGS OBJECT)
	endif()

	forward_arg(COMPONENTS __FORWARD_ARGS)
	forward_arg(ENVS_CLONE __FORWARD_ARGS)
	forward_arg(LIBS_CLONE __FORWARD_ARGS)
	forward_arg(OUTPUT_DIR __FORWARD_ARGS)
	forward_arg(OUTPUT_NAME __FORWARD_ARGS)
	forward_arg(SOURCES __FORWARD_ARGS)

	add_lib("${__NAME}" ${__FORWARD_ARGS})

	set_target_properties("${__NAME}" PROPERTIES MODULE_PARENT "${__PARENT}")

	define_module_dependencies("${__NAME}" ${__ARGS_DEPENDENCIES})

endfunction()

foreach(__MODULE_ID IN LISTS MODULES_LIST)

	add_subdirectory("${${__MODULE_ID}_MODULE_PATH}")

endforeach()