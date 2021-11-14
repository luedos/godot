# Assers if any variable passed by the name is empty.
function(assert_if_empty)

	foreach(__VAR_NAME IN LISTS ARGN)
		if("${${__VAR_NAME}}" STREQUAL "")
			message(FATAL_ERROR "The value of \"${__VAR_NAME}\" is empty." )
		endif()
	endforeach()	

endfunction()

# Sets variable into parent scope if varaible name is not empty
macro(optionally_return __OUTPUT_NAME)

	if(NOT "${__OUTPUT_NAME}" STREQUAL "")
		set("${__OUTPUT_NAME}" "${ARGN}" PARENT_SCOPE)
	endif()

endmacro()

# Basically just adds empty quotes between semicolums, 
# so then the expression will be expanded into the method call (or if statement),
# empty elements will not disappear.
function(fix_if_expression __OUTPUT __EXPRESSION)

	assert_if_empty(__OUTPUT)

	string(REPLACE ";;" ";\"\";" __EXPRESSION "${__EXPRESSION}")
	if("${__EXPRESSION}" MATCHES "^;.+")
		set(__EXPRESSION "\"\"${__EXPRESSION}")
	endif()

	if("${__EXPRESSION}" MATCHES ".+;$")
		set(__EXPRESSION "${__EXPRESSION}\"\"")
	endif()

	set(${__OUTPUT} "${__EXPRESSION}" PARENT_SCOPE)

endfunction()

# Prints message with FATAL_ERROR flag then if statement yields false.
# An if statement passed as ARGN.
function(assert __MESSAGE)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(NOT (${__EXPRESSION}))

		message(FATAL_ERROR "${__MESSAGE}")

	endif()

endfunction()

# Writes result of the if statement (which passed as ARGN) to the output variable (in format true/false).
function(inline_if __OUTPUT)

	assert_if_empty(__OUTPUT)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(${__EXPRESSION})
		set("${__OUTPUT}" true PARENT_SCOPE)
	else()
		set("${__OUTPUT}" false PARENT_SCOPE)
	endif()

endfunction()

# Writes '__TRUE' argument, or '__FALSE' argument into output variable,
# based on an if statement passed as ARGN.
function(ternary_if __OUTPUT __TRUE __FALSE)

	assert_if_empty(__OUTPUT)

	fix_if_expression(__EXPRESSION "${ARGN}")

	if(${__EXPRESSION})
		set("${__OUTPUT}" ${__TRUE} PARENT_SCOPE)
	else()
		set("${__OUTPUT}" ${__FALSE} PARENT_SCOPE)
	endif()

endfunction()

# Returns true/false if '__STRING' argument has generator expression in it.
function(check_for_gen_expr __OUTPUT __STRING)

	assert_if_empty(__OUTPUT)

	string(GENEX_STRIP "${__STRING}" __STRIPED_STRING)

	if(__STRIPED_STRING STREQUAL __STRING)
		# no generator expression was stripped in the first place
		set("${__OUTPUT}" false PARENT_SCOPE)
	else()
		# something was stripped, so generator expression existed
		set("${__OUTPUT}" true PARENT_SCOPE)
	endif()

endfunction()

# Extracts all items with generator expressions from the '__INPUT_LIST' list.
# Extracted items placed into '__OUTPUT_GEN_EXPR_LIST' list.
# Clean list, without generator expression items, placed into '__OUTPUT_CLEAN_LIST' list.
function(extract_items_with_gen_expr __INPUT_LIST __OUTPUT_CLEAN_LIST __OUTPUT_GEN_EXPR_LIST)

	assert_if_empty(__INPUT_LIST)

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

	optionally_return("${__OUTPUT_CLEAN_LIST}" "${__LOCAL_CLEAN_LIST}")
	optionally_return("${__OUTPUT_GEN_EXPR_LIST}" "${__LOCAL_GEN_EXPR_LIST}")

endfunction()

# Sets cache varaible as string (no force). 
# Additional argument 'ENUM' can be passed. Strings passed with it will be seted as STRINGS property of the cache variable.
# Also description can be passed as 'DESCRIPTION' argument.
function(set_string_option __NAME __VALUE)

	assert_if_empty(__NAME)

	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE ENUM)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}")

	set("${__NAME}" "${__VALUE}" CACHE STRING "${__ARGS_DESCRIPTION}")

	if (__ARGS_ENUM)
		set_property(CACHE "${__NAME}" PROPERTY STRINGS ${__ARGS_ENUM})
	endif()
endfunction()

# Sets cache variable as path (no force).
# If 'FILE' argument is passed, the actual type of the cache variable will be FILEPATH. Otherwise - PATH.
# Also description can be passed as 'DESCRIPTION' argument.
function(set_path_option __NAME __VALUE)
	
	assert_if_empty(__NAME)

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

# Sets cache variable as bool (no force).
# Description can be passed as 'DESCRIPTION' argument.
function(set_bool_option __NAME __VALUE)
	
	assert_if_empty(__NAME)
	
	set(__OPTIONS "")
	set(__VALUES DESCRIPTION)
	set(__MULTIVALUE "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS}" "${__VALUES}" "${__MULTIVALUE}")

	set("${__NAME}" "${__VALUE}" CACHE BOOL "${__ARGS_DESCRIPTION}")

endfunction()

# Normilizes path, or rather:
# - normalazes all slashes into a cmake style
# - resolves all possible back dirs (../). As example:
#   - 'some/../folder/bwn' -> 'folder/bwn'
#   - 'some/../../../folder/bwn' -> '../../folder/bwn'
# - also can force path to be absolute with 'ABSOLUTE' option. If path is not yet absulut, it will be counted as relative to the 'CMAKE_CURRENT_SOURCE_DIR'
# - all trailed slashes is removed from the end of the path ('some/folder/' -> 'some/folder')
function(normilize_path __OUTPUT __PATH)
	
	assert_if_empty(__OUTPUT)
	
	set(__OPTIONS_ARGS 
		ABSOLUTE # Force path to be absolute
	)
	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	# normilize only slashes
	file(TO_CMAKE_PATH "${__PATH}" __LOCAL_OUTPUT)

	# this will be handy later
	if (IS_ABSOLUTE "${__LOCAL_OUTPUT}")
		set(__ARGS_ABSOLUTE true)
	endif()

	# This is defult prefix to use. 
	set(__PATH_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}")

	# lots of fuckery here, better not look
	# ye, ye, I know, python is better for that (python at least has library for working with the paths).
	# So basically what is happening: 
	# Because the only thing in cmake (at 3.19), which can actually normilize our path is file(REAL_PATH), and because it always returns absolute path, 
	# if our path will have some back dirs which goes beond BASE_DIRECTORY of the file(REAL_PATH) (like 'C:/some/root/../../../../../../rel/path'),
	# this function will return path cutted off by the system root dir (example above will became 'C:/rel/path'), 
	# and all back dirs will be lost if we didn't wanted to have absolute path.
	# Solution: if we passed relative path, and want relative path back, we will simply append to __PATH_PREFIX as much dirs as there back dirs,
	# so the file(REAL_PATH) will never have the chance to go beond system root dir. 
	# In the end we will use file(RELATIVE_PATH) with our prefix with all appended fals dirs as base directory,
	# so all neseccery back dirs will be preserved..
	if (NOT __ARGS_ABSOLUTE)
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

