
macro(inline_if __OUTPUT)

	if(${ARGN})
		set(${__OUTPUT} true)
	else()
		set(${__OUTPUT} false)
	endif()

endmacro()

macro(ternary_if __OUTPUT __TRUE __FALSE)

	if(${ARGN})
		set(${__OUTPUT} ${__TRUE})
	else()
		set(${__OUTPUT} ${__FALSE})
	endif()

endmacro()

function(set_string_option __NAME __VALUE)
	# local vars
	set(__OPT_DESCRIPTION "")
	set(__OPT_ENUM "")

	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE ENUM)
	cmake_parse_arguments(__OPT "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}" ${ARGN})

	set("${__NAME}" "${__VALUE}" CACHE STRING "${__OPT_DESCRIPTION}")

	if (__OPT_ENUM)
		set_property(CACHE "${__NAME}" PROPERTY STRINGS ${__OPT_ENUM})
	endif()
endfunction()

function(set_path_option __NAME __VALUE)
	# local vars
	set(__OPT_DESCRIPTION "")
	set(__OPT_FILE "")

	set(__OPTIONS FILE)
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE "")
	cmake_parse_arguments(__OPT "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}" ${ARGN})
	if (__OPT_FILE)
		set("${__NAME}" "${__VALUE}" CACHE FILEPATH "${__OPT_DESCRIPTION}")
	else()
		set("${__NAME}" "${__VALUE}" CACHE PATH "${__OPT_DESCRIPTION}")
	endif()
endfunction()

function(set_bool_option __NAME __VALUE)
	# local vars
	set(__OPT_DESCRIPTION "")

	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE "")
	cmake_parse_arguments(__OPT "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}" ${ARGN})

	set("${__NAME}" "${__VALUE}" CACHE BOOL "${__OPT_DESCRIPTION}")

endfunction()

function(normilize_path __OUTPUT __PATH)
	set(__OPTIONS_ARGS 
		ABSOLUTE # Force path to be absolute
	)

	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	# normilize only slashes
	file(TO_CMAKE_PATH "${__PATH}" __LOCAL_OUTPUT)

	if (IS_ABSOLUTE __LOCAL_OUTPUT)
		set(__ARGS_ABSOLUTE true)
	endif()

	set(__PATH_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}") # just to make it absolute
	if (NOT __ARGS_ABSOLUTE)
		# lots of fuckery here, better not look
		# ye, ye, I know, python is better for that (python at least has library for working with the paths).
		string(REGEX MATCHALL "\\.\\./" __BACKWARD_DIR_LIST "${__LOCAL_OUTPUT}")
		list(LENGTH __BACKWARD_DIR_LIST __COUNT)
		if(NOT __COUNT EQUAL 0)
			foreach(__I RANGE 1 ${__COUNT})
				set(__PATH_PREFIX "${__PATH_PREFIX}/d")
			endforeach()
		endif()
	endif()

	file(REAL_PATH "${__LOCAL_OUTPUT}" __LOCAL_OUTPUT BASE_DIRECTORY "${__PATH_PREFIX}")

	# if we are not desired to be absolute, and we wasn't absolute in the first place, 
	# then REAL_PATH made us absolute anyway, 
	# so now we need to strip absolute part from the begining of our path.
	if (NOT __ARGS_ABSOLUTE)
		file(RELATIVE_PATH __LOCAL_OUTPUT "${__PATH_PREFIX}" "${__LOCAL_OUTPUT}")
	endif()

	set(${__OUTPUT} "${__LOCAL_OUTPUT}" PARENT_SCOPE)
endfunction()

