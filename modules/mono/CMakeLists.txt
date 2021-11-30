
#Note: Through out this directory we will create number of custom_targets where, supposedly, better whould be use POST_BUILD custom_command events.
# This is done intentionnaly, because mono-lib could be OBJECT library, and those one doesn't support POST_BUILD/PRE_LINK/PRE_BUILD events..
# We also can't use simple custom commands, because not always we know exact output files. Plus most of the outputs use generator expressions,
# and generator expression in OUTPUT paremeter of the custom_command supported only from cmake 3.20.

add_module_lib(mono-lib
	COMPONENTS
		modules-env
		warnings-env
)

if (GODOT_BUILD_TOOLS)
	# NOTE: It is safe to generate this file here, since this is still executed serially
	execute_python_method(gen_cs_glue_version generate_header
		MODULE_DIR "build_scripts"
		PYTHON_ARGS
			STR_VAL "glue/GodotSharp"
			STR_VAL "glue/cs_glue_version.gen.h"
	)
endif()

if(GODOT_MONO_GLUE)
	target_compile_definitions(mono-lib PRIVATE "MONO_GLUE_ENABLED")

	if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/glue/mono_glue.gen.cpp")
		message(FATAL_ERROR "Mono glue sources not found. Did you forget to run '--generate-mono-glue'?")
	endif()
endif()

############ Setup #############

inline_if(__IS_WINDOWS 		GODOT_PLATFORM STREQUAL "windows")
inline_if(__IS_ANDROID 		GODOT_PLATFORM STREQUAL "android")
inline_if(__IS_JAVASCRIPT 	GODOT_PLATFORM STREQUAL "javascript")
inline_if(__IS_IOS	 		GODOT_PLATFORM STREQUAL "iphone")
inline_if(__IS_DESKTOP 		
	GODOT_PLATFORM MATCHES "(windows|osx|x11|server|uwp|haiku)"
)
inline_if(__IS_UNIX_LIKE
	GODOT_PLATFORM MATCHES "(osx|x11|server|android|haiku|iphone)"
)

#TODO: don't forget to add GODOT_IOS_SIMULATOR if I will ever be working with apple products (probably not..).
inline_if(__IS_IOS_SIM 		__IS_IOS AND GODOT_IOS_SIMULATOR)
inline_if(__MODULE_SUPPORTS_TOOLS NOT GODOT_PLATFORM MATCHES "(android|javascript|iphone)")
set(__MONO_BCL GODOT_MONO_BCL)

# basiaclly defining a map
set(__SUPPORTED_ANDROID_ARCH_DIRS "armv7" "arm64v8" "x86" "x86_64")
set(__armv7_ANDROID_ARCH_DIR 		"armeabi-v7a")
set(__arm64v8_ANDROID_ARCH_DIR 		"arm64-v8a")
set(__x86_ANDROID_ARCH_DIR			"x86")
set(__x86_64_ANDROID_ARCH_DIR		"x86_64")
set(__ANDROID_OUTPUT_DIR "${GODOT_SOURCE_DIR}/platform/android/java/lib/libs/$<IF:${IS_RELEASE_GEN_EXPR},release,debug>/${__${GODOT_ANDROID_ARCH}_ANDROID_ARCH_DIR}")

set(__MONO_LIB_NAMES "mono-2.0-sgen" "monosgen-2.0")

# This custom command is basically allow us to create custom target with dynamic COMMAND parameter.
# Because custom target 'COMMAND' paremeter can't be expanded, but custom command for the same output file can be appended.
add_custom_command(
	OUTPUT mono-files-copy-gen-source
	COMMAND "" # first command is empty, others will be just appended
	VERBATIM # because most of the commands will be python ones..
)
add_custom_target(mono-files-copy-gen
	DEPENDS
		mono-files-copy-gen-source
	COMMENT "[mono-files-copy-gen] Copying all neseccery files fro mono-lib.."
)
add_dependencies(mono-lib mono-files-copy-gen)
set_source_files_properties(mono-gen-files-copy-source PROPERTIES SYMBOLIC TRUE)