# Joins two or more paths, and writes the result into output variable. Returned path is normilized. 
# All paths except the first can't be absolute.
function(join_paths __OUTPUT __FIRST_PATH __SECOND_PATH)
	
	assert_if_empty(__OUTPUT)

	# Ok, so here is the problem:
	# If any path, which has ';' in it (like "some/ran;dom/path"), will be passed through ARGN,
	# it will be interpreted as two paths instead of one (like "some/ran" and "dom/path").
	# This is due to how CMake works with lists (each list is basically the string with ';' as a devider).
	# We can partially fix that if we will enforce 2 arguments __FIRST_PATH __SECOND_PATH instead of always relying on ARGN.
	# Because 99% of the time, this function will join only 2 paths, this will work.
	# Another problem is if name in some path will start from ';' and you are using windows (like so "some\;name").
	# This will be interpreted like explicit escaping of ';', and final path will be "some;name".
	# So basically, don't use ';' in your paths (please).

	# This function expects the first path to not have slash in the end.
	# Also we are not normilizing output path as a whole yet, only second path in an isolation.
	function(__join_paths __OUTPUT __FIRST_PATH_INNER __SECOND_PATH_INNER)
		if(IS_ABSOLUTE "${__SECOND_PATH_INNER}")
			message(FATAL_ERROR "Can't join absolute path \"${__SECOND_PATH_INNER}\".")
		endif()
		
		normilize_path(__SECOND_PATH_INNER "${__SECOND_PATH_INNER}")

		if (NOT "${__SECOND_PATH_INNER}" STREQUAL "")
			set(__FIRST_PATH_INNER "${__FIRST_PATH_INNER}/${__SECOND_PATH_INNER}")
		endif()

		set(${__OUTPUT} "${__FIRST_PATH_INNER}" PARENT_SCOPE)
	endfunction()

	# normilize first path, so no trailing slashes in the end.
	normilize_path(__JOINED_PATH "${__FIRST_PATH}")
	__join_paths(__JOINED_PATH "${__JOINED_PATH}" "${__SECOND_PATH}")

	foreach(__PATH IN LISTS ARGN)
		__join_paths(__JOINED_PATH "${__JOINED_PATH}" "${__PATH}")
	endforeach()

	# Only now normilizing all joind paths as a whole.
	normilize_path(__JOINED_PATH "${__JOINED_PATH}")
	set(${__OUTPUT} "${__JOINED_PATH}" PARENT_SCOPE)
endfunction()

# Globs files and adds them to the target as sources.
# The signature is very simular to the regular target_sources, but here you must pass glob expression instead of actual sources. 
# Also for, simplicity sake, only one glob expression with one scope can be provided.
function(target_glob_sources __TARGET __SCOPE __GLOB_EXPR)

	assert_if_empty(__TARGET __SCOPE)

	file(GLOB __SOURCES LIST_DIRECTORIES false "${__GLOB_EXPR}")
	target_sources("${__TARGET}" "${__SCOPE}" ${__SOURCES})
endfunction()

# Basically the regular target_sources, but for all passed sources is also seted GENERATED property. 
# Also for, simplicity sake, only one pack of targets with one scope can be provided.
function(target_generated_sources __TARGET __SCOPE)

	assert_if_empty(__TARGET __SCOPE)

	if(NOT "${ARGN}" STREQUAL "")
		target_sources("${__TARGET}" "${__SCOPE}" ${ARGN})
		set_source_files_properties(${ARGN}
			TARGET_DIRECTORY "${__TARGET}"
			PROPERTIES GENERATED TRUE
		)
	endif()

endfunction()

# Adds sources to the target prepended with some path. 
# Usefull for all those thirdparty sources in the modules..
function(target_sources_from_path __TARGET __SCOPE __PATH)

	assert_if_empty(__TARGET __SCOPE)

	set(__SOURCES_LIST "")

	foreach(__SRC IN LISTS ARGN)
		
		join_paths(__SRC "${__PATH}" "${__SRC}")
		list(APPEND __SOURCES_LIST "${__SRC}")

	endforeach()

	target_sources("${__TARGET}" "${__SCOPE}" ${__SOURCES_LIST})

endfunction()

# Returns name of the top directory. 
# Basically the get_filename_component, but will be able to resolve path which ends with slash.
function(get_top_directory __PATH __OUTPUT)

	assert_if_empty(__OUTPUT)

	# local variables
	unset(__FOLDER_NAME)

	# if path ends with slash, get_filename_component will not work
	normilize_path(__PATH "${__PATH}")

	get_filename_component(__FOLDER_NAME "${__PATH}" NAME)

	set(${__OUTPUT} "${__FOLDER_NAME}" PARENT_SCOPE)
endfunction()

# Returns true if module can be considered as module.
function(is_module __PATH __OUTPUT)

	assert_if_empty(__OUTPUT)

	if (IS_DIRECTORY "${__PATH}" AND EXISTS "${__PATH}/CMakeLists.txt")
		set(${__OUTPUT} true PARENT_SCOPE)
	else()
		set(${__OUTPUT} false PARENT_SCOPE)
	endif()
endfunction()

# Appends all paths from base directories passed through ARGN if they are modules.
# Important note which you can forget. This function requere not the actual models dirs, but the parent dirs for module dirs:
# input dir: some/dir
# modules dirs: 
#   - some/dir/module1
#   - some/dir/module2
#   - ...
function(get_modules_paths __OUTPUT)

	assert_if_empty(__OUTPUT)

	# local variable
	unset(__MODULE_VALID)
	unset(__MODULES_DIRS)
	unset(__PARENT_GLOB)
	unset(__PATH_REGEX_MATCH)
	unset(__RET_LIST)

	foreach(__PARENT_DIR IN LISTS ARGN)
		# we need normilized absolute directory  
		if(NOT IS_ABSOLUTE __PARENT_DIR)
			join_paths(__PARENT_DIR "${GODOT_SOURCE_DIR}" "${__PARENT_DIR}")
		else()
			normilize_path(__PARENT_DIR "${__PARENT_DIR}")
		endif()

		# because path was normilized, we can safely just add slash in the end
		set(__PARENT_DIR "${__PARENT_DIR}/*")
		file(GLOB __MODULES_DIRS LIST_DIRECTORIES true "${__PARENT_DIR}")

		foreach(__DIR IN LISTS __MODULES_DIRS)

			is_module("${__DIR}" __MODULE_VALID)
			if(__MODULE_VALID)
				list(APPEND __RET_LIST "${__DIR}")
			endif()		

		endforeach()

	endforeach()

	set("${__OUTPUT}" "${__RET_LIST}" PARENT_SCOPE)
endfunction()