# Ok, so here is the problem:
# If any path, which has ';' in it (like "some/ran;dom/path"), will be passed through ARGN,
# it will be interpreted as two paths instead of one (like "some/ran" and "dom/path").
# This is due to how CMake works with lists (each list is basically the string with ';' as a devider).
# We can partially fix that if we will enforce 2 arguments __FIRST_PATH __SECOND_PATH instead of always relying on ARGN.
# Because 99% of the time, this function will join only 2 paths, this will work.
# Another problem is if name in some path will start from ';' and you are using windows (like so "some\;name").
# This will be interpreted like explicit escaping of ';', and final path will be "some;name".
# So basically, don't use ';' in your paths (please).
function(join_paths __OUTPUT __FIRST_PATH __SECOND_PATH)

	function(__join_paths __OUTPUT __FIRST_PATH_INNER __SECOND_PATH_INNER)
		if(IS_ABSOLUTE __SECOND_PATH_INNER)
			message(FATAL_ERROR "Can't join absolute path \"${__SECOND_PATH_INNER}\".")
		endif()
		
		normilize_path("${__SECOND_PATH_INNER}" __SECOND_PATH_INNER)

		if (NOT "${__SECOND_PATH_INNER}" STREQUAL "")
			set(__FIRST_PATH_INNER "${__FIRST_PATH_INNER}/${__SECOND_PATH_INNER}")
		endif()

		set(${__OUTPUT} "${__FIRST_PATH_INNER}" PARENT_SCOPE)
	endfunction()

	normilize_path(__JOINED_PATH "${__FIRST_PATH}")
	__join_paths(__JOINED_PATH "${__JOINED_PATH}" "${__SECOND_PATH}")

	foreach(__PATH IN LISTS ARGN)
		__join_paths(__JOINED_PATH "${__JOINED_PATH}" "${__PATH}")
	endforeach()

	normilize_path(__JOINED_PATH "${__JOINED_PATH}")
	set(${__OUTPUT} "${__JOINED_PATH}" PARENT_SCOPE)
endfunction()

function(target_glob_sources __TARGET __SCOPE __GLOB_EXPR)
	file(GLOB __SOURCES LIST_DIRECTORIES false "${__GLOB_EXPR}")
	target_sources("${__TARGET}" "${__SCOPE}" ${__SOURCES})
endfunction()

function(get_top_directory __PATH __OUTPUT)
	# local variables
	unset(__FOLDER_NAME)

	# if path ends with slash, get_filename_component will not work
	normilize_path(__PATH "${__PATH}")

	get_filename_component(__FOLDER_NAME "${__PATH}" NAME)

	set(${__OUTPUT} "${__FOLDER_NAME}" PARENT_SCOPE)
endfunction()

function(is_module __PATH __OUTPUT)
	if (IS_DIRECTORY __PATH AND EXISTS "${__PATH}/CMakeLists.txt")
		set(${__OUTPUT} true PARENT_SCOPE)
	else()
		set(${__OUTPUT} false PARENT_SCOPE)
	endif()
endfunction()

# appends all paths from current directories if they are modules
# returns absolute paths
function(get_modules_paths __OUTPUT)
	# local variable
	unset(__MODULE_VALID)
	unset(__MODULES_DIRS)
	unset(__PARENT_GLOB)
	unset(__PATH_REGEX_MATCH)
	unset(__RET_LIST)

	foreach(__PARENT_DIR IN LISTS ARGN)
		# if path is not absolute by default, it will be counted as relative to ${CMAKE_SOURCE_DIR} 
		normilize_path(__PARENT_DIR "${__PARENT_DIR}" ABSOLUTE)
		set(__PARENT_DIR "${__PARENT_DIR}/*")

		file(GLOB __MODULES_DIRS LIST_DIRECTORIES true "${__PARENT_DIR}")

		foreach(__DIR IN LISTS __MODULES_DIRS)

			is_module("${__DIR}" __MODULE_VALID)
			if(__MODULE_VALID)
				list(APPEND __RET_LIST "${__DIR}")
			endif()		

		endforeach()

	endforeach()

	set(${__OUTPUT} "${__RET_LIST}" PARENT_SCOPE)
endfunction()

