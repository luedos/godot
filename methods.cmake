
function(fix_if_expression __OUTPUT __EXPRESSION)

	string(REPLACE ";;" ";\"\";" __EXPRESSION "${__EXPRESSION}")
	if("${__EXPRESSION}" MATCHES "^;.+")
		set(__EXPRESSION "\"\"${__EXPRESSION}")
	endif()

	if("${__EXPRESSION}" MATCHES ".+;$")
		set(__EXPRESSION "${__EXPRESSION}\"\"")
	endif()

	set(${__OUTPUT} "${__EXPRESSION}" PARENT_SCOPE)

endfunction()

function(assert __MESSAGE)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(NOT (${__EXPRESSION}))

		message(FATAL_ERROR "${__MESSAGE}")

	endif()

endfunction()

function(assert_if_empty __ARG_NAME)

	assert("The value of \"${__ARG_NAME}\" is empty." 
		NOT "${${__ARG_NAME}}" STREQUAL ""
	)

endfunction()

function(inline_if __OUTPUT)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(${__EXPRESSION})
		set("${__OUTPUT}" true PARENT_SCOPE)
	else()
		set("${__OUTPUT}" false PARENT_SCOPE)
	endif()

endfunction()

function(ternary_if __OUTPUT __TRUE __FALSE)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(${__EXPRESSION})
		set("${__OUTPUT}" ${__TRUE} PARENT_SCOPE)
	else()
		set("${__OUTPUT}" ${__FALSE} PARENT_SCOPE)
	endif()

endfunction()

function(check_for_gen_expr __OUTPUT __STRING)

	string(GENEX_STRIP "${__STRING}" __STRIPED_STRING)

	if(__STRIPED_STRING STREQUAL __STRING)
		# no generator expression was stripped in the first place
		set("${__OUTPUT}" false PARENT_SCOPE)
	else()
		# something was stripped, so generator expression existed
		set("${__OUTPUT}" true PARENT_SCOPE)
	endif()

endfunction()

function(extract_items_with_gen_expr __INPUT_LIST __OUTPUT_CLEAN_LIST __OUTPUT_GEN_EXPR_LIST)

	set(__LOCAL_CLEAN_LIST "")
	set(__LOCAL_GEN_EXPR_LIST "")

	foreach(__ITEM IN LISTS ${__INPUT_LIST})
		
		check_for_gen_expr(__HAS_GEN_EXPR "${__ITEM}")
		if(__HAS_GEN_EXPR)
			list(APPEND __LOCAL_GEN_EXPR_LIST "${__ITEM}")
		else()
			list(APPEND __LOCAL_CLEAN_LIST "${__ITEM}")
		endif()

	endforeach()

	set("${__OUTPUT_CLEAN_LIST}" "${__LOCAL_CLEAN_LIST}" PARENT_SCOPE)
	set("${__OUTPUT_GEN_EXPR_LIST}" "${__LOCAL_GEN_EXPR_LIST}" PARENT_SCOPE)

endfunction()

function(set_string_option __NAME __VALUE)
	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE ENUM)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}")

	set("${__NAME}" "${__VALUE}" CACHE STRING "${__ARGS_DESCRIPTION}")

	if (__ARGS_ENUM)
		set_property(CACHE "${__NAME}" PROPERTY STRINGS ${__ARGS_ENUM})
	endif()
endfunction()

function(set_path_option __NAME __VALUE)
	set(__OPTIONS FILE)
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}")
	if (__ARGS_FILE)
		set("${__NAME}" "${__VALUE}" CACHE FILEPATH "${__ARGS_DESCRIPTION}")
	else()
		set("${__NAME}" "${__VALUE}" CACHE PATH "${__ARGS_DESCRIPTION}")
	endif()
endfunction()

function(set_bool_option __NAME __VALUE)
	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}")

	set("${__NAME}" "${__VALUE}" CACHE BOOL "${__ARGS_DESCRIPTION}")