# Clones properties from one target to another.
# Properties can be appended, instead of complitly rewritten, with 'APEEND' option.
# Two option must be seted: 'FROM' and 'TO' (which are relates to the source and target respectively). 
# Possible values for both of those options are 'INTERFACE' or 'PRIVATE'. 
# If 'PRIVATE' selected the property name will be used as is, 
# and if 'INTERFACE' is selected, the property name will be appended with 'INTERFACE_' prefix
# (which can be usefull with properties such as COMPILE_DEFINITIONS etc.). 
# Properties passed with 'PROPERTIES' option.
# as example, you can append COMPILE_DEFINITIONS property of the <source>, to the interface of the <target>:
# clone_target_properties(<source> <target> FROM PRIVATE TO INTERFACE PROPERTIES COMPILE_DEFINITIONS)
function(clone_target_properties __SOURCE __TARGET)

	assert_if_empty(__SOURCE __TARGET)

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

	# arguments validation..
	set(__PROP_TYPE INTERFACE PRIVATE)
	if (NOT __ARGS_FROM IN_LIST __PROP_TYPE)
		message(FATAL_ERROR "Can't parse FROM argument in the clone_target_properties function. Argument value is \"${__ARGS_FROM}\", and possible values is \"${__PROP_TYPE}\"")
	endif()
	if (NOT __ARGS_TO IN_LIST __PROP_TYPE)
		message(FATAL_ERROR "Can't parse TO argument in the clone_target_properties function. Argument value is \"${__ARGS_TO}\", and possible values is \"${__PROP_TYPE}\"")
	endif()

	foreach(__PROP IN LISTS __ARGS_PROPERTIES)
		# just skipping empty properties..
		if ("${__PROP}" STREQUAL "")
			continue()
		endif()

		# getting source property.. 
		set(__FROM_PROP_NAME "${__PROP}")
		if (__ARGS_FROM STREQUAL "INTERFACE")
			set(__FROM_PROP_NAME "INTERFACE_${__FROM_PROP_NAME}")
		endif()
		get_target_property(__FROM_PROP_VALUE "${__SOURCE}" "${__FROM_PROP_NAME}")

		# first defining name for the target property..
		set(__TO_PROP_NAME "${__PROP}")
		if (__ARGS_TO STREQUAL "INTERFACE")
			set(__TO_PROP_NAME "INTERFACE_${__TO_PROP_NAME}")
		endif()

		# ..and then setting or appending source value to the defined name. 
		if (__ARGS_APPEND)
			set_property(TARGET "${__TARGET}" APPEND PROPERTY "${__TO_PROP_NAME}" "${__FROM_PROP_VALUE}")
		else()
			set_property(TARGET ${__TARGET} PROPERTY "${__TO_PROP_NAME}" "${__FROM_PROP_VALUE}")
		endif()

	endforeach()
endfunction()

# Simple parsing of the python value definition.
# possible types are compose of two types: <value_type>_<value_origin>
# Value type can be:
#   - STR - the value will be interpreted as string, and automatically placed into single quotes ('')
#   - RAW - the value will not be modified in any way
#   - BOOL - the value will be True/False depending on the CMake truthfulness of the value.
#   - ARR - the value will be interpreted as an array of strings, and parsed as ['value1', 'value2', ..]
# Value origin:
#   - VAL - the value will be taken from '__VAR' argument as is.
#   - VAR - the '__VAR' will be interpreted as CMake variable name, and the actual value will be used by expanding this variable name.
#   - ENV_VAR -  the '__VAR' will be interpreted as environment CMake variable name, expanding of which will be done with ENV keyword ( $ENV{#{__VAR}} )
#   - CACHE_VAR - same as ENV_VAR but for CACHE variables ( $CACHE{${__VAR}} ).
# The value of the '__VAR' argument can be passed in a form '<var name>=<var value>'. 
# In that case the value for parsing will be taken from <var value> part, 
# and '<var name>=' part will be prefixed to the output parsed value. 
# Alternativly <var name> prefix can be cleared with 'CLEAR_VARNAME' option, or even all this logic can be turned off with 'DONT_PARSE_VARNAME' option.
# <var name> value must consist only from letters, numbers or underscores. 
# (even though python variable name can't consist only numbers, I'm to lazy to include that corner case..)
# Also one additional argument can be passed: 'ARRAY_SEPARATOR'. It's value is defines which separator will be used in case of array parsing (by default it's ', ')
function(parse_to_python_var __OUTPUT __TYPE __VAR)

	assert_if_empty(__OUTPUT __TYPE)

	assert("Type is not correct (${__TYPE})!"
		__TYPE MATCHES "^(RAW|STR|BOOL|ARR)_(VAL|VAR|ENV_VAR|CACHE_VAR)$"
	)

	set(__OPTIONS_ARGS 
		DONT_PARSE_VARNAME
		CLEAR_VARNAME
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

	# '__VAR_PREFIX' will be used in the end. Even if we will not match here, '__VAR_PREFIX' is unseted one line higher, so nothing will happend.
	if(NOT __ARGS_DONT_PARSE_VARNAME AND __VAR MATCHES "^[A-Za-z0-9_]+=.+")

		string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__VAR}")
		# modify the actual '__VAR' to not include '<name>=' prefix.
		string(REGEX REPLACE "^[A-Za-z0-9_]+=(.+)" "\\1" __VAR "${__VAR}")
		
		if(NOT __ARGS_CLEAR_VARNAME)
			set(__VAR_PREFIX "${__VAR_NAME}=")
		endif()
	endif()

	# parsing the actual value..
	if(__TYPE MATCHES ".+_ENV_VAR$")

		set(__VAR_VALUE "$ENV{${__VAR}}")

	elseif(__TYPE MATCHES ".+_CACHE_VAR$")

		set(__VAR_VALUE "$CACHE{${__VAR}}")

	elseif(__TYPE MATCHES ".+_VAR")

		set(__VAR_VALUE "${${__VAR}}")

	elseif(__TYPE MATCHES ".+_VAL")

		set(__VAR_VALUE "${__VAR}")

	else()
		# in theary we can't get here because of type validation in front of the function, but just in case.
		message(FATAL_ERROR "Incorrect variable type was provided to the python arguments parser (${__TYPE})")
	endif()

	# formating (and returning) value we got in previous step
	if(__TYPE MATCHES "^STR_.+")
		set("${__OUTPUT}" "${__VAR_PREFIX}'${__VAR_VALUE}'" PARENT_SCOPE)
	elseif(__TYPE MATCHES "^RAW_.+")
		set("${__OUTPUT}" "${__VAR_PREFIX}${__VAR_VALUE}" PARENT_SCOPE)
	elseif(__TYPE MATCHES "^BOOL_.+")
		if(__VAR_VALUE)
			set("${__OUTPUT}" "${__VAR_PREFIX}True" PARENT_SCOPE)
		else()
			set("${__OUTPUT}" "${__VAR_PREFIX}False" PARENT_SCOPE)
		endif()
	elseif(__TYPE MATCHES "^ARR_.+")

		if("${__VAR_VALUE}" STREQUAL "")
			set(__VAR_VALUE "[]")
		else()
			list(JOIN __VAR_VALUE "'${__ARGS_ARRAY_SEPARATOR}'" __VAR_VALUE)
			set(__VAR_VALUE "['${__VAR_VALUE}']")
		endif()

		set("${__OUTPUT}" "${__VAR_PREFIX}${__VAR_VALUE}" PARENT_SCOPE)

	else()
		# in theary we can't get here because of type validation in front of the function, but just in case.
		message(FATAL_ERROR "Incorrect variable type was provided to the python arguments parser (${__TYPE})")
	endif()

endfunction()