function(clone_target_properties __SOURCE __TARGET)
	set(__OPTIONS_ARGS 
		APPEND # Do we need to append properties, or reset them
	)
	set(__ONE_VALUE_ARGS 
		FROM # Type of the source properties. Can be INTERFACE or PRIVATE 
		TO # Type of the target properties. Can be INTERFACE or PRIVATE
	)
	set(__MULTI_VALUE_ARGS 
		PROPERTIES # Which properties to clone
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	set(__PROP_TYPE INTERFACE PRIVATE)

	# arguments validation..
	if (NOT __ARGS_FROM IN_LIST __PROP_TYPE)
		message(FATAL_ERROR "Can't parse FROM argument in the clone_target_properties function. Argument value is \"${__ARGS_FROM}\", and possible values is \"${__PROP_TYPE}\"")
	endif()
	if (NOT __ARGS_TO IN_LIST __PROP_TYPE)
		message(FATAL_ERROR "Can't parse TO argument in the clone_target_properties function. Argument value is \"${__ARGS_TO}\", and possible values is \"${__PROP_TYPE}\"")
	endif()

	foreach(__PROP IN LISTS __ARGS_PROPERTIES)
		if ("${__PROP}" STREQUAL "")
			continue()
		endif()

		set(__FROM_PROP_NAME "${__PROP}")
		if (__ARGS_FROM STREQUAL "INTERFACE")
			set(__FROM_PROP_NAME "INTERFACE_${__FROM_PROP_NAME}")
		endif()

		get_target_property(__FROM_PROP_VALUE "${__SOURCE}" "${__FROM_PROP_NAME}")

		set(__TO_PROP_NAME "${__PROP}")
		if (__ARGS_TO STREQUAL "INTERFACE")
			set(__TO_PROP_NAME "INTERFACE_${__TO_PROP_NAME}")
		endif()

		if (__ARGS_APPEND)
			set_property(TARGET "${__TARGET}" APPEND PROPERTY "${__TO_PROP_NAME}" "${__FROM_PROP_VALUE}")
		else()
			set_property(TARGET ${__TARGET} PROPERTY "${__TO_PROP_NAME}" "${__FROM_PROP_VALUE}")
		endif()

	endforeach()
endfunction()

function(parse_to_python_map __OUTPUT)
	
	unset(__ARG_TYPE)
	unset(__ARG_KEY)

	set(__PYTHON_MAP "{")

	foreach(__ARG IN LISTS ARGN)

		if(NOT DEFINED __ARG_TYPE)
			set(__ARG_TYPE "${__ARG}")
			continue()
		endif()

		if(NOT DEFINED __ARG_KEY)
			set(__ARG_KEY "${__ARG}")
			continue()
		endif()

		if(__FIRST)
			set(__FIRST false)
		else()
			set(__PYTHON_MAP "${__PYTHON_MAP}, ")
		endif()

		if(__ARG_TYPE STREQUAL "STR_VAL")
			set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':'${__ARG}'")
		elseif(__ARG_TYPE STREQUAL "RAW_VAL")
			set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':${__ARG}")
		elseif(__ARG_TYPE STREQUAL "STR_VAR")
			set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':'${${__ARG}}'")
		elseif(__ARG_TYPE STREQUAL "BOOL_VAR")
			if("${${__ARG}}")
				set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':True")
			else()
				set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':False")
			endif()
		elseif(__ARG_TYPE STREQUAL "RAW_VAR")
			set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':${${__ARG}}")
		elseif(__ARG_TYPE STREQUAL "ARR_VAR")
			set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':str('${${__ARG}}').split(';')")
		else()
			message(WARNING "Incorrect variable type was provided to the python map parser (${__ARG_TYPE})")
		endif()

		unset(__ARG_TYPE)
		unset(__ARG_KEY)
	endforeach()

	if(DEFINED __ARG_TYPE)		
		message(WARNING "Last variable of type \"${__ARG_TYPE}\" provided to the python map parser did not has a value.")
	endif()

	set(${__OUTPUT} "${__PYTHON_MAP} }" PARENT_SCOPE)

endfunction()

# parses specific list of variables into python function arguments.
# function signature is parse_to_python_args(<output_var> [<type> <var> [<type> <var> [...]]])
# where: <type> is the type of the argument, and <var> is value of the argument. Next Types supported:
# STR_VAL: simple string value where <var> is a value of a string in the raw form (STR_VAL 'just simple string' -> 'just simple string')
# RAW_VAL: just value in the raw form (RAW_VAL 'raw_value' -> raw_value  (note: no quotes around the value))
# STR_VAR: variable of a string (STR_VAR variable -> '${variable}')
# BOOL_VAR: bool variable, actual argument will have value of True/False depending on the truthfulness of cmake variable itself (BOOL_VAR variable -> if("${variable}") True else() False endif())
# RAW_VAR: same as RAW_VAL but with actual variable (RAW_VAR variable -> ${variable})
# ARR_VAR: variable which will be transformed into array (ARR_VAR variable -> str('${variable}').split(';'))
# Also, the <var> can be passed in the form of 'name=var'. This way the <var> will be splited into <name> and <var> before evaluation, and passed into python as kwarg (e.g. STR_VAL 'name=value' -> name='value')
function(parse_to_python_args __OUTPUT)

	unset(__ARG_TYPE)
	unset(__ARG_PREFIX)

	foreach(__ARG IN LISTS ARGN)

		if(NOT DEFINED __ARG_TYPE)
			set(__ARG_TYPE "${__ARG}")
			continue()
		endif()

		if(__FIRST)
			set(__FIRST false)
		else()
			set(__PYTHON_ARGS "${__PYTHON_ARGS}, ")
		endif()

		string(REPLACE "=" ";" __ARG_LIST "${__ARG}")
		list(LENGTH __ARG_LIST __ARG_LIST_LEN)

		if(__ARG_LIST_LEN GREATER_EQUAL 2)
			list(SUBLIST __ARG_LIST 0 1 __ARG_NAME)
			list(SUBLIST __ARG_LIST 1 -1 __ARG)

			set(__ARG_PREFIX "${__ARG_NAME}=") 
		endif()

		if(__ARG_TYPE STREQUAL "STR_VAL")
			set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}'${__ARG}'")
		elseif(__ARG_TYPE STREQUAL "RAW_VAL")
			set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}${__ARG}")
		elseif(__ARG_TYPE STREQUAL "STR_VAR")
			set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}'${${__ARG}}'")
		elseif(__ARG_TYPE STREQUAL "BOOL_VAR")
			if("${${__ARG}}")
				set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}True")
			else()
				set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}False")
			endif()
		elseif(__ARG_TYPE STREQUAL "RAW_VAR")
			set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}${${__ARG}}")
		elseif(__ARG_TYPE STREQUAL "ARR_VAR")
			set(__PYTHON_ARGS "${__PYTHON_ARGS} ${__ARG_PREFIX}str('${${__ARG}}').split(';')")
		else()
			message(WARNING "Incorrect variable type was provided to the python arguments parser (${__ARG_TYPE})")
		endif()

		unset(__ARG_TYPE)
		unset(__ARG_PREFIX)
	endforeach()

	if(DEFINED __ARG_TYPE)		
		message(WARNING "Last variable of type \"${__ARG_TYPE}\" provided to the python arguments parser did not has a value.")
	endif()

	set(${__OUTPUT} "${__PYTHON_ARGS}" PARENT_SCOPE)