endfunction()

function(normilize_path __OUTPUT __PATH)
	set(__OPTIONS_ARGS 
		ABSOLUTE # Force path to be absolute
	)

	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	# normilize only slashes
	file(TO_CMAKE_PATH "${__PATH}" __LOCAL_OUTPUT)

	if (IS_ABSOLUTE "${__LOCAL_OUTPUT}")
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
		if(IS_ABSOLUTE "${__SECOND_PATH_INNER}")
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

function(target_generated_sources __TARGET __SCOPE)

	assert_if_empty(__TARGET)
	assert_if_empty(__SCOPE)

	if(NOT "${ARGN}" STREQUAL "")
		target_sources("${__TARGET}" "${__SCOPE}" ${ARGN})
		set_source_files_properties(${ARGN}
			TARGET_DIRECTORY "${__TARGET}"
			PROPERTIES GENERATED TRUE
		)
	endif()

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
	if (IS_DIRECTORY "${__PATH}" AND EXISTS "${__PATH}/CMakeLists.txt")
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
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

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

function(parse_to_python_var __OUTPUT __TYPE __VAR)

	set(__OPTIONS_ARGS 
		""
	)
	set(__ONE_VALUE_ARGS 
		ARRAY_SEPARATOR
	)
	set(__MULTI_VALUE_ARGS 
		""
	)
	cmake_parse_arguments(PARSE_ARGV 3 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if("${__ARGS_ARRAY_SEPARATOR}" STREQUAL "")
		set(__ARGS_ARRAY_SEPARATOR ", ")
	endif()

	unset(__VAR_PREFIX)

	if(__VAR MATCHES "^[A-Za-z0-9_]+=.+")

		string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__VAR}")
		string(REGEX REPLACE "^[A-Za-z0-9_]+=(.+)" "\\1" __VAR "${__VAR}")
		set(__VAR_PREFIX "${__VAR_NAME}=")

	endif()

	if(__TYPE MATCHES ".+_ENV_VAR$")

		set(__VAR_VALUE "$ENV{${__VAR}}")

	elseif(__TYPE MATCHES ".+_CACHE_VAR$")

		set(__VAR_VALUE "$CACHE{${__VAR}}")

	elseif(__TYPE MATCHES ".+_VAR")

		set(__VAR_VALUE "${${__VAR}}")

	elseif(__TYPE MATCHES ".+_VAL")

		set(__VAR_VALUE "${__VAR}")

	else()
		message(WARNING "Incorrect variable type was provided to the python arguments parser (${__TYPE})")
		set("${__OUTPUT}" "" PARENT_SCOPE)
		return()
	endif()

	if(__TYPE MATCHES "^STR_.+")
		set("${__OUTPUT}" "${__VAR_PREFIX}'${__VAR_VALUE}'" PARENT_SCOPE)
	elseif(__TYPE MATCHES "^RAW_.+")
		set("${__OUTPUT}" "${__VAR_PREFIX}${__VAR_VALUE}" PARENT_SCOPE)
	elseif(__TYPE MATCHES "^BOOL_.*VAR$") # only var for bool
		if(__VAR_VALUE)
			set("${__OUTPUT}" "${__VAR_PREFIX}True" PARENT_SCOPE)
		else()
			set("${__OUTPUT}" "${__VAR_PREFIX}False" PARENT_SCOPE)
		endif()
	elseif(__TYPE MATCHES "^ARR_.*VAR$") # only var for arr

		if("${__VAR_VALUE}" STREQUAL "")
			set(__VAR_VALUE "[]")
		else()
			list(JOIN __VAR_VALUE "'${__ARGS_ARRAY_SEPARATOR}'" __VAR_VALUE)
			set(__VAR_VALUE "['${__VAR_VALUE}']")
		endif()

		set("${__OUTPUT}" "${__VAR_PREFIX}${__VAR_VALUE}" PARENT_SCOPE)

	else()
		message(WARNING "Incorrect variable type was provided to the python arguments parser (${__TYPE})")
		set("${__OUTPUT}" "" PARENT_SCOPE)			
	endif()