# Parses arguments into python map.
# Arguments for the parser mast be passed in form of <key0 type> <key0 name> <key0 value> <key1 type> <key1 name> <key1 value> ...
# <key type> and <key value> works by the rules of parse_to_python_var function.
# Function can accept arguments or lists of variables. For first case '__INPUT_TYPE' should be defined as 'FROM_ARGS' and for another as 'FROM_LISTS'.
# '__INPUT_TYPE' variable can't remain unset.
# In case of lists variables as inputs, they will be basiacally merged, so the ending of the first list can have a <key type>, and the start of the second list will have <key name> and <key value> 
function(parse_to_python_map __OUTPUT __INPUT_TYPE)
	
	assert_if_empty(__OUTPUT)
	assert("Incorrect input type for parse_to_python_map (${__INPUT_TYPE}), must be FROM_ITEMS|FROM_LISTS."
		__INPUT_TYPE MATCHES "(FROM_ARGS|FROM_LISTS)"
	)

	# In the implementation we always using lists. 
	if(__INPUT_TYPE STREQUAL "FROM_ARGS")
		# If input type is 'FROM_ARGS' we'll just use ARGN as this list.
		set(__INPUT_LISTS ARGN)
	else()
		# otherwise, items in the ARGN is var names for all lists we want to use
		set(__INPUT_LISTS ${ARGN})
	endif()

	# for clear start
	unset(__ARG_TYPE)
	unset(__ARG_KEY)
	set(__FIRST true)

	# just an output type
	set(__PYTHON_MAP "{")

	foreach(__ARG IN LISTS ${__INPUT_LISTS})

		# first argument is type
		if(NOT DEFINED __ARG_TYPE)
			set(__ARG_TYPE "${__ARG}")
			continue()
		endif()

		# second argument is key name
		if(NOT DEFINED __ARG_KEY)
			set(__ARG_KEY "${__ARG}")
			continue()
		endif()

		# first key pack can't have comma at the start.
		if(__FIRST)
			set(__FIRST false)
		else()
			set(__PYTHON_MAP "${__PYTHON_MAP}, ")
		endif()

		# the finale argument is value
		parse_to_python_var(__ARG_VALUE "${__ARG_TYPE}" "${__ARG}" DONT_PARSE_VARNAME)

		set(__PYTHON_MAP "${__PYTHON_MAP} '${__ARG_KEY}':${__ARG_VALUE}")

		# reseting to start parse type and name over.
		unset(__ARG_TYPE)
		unset(__ARG_KEY)
	endforeach()

	# if type is defined, that means we havent parsed last value yet
	if(DEFINED __ARG_TYPE)		
		message(WARNING "Last variable of type \"${__ARG_TYPE}\" provided to the python map parser did not has a value.")
	endif()

	set("${__OUTPUT}" "${__PYTHON_MAP} }" PARENT_SCOPE)

endfunction()

# Parses arguments into python function argument collection.
# Arguments for the parser mast be passed in form of <arg0 type> <arg0 value> <arg1 type> <arg1 value> ...
# <arg type> and <arg value> works by the rules of parse_to_python_var function.
# Function can accept arguments or lists of variables. For first case '__INPUT_TYPE' should be defined as 'FROM_ARGS' and for another as 'FROM_LISTS'.
# '__INPUT_TYPE' variable can't remain unset.
# In case of lists variables as inputs, they will be basiacally merged, so the ending of the first list can have a <arg type>, and the start of the second list will have <arg value>.
function(parse_to_python_function_args __OUTPUT __INPUT_TYPE)

	assert_if_empty(__OUTPUT)
	assert("Incorrect input type for parse_to_python_function_args (${__INPUT_TYPE}), must be FROM_ITEMS|FROM_LISTS."
		__INPUT_TYPE MATCHES "(FROM_ARGS|FROM_LISTS)"
	)

	# In the implementation we always using lists. 
	if(__INPUT_TYPE STREQUAL "FROM_ARGS")
		# If input type is 'FROM_ARGS' we'll just use ARGN as this list.
		set(__INPUT_LISTS ARGN)
	else()
		# otherwise, items in the ARGN is var names for all lists we want to use
		set(__INPUT_LISTS ${ARGN})
	endif()

	# for clear start
	unset(__ARG_TYPE)
	set(__FIRST TRUE)

	# output variable.
	set(__PYTHON_ARGS "")

	foreach(__ITEM IN LISTS ${__INPUT_LISTS})
		
		# first argument is type
		if(NOT DEFINED __ARG_TYPE)
			set(__ARG_TYPE "${__ITEM}")
			continue()
		endif()

		# first values pack can't have coma at the start.
		if(__FIRST)
			set(__FIRST FALSE)
		else()
			set(__PYTHON_ARGS "${__PYTHON_ARGS}, ")
		endif()

		# second argument is value
		parse_to_python_var(__ARG "${__ARG_TYPE}" "${__ITEM}")

		set(__PYTHON_ARGS "${__PYTHON_ARGS}${__ARG}")
		
		# now parsing again..
		unset(__ARG_TYPE)

	endforeach()

	set("${__OUTPUT}" "${__PYTHON_ARGS}" PARENT_SCOPE)

endfunction()

# Creates an python method call.
# Other then function name, function can also accept module name from which function should be called ('FROM_MODULE'). 
# 'FROM_MODULE' value must be a valid form for the python import call (like some.deep.module).
# Arguments for the function call can be passed with 'PYTHON_ARGS' argument, and works by the parse_to_python_function_args rules (in form of <arg type> <arg value>).
# Just as a reminder, <arg value> can be passed in the form "name=value". In that case (because of parse_to_python_var) argument to the python call will be keyword argument.
# Example of PYTHON_ARGS: STR_VAL "some string" STR_VAR "__CMAKE_VARIABLE" STR_VAR "arg_name=__CMAKE_VARIABLE2" 
function(compose_python_method_call __OUTPUT __FUNCTION_NAME)

	assert_if_empty(__OUTPUT __FUNCTION_NAME)

	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS 
		FROM_MODULE
	)
	set(__MULTI_VALUE_ARGS 
		PYTHON_ARGS
	)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	# basically output variable
	set(__FUNCTION_CALL "")
	# if __ARGS_FROM_MODULE was defined, and it's not just few dots (just in case)
	if(NOT "${__ARGS_FROM_MODULE}" STREQUAL "" AND NOT __ARGS_FROM_MODULE MATCHES "^\\.+$")

		string(REGEX REPLACE "\\.$" "" __MODULE "${__ARGS_FROM_MODULE}") # just in case we have dot in the end...
		string(REGEX REPLACE "^\\." "" __MODULE "${__MODULE}") # ... or beggining

		# extracting module name. (if we got 'some.deep.module' we will compose next importing string 'import some.deep.module as module')
		string(REGEX REPLACE "^.*\\.([^\\.]+)$" "\\1" __MODULE_NAME "${__MODULE}")
		if("${__MODULE_NAME}" STREQUAL "")
			set(__MODULE_NAME "${__MODULE}")
		endif()

		# in the end we will simply append function call, so even if we haven't any module, we still will have valid python call.
		set(__FUNCTION_CALL "import ${__MODULE} as ${__MODULE_NAME}; ${__MODULE_NAME}.")
	endif()

	# Passing '__ARGS_PYTHON_ARGS' to the parser without expanding it.
	parse_to_python_function_args(__FUNCTION_ARGS FROM_LISTS __ARGS_PYTHON_ARGS)

	# composing finale result.
	set(__FUNCTION_CALL "${__FUNCTION_CALL}${__FUNCTION_NAME}(${__FUNCTION_ARGS})")

	set("${__OUTPUT}" "${__FUNCTION_CALL}" PARENT_SCOPE)

endfunction()