endfunction()

function(compose_python_method_call __OUTPUT __FUNCTION_NAME)
	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS 
		FROM_MODULE # module which need to be imported, and from which function must be called 
	)
	set(__MULTI_VALUE_ARGS 
		PYTHON_ARGS # works by the rules of the parse_to_python_args
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	set(__FUNCTION_CALL "")
	if(NOT "${__ARGS_FROM_MODULE}" STREQUAL "")

		string(REGEX REPLACE "\\.$" "" __MODULE "${__ARGS_FROM_MODULE}") # just in case we have dot in the end
		string(REGEX REPLACE "^\\." "" __MODULE "${__MODULE}") # ... or beggining

		string(REGEX REPLACE "^.*\\.([^\\.]+)$" "\\1" __MODULE_NAME "${__MODULE}")
		if("${__MODULE_NAME}" STREQUAL "")
			set(__MODULE_NAME "${__MODULE}")
		endif()

		set(__FUNCTION_CALL "import ${__MODULE} as ${__MODULE_NAME}; ${__MODULE_NAME}.")
	endif()

	parse_to_python_args(__FUNCTION_ARGS ${__ARGS_PYTHON_ARGS})

	set(__FUNCTION_CALL "${__FUNCTION_CALL}${__FUNCTION_NAME}(${__FUNCTION_ARGS})")

	set("${__OUTPUT}" "${__FUNCTION_CALL}" PARENT_SCOPE)

endfunction()

function(add_python_generator_command __MODULE __FUNCTION)
	set(__OPTIONS_ARGS 
		USE_PYTHON3 # explicitly tell to use python3
		BUILTIN_MODULE # by default add_python_generator_command adds file ${__MODULE}.py as a dependency. If this option is turned on, this behavior will be omitted.
	)
	set(__ONE_VALUE_ARGS 
		MODULE_DIR # relative directory of the module
		WORKING_DIR # working directory of the command. If none, then used CMAKE_CURRENT_SOURCE_DIR
	)
	set(__MULTI_VALUE_ARGS 
		SOURCE_FILES # Source files to be used
		TARGET_FILES # Target files expected to be produced by this comand
		PYTHON_ARGS # works by the rules of the parse_to_python_args
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.{__MODULE}")
	endif()

	# Each generator function expected to have at lease 2 parameters,
	# so automatically add target and source files as first two arguments to the function call, and everything else after that 
	set(__ARGS_PYTHON_ARGS ARR_VAR "__ARGS_TARGET_FILES" ARR_VAR "__ARGS_SOURCE_FILES" ${__ARGS_PYTHON_ARGS})

	compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
		FROM_MODULE "${__MODULE}"
		PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
	)

	if ("${__ARGS_WORKING_DIR}" STREQUAL "")
		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()

	set(__PYTHON "python")
	if (__ARGS_USE_PYTHON3)
		set(__PYTHON "python3")
	endif()

	set(__DEPENDS ${__ARGS_SOURCE_FILES})
	if(NOT __ARGS_BUILDIN_MODULE)
		join_paths(__MODULE_ABS_DIR "${__ARGS_WORKING_DIR}" "${__ARGS_MODULE_DIR}" "${__MODULE}.py")
		list(APPEND __DEPENDS "${__MODULE_ABS_DIR}")
	endif()

	add_custom_command(
		OUTPUT ${__ARGS_TARGET_FILES}
		DEPENDS ${__DEPENDS}
		COMMAND ${__PYTHON} "-c" "${__METHOD_CALL}"
		WORKING_DIRECTORY "${__ARGS_WORKING_DIR}"
	)

endfunction()

function(execute_python_method __MODULE __FUNCTION)
	set(__OPTIONS_ARGS 
		USE_PYTHON3 # explicitly tell to use python3
		ECHO_OUTPUT_VARIABLE
		ECHO_ERROR_VARIABLE
		OPTIONAL # do we need to throw an error, if this command fails? If no, specify this option. 
	)
	set(__ONE_VALUE_ARGS 
		MODULE_DIR # relative directory of the module
		WORKING_DIR # working directory of the command. If none, then used CMAKE_CURRENT_SOURCE_DIR
		OUTPUT_VARIABLE
		ERROR_VARIABLE
	)
	set(__MULTI_VALUE_ARGS 
		PYTHON_ARGS # works by the rules of the parse_to_python_args
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.{__MODULE}")
	endif()

	compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
		FROM_MODULE "${__MODULE}"
		PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
	)

	if ("${__ARGS_WORKING_DIR}" STREQUAL "")
		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()

	set(__PYTHON "python")
	if (__ARGS_USE_PYTHON3)
		set(__PYTHON "python3")
	endif()

	set(__ADDITIONAL_ARGS "")
	
	if(NOT "${__ARGS_OUTPUT_VARIABLE}" STREQUAL "")
		list(APPEND __ADDITIONAL_ARGS OUTPUT_VARIABLE __TEMP_OUTPUT_VAR)
	endif()
	if(NOT "${__ARGS_ERROR_VARIABLE}" STREQUAL "")
		list(APPEND __ADDITIONAL_ARGS ERROR_VARIABLE __TEMP_ERROR_VAR)
	endif()

	if(__ARGS_ECHO_OUTPUT_VARIABLE)
		list(APPEND __ADDITIONAL_ARGS ECHO_OUTPUT_VARIABLE)
	endif()
	if(__ARGS_ECHO_ERROR_VARIABLE)
		list(APPEND __ADDITIONAL_ARGS ECHO_ERROR_VARIABLE)
	endif()
	if(NOT __ARGS_OPTIONAL)
		list(APPEND __ADDITIONAL_ARGS COMMAND_ERROR_IS_FATAL ALL)
	endif()

	execute_process(
		COMMAND "${__PYTHON}" "-c" "${__METHOD_CALL}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		${__ADDITIONAL_ARGS}
	)

	if(NOT "${__ARGS_OUTPUT_VARIABLE}" STREQUAL "")
		set("${__ARGS_OUTPUT_VARIABLE}" "${__TEMP_OUTPUT_VAR}" PARENT_SCOPE)
	endif()
	if(NOT "${__ARGS_ERROR_VARIABLE}" STREQUAL "")
		set("${__ARGS_ERROR_VARIABLE}" "${__TEMP_ERROR_VAR}" PARENT_SCOPE)
	endif()

endfunction()

function(add_lib __NAME)

	set(__OPTIONS_ARGS 
		STANDALONE # is this library shuld be actual library (by default all libraries here are object libraries, a.k.a. scopes for source files)
		EXCLUDE_FROM_ALL # works only with standalone
	)
	set(__ONE_VALUE_ARGS
		PARENT_LIB # lib this library will link to
		PARENT_ENV # other possibility is to link agains environment
		OUTPUT_DIR # directory of the output library
	)
	set(__MULTI_VALUE_ARGS 
		COMPONENTS # all libraries/environments which will be connected to this library.
		ENVS_CLONE
		LIBS_CLONE
		SOURCES
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	if(__ARGS_EXCLUDE_FROM_ALL)
		set(__EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
	else()
		unset(__EXCLUDE_FROM_ALL)
	endif()

	if(__ARGS_STANDALONE)
		add_library("${__NAME}" STATIC ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})

		# if it's not standalone (a.k.a. STATIC) where is no need for the setiing of the output parameters
		
		# seting output name
		string(REGEX REPLACE "-lib$" "" __LIB_NAME "${__NAME}")
		set_target_properties("${__NAME}" PROPERTIES 
			OUTPUT_NAME "${EXTRA_SUFFIX}${__LIB_NAME}"
			COMPILE_PDB_NAME "${EXTRA_SUFFIX}${__LIB_NAME}"
		)

		if(NOT "${__ARGS_OUTPUT_DIR}" STREQUAL "")
			if(NOT IS_ABSOLUTE __ARGS_OUTPUT_DIR)
				join_paths(__ARGS_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}" "${__ARGS_OUTPUT_DIR}")
			endif()
	
			# generator expression $<0:> in the very end need for the multiconfigurational generators,
			# because multiconfigurational generators always append $<CONFIG> in the end of output path if path does not has any of generator expressions already
			set_target_properties("${__NAME}" PROPERTIES 
				ARCHIVE_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>"
				COMPILE_PDB_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>" # just in case
			)
		endif()
	else()
		add_library("${__NAME}" OBJECT ${__ARGS_SOURCES})
	endif()

	foreach(__ENV IN LISTS __ARGS_ENVS_CLONE)
		clone_target_properties("${__ENV}" "${__NAME}"
			APPEND
			FROM INTERFACE 
			TO PRIVATE
			PROPERTIES 
				INCLUDE_DIRECTORIES 
				COMPILE_OPTIONS 
				COMPILE_DEFINITIONS
		)
	endforeach()

	foreach(__LIB IN LISTS __ARGS_LIBS_CLONE)
		clone_target_properties("${__LIB}" "${__NAME}"
			APPEND
			FROM PRIVATE 
			TO PRIVATE
			PROPERTIES 
				INCLUDE_DIRECTORIES 
				COMPILE_OPTIONS 
				COMPILE_DEFINITIONS
		)
	endforeach()

	foreach(__SUB IN LISTS __ARGS_COMPONENTS)
		target_link_libraries("${__NAME}" PRIVATE "${__SUB}")
	endforeach()

	if(NOT "${__ARGS_PARENT_LIB}" STREQUAL "")
		target_link_libraries("${__ARGS_PARENT_LIB}" PRIVATE "${__NAME}")
	endif()

	if(NOT "${__ARGS_PARENT_ENV}" STREQUAL "")
		target_link_libraries("${__ARGS_PARENT_ENV}" INTERFACE "${__NAME}")
	endif()

endfunction()

function(add_exe __NAME)

	set(__OPTIONS_ARGS
		EXCLUDE_FROM_ALL # works only with standalone
	)
	set(__ONE_VALUE_ARGS
		OUTPUT_DIR # directory of the output library
	)
	set(__MULTI_VALUE_ARGS 
		COMPONENTS # all libraries/environments which will be connected to this exe.
		SOURCES
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	if(__ARGS_EXCLUDE_FROM_ALL)
		set(__EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
	else()
		unset(__EXCLUDE_FROM_ALL)
	endif()

	add_executable("${__NAME}" ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})

	string(REGEX REPLACE "-exe$" "" __EXE_NAME "${__NAME}")
	set_target_properties("${__NAME}" PROPERTIES 
		RUNTIME_OUTPUT_NAME "${EXTRA_SUFFIX}${__EXE_NAME}"
		COMPILE_PDB_NAME "${EXTRA_SUFFIX}${__EXE_NAME}"
	)

	if(NOT "${__ARGS_OUTPUT_DIR}" STREQUAL "")
		if(NOT IS_ABSOLUTE __ARGS_OUTPUT_DIR)
			join_paths(__ARGS_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}" "${__ARGS_OUTPUT_DIR}")
		endif()
	
		# generator expression $<0:> in the very end need for the multiconfigurational generators,
		# because multiconfigurational generators always append $<CONFIG> in the end of output path if path does not has any of generator expressions already
		set_target_properties("${__NAME}" PROPERTIES 
			RUNTIME_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>"
			COMPILE_PDB_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>" # just in case
		)
	endif()

	foreach(__SUB IN LISTS __ARGS_COMPONENTS)
		target_link_libraries("${__NAME}" PRIVATE "${__SUB}")
	endforeach()

endfunction()

function(add_env __NAME)
	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS
		COMPONENTS
		ENVS_CLONE
	)
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	add_library("${__NAME}" INTERFACE)

	foreach(__ENV IN LISTS __ARGS_ENVS_CLONE)
		clone_target_properties("${__ENV}" "${__NAME}"
			APPEND
			FROM INTERFACE 
			TO INTERFACE
			PROPERTIES 
				INCLUDE_DIRECTORIES 
				COMPILE_OPTIONS 
				COMPILE_DEFINITIONS
		)
	endforeach()

	foreach(__SUB IN LISTS __ARGS_COMPONENTS)
		target_link_libraries("${__NAME}" INTERFACE "${__SUB}")
	endforeach()

endfunction()

function(foreach_append_string __LIST_VAR __STRING)

	set(__INNER_LIST "")

	foreach(__ITEM IN LISTS "${__LIST_VAR}")

		list(APPEND __INNER_LIST "${__STRING}${__ITEM}")

	endforeach()

	set("${__LIST_VAR}" ${__INNER_LIST} PARENT_SCOPE)

endfunction()

function(extract_file_from_list __LIST_VAR __FILE)

	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS 
		RETURN # name of the variable to which extracted file will be returned.
	)
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(__ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}" ${ARGN})

	normilize_path(__FILE "${__FILE}")
	string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" __REGEX "${__FILE}")
	set(__REGEX "${__REGEX}$")

	set(__OUT_LIST "")
	set(__EXTRACTED_FILES "")

	foreach(__FILE_ITEM IN LISTS "${__LIST_VAR}")
		
		normilize_path(__NORMILIZED_FILE_ITEM "${__FILE_ITEM}")

		string(REGEX MATCH "${__REGEX}" __RESULT "${__NORMILIZED_FILE_ITEM}")

		if("${__RESULT}" STREQUAL "")
			list(APPEND __OUT_LIST "${__FILE_ITEM}")
		else()
			list(APPEND __EXTRACTED_FILES "${__FILE_ITEM}")
		endif()

	endforeach()

	set("${__LIST_VAR}" ${__OUT_LIST} PARENT_SCOPE)
	if(NOT "${__ARGS_RETURN}" STREQUAL "")
		set("${__ARGS_RETURN}" ${__EXTRACTED_FILES} PARENT_SCOPE)
	endif()

endfunction()