endfunction()

function(parse_to_python_map __OUTPUT __INPUT_TYPE)
	
	if(NOT __INPUT_TYPE MATCHES "(FROM_ARGS|FROM_LISTS)")
		message(FATAL_ERROR "Incorrect input type for parse_to_python_map (${__INPUT_TYPE}), must be FROM_ITEMS|FROM_LISTS.")
	endif()

	if(__INPUT_TYPE STREQUAL "FROM_ARGS")
		set(__INPUT_LISTS ARGN)
	else()
		set(__INPUT_LISTS ${ARGN})
	endif()

	unset(__ARG_TYPE)
	unset(__ARG_KEY)
	set(__FIRST true)

	set(__PYTHON_MAP "{")

	foreach(__ARG IN LISTS ${__INPUT_LISTS})

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

		parse_to_python_var(__ARG_VALUE "${__ARG_TYPE}" "${__ARG}")

		set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':${__ARG_VALUE}")

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
function(parse_to_python_function_args __OUTPUT __INPUT_TYPE)

	if(NOT __INPUT_TYPE MATCHES "(FROM_ARGS|FROM_LISTS)")
		message(FATAL_ERROR "Incorrect input type for parse_to_python_function_args (${__INPUT_TYPE}), must be FROM_ITEMS|FROM_LISTS.")
	endif()

	if(__INPUT_TYPE STREQUAL "FROM_ARGS")
		set(__INPUT_LISTS ARGN)
	else()
		set(__INPUT_LISTS ${ARGN})
	endif()

	set(__PYTHON_ARGS "")
	unset(__ARG_TYPE)
	set(__FIRST TRUE)

	foreach(__ITEM IN LISTS ${__INPUT_LISTS})
		
		if(NOT DEFINED __ARG_TYPE)
			set(__ARG_TYPE "${__ITEM}")
			continue()
		endif()

		if(__FIRST)
			set(__FIRST FALSE)
		else()
			set(__PYTHON_ARGS "${__PYTHON_ARGS}, ")
		endif()

		parse_to_python_var(__ARG "${__ARG_TYPE}" "${__ITEM}")

		set(__PYTHON_ARGS "${__PYTHON_ARGS}${__ARG}")
		
		unset(__ARG_TYPE)

	endforeach()

	set("${__OUTPUT}" "${__PYTHON_ARGS}" PARENT_SCOPE)

endfunction()

function(compose_python_method_call __OUTPUT __FUNCTION_NAME)
	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS 
		FROM_MODULE # module which need to be imported, and from which function must be called 
	)
	set(__MULTI_VALUE_ARGS 
		PYTHON_ARGS # works by the rules of the parse_to_python_function_args_from_lists
	)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

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

	parse_to_python_function_args(__FUNCTION_ARGS FROM_LISTS __ARGS_PYTHON_ARGS)

	set(__FUNCTION_CALL "${__FUNCTION_CALL}${__FUNCTION_NAME}(${__FUNCTION_ARGS})")

	set("${__OUTPUT}" "${__FUNCTION_CALL}" PARENT_SCOPE)

endfunction()