# Mode can be TREE (a.k.a. DIRECTORY) or FILE
# Copies file or directory.
# By defult tries to copy file at configure time, 
# but if file path has generator expression in it (or 'FORCE_BUILD_TIME' option specified),
# file will be copied by custom prebuild event.
function(__copy_path __MODE __SRC __DST)

	assert_if_empty(__SRC __DST)

	if(NOT __MODE MATCHES "(FILE|TREE)")
		message(FATAL_ERROR "__copy_path mode incorrect (${__MODE}), must be FILE or TREE")
	endif()

	inline_if(__IS_FILE __MODE STREQUAL "FILE")

	set(__OPTIONS_ARGS 		
		# By default copying of the file, through custom command at a build time, 
		# will be done only if src or dst paths has generator expression in them.
		# If none of those paths has a generator expression the file will be copied at configure time, with configure_file.
		# But if you want to force usage of custom command, and build time copying, set this option.		
		FORCE_BUILD_TIME 
		# By default, if file does not exist, the command will throw an error in some way. 
		# If you want less strict policy, and don't want to throw an error if file does not exist, use this option.
		OPTIONAL
	)
	set(__ONE_VALUE_ARGS "")
	set(__MULTI_VALUE_ARGS "")
	cmake_parse_arguments(PARSE_ARGV 3 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	check_for_gen_expr(__SRC_HAS_GEN_EXPR "${__SRC}")
	check_for_gen_expr(__DST_HAS_GEN_EXPR "${__DST}")
	if(__SRC_HAS_GEN_EXPR OR __DST_HAS_GEN_EXPR)
		set(__ARGS_FORCE_BUILD_TIME true)
	endif()

	if(NOT IS_ABSOLUTE "${__SRC}")
		join_paths(__SRC "${CMAKE_CURRENT_SOURCE_DIR}" "${__SRC}")
	else()
		# need to normilize only in else statement, because join_paths normilises by default
		normilize_path(__SRC "${__SRC}")
	endif()

	if(NOT IS_ABSOLUTE "${__DST}")
		join_paths(__DST "${CMAKE_BINARY_DIR}" "${__DST}")
	else()
		normilize_path(__DST "${__DST}")
	endif()

	if(__ARGS_FORCE_BUILD_TIME)

		if(__IS_FILE)
			set(__COMMAND "import os; from shutil import copy;src='${__SRC}'; dst='${__DST}';dst_folder=os.path.dirname(dst);") # initial data
			set(__COMMAND "${__COMMAND} (os.makedirs(dst_folder) if not os.path.exists(dst_folder) else None, copy(src, dst)) if os.path.isfile(src) else ")  # actual copy
		else()
			set(__COMMAND "import os; from distutils.dir_util import copy_tree;src='${__SRC}'; dst='${__DST}';") # initial data
			set(__COMMAND "${__COMMAND} copy_tree(src, dst) if os.path.exists(src) else ")  # actual copy
		endif()

		if(__ARGS_OPTIONAL)
			set(__COMMAND "${__COMMAND} None")
		else()
			set(__COMMAND "${__COMMAND} (print(f'${__MODE} ({src}) does not exist'), exit(-1))") # last things if the got to "else" part of the command
		endif()

		add_custom_command(OUTPUT mono-files-copy-gen-source
			APPEND
			COMMAND "python" "-c" "${__COMMAND}"
			VERBATIM
		)

	else()
		if(NOT EXISTS "${__SRC}")

			if(NOT __ARGS_OPTIONAL)
				message(FATAL_ERROR "Can't copy nonexistent ${__MODE} (${__SRC}).")
			endif()

			return()
		endif()

		if(__IS_FILE)
			file(COPY "${__SRC}" DESTINATION "${__DST}")
		else()
			execute_process(
				COMMAND ${CMAKE_COMMAND} -E copy_directory "${__SRC}" "${__DST}"
				COMMAND_ERROR_IS_FATAL ANY
			)
		endif()

	endif()

endfunction()

# returns file name (or curname if 'RETURN_ONLY_CURNAME' specified),
# in sertain directory ('PATH' option), which has one of specified extentions ('FILE_EXTENTIONS'),
# and one of specified prefixes ('FILE_PREFIXES').

function(__find_file_in_dir __OUTPUT)

	set(__OPTIONS_ARGS 
		RETURN_ONLY_CURNAME
	)
	set(__ONE_VALUE_ARGS 
		PATH
	)
	set(__MULTI_VALUE_ARGS 
		FILE_NAMES
		FILE_EXTENTIONS
		FILE_PREFIXES
	)
	cmake_parse_arguments(PARSE_ARGV 1 __ARGS "${__OPTIONS_ARGS}" "${__ONE_VALUE_ARGS}" "${__MULTI_VALUE_ARGS}")

	assert_if_empty(__OUTPUT __ARGS_PATH __ARGS_FILE_NAMES)

	# if extentions or prefixes are empty, we are adding single star.
	# this will indicate that extention (or prefixes) list has only one empty item.
	# later in function we will simply check for this star.
	if("${__ARGS_FILE_EXTENTIONS}" STREQUAL "")
		list(APPEND __ARGS_FILE_EXTENTIONS "*") # aka none
	endif()

	if("${__ARGS_FILE_PREFIXES}" STREQUAL "")
		list(APPEND __ARGS_FILE_PREFIXES "*") # aka none
	endif()

	foreach(__EXTENTION IN LISTS __ARGS_FILE_EXTENTIONS)
		if("${__EXTENTION}" STREQUAL "*")
			set(__EXTENTION "")
		endif()

		# if extention does not have dot at the begining, we will add it..
		if(NOT "${__EXTENTION}" STREQUAL "" 
			AND NOT __EXTENTION MATCHES "^\\..*")
			
			set(__EXTENTION ".${__EXTENTION}")
		endif()

		foreach(__PREFIX IN LISTS __ARGS_FILE_PREFIXES)

			if("${__PREFIX}" STREQUAL "*")
				set(__PREFIX "")
			endif()

			foreach(__CURNAME IN LISTS __ARGS_FILE_NAMES)
				
				set(__FILE_NAME "${__PREFIX}${__CURNAME}${__EXTENTION}")

				join_paths(__PATH "${__ARGS_PATH}" "${__FILE_NAME}")

				if(EXISTS "${__PATH}" AND NOT IS_DIRECTORY "${__PATH}")
					if(__ARGS_RETURN_ONLY_CURNAME)
						set("${__OUTPUT}" "${__CURNAME}" PARENT_SCOPE)
					else()
						set("${__OUTPUT}" "${__FILE_NAME}" PARENT_SCOPE)
					endif()
					return()
				endif()

			endforeach() # names

		endforeach() # prefixes

	endforeach() # extentions

	set("${__OUTPUT}" "" PARENT_SCOPE)

endfunction()

#################################

# Configure Thread Local Storage
include(CheckCXXSourceCompiles)

# Simply checking that provided keyword will compile with or default parameters.
function(__check_keyword_compile __OUTPUT __KEYWORD)
	message(STATUS "Checking for `${__KEYWORD}` support...")
	# just in case if compiler changed without our notice..
	unset(${__OUTPUT}_OUTPUT CACHE)
	check_cxx_source_compiles(
		"${__KEYWORD} int foo = 0; 
		int main() 
		{ 
			return foo; 
		}"
		"${__OUTPUT}_OUTPUT"
	)
	set(${__OUTPUT} "${${__OUTPUT}_OUTPUT}" PARENT_SCOPE)
endfunction()

__check_keyword_compile(__CXX11_THREAD_LOCAL "thread_local")

if(__CXX11_THREAD_LOCAL)
	target_compile_definitions(mono-lib PRIVATE "HAVE_CXX11_THREAD_LOCAL")
else()
	if(MSVC)
		__check_keyword_compile(__DECLSPEC_COMPILE "__declspec(thread)")
		if(__DECLSPEC_COMPILE)
			target_compile_definitions(mono-lib PRIVATE "HAVE_DECLSPEC_THREAD")
		endif()
	else()
		__check_keyword_compile(__GCC__THREAD_COMPILE "__thread")
		if(__GCC__THREAD_COMPILE)
			target_compile_definitions(mono-lib PRIVATE "HAVE_GCC___THREAD")
		endif()
	endif()
endif()

# Configure Mono

if(__IS_ANDROID AND NOT GODOT_ANDROID_ARCH IN_LIST __SUPPORTED_ANDROID_ARCH_DIRS)
	message(FATAL_ERROR "This module does not support the specified 'android_arch': ${GODOT_ANDROID_ARCH} (possible architectures are: ${__SUPPORTED_ANDROID_ARCH_DIRS})")
endif()

if(GODOT_BUILD_TOOLS AND NOT __MODULE_SUPPORTS_TOOLS)
	# TODO:
	# Android: We have to add the data directory to the apk, concretely the Api and Tools folders.
	message(FATAL_ERROR "This module does not currently support building for this platform with tools enabled.")
endif()

if(__IS_ANDROID AND GODOT_MONO_STATIC)
	# FIXME: When static linking and doing something that requires libmono-native, we get a dlopen error as 'libmono-native'
	# seems to depend on 'libmonosgen-2.0'. Could be fixed by re-directing to '__Internal' with a dllmap or in the dlopen hook.
	message(FATAL_ERROR "Statically linking Mono is not currently supported for this platform.")
endif()

if(NOT GODOT_MONO_STATIC AND (__IS_JAVASCRIPT OR __IS_IOS))
	message(FATAL_ERROR "Dynamically linking Mono is not currently supported for this platform.")
endif()

if("${GODOT_MONO_PREFIX}" STREQUAL "" AND (NOT "$ENV{MONO32_PREFIX}" STREQUAL "" OR NOT "$ENV{MONO64_PREFIX}" STREQUAL ""))
	message(WARNING "The environment variables 'MONO32_PREFIX' and 'MONO64_PREFIX' are deprecated; use the 'GODOT_MONO_PREFIX' parameter instead")
endif()

# Although we don't support building with tools for any platform where we currently use static AOT,
# if these are supported in the future, we won't be using static AOT for them as that would be
# too restrictive for the editor. These builds would probably be made to only use the interpreter.
# aka mono_aot_static
if(__IS_IOS AND NOT __IS_IOS_SIM AND NOT GODOT_BUILD_TOOLS)
	target_compile_definitions(mono-lib PRIVATE "GD_MONO_SINGLE_APPDOMAIN")
else()
	target_compile_definitions(mono-lib PRIVATE $<$<NOT:${IS_RELEASE_GEN_EXPR}>:GD_MONO_HOT_RELOAD>)
endif()

if(__IS_WINDOWS)

	set(__MONO_ROOT "${GODOT_MONO_PREFIX}")

	if("${__MONO_ROOT}" STREQUAL "" AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
		execute_python_method(mono_reg_utils cmake_find_mono_root_dir
			MODULE_DIR "build_scripts"
			PYTHON_ARGS 
				RAW_VAR "PROCESSOR_BITS"
			OUTPUT_VARIABLE __MONO_ROOT
		)
	endif()

	if("${__MONO_ROOT}" STREQUAL "")
		message(FATAL_ERROR "Mono installation directory not found; specify one manually with the 'GODOT_MONO_PREFIX' parameter.")
	endif()

	message(STATUS "Found Mono root directory: ${__MONO_ROOT}")

	join_paths(__MONO_LIB_PATH "${__MONO_ROOT}" "lib")
	target_link_directories(global-env INTERFACE "${__MONO_LIB_PATH}")

	join_paths(__MONO_INCLUDE_PATH "${__MONO_ROOT}" "include/mono-2.0")
	target_include_directories(mono-lib PRIVATE "${__MONO_INCLUDE_PATH}")

	set(__LIB_EXTENTIONS ".lib")
	if (NOT MSVC)
		list(PREPEND __LIB_EXTENTIONS ".a")
	endif()

	if(GODOT_MONO_STATIC)

		if(MSVC)
			set(__MONO_STATIC_LIB_NAME "libmono-static-sgen")
		else()
			set(__MONO_STATIC_LIB_NAME "libmonosgen-2.0")
		endif()

		__find_file_in_dir(__MONO_STATIC_LIB_FILE 
			PATH "${__MONO_LIB_PATH}"
			FILE_NAMES "${__MONO_STATIC_LIB_NAME}"
			FILE_EXTENTIONS ${__LIB_EXTENTIONS}
		)

		if("${__MONO_STATIC_LIB_FILE}" STREQUAL "")
			message(FATAL_ERROR "Could not find static mono library in: ${__MONO_LIB_PATH}")
		endif()

		#TODO: This can be source of the problem, all these libraries, in this solution, will be linked into all project targets,
		# but in scons solution they will not be linked to everything, because environment always is copied
		# need to test this
		if(MSVC)

			target_link_libraries(global-env INTERFACE
				"${__MONO_STATIC_LIB_FILE}"
				"Mincore.lib"
				"msvcrt.lib"
				"LIBCMT.lib"
				"Psapi.lib"
			)

		else()
			join_paths(__MONO_STATIC_LIB_FILE_PATH "${__MONO_LIB_PATH}" "${__MONO_STATIC_LIB_FILE}")
			target_link_options(global-env INTERFACE 
				"-Wl,-whole-archive" 
				"${__MONO_STATIC_LIB_FILE_PATH}" 
				"-Wl,-no-whole-archive"
			)

			target_link_libraries(global-env INTERFACE
				"psapi"
				"version"
			)

		endif()

	else() # GODOT_MONO_STATIC

		__find_file_in_dir(__MONO_LIB_NAME 
			PATH "${__MONO_LIB_PATH}"
			FILE_NAMES ${__MONO_LIB_NAMES}
			FILE_PREFIXES "" "lib"
			FILE_EXTENTIONS ${__LIB_EXTENTIONS}
			RETURN_ONLY_CURNAME
		)

		if("${__MONO_LIB_NAME}" STREQUAL "")
			message(FATAL_ERROR "Could not find mono library in: ${__MONO_LIB_PATH}")
		endif()

		if(MSVC)
			target_link_libraries(global-env INTERFACE "${__MONO_LIB_NAME}.lib")
		else()
			target_link_libraries(global-env INTERFACE "${__MONO_LIB_NAME}")
		endif()

		join_paths(__MONO_BIN_PATH "${__MONO_ROOT}" "bin")

		__find_file_in_dir(__MONO_DLL_FILE 
			PATH "${__MONO_BIN_PATH}"
			FILE_NAMES ${__MONO_LIB_NAMES}
			FILE_PREFIXES "" "lib"
			FILE_EXTENTIONS ".dll"
		)

		if("${__MONO_DLL_FILE}" STREQUAL "")
			message(FATAL_ERROR "Could not find mono shared library in: ${__MONO_BIN_PATH}")
		endif()

		__copy_path(FILE 
			"${__MONO_BIN_PATH}/${__MONO_DLL_FILE}" 
			"${GODOT_BIN_DIRECTORY}/${__MONO_DLL_FILE}"
		)

	endif()

else()

	inline_if(__IS_APPLE	 		GODOT_PLATFORM MATCHES "(iphone|osx)")
	inline_if(__IS_MACOS			__IS_APPLE AND NOT __IS_IOS)

	ternary_if(__SHAREDLIB_EXT 
		".dylib" 
		".so" 
		__IS_APPLE
	)

	set(__MONO_ROOT "${GODOT_MONO_PREFIX}")

	if("${__MONO_ROOT}" STREQUAL "" AND (__IS_ANDROID OR __IS_JAVASCRIPT OR __IS_IOS))
		message(FATAL_ERROR "Mono installation directory not found; specify one manually with the 'GODOT_MONO_PREFIX' parameter.")
	endif()


	if("${__MONO_ROOT}" STREQUAL "" AND __IS_MACOS)

		# Try with some known directories under OSX
		foreach(
			__DIR 
			"/Library/Frameworks/Mono.framework/Versions/Current" 
			"/usr/local/var/homebrew/linked/mono"
		)

			if(IS_DIRECTORY "${__DIR}")
				set(__MONO_ROOT "${__DIR}")
				break()
			endif()
		endforeach()

	endif()

	# We can't use pkg-config to link mono statically,
	# but we can still use it to find the mono root directory
	if("${__MONO_ROOT}" STREQUAL "" AND GODOT_MONO_STATIC)
		# God I hope this works..

		# if pkg config wasn't searched (or found) yet, search for it
		if(NOT PKG_CONFIG_FOUND)
			find_package(PkgConfig)
		endif()

		# if it wasn't found even now, we have nothing to do
		if(PKG_CONFIG_FOUND)
			pkg_check_modules(__MONO_PKG monosgen-2)
	
			foreach(__DIR IN LISTS __MONO_PKG_LIBRARY_DIRS)
	
				__find_file_in_dir(__NAME_FOUND
					PATH "${__DIR}"
					FILE_NAMES ${__MONO_LIB_NAMES}
					FILE_PREFIXES "lib"
					FILE_EXTENTIONS ${__SHAREDLIB_EXT}
					RETURN_ONLY_CURNAME
				)
	
				join_paths(__MONO_INCLUDE_DIR "${__DIR}" "../include/mono-2.0")
				if(NOT "${__NAME_FOUND}" STREQUAL "" AND IS_DIRECTORY "${__MONO_INCLUDE_DIR}")
	
					join_paths(__MONO_ROOT "${__DIR}" "..")
					break()
	
				endif()
	
			endforeach()
		endif()

		if("${__MONO_ROOT}" STREQUAL "")
			message(FATAL_ERROR "Building with GODOT_MONO_STATIC=true, but failed to find the mono prefix with pkg-config; specify one manually with the 'GODOT_MONO_PREFIX' parameter")
		endif()

	endif()

	if(__IS_IOS AND NOT __IS_IOS_SIM)
		target_compile_definitions(mono-lib PRIVATE "IOS_DEVICE")
	endif()

	if(NOT "${__MONO_ROOT}" STREQUAL "")

		message(STATUS "Found Mono root directory: ${__MONO_ROOT}")

		join_paths(__MONO_LIB_PATH "${__MONO_ROOT}" "lib")
		target_link_directories(global-env INTERFACE "${__MONO_LIB_PATH}")

		join_paths(__MONO_INCLUDE_PATH "${__MONO_ROOT}" "include/mono-2.0")
		target_include_directories(mono-lib PRIVATE "${__MONO_INCLUDE_PATH}")

		__find_file_in_dir(__MONO_LIB 
			PATH "${__MONO_LIB_PATH}"
			FILE_NAMES ${__MONO_LIB_NAMES}
			FILE_PREFIXES "lib"
			FILE_EXTENTIONS ".a"
			RETURN_ONLY_CURNAME
		)		

		if("${__MONO_LIB}" STREQUAL "")
			message(FATAL_ERROR "Could not find mono library in: ${__MONO_LIB_PATH}")
		endif()

		target_compile_definitions(mono-lib PRIVATE "_REENTRANT")

		if(GODOT_MONO_STATIC)
			if (NOT __IS_JAVASCRIPT)
				target_link_options(global-env INTERFACE "-rdynamic")
			endif()

			join_paths(__MONO_LIB_FILE "${__MONO_LIB_PATH}" "lib${__MONO_LIB}.a")

			if(__IS_APPLE)

				if(__IS_MACOS)

					target_link_options(global-env PRIVATE "-Wl,-force_load,${__MONO_LIB_FILE}")

				else()
					ternary_if(__MONO_LIBRARY_SUFFIX
						"simulator.a" # true
						"a" # false
						__IS_IOS_SIM
					)
					function(__copy_mono_lib __LIB_NAME)
						__copy_path(FILE 
							"${__MONO_LIB_PATH}/${__LIB_NAME}.a" 
							"${GODOT_BIN_DIRECTORY}/${__LIB_NAME}.iphone.${CMAKE_SYSTEM_PROCESSOR}.${__MONO_LIBRARY_SUFFIX}"
						)
					endfunction()

					# Copy Mono libraries to the output folder. These are meant to be bundled with
					# the export templates and added to the Xcode project when exporting a game.
					__copy_mono_lib("lib${__MONO_LIB}")
					__copy_mono_lib("libmono-native")
					__copy_mono_lib("libmono-profiler-log")

					if (NOT __IS_IOS_SIM)
						__copy_mono_lib("libmono-ee-interp")
						__copy_mono_lib("libmono-icall-table")
						__copy_mono_lib("libmono-ilgen")
					endif()


				endif()

			else() # __IS_APPLE

				if(NOT (__IS_DESKTOP OR __IS_ANDROID OR __IS_JAVASCRIPT))
					message(FATAL_ERROR "Assert!")
				endif()

				target_link_options(global-env INTERFACE 
					"-Wl,-whole-archive"
					"${__MONO_LIB_FILE}"
					"-Wl,-no-whole-archive"
				)

			endif()

			if(__IS_JAVASCRIPT)
				target_link_libraries(global-env INTERFACE 
					"mono-icall-table"
					"mono-native"
					"mono-ilgen"
					"mono-ee-interp"
				)

				join_paths(__WASM_SRC_DIR "${__MONO_ROOT}" "src")

				if(NOT IS_DIRECTORY "${__WASM_SRC_DIR}")
					message(FATAL_ERROR "Could not find mono wasm src directory")
				endif()

				#SCons comment: Ideally this should be defined only for 'driver.c', but I can't fight scons for another 2 hours
				#TODO: test it, and maybe really cange it to set only one source property. 
				target_compile_definitions(mono-lib PRIVATE "CORE_BINDINGS")

				target_sources(mono-lib PRIVATE
					"${__WASM_SRC_DIR}/driver.c"
					"${__WASM_SRC_DIR}/zlib-helper.c"
					"${__WASM_SRC_DIR}/corebindings.c"
				)

				target_link_options(global-env INTERFACE
					"--js-library" "${__WASM_SRC_DIR}/library_mono.js"
					"--js-library" "${__WASM_SRC_DIR}/binding_support.js"
					"--js-library" "${__WASM_SRC_DIR}/dotnet_support.js"
				)

			endif()

		else() # GODOT_MONO_STATIC

			target_link_libraries(global-env INTERFACE "${__MONO_LIB}")

		endif()

		if(__IS_MACOS)
			target_link_libraries(global-env INTERFACE "iconv" "pthread")
		elseif(__IS_ANDROID)
			# Nothing
		elseif(__IS_IOS)
			# Nothing, linking is delegated to the exported Xcode project
		elseif(__IS_JAVASCRIPT)
			target_link_libraries(global-env INTERFACE "m" "rt" "dl" "pthread")
		else()
			target_link_libraries(global-env INTERFACE "m" "rt" "dl" "pthread")
		endif()

		if(NOT GODOT_MONO_STATIC)

			__find_file_in_dir(__MONO_SO_FILE
				PATH "${__MONO_LIB_PATH}"
				FILE_NAMES ${__MONO_LIB_NAMES}
				FILE_PREFIXES "lib"
				FILE_EXTENTIONS ${__SHAREDLIB_EXT}
			)

			if("${__MONO_SO_FILE}" STREQUAL "")
				message(FATAL_ERROR "Could not find mono shared library in: ${__MONO_LIB_PATH}")
			endif()

		endif()

	else() # NOT "${__MONO_ROOT}" STREQUAL ""

		if(GODOT_MONO_STATIC)
			message(FATAL_ERROR "Assert!")
		endif()

		# TODO: Add option to force using pkg-config
		print("Mono root directory not found. Using pkg-config instead..")

		if(NOT PKG_CONFIG_FOUND)
			find_package(PkgConfig)
		endif()

		if(PKG_CONFIG_FOUND)

			pkg_check_modules(__MONO_PKG monosgen-2)
	
			target_link_libraries(global-env INTERFACE ${__MONO_PKG_LIBRARIES})
			target_link_directories(global-env INTERFACE ${__MONO_PKG_LIBRARY_DIRS})
			target_link_options(global-env INTERFACE ${__MONO_PKG_LDFLAGS_OTHER})
	
			target_include_directories(mono-lib PRIVATE ${__MONO_PKG_INCLUDE_DIRS})
			target_compile_options(mono-lib PRIVATE ${__MONO_PKG_CFLAGS_OTHER})
	
			foreach(__DIR IN LISTS __MONO_PKG_LIBRARY_DIRS)
				
				__find_file_in_dir(__FILE_FOUND 
					PATH "${__DIR}"
					FILE_NAMES ${__MONO_LIB_NAMES}
					FILE_PREFIXES "lib"
					FILE_EXTENTIONS ${__SHAREDLIB_EXT}
				)
	
				if(NOT "${__FILE_FOUND}" STREQUAL "")
	
					set(__MONO_LIB_PATH "${__DIR}")
					set(__MONO_SO_FILE "${__FILE_FOUND}")
					break()
	
				endif()
	
			endforeach()

		endif()

		if("${__MONO_SO_FILE}" STREQUAL "")
			message(FATAL_ERROR "Could not find mono shared library in: ${__MONO_PKG_LIBRARY_DIRS}")
		endif()

	endif()

	if(NOT GODOT_MONO_STATIC)
		ternary_if(__LIBS_OUTPUT_DIR
			"${__ANDROID_OUTPUT_DIR}"
			"${GODOT_BIN_DIRECTORY}"
			__IS_ANDROID
		)

		__copy_path(FILE 
			"${__MONO_LIB_PATH}/${__MONO_SO_FILE}" 
			"${__LIBS_OUTPUT_DIR}/${__MONO_SO_FILE}"
		)

	endif()

endif()

parse_to_python_map(__FAKE_ENV_MAP FROM_ARGS
	STR_VAL "target" "$<${IS_RELEASE_GEN_EXPR}:release>$<${IS_DEBUG_GEN_EXPR}:debug>$<${IS_OPT_DEBUG_GEN_EXPR}:release_debug>"
	STR_VAR "platform" "GODOT_PLATFORM"
	RAW_VAR "bits" "PROCESSOR_BITS"
	STR_VAL "android_output_dir" "${__ANDROID_OUTPUT_DIR}"
)

set(__BUILD_SCRIPTS_COMMAND_PREFIX "import build_scripts.cmake_mono_configure_utils as cmake_mono_configure_utils; cmake_mono_configure_utils")

if(NOT GODOT_BUILD_TOOLS)

	if(__IS_DESKTOP)

		if("${__MONO_ROOT}" STREQUAL "")
			if(NOT PKG_CONFIG_FOUND)
				find_package(PkgConfig)
			endif()
		
			if(PKG_CONFIG_FOUND)
				pkg_get_variable(__MONO_ROOT "mono-2" "prefix")
			endif()
		endif()
		
		add_custom_target(mono-create-template-dir-gen
			COMMAND "python" "-c" "${__BUILD_SCRIPTS_COMMAND_PREFIX}.make_template_dir(env=${__FAKE_ENV_MAP}, mono_root='${__MONO_ROOT}', output_dir='${GODOT_BIN_DIRECTORY}')"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "[mono-create-template-dir-gen] Creating template dir.."
			VERBATIM
		)
		add_dependencies(mono-lib mono-create-template-dir-gen)

	elseif(__IS_ANDROID)

		set(__CONFIG_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build_scripts/mono_android_config.xml")
		set(__CONFIG_OUTPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/mono_gd")

		# Do not forget, that this command will generate android_mono_config.gen.cpp, and we want this only if tools are disabled!
		execute_python_method(make_android_mono_config generate_compressed_config
			MODULE_DIR build_scripts
			PYTHON_ARGS
				STR_VAR "__CONFIG_FILE_PATH"
				STR_VAR "__CONFIG_OUTPUT_PATH"
		)

		add_custom_target(mono-copy-shared-libs-gen
			COMMAND "python" "-c" "${__BUILD_SCRIPTS_COMMAND_PREFIX}.copy_mono_shared_libs(env=${__FAKE_ENV_MAP}, mono_root='${__MONO_ROOT}', target_mono_root_dir=None)"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "[mono-copy-shared-libs-gen] Copying mono shared libraries.."
			VERBATIM
		)
		add_dependencies(mono-lib mono-copy-shared-libs-gen)

	elseif(__IS_JAVASCRIPT)
		# No data directory for this platform
	elseif(__IS_IOS)
		# No data directory for this platform
	endif()

endif()

if(GODOT_COPY_MONO_ROOT)

	if(GODOT_BUILD_TOOLS)
		if("${__MONO_ROOT}" STREQUAL "")
			if(NOT PKG_CONFIG_FOUND)
				find_package(PkgConfig)
			endif()
	
			if(PKG_CONFIG_FOUND)
				pkg_get_variable(__MONO_ROOT "mono-2" "prefix")
			endif()
		endif()

		set(__COMMAND "android_dir='${__ANDROID_OUTPUT_DIR}'; import build_scripts.cmake_mono_configure_utils as cmake_mono_configure_utils; ") # initial setup
		set(__COMMAND "${__COMMAND} cmake_mono_configure_utils.copy_mono_root_files(env=${__FAKE_ENV_MAP}, mono_root='${__MONO_ROOT}', output_dir='${GODOT_BIN_DIRECTORY}', mono_blc='${GODOT_MONO_BCL}') ") # calling copy_mono_root_files if tools are enabled

		add_custom_target(mono-copy-root-gen
			COMMAND "python" "-c" "${__COMMAND}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "[mono-copy-root-gen] Copying mono_root from \"${__MONO_ROOT}\".."
			VERBATIM
		)
		add_dependencies(mono-lib mono-copy-root-gen)

	else()

		message(STATUS "Ignoring option: GODOT_COPY_MONO_ROOT; only available for builds with GODOT_BUILD_TOOLS enabled.")

	endif()

endif()

if(GODOT_BUILD_TOOLS AND GODOT_MONO_GLUE AND GODOT_BUILD_CIL)

	set(__LAST_TARGET "")

	#====================== Api Solution Build =======================
	set(__TARGET_FILENAMES
		"GodotSharp.dll"
		"GodotSharp.pdb"
		"GodotSharp.xml"
		"GodotSharpEditor.dll"
		"GodotSharpEditor.pdb"
		"GodotSharpEditor.xml"
	)

	foreach(__CONFIG "Debug" "Release")
		
		parse_to_python_map(__FAKE_ENV_MAP FROM_ARGS
			RAW_VAL "target" "target_var"
			STR_VAR "platform" "GODOT_PLATFORM"
			RAW_VAR "bits" "PROCESSOR_BITS"
			BOOL_VAR "tools" "GODOT_BUILD_TOOLS"
			STR_VAR "mono_prefix" "GODOT_MONO_PREFIX"
			STR_VAL "module_dir" "${CMAKE_CURRENT_SOURCE_DIR}"
			STR_VAR "solution_build_config" "__CONFIG"
			BOOL_VAR "verbose" "VERBOSE"
		)

		set(__EDITOR_API_DIR "${GODOT_BIN_DIRECTORY}/GodotSharp/Api/${__CONFIG}")

		set(__TARGETS "")

		foreach(__FILE IN LISTS __TARGET_FILENAMES)
			list(APPEND __TARGETS "${__EDITOR_API_DIR}/${__FILE}")
		endforeach()

		string(TOLOWER "${__CONFIG}" __CONFIG_LOWER)
		set(__CUSTOM_TARGET_NAME "mono-${__CONFIG_LOWER}-api-solution-gen")

		add_python_generator_command(api_solution_build build_api_solution
			TARGET_FILES ${__TARGETS}
			MODULE_DIR "build_scripts"
			WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
			CREATE_CUSTOM_TARGET "${__CUSTOM_TARGET_NAME}"
			SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS # we are not really consered about loosing some byproducts
			BY_FILE "api_solution_${__CONFIG_LOWER}"
			CUSTOM_VARS
				STR_VAL "target_var=$<${IS_RELEASE_GEN_EXPR}:release>$<${IS_DEBUG_GEN_EXPR}:debug>$<${IS_OPT_DEBUG_GEN_EXPR}:release_debug>"
			PYTHON_ARGS
				RAW_VAR "env=__FAKE_ENV_MAP"
		)

		# This is comment from SCons version, I'm not sure we need to do the same in cmake, but just to be sure
        # Make the Release build of the API solution depend on the Debug build.
        # We do this in order to prevent SCons from building them in parallel,
        # which can freak out MSBuild. In many cases, one of the builds would
        # hang indefinitely requiring a key to be pressed for it to continue.
		if(NOT "${__LAST_TARGET}" STREQUAL "")
			add_dependencies("${__CUSTOM_TARGET_NAME}" "${__LAST_TARGET}")
		endif()

		set(__LAST_TARGET "${__CUSTOM_TARGET_NAME}")

	endforeach()

	#====================== Godot Tools Build =======================

	set(__EDITOR_TOOLS_DIR "${GODOT_BIN_DIRECTORY}/GodotSharp/Tools")

	set(__TARGETS 
		"${__EDITOR_TOOLS_DIR}/GodotTools.dll"
		"$<${IS_DEBUG_GEN_EXPR}:${__EDITOR_TOOLS_DIR}/GodotTools.pdb>"
	)

	parse_to_python_map(__FAKE_ENV_MAP FROM_ARGS
		RAW_VAL "target" "target_var"
		STR_VAR "platform" "GODOT_PLATFORM"
		RAW_VAR "bits" "PROCESSOR_BITS"
		BOOL_VAR "tools" "GODOT_BUILD_TOOLS"
		STR_VAR "mono_prefix" "GODOT_MONO_PREFIX"
		STR_VAL "module_dir" "${CMAKE_CURRENT_SOURCE_DIR}"
		BOOL_VAR "verbose" "VERBOSE"
		RAW_VAL "output_dir" "binary_dir_var"
		STR_VAR "root_dir" "GODOT_SOURCE_DIR"
	)

	set(__CUSTOM_TARGET_NAME "mono-tools-solution-gen")
	add_python_generator_command(godot_tools_build build_godot_tools
		TARGET_FILES ${__TARGETS}
		MODULE_DIR "build_scripts"
		WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
		CREATE_CUSTOM_TARGET "${__CUSTOM_TARGET_NAME}"
		SILENCE_GEN_EXPR_BYPRODUCTS_WARNINGS
		BY_FILE "tools_solution"
		CUSTOM_VARS
			STR_VAL "target_var=$<${IS_RELEASE_GEN_EXPR}:release>$<${IS_DEBUG_GEN_EXPR}:debug>$<${IS_OPT_DEBUG_GEN_EXPR}:release_debug>"
			STR_VAL "binary_dir_var=${GODOT_BIN_DIRECTORY}"
		PYTHON_ARGS
			RAW_VAR "env=__FAKE_ENV_MAP"
	)

	if(NOT "${__LAST_TARGET}" STREQUAL "")
		add_dependencies("${__CUSTOM_TARGET_NAME}" "${__LAST_TARGET}")
	endif()
	set(__LAST_TARGET "${__CUSTOM_TARGET_NAME}")

	#================================================================

	add_dependencies(mono-lib "${__LAST_TARGET}")

endif()

target_glob_sources(mono-lib PRIVATE "*.cpp")
target_glob_sources(mono-lib PRIVATE "glue/*.cpp")

file(GLOB __MONO_GD_SOURCES LIST_DIRECTORIES false "${CMAKE_CURRENT_SOURCE_DIR}/mono_gd/*.cpp")
# we are remembering that this file must be included only if tools are disabled
extract_file_from_list(__MONO_GD_SOURCES "android_mono_config.gen.cpp" RETURN __MONO_GD_ANDROID_CONFIG_SOURCE)
target_sources(mono-lib PRIVATE	${__MONO_GD_SOURCES})

if(__IS_ANDROID AND NOT GODOT_BUILD_TOOLS)
	target_sources(mono-lib PRIVATE	${__MONO_GD_ANDROID_CONFIG_SOURCE})	
endif()

target_glob_sources(mono-lib PRIVATE "utils/*.cpp")
target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.cpp")
target_sources(mono-lib PRIVATE "glue/mono_glue.gen.cpp")

if(GODOT_PLATFORM MATCHES "(osx|iphone)")
	target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.mm")
	target_glob_sources(mono-lib PRIVATE "mono_gd/support/*.m")
elseif(GODOT_PLATFORM STREQUAL "android")
	target_sources(mono-lib PRIVATE "mono_gd/android_mono_config.gen.cpp")
endif()

if(GODOT_BUILD_TOOLS)
	target_glob_sources(mono-lib PRIVATE "editor/*.cpp")
endif()