# Creates custom command which in some way or another calls python method with signature <function>(target, source) ('target' and 'source' are arrays). 
# This signature is popups all over the place, and, usualy, those types of functions used as Commands in SCons solution (SCons commands also requeres 'target' and 'source' arguments).
# This function by default creates the custom_command, but it also can create custom_target if 'CREATE_CUSTOM_TARGET' option is used (value of this option will became custom target name).
#
# Main arguments here is 'TARGET_FILES' and 'SOURCE_FILES'. Those arrays of files passed to the 'target' and 'source' arguments of the python function respectevly.
# Automatically 'TARGET_FILES' are passed to the BYPRODUCTS/OUTPUT files of a custom_target/custom_command respectivly, and 'SOURCE_FILES' are passed to the DEPENDS of the custom_target/custom_command.
# Additionally you can pass 'SYMBOLIC_TARGETS' and 'SYMBOLIC_SOURCES'. Those files(names) are not passed to the method call itself, but rather to the BYPRODUCTS/OUTPUT/DEPENDS options.
# Also 'SYMBOLIC_TARGETS' and 'SYMBOLIC_SOURCES' automaticaly marked as SYMBOLIC.
# If CMake version is less then 3.20, then BYPRODUCTS/OUTPUT can't have generator expression in them. 
# In that case function will extract all generator expression values from BYPRODUCTS/OUTPUT, and through a warning. 
# If you know what you doing, you can use 'SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS' option to silence this warning.
#
# You can also specify target to which 'TARGET_FILES' must be appended as sources with 'SOURCES_DEPENDENT_TARGET' option.  
#
# You can also specify working directory for the command with 'WORKING_DIR' option. By default working directory is CMAKE_CURRENT_SOURCE_DIR 
# 
# One of the main arguments '__MODULE' defines from which module method should be called (this is optional command). 
# If this module is from some ralative directory you can specify this directory by 'MODULE_DIR' option. 
# By default module file (in form <working dir>/<module dir>/<module name>.py) is added to the DEPENDS. If this logic must be omitted, use BUILTIN_MODULE option.
# 
# If you want your command to be fully dependent on some generator expression you can pass this generator expression with 'GEN_EXPR_DEPENDENT' option. 
# If this generator expression returns 0, command will not be executed.
#
# Additional python arguments can be passed with 'PYTHON_ARGS' option. 
# Those arguments parsed with parse_to_python_var function and will be appended to the function call after 'target' and 'source' options
#
# With 'APPEND_SYS_PATH' you can append additional system paths to the sys.path python variable before method call.
#
# If you want to save some space in the command itself, you can use 'BY_FILE' option. 
# This option will create file with name <option value>_generator.py in the <CMAKE_CURRENT_BINARY_DIR>/generators/ folder and place in it as much python code as possible.
# This is usefull if you have a lot of sources for example.
# 
# You can also specify custom variables with 'CUSTOM_VARS' option, which will be created before the function call.
# Those custom variable always placed in the command body, even if you are using 'BY_FILE' option, 
# and it makes them usefull if you want to place most of the command into seperate file, but also to have some options as generator sxpressions.
# 
# By defualt command is calls just python, if you want to force usage of python3 you can specify 'USE_PYTHON3' option.
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

	# just parsing module in python form for the future compose_method call.
	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.${__MODULE}")
	endif()

	# seting default working dir..
	if ("${__ARGS_WORKING_DIR}" STREQUAL "")
		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()

	set(__DEPENDS ${__ARGS_SOURCE_FILES})
	if(NOT __ARGS_BUILTIN_MODULE)
		join_paths(__MODULE_ABS_DIR "${__ARGS_WORKING_DIR}" "${__ARGS_MODULE_DIR}" "${__MODULE}.py")
		list(APPEND __DEPENDS "${__MODULE_ABS_DIR}")
	endif()

	check_for_gen_expr(__SOURCE_FILES_HAS_GEN_EXPR "${__ARGS_SOURCE_FILES}")
	if(__SOURCE_FILES_HAS_GEN_EXPR)

		# if sources files has gen expr, we will put them into seperate variable infront of the command
		list(PREPEND __ARGS_CUSTOM_VARS ARR_VAR "var_source_files=__ARGS_SOURCE_FILES")
		# and prepend command future call with usage of this variable as 'source' argument
		list(PREPEND __ARGS_PYTHON_ARGS RAW_VAL "source=var_source_files")

	else()

		# if no gen expressions, just prepend those sources as 'source' argument
		list(PREPEND __ARGS_PYTHON_ARGS ARR_VAR "source=__ARGS_SOURCE_FILES")

	endif()

	check_for_gen_expr(__TARGET_FILES_HAS_GEN_EXPR "${__ARGS_TARGET_FILES}")
	if(__TARGET_FILES_HAS_GEN_EXPR)

		# if target files has gen expr, we will put them into seperate variable infront of the command
		list(PREPEND __ARGS_CUSTOM_VARS ARR_VAR "var_target_files=__ARGS_TARGET_FILES")
		# and prepend command future call with usage of this variable as 'target' argument
		list(PREPEND __ARGS_PYTHON_ARGS RAW_VAL "target=var_target_files")

	else()

		# if no gen expressions, just prepend those sources as 'target' argument
		list(PREPEND __ARGS_PYTHON_ARGS ARR_VAR "target=__ARGS_TARGET_FILES")

	endif()

	#===================== Parsing custom variables =======================
	# this what will be placed in front of the command.
	set(__CUSTOM_VAR_INIT "")
	# this is just a list of all custom variables names (this will be useful if we want to use BY_FILE)
	set(__CUSTOM_VARS_LIST "")
	unset(__VAR_TYPE)
	# just to forse any variable to have distinct name 
	set(__VAR_ID "0")
	foreach(__CUSTOM_VAR IN LISTS __ARGS_CUSTOM_VARS)
		
		# first argument is type
		if(NOT DEFINED __VAR_TYPE)
			set(__VAR_TYPE "${__CUSTOM_VAR}")
			continue()
		endif()

		# if variable does not have a name, just generate it
		if(NOT __CUSTOM_VAR MATCHES "^[A-Za-z0-9_]+=.+")
			message(WARNING "Custom variable number ${__VAR_ID} of the command does't have a name (${__CUSTOM_VAR}), the name for this variable will be 'var${__VAR_ID}'")
			set(__CUSTOM_VAR "var${__VAR_ID}=${__CUSTOM_VAR}")
		endif()

		# defining variable name
		string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__CUSTOM_VAR}")
		list(APPEND __CUSTOM_VARS_LIST "${__VAR_NAME}")

		# second argument is value
		parse_to_python_var(__CUSTOM_VAR_VALUE "${__VAR_TYPE}" "${__CUSTOM_VAR}")
		set(__CUSTOM_VAR_INIT "${__CUSTOM_VAR_INIT}${__CUSTOM_VAR_VALUE}; ")

		# start next cycle from the type
		unset(__VAR_TYPE)

		# increasing var id so var names will not repeat
		math(EXPR __VAR_ID "${__VAR_ID} + 1")
	endforeach()

	#===================== Parsing actual command =======================

	if(NOT "${__ARGS_BY_FILE}" STREQUAL "")

		#===================== Parsing script file, and arguments for the command call =======================
		# the actual code will be basically plased into a function 'run' inside a file.
		# this function will accept all custom variables initialized in the command itself.
		list(JOIN __CUSTOM_VARS_LIST ", " __CASTOM_VAR_ARGS_LIST)
		set(__PYTHON_FILE_CODE "def run(${__CASTOM_VAR_ARGS_LIST}):")

		# because later we will define working directory for the command itself, as a directory of generated file, 
		# first thign we need to do, is to chage dir to the actual working directory.
		set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}\n\timport os\n\tos.chdir('${__ARGS_WORKING_DIR}')\n\t")

		# appending all sys paths if they were passed
		if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")
			parse_to_python_var(__SYS_PATHS_ARRAY ARR_VAR __ARGS_APPEND_SYS_PATH DONT_PARSE_VARNAME)
			set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}import sys\n\tsys.path = sys.path + ${__SYS_PATHS_ARRAY}\n\n\t")
		endif()

		# creating each argument as a seperate variable for best readability
		set(__ARG_ID "0")
		# list of all args for the method in the form which is excepted by the compose_method PYTHON_ARGS.
		set(__METHOD_CALL_ARGS "")
		unset(__VAR_TYPE)
		foreach(__VAR IN LISTS __ARGS_PYTHON_ARGS)

			# again first arg is a type
			if(NOT DEFINED __VAR_TYPE)
				set(__VAR_TYPE "${__VAR}")
				continue()
			endif()

			
			if(__VAR MATCHES "^[A-Za-z0-9_]+=.+")

				# if argument has name we will extract this name, and append it to the method call as <var name>=<arg name>, 
				# where <arg name> is a variable generated by us, which holds actual value of the argument.
				# Basically values always are placed into argN variables, 
				# but if we intend method call to have keyword argument, we want to this keyword argument simply point to our defined variable.   
				string(REGEX REPLACE "^([A-Za-z0-9_]+)=.+" "\\1" __VAR_NAME "${__VAR}")
				string(REGEX REPLACE "^[A-Za-z0-9_]+=(.+)" "\\1" __VAR "${__VAR}")

				# this is what will be in the actual method call..
				list(APPEND __METHOD_CALL_ARGS RAW_VAL "${__VAR_NAME}=arg${__ARG_ID}")
				# and this is just a comment which will be infront of argN variable declaration.
				set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}# ${__VAR_NAME} function argument\n\t")

			else()

				# If it's not a keyword argument, simply add argN variable to the method call
				list(APPEND __METHOD_CALL_ARGS RAW_VAL "arg${__ARG_ID}")

			endif()

			# now we creating the actual variable argN.
			# Note, that if __VAR was keyword, we already removed it, so now __VAR contains only value.
			parse_to_python_var(__VAR_VALUE "${__VAR_TYPE}" "${__VAR}" ARRAY_SEPARATOR ",\n\t")
			set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}arg${__ARG_ID}=${__VAR_VALUE}\n\t")
			
			math(EXPR __ARG_ID "${__ARG_ID} + 1")

			unset(__VAR_TYPE)

		endforeach()

		# composing the actual method call.
		compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
			FROM_MODULE "${__MODULE}"
			PYTHON_ARGS ${__METHOD_CALL_ARGS}
		)
		set(__PYTHON_FILE_CODE "${__PYTHON_FILE_CODE}${__METHOD_CALL}\n\t")

		# changing working directory for the future command.
		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_BINARY_DIR}/generators")

		# creating actual file..
		set(__GENERATOR_FILE "${__ARGS_WORKING_DIR}/${__ARGS_BY_FILE}_generator.py")
		file(WRITE "${__GENERATOR_FILE}" "${__PYTHON_FILE_CODE}")

		# also, just in case, appending this file as dependecy for the command
		list(APPEND __DEPENDS "${__GENERATOR_FILE}")

		# and finally creating actual command, which is just importing our generated file and call run function with all custom variables..
		set(__COMMAND "${__CUSTOM_VAR_INIT}import ${__ARGS_BY_FILE}_generator;${__ARGS_BY_FILE}_generator.run(${__CASTOM_VAR_ARGS_LIST})")

	else()

		#===================== Parsing whole command =======================

		# in case of whole command everythins is much easier..
		# just compose actual method call with all arguments..
		compose_python_method_call(__COMMAND "${__FUNCTION}" 
			FROM_MODULE "${__MODULE}"
			PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
		)

		# appends infront of it custom variables.
		set(__COMMAND "${__CUSTOM_VAR_INIT}${__COMMAND}")

		# and sys paths if they were defined.
		if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")

			parse_to_python_var(__SYS_PATHS_ARRAY ARR_VAR __ARGS_APPEND_SYS_PATH DONT_PARSE_VARNAME)
			set(__COMMAND "import sys; sys.path = sys.path + ${__SYS_PATHS_ARRAY}; ${__COMMAND}")

		endif()

	endif()

	# if our command is dependent on any generator expression, we will simpy exit from this command then generator expression returns false.
	if(NOT "${__ARGS_GEN_EXPR_DEPENDENT}" STREQUAL "")
		set(__COMMAND "$<$<NOT:${__ARGS_GEN_EXPR_DEPENDENT}>:exit(0);>${__COMMAND}")
	endif()

	# we are not using gen expr files if we are less then 3.20.0 because BYPRODUCTS in custom target and OUTPUT in custom command can use gen expr only after 3.20.0
	extract_items_with_gen_expr(__ARGS_TARGET_FILES __CLEAN_TARGETS __GEN_EXPR_TARGETS)
	ternary_if(__TARGET_FILES_LIST_NAME
		"__ARGS_TARGET_FILES"
		"__CLEAN_TARGETS"
		"${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.20.0" # if version is greater or equal then 3.20 we are using targets with generator expressions
	)

	foreach(__SYMBOLIC_SRC IN LISTS __ARGS_SYMBOLIC_TARGETS)
		set_property(SOURCE "${__SYMBOLIC_SRC}"	PROPERTY SYMBOLIC TRUE)
	endforeach()

	# defining which python to use in the command..
	set(__PYTHON "python")
	if (__ARGS_USE_PYTHON3)
		set(__PYTHON "python3")
	endif()

	# just simple debug info
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
			VERBATIM
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
			VERBATIM
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