function(add_python_generator_command __MODULE __FUNCTION)

	assert_if_empty(__FUNCTION)

	set(__OPTIONS_ARGS 
		SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS # silence warning if byproducts has gen expr in them and cmake version is less then 3.20.0
		USE_PYTHON3 # explicitly tell to use python3
		BUILTIN_MODULE # by default add_python_generator_command adds file ${__MODULE}.py as a dependency. If this option is turned on, this behavior will be omitted.
	)
	set(__ONE_VALUE_ARGS 
		MODULE_DIR # relative directory of the module
		WORKING_DIR # working directory of the command. If none, then used CMAKE_CURRENT_SOURCE_DIR
		BY_FILE # generate command as python file in binary dir. This is usefull if command is really big
		SOURCES_DEPENDENT_TARGET # optionally add target files as sources for specific target 
		GEN_EXPR_DEPENDENT
		CREATE_CUSTOM_TARGET
	)
	set(__MULTI_VALUE_ARGS 
		SOURCE_FILES # Source files to be used
		TARGET_FILES # Target files expected to be produced by this comand
		SYMBOLIC_TARGETS # The posibility to add some target sources with SYMBOLIC property turned on
		SYMBOLIC_SOURCES # The posibility to add some sources with SYMBOLIC property turned on
		CUSTOM_VARS # some custom variables which will be appended in front of the command before actually executing command itself (could be usefull if you want to use BY_FILE option, but some things in your output is gen expr dependent)
		PYTHON_ARGS # works by the rules of the parse_to_python_args
		APPEND_SYS_PATH # it is possible to append some sys paths before calling the method
	)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.${__MODULE}")
	endif()

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

	# if sources files has gen expr, we will put them into seperate variable infront of the command
	check_for_gen_expr(__SOURCE_FILES_HAS_GEN_EXPR "${__ARGS_SOURCE_FILES}")
	if(__SOURCE_FILES_HAS_GEN_EXPR)

		list(PREPEND __ARGS_CUSTOM_VARS ARR_VAR "var_source_files=__ARGS_SOURCE_FILES")
		list(PREPEND __ARGS_PYTHON_ARGS RAW_VAL "source=var_source_files")

	else()

		list(PREPEND __ARGS_PYTHON_ARGS ARR_VAR "source=__ARGS_SOURCE_FILES")

	endif()

	# if target files has gen expr, we will put them into seperate variable infront of the command
	check_for_gen_expr(__TARGET_FILES_HAS_GEN_EXPR "${__ARGS_TARGET_FILES}")
	if(__TARGET_FILES_HAS_GEN_EXPR)

		list(PREPEND __ARGS_CUSTOM_VARS ARR_VAR "var_target_files=__ARGS_TARGET_FILES")
		list(PREPEND __ARGS_PYTHON_ARGS RAW_VAL "target=var_target_files")

	else()

		list(PREPEND __ARGS_PYTHON_ARGS ARR_VAR "target=__ARGS_TARGET_FILES")

	endif()

	#===================== Parsing custom variables =======================
	set(__CUSTOM_VAR_INIT "")
	set(__CUSTOM_VARS_LIST "")
	unset(__VAR_TYPE)
	set(__VAR_ID "0")
	foreach(__CUSTOM_VAR IN LISTS __ARGS_CUSTOM_VARS)
		
		if(NOT DEFINED __VAR_TYPE)
			set(__VAR_TYPE "${__CUSTOM_VAR}")
			continue()
		endif()

		if(NOT __CUSTOM_VAR MATCHES "^[A-Za-z0-9_]+=.+")
			message(WARNING "Custom variable number ${__VAR_ID} of the command does't have a name (${__CUSTOM_VAR}), the name for this variable will be 'var${__VAR_ID}'")
			set(__CUSTOM_VAR "var${__VAR_ID}=${__CUSTOM_VAR}")
		endif()

		string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__CUSTOM_VAR}")
		list(APPEND __CUSTOM_VARS_LIST "${__VAR_NAME}")

		parse_to_python_var(__CUSTOM_VAR_VALUE "${__VAR_TYPE}" "${__CUSTOM_VAR}")
		set(__CUSTOM_VAR_INIT "${__CUSTOM_VAR_INIT}${__CUSTOM_VAR_VALUE}; ")
		unset(__VAR_TYPE)
	endforeach()

	#===================== Parsing actual command =======================

	if(NOT "${__ARGS_BY_FILE}" STREQUAL "")

		#===================== Parsing script file, and arguments for the command call =======================
		list(JOIN __CUSTOM_VARS_LIST ", " __CASTOM_VAR_ARGS_LIST)

		set(__PYTHON_FILE_CODE "def run(${__CASTOM_VAR_ARGS_LIST}):")

		set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}\n\timport os\n\tos.chdir('${__ARGS_WORKING_DIR}')\n\t")

		if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")
			set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}import sys\n\tsys.path = sys.path + str('${__ARGS_APPEND_SYS_PATH}').split(';')\n\n\t")
		endif()

		set(__ARG_ID "0")
		set(__METHOD_CALL_ARGS "")
		unset(__VAR_TYPE)
		foreach(__VAR IN LISTS __ARGS_PYTHON_ARGS)

			if(NOT DEFINED __VAR_TYPE)
				set(__VAR_TYPE "${__VAR}")
				continue()
			endif()

			if(__VAR MATCHES "^[A-Za-z0-9_]+=.+")

				string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__VAR}")
				string(REGEX REPLACE "^[A-Za-z0-9_]+=(.+)" "\\1" __VAR "${__VAR}")

				list(APPEND __METHOD_CALL_ARGS RAW_VAL "${__VAR_NAME}=arg${__ARG_ID}")
				set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}# ${__VAR_NAME} function argument\n\t")

			else()

				list(APPEND __METHOD_CALL_ARGS RAW_VAL "arg${__ARG_ID}")

			endif()

			parse_to_python_var(__VAR_VALUE "${__VAR_TYPE}" "${__VAR}" ARRAY_SEPARATOR ",\n\t")
			set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}arg${__ARG_ID}=${__VAR_VALUE}\n\t")
			
			math(EXPR __ARG_ID "${__ARG_ID} + 1")

			unset(__VAR_TYPE)

		endforeach()

		compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
			FROM_MODULE "${__MODULE}"
			PYTHON_ARGS ${__METHOD_CALL_ARGS}
		)

		set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}${__METHOD_CALL}\n\t")

		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_BINARY_DIR}/generators")

		set(__GENERATOR_FILE "${__ARGS_WORKING_DIR}/${__ARGS_BY_FILE}_generator.py")
		list(APPEND __DEPENDS "${__GENERATOR_FILE}")
		file(WRITE "${__GENERATOR_FILE}" "${__PYTHON_FILE_CODE}")
		set(__COMMAND "${__CUSTOM_VAR_INIT}import ${__ARGS_BY_FILE}_generator;${__ARGS_BY_FILE}_generator.run(${__CASTOM_VAR_ARGS_LIST})")

	else()

		#===================== Parsing whole command =======================

		compose_python_method_call(__COMMAND "${__FUNCTION}" 
			FROM_MODULE "${__MODULE}"
			PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
		)

		if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")

			set(__COMMAND "import sys; sys.path = sys.path + str('${__ARGS_APPEND_SYS_PATH}').split(';'); ${__CUSTOM_VAR_INIT}${__COMMAND}")

		endif()

	endif()

	if(NOT "${__ARGS_GEN_EXPR_DEPENDENT}" STREQUAL "")
		set(__COMMAND "$<$<NOT:${__ARGS_GEN_EXPR_DEPENDENT}>:exit(0);>${__COMMAND}")
	endif()

	extract_items_with_gen_expr(__ARGS_TARGET_FILES __CLEAN_TARGETS __GEN_EXPR_TARGETS)
	# we are not using gen expr files if we are less then 3.20.0 because BYPRODUCTS in custom target and OUTPUT in custom command can use gen expr only after 3.20.0
	ternary_if(__TARGET_FILES_LIST_NAME
		"__ARGS_TARGET_FILES"
		"__CLEAN_TARGETS"
		"${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.20.0" 
	)

	foreach(__SYMBOLIC_SRC IN LISTS __ARGS_SYMBOLIC_TARGETS)
		set_property(SOURCE "${__SYMBOLIC_SRC}"	PROPERTY SYMBOLIC TRUE)
	endforeach()

	if(VERBOSE)
		message(STATUS "========== Adding python generator command =========")
		message(STATUS "Target files: ${__ARGS_TARGET_FILES}")
		message(STATUS "Source files: ${__ARGS_SOURCE_FILES}")
		message(STATUS "Working dir: ${__ARGS_WORKING_DIR}")
		message(STATUS "Depends on: ${__DEPENDS}")
		message(STATUS "Command: ${__COMMAND}")
		message(STATUS "====================================================")
	endif()

	if("${__ARGS_CREATE_CUSTOM_TARGET}" STREQUAL "")
		if(NOT __ARGS_SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS 
			AND CMAKE_VERSION VERSION_LESS "3.20.0" 
			AND NOT "${__GEN_EXPR_TARGETS}" STREQUAL "")

			list(JOIN __GEN_EXPR_TARGETS "\n\t" __GEN_EXPR_TARGETS_FORMATED)
			message(WARNING "Custom command OUTPUT files supports generator expression only since 3.20.0 version. Next files were cut off from OUTPUTs of the custom command:\n\t${__GEN_EXPR_TARGETS_FORMATED}")
		endif()

		if("${${__TARGET_FILES_LIST_NAME}}" STREQUAL "" AND "${__ARGS_SYMBOLIC_TARGETS}" STREQUAL "")
			message(FATAL_ERROR "No output files were provided to the custom target.")
		endif()

		add_custom_command(
			OUTPUT ${${__TARGET_FILES_LIST_NAME}} ${__ARGS_SYMBOLIC_TARGETS}
			COMMAND "${__PYTHON}" "-c" "${__COMMAND}"
			DEPENDS ${__DEPENDS} ${__ARGS_SYMBOLIC_SOURCES}
			WORKING_DIRECTORY "${__ARGS_WORKING_DIR}"
			COMMENT "Executing python method: ${__FUNCTION}"
		)

	else()
		if(NOT __ARGS_SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS 
			AND CMAKE_VERSION VERSION_LESS "3.20.0" 
			AND NOT "${__GEN_EXPR_TARGETS}" STREQUAL "")

			list(JOIN __GEN_EXPR_TARGETS "\n\t" __GEN_EXPR_TARGETS_FORMATED)
			message(WARNING "Custom target BYPRODUCTS files supports generator expression only since 3.20.0 version. Next files were cut off from BYPRODUCTs of the custom target:\n\t${__GEN_EXPR_TARGETS_FORMATED}")
		endif()

		add_custom_target("${__ARGS_CREATE_CUSTOM_TARGET}"
			COMMAND "${__PYTHON}" "-c" "${__COMMAND}"
			DEPENDS ${__DEPENDS} ${__ARGS_SYMBOLIC_SOURCES}
			BYPRODUCTS ${${__TARGET_FILES_LIST_NAME}} ${__ARGS_SYMBOLIC_TARGETS}
			WORKING_DIRECTORY "${__ARGS_WORKING_DIR}"
			COMMENT "Executing python method: ${__FUNCTION}"
		)

	endif()

	if(NOT "${__ARGS_SOURCES_DEPENDENT_TARGET}" STREQUAL "" AND NOT "${__ARGS_TARGET_FILES}" STREQUAL "")

		target_sources("${__ARGS_SOURCES_DEPENDENT_TARGET}" PRIVATE
			${__ARGS_TARGET_FILES}
		)

		set_source_files_properties(${__ARGS_TARGET_FILES}
			TARGET_DIRECTORY "${__ARGS_SOURCES_DEPENDENT_TARGET}"
			PROPERTIES GENERATED TRUE
		)

	endif()

endfunction()

function(execute_python_method __MODULE __FUNCTION)
	set(__OPTIONS_ARGS 
		USE_PYTHON3 # explicitly tell to use python3
		ECHO_OUTPUT_VARIABLE
		ECHO_ERROR_VARIABLE
		OPTIONAL # do we need to throw an error, if this command fails? If no, specify this option. 
		VERBOSE # do we need to output to the console that this method being executed (mostly for debug purpuses)
	)
	set(__ONE_VALUE_ARGS 
		MODULE_DIR # relative directory of the module
		WORKING_DIR # working directory of the command. If none, then used CMAKE_CURRENT_SOURCE_DIR
		OUTPUT_VARIABLE
		ERROR_VARIABLE
	)
	set(__MULTI_VALUE_ARGS 
		PYTHON_ARGS # works by the rules of the parse_to_python_args
		APPEND_SYS_PATH # it is possible to append some sys paths before calling the method
	)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.${__MODULE}")
	endif()

	compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
		FROM_MODULE "${__MODULE}"
		PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
	)

	if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")

		set(__METHOD_CALL "import sys; sys.path = sys.path + str('${__ARGS_APPEND_SYS_PATH}').split(';'); ${__METHOD_CALL}")

	endif()

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
		list(APPEND __ADDITIONAL_ARGS COMMAND_ERROR_IS_FATAL ANY)
	endif()

	if(__ARGS_VERBOSE)

		message(STATUS "============== Executing python method =============")
		message(STATUS "Working dir: ${__ARGS_WORKING_DIR}")
		message(STATUS "Command: ${__METHOD_CALL}")
		message(STATUS "====================================================")

	endif()

	execute_process(
		COMMAND "${__PYTHON}" "-c" "${__METHOD_CALL}"
		WORKING_DIRECTORY "${__ARGS_WORKING_DIR}"
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
		OBJECT # is library need to be object one (static by default)
		EXCLUDE_FROM_ALL # works only with standalone
	)
	set(__ONE_VALUE_ARGS
		PARENT_LIB # lib this library will link to
		PARENT_ENV # other possibility is to link agains environment
		OUTPUT_DIR # directory of the output library
		OUTPUT_NAME # force different output name (by default is name of target without -lib prefix and with added EXTRA_SUFFIX to the end of it)
	)
	set(__MULTI_VALUE_ARGS 
		COMPONENTS # all libraries/environments which will be connected to this library.
		ENVS_CLONE
		LIBS_CLONE
		SOURCES
	)
	cmake_parse_arguments(PARSE_ARGV 1 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if(__ARGS_EXCLUDE_FROM_ALL)
		set(__EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
	else()
		unset(__EXCLUDE_FROM_ALL)
	endif()

	if(NOT __ARGS_OBJECT)
		add_library("${__NAME}" STATIC ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})

		# if it's not standalone (a.k.a. STATIC) where is no need for the setiing of the output parameters
		
		if ("${__ARGS_OUTPUT_NAME}" STREQUAL "")
			# seting output name
			string(REGEX REPLACE "-lib$" "" __LIB_NAME "${__NAME}")
			set_target_properties("${__NAME}" PROPERTIES 
				OUTPUT_NAME "${__LIB_NAME}${EXTRA_SUFFIX}"
			)
		else()
			set_target_properties("${__NAME}" PROPERTIES 
				OUTPUT_NAME "${__ARGS_OUTPUT_NAME}"
			)
		endif()

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
	cmake_parse_arguments(PARSE_ARGV 1 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if(__ARGS_EXCLUDE_FROM_ALL)
		set(__EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
	else()
		unset(__EXCLUDE_FROM_ALL)
	endif()

	add_executable("${__NAME}" ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})

	string(REGEX REPLACE "-exe$" "" __EXE_NAME "${__NAME}")
	set_target_properties("${__NAME}" PROPERTIES 
		OUTPUT_NAME "${__EXE_NAME}${EXTRA_SUFFIX}"
	)

	if(NOT "${__ARGS_OUTPUT_DIR}" STREQUAL "")
		if(NOT IS_ABSOLUTE "${__ARGS_OUTPUT_DIR}")
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
	cmake_parse_arguments(PARSE_ARGV 1 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

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
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

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