# This function is just symple interface for executing python methods from execute_process.
# The module, from which function will be called, can be deifned with '__MODULE' and 'MODULE_DIR' arguments.
# '__MODULE' deines module name itself, and 'MODULE_DIR' defines relative directory of the module.
# Working directory of the command can be defined with 'WORKING_DIR' option (defualt is CMAKE_CURRENT_SOURCE_DIR).
# Arguments for the python method call can be defined with 'PYTHON_ARGS' option (which is works by the rules of parse_to_python_function_args).
# Additionally you can pass 'OUTPUT_VARIABLE' and 'ERROR_VARIABLE' options which will standart and error aoutputs of the command.
# By defualt capturing the output will mute it from console. If you want to capture output into the command and echo it to the console,
# you can use 'ECHO_OUTPUT_VARIABLE' and 'ECHO_ERROR_VARIABLE' options.
# By default, if command fails, exception is throughn in the cmake itself. If you don't want this behavior use 'OPTIONAL' option.
# Also you can add aditional sys paths to the python command with 'APPEND_SYS_PATH' option.
function(execute_python_method __MODULE __FUNCTION)

	assert_if_empty(__FUNCTION)

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
		APPEND_SYS_PATH # it is possible to append some sys paths before calling the method
	)
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	# parsing module dir into pythom import form (with dots)
	if(NOT "${__ARGS_MODULE_DIR}" STREQUAL "")
		string(REGEX REPLACE "[/\\]$" "" __SUB_MODULES "${__ARGS_MODULE_DIR}")
		string(REGEX REPLACE "[/\\]" "." __SUB_MODULES "${__SUB_MODULES}")
		set(__MODULE "${__SUB_MODULES}.${__MODULE}")
	endif()

	# creating actual method call..
	compose_python_method_call(__METHOD_CALL "${__FUNCTION}" 
		FROM_MODULE "${__MODULE}"
		PYTHON_ARGS ${__ARGS_PYTHON_ARGS}
	)

	# appending to the command sys paths if any were given..
	if(NOT "${__ARGS_APPEND_SYS_PATH}" STREQUAL "")

		parse_to_python_var(__SYS_PATHS_ARRAY ARR_VAR __ARGS_APPEND_SYS_PATH DONT_PARSE_VARNAME)
		set(__METHOD_CALL "import sys; sys.path = sys.path + ${__SYS_PATHS_ARRAY}; ${__METHOD_CALL}")

	endif()

	# default working dir
	if ("${__ARGS_WORKING_DIR}" STREQUAL "")
		set(__ARGS_WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
	endif()

	# defining python to be used with command.
	set(__PYTHON "python")
	if (__ARGS_USE_PYTHON3)
		set(__PYTHON "python3")
	endif()

	# most of the staff in our command is handled by the execute_process itself, so all we need is just add some additional arguments to it..
	set(__ADDITIONAL_ARGS "")
	
	if(NOT "${__ARGS_OUTPUT_VARIABLE}" STREQUAL "")
		# we will store output into the temp variable
		list(APPEND __ADDITIONAL_ARGS OUTPUT_VARIABLE __TEMP_OUTPUT_VAR)
	endif()
	if(NOT "${__ARGS_ERROR_VARIABLE}" STREQUAL "")
		# we will store output into the temp variable
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

	if(VERBOSE)

		message(STATUS "============== Executing python method =============")
		message(STATUS "Working dir: ${__ARGS_WORKING_DIR}")
		message(STATUS "Command: ${__METHOD_CALL}")
		message(STATUS "====================================================")

	endif()

	# executing actual command
	execute_process(
		COMMAND "${__PYTHON}" "-c" "${__METHOD_CALL}"
		WORKING_DIRECTORY "${__ARGS_WORKING_DIR}"
		${__ADDITIONAL_ARGS}
	)

	optionally_return("${__ARGS_OUTPUT_VARIABLE}" "${__TEMP_OUTPUT_VAR}")
	optionally_return("${__ARGS_ERROR_VARIABLE}" "${__TEMP_ERROR_VAR}")

endfunction()

function(define_lib_dependencies __NAME)

	assert_if_empty(__NAME)

	get_target_property(__TARGET_TYPE "${__NAME}" TYPE)

	if (__TARGET_TYPE STREQUAL "OBJECT_LIBRARY")
		foreach(__DEPENDENCY IN LISTS ARGN)
			if (TARGET "${__DEPENDENCY}")
				get_target_property(__TARGET_TYPE "${__DEPENDENCY}" TYPE)
				
				assert("Library ${__NAME} was marked as OBJECT, and so it can't have OBJECT library dependency (dependency is \"${__DEPENDENCY}\")"
					NOT __TARGET_TYPE STREQUAL "OBJECT_LIBRARY"
				)
			endif()
		endforeach()
	endif()
	target_link_libraries("${__NAME}" PRIVATE ${ARGN})

endfunction()

# This function is for more simple adding of the libraries.
# By default all libraries is STATIC, but you can force to generate OBJECT library with 'OBJECT' option.
# Also, just as in regular add_library call, you can add 'EXCLUDE_FROM_ALL' option.
# You can specify one library with 'PARENT_LIB' option, to which created library will be automatically linked privatly (with PRIVATE keyword),
# or one environment with 'PARENT_ENV' option, to which our created library will be linked by interface (with INTERFACE keyword).
# Also you can specify any number of other libraries, which will be linked to our created library privatly.
# You can specify output directory and output name for the library (but this will only wotk if your library STATIC).
# If OUTPUT_NAME wasn't specified, default one is name of the library without '-lib' part in the end, 
# appended by the 'EXTRA_SUFFIX' variable (EXTRA_SUFFIX variable is defined in main godot CMakeLists file).
# Sources of the library can b provided with 'SOURCES' option.
# Also you can specify libraries and environments which properties you want to clone into your library with 'LIBS_CLONE' and 'ENVS_CLONE' respectevly.
# Properties to be cloned is INCLUDE_DIRECTORIES, COMPILE_OPTIONS, COMPILE_DEFINITIONS, but they can be expanded in the future..
function(add_lib __NAME)

	assert_if_empty(__NAME)

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
		DEPENDENCIES
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
		# adding actual library..
		add_library("${__NAME}" STATIC ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})
		
		# defining a name for it..
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

		# and defining output dir if one were provided.
		if(NOT "${__ARGS_OUTPUT_DIR}" STREQUAL "")
			if(NOT IS_ABSOLUTE __ARGS_OUTPUT_DIR)
				join_paths(__ARGS_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}" "${__ARGS_OUTPUT_DIR}")
			endif()
	
			# generator expression $<0:> in the very end need for the multiconfigurational generators,
			# because multiconfigurational generators always append $<CONFIG> in the end of output path if path does not has any of generator expressions already
			set_target_properties("${__NAME}" PROPERTIES 
				ARCHIVE_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>"
				COMPILE_PDB_OUTPUT_DIRECTORY "${__ARGS_OUTPUT_DIR}$<0:>"
			)
		endif()

		foreach(__COMP ${__ARGS_COMPONENTS})
			if (TARGET "${__COMP}")
				get_target_property(__TARGET_TYPE "${__COMP}" TYPE)
				
				if (NOT __TARGET_TYPE MATCHES "(OBJECT_LIBRARY|INTERFACE_LIBRARY)")
					message(WARNING "Static library ${__NAME} can't have non OBJECT or non INTERFACE library \"${__COMP}\" as a component. This component will be moved into dependencies.")
					list(REMOVE_ITEM __ARGS_COMPONENTS "${__COMP}")
					list(APPEND __ARGS_DEPENDENCIES "${__COMP}")
				endif()
			endif()
		endforeach()

	else()
		# Before we will add object library, we need to check that we are not linking to it another OBJECT library,
		# nor we are linking it to another OBJECT library (OBJECT libraries are loose their objects if they are linked one to another).
		if(NOT "${__ARGS_PARENT_LIB}" STREQUAL "")
			get_target_property(__TARGET_TYPE "${__ARGS_PARENT_LIB}" TYPE)
			assert("Can't link OBJECT library '${__NAME}' to another OBJECT library ${__ARGS_PARENT_LIB}"
				NOT "${__TARGET_TYPE}" STREQUAL "OBJECT_LIBRARY"
			)
		endif()

		if(NOT "${__ARGS_PARENT_ENV}" STREQUAL "")
			get_target_property(__TARGET_TYPE "${__ARGS_PARENT_ENV}" TYPE)
			assert("Can't link OBJECT library '${__NAME}' to another OBJECT library ${__ARGS_PARENT_ENV}"
				NOT "${__TARGET_TYPE}" STREQUAL "OBJECT_LIBRARY"
			)
		endif()

		foreach(__COMP ${__ARGS_COMPONENTS})
			if (TARGET "${__COMP}")
				get_target_property(__TARGET_TYPE "${__COMP}" TYPE)
				
				if (NOT __TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
					message(WARNING "Object library ${__NAME} can't have non INTERFACE library \"${__COMP}\" as a component. This component will be moved into dependencies.")
					list(REMOVE_ITEM __ARGS_COMPONENTS "${__COMP}")
					list(APPEND __ARGS_DEPENDENCIES "${__COMP}")
				endif()
			endif()
		endforeach()

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

	target_link_libraries("${__NAME}" PRIVATE ${__ARGS_COMPONENTS})

	if(NOT "${__ARGS_PARENT_LIB}" STREQUAL "")
		target_link_libraries("${__ARGS_PARENT_LIB}" PRIVATE "${__NAME}")
	endif()

	if(NOT "${__ARGS_PARENT_ENV}" STREQUAL "")
		target_link_libraries("${__ARGS_PARENT_ENV}" INTERFACE "${__NAME}")
	endif()

	if(NOT "${__ARGS_DEPENDENCIES}" STREQUAL "")
		define_lib_dependencies("${__NAME}" ${__ARGS_DEPENDENCIES})
	endif()

endfunction()

# Adds executable with some additional options.
# Same as add_executable 'EXCLUDE_FROM_ALL' option can be provided.
# As well as add_lib, 'OUTPUT_DIR' and 'OUTPUT_NAME' options can be provided.
# Default name for executable is name without '-exe' part in the end, appended by the  EXTRA_SUFFIX variable.
# Same as add_lib, 'COMPONENTS' can be provided, which holds all targets to be linked to out executable.
# Sources of the executable can be provided with 'SOURCES' option.
function(add_exe __NAME)

	assert_if_empty(__NAME)

	set(__OPTIONS_ARGS
		EXCLUDE_FROM_ALL # works only with standalone
	)
	set(__ONE_VALUE_ARGS
		OUTPUT_DIR # directory of the output library
		OUTPUT_NAME # force different output name (by default is name of target without -exe prefix and with added EXTRA_SUFFIX to the end of it)
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

	# creating actual executable..
	add_executable("${__NAME}" ${__EXCLUDE_FROM_ALL} ${__ARGS_SOURCES})

	# defining executable name..
	if ("${__ARGS_OUTPUT_NAME}" STREQUAL "")
		string(REGEX REPLACE "-exe$" "" __EXE_NAME "${__NAME}")
		set_target_properties("${__NAME}" PROPERTIES 
			OUTPUT_NAME "${__EXE_NAME}${EXTRA_SUFFIX}"
		)
	else()
		set_target_properties("${__NAME}" PROPERTIES 
			OUTPUT_NAME "${__ARGS_OUTPUT_NAME}"
		)
	endif()

	# .. and output directory.. 
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

	# and in the end, just linking all the components to our executable.
	target_link_libraries("${__NAME}" PRIVATE ${__ARGS_COMPONENTS})

endfunction()

# Environment is basically an interface library. It's usefull if you want to share some options between multipul targets.
# You can provide additional components with 'COMPONENTS' keyword, which will be linked to our environment by interface.
# Also you can provide some environments to clone properties from. 
# Properties to be cloned is INCLUDE_DIRECTORIES, COMPILE_OPTIONS, COMPILE_DEFINITIONS, but they can be expanded in the future..
function(add_env __NAME)

	assert_if_empty(__NAME)

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

# This method extracts specific file from the list of file paths.
# Must be provided the full file name.
# The result will be written back into input variable.
# If you want to preserve extracted file paths, you can specify 'RETURN' option with the output variable in which extracted files must be written.
# Comparison is happens on the normilized paths.
function(extract_file_from_list __LIST_VAR __FILE)

	assert_if_empty(__LIST_VAR __FILE)

	set(__OPTIONS_ARGS "")
	set(__ONE_VALUE_ARGS 
		RETURN # name of the variable to which extracted files will be returned.
	)
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	# we will compare only normilized paths.
	normilize_path(__FILE "${__FILE}")
	# escape all regex special characters, for future regex match.
	string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" __REGEX "${__FILE}")
	set(__REGEX "${__REGEX}$")

	set(__OUT_LIST "")
	set(__EXTRACTED_FILES "")

	foreach(__FILE_ITEM IN LISTS "${__LIST_VAR}")
		
		normilize_path(__NORMILIZED_FILE_ITEM "${__FILE_ITEM}")

		if(NOT __NORMILIZED_FILE_ITEM MATCHES "${__REGEX}")
			list(APPEND __OUT_LIST "${__FILE_ITEM}")
		else()
			list(APPEND __EXTRACTED_FILES "${__FILE_ITEM}")
		endif()

	endforeach()

	set("${__LIST_VAR}" "${__OUT_LIST}" PARENT_SCOPE)
	optionally_return("${__ARGS_RETURN}" "${__EXTRACTED_FILES}")

endfunction()

function(target_append_pkg_config __TARGET __SCOPE)

	assert_if_empty(__TARGET __SCOPE)
	assert("PkgConfig must be included before using 'target_append_pkg_config' function."
		PKG_CONFIG_FOUND
	)

	set(__OPTIONS_ARGS 
		INCLUDES
		OTHER_CFLAGS
		ALL_CFLAGS

		LINK_LIBS
		LINK_DIRS
		OTHER_LDFLAGS
		ALL_LDFLAGS

		ALL

		REQUIRED
	)
	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(PARSE_ARGV 2 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	if(__ARGS_REQUIRED)
		set(__REQUIRED REQUIRED)
	else()
		set(__REQUIRED "")
	endif()

	if(__ARGS_ALL)
		set(__ARGS_ALL_CFLAGS TRUE)
		set(__ARGS_ALL_LDFLAGS TRUE)
	endif()

	if(__ARGS_ALL_CFLAGS)
		set(__ARGS_INCLUDES TRUE)
		set(__ARGS_OTHER_CFLAGS TRUE)
	endif()

	if(__ARGS_ALL_LDFLAGS)
		set(__ARGS_LINK_LIBS TRUE)
		set(__ARGS_LINK_DIRS TRUE)
		set(__ARGS_OTHER_LDFLAGS TRUE)
	endif()

	# basically, everything unparsed is modules
	foreach(__MODULE IN LISTS __ARGS_UNPARSED_ARGUMENTS)
		
		pkg_check_modules(__PKG ${__REQUIRED} "${__MODULE}")
		if (NOT __PKG_FOUND)
			continue()
		endif()

		if(__ARGS_INCLUDES)
			target_include_directories("${__TARGET}" "${__SCOPE}" ${__PKG_INCLUDE_DIRS})
		endif()

		if(__ARGS_OTHER_CFLAGS)
			target_compile_options("${__TARGET}" "${__SCOPE}" ${__PKG_CFLAGS_OTHER})
		endif()

		if(__ARGS_LINK_LIBS)
			target_link_libraries("${__TARGET}" "${__SCOPE}" ${__PKG_LINK_LIBRARIES})
		endif()

		if (__ARGS_LINK_DIRS)
			target_link_directories("${__TARGET}" "${__SCOPE}" ${__PKG_LIBRARY_DIRS})
		endif()

		if(__ARGS_OTHER_LDFLAGS)
			target_link_options("${__TARGET}" "${__SCOPE}" ${__PKG__LDFLAGS_OTHER})
		endif()

	endforeach()

endfunction()

function(check_pkg_exist __OUTPUT __PKG_NAME)

	assert_if_empty(__PKG_NAME __OUTPUT)

	assert("PkgConfig must be included before using 'check_pkg_exist' function."
		PKG_CONFIG_FOUND
	)

	# executing actual command
	execute_process(
		COMMAND "${PKG_CONFIG_EXECUTABLE}" "--exists" "${__PKG_NAME}"
		RESULT_VARIABLE __RET
	)

	if(__RET EQUAL 0)
		set("${__OUTPUT}" TRUE PARENT_SCOPE)
	else()
		set("${__OUTPUT}" FALSE PARENT_SCOPE)
	endif()

endfunction()