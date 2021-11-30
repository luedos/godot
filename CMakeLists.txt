cmake_minimum_required (VERSION 3.19.0)
project (godot VERSION 3.2.3 LANGUAGES CXX C)

# Seting defualt language standarts. 
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Just for all hardcoded folders outthere.
# This is not strictly needed, but, because there a lot of submodules which uses rood directory for thirdparty sources search, 
# using CMAKE_SOURCE_DIR for it disterbs me a little bit. So even though this project is not intended to be a part of another cmake project, 
# I still will create this variable just in case when CMAKE_SOURCE_DIR will shout incorrect result.  
set(GODOT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

# First of all, including all needed functions
include(methods.cmake)
# package config is used by the project here and there
find_package(PkgConfig QUIET)


############### Processing platforms ###############

# Platform of the godot is decided by the system,
# and if you want to change it, you must change CMAKE_SYSTEM_NAME.
# Because this will not only let the godot know which platform you are using,
# but also cmake itself, which then will instruct compiler as well.
# For that is suggested to write some toolchain files.
# That said, you also has the ability to override godot platform, in toolchain file or console for example,
# by specifying GODOT_PLATFORM variable. That is useful if you want something like "server" as a platform.
if ("${GODOT_PLATFORM}" STREQUAL "")
	string(TOLOWER "${CMAKE_SYSTEM_NAME}" __SYSTEM_NAME)
	if(__SYSTEM_NAME MATCHES "(windows|win32)")
		set(GODOT_PLATFORM "windows") # windows case
	elseif(__SYSTEM_NAME MATCHES "(x11|linux)")
		set(GODOT_PLATFORM "x11")
	else()
		# For now we are not supporting any other platforms..
		message(FATAL_ERROR "Platform \"${CMAKE_SYSTEM_NAME}\" is not supported.")
	endif()
endif()

# Just in case we provided platform from some options
if(GODOT_PLATFORM MATCHES "(linux|dragonfly|freebsd|netbsd|openbsd|linuxbsd|bsd)")
	set(GODOT_PLATFORM "x11")
endif()

############### Processing processor ###############

set(PROCESSOR_IS_X86 FALSE)
set(PROCESSOR_IS_ARM FALSE)
set(PROCESSOR_IS_AARCH64 FALSE)
set(PROCESSOR_IS_POWER FALSE)
set(PROCESSOR_IS_MIPS FALSE)
set(PROCESSOR_IS_RISCV FALSE)

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" __PROCESSOR_ARCHITECTURE)
if(GODOT_PLATFORM STREQUAL "android")
	string(TOLOWER "${CMAKE_ANDROID_ARCH}" __PROCESSOR_ARCHITECTURE)
endif()

if(__PROCESSOR_ARCHITECTURE MATCHES "^mips")
	set(PROCESSOR_IS_MIPS TRUE)
elseif(__PROCESSOR_ARCHITECTURE MATCHES "^arm")
	set(PROCESSOR_IS_ARM TRUE)
elseif(__PROCESSOR_ARCHITECTURE MATCHES "^aarch64")
	set(PROCESSOR_IS_AARCH64 TRUE)
elseif(__PROCESSOR_ARCHITECTURE MATCHES "(^x86)|(amd64)|(^i.86$)")
	set(PROCESSOR_IS_X86 TRUE)
elseif(__PROCESSOR_ARCHITECTURE MATCHES "^(powerpc|ppc)")
	set(PROCESSOR_IS_POWER TRUE)
elseif(__PROCESSOR_ARCHITECTURE MATCHES "^risc")
	# I'm not sure if this is will work.. I've never tested this architecture, 
	# and haven't found what cmake will write into CMAKE_SYSTEM_PROCESSOR in this case.
	set(PROCESSOR_IS_RISCV TRUE)
else()
	# This is mostly mean that our script will go blind folded into build process, 
	# but that doesn't nessecerely mean that build will failed.
	message(WARNING "The target architecture \"${__PROCESSOR_ARCHITECTURE}\" wasn't processed, this can lead to some problems in build time")
endif()

set(PROCESSOR_BITS 64)
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(PROCESSOR_BITS 32)
endif()

#[=[
DOCUMENTATION FOR PLATFORMS

All functions platform detect.cmake file should implement
- function(<platform_id>_get_platform_name __OUTPUT) -> returns platform name (will be stored in "<platfom_id>_PLATFROM_NAME")
- function(<platform_id>_get_is_platform_active __OUTPUT) -> returns true is platform active (will be stored in "<platfom_id>_IS_PLATFORM_ACTIVE")
- function(<platform_id>_get_can_platform_build __OUTPUT) -> returns true is platform can be built (will be stored in "<platfom_id>_PLATFROM_CAN_BUILD")
- function(<platform_id>_create_custom_options) -> will add some custom options with set_<type>_option function
- function(<platform_id>_configure_platform) -> doing all kind of stuff, like adding specific flags for compiler/linker, modifing some option etc.
- (optional) function(<platform_id>_get_program_suffix <output_variable>) -> returns some platform dependent suffix for program file

Variables which will be defined for platforms
- ACTIVE_PLATFORM_PATHS -> active platform paths
- ACTIVE_PLATFORMS -> active platform actual names
- PLATFORMS_LIST -> buildable platforms raw names (folder names)
- PLATFORMS_EXPORTERS -> list of platform ids (raw names) which has export.cpp file
- PLATFORMS_APIS -> list of platform ids (raw names) which has api.cpp file
- <platform_name>_IS_PLATFORM_ACTIVE -> is platform active (usually just defined from <platform_name>_get_is_platform_active)
- <platform_name>_PLATFROM_NAME -> actual platform name. This variable is output from <platform_name>_get_platform_name method
]=]

set(ACTIVE_PLATFORM_PATHS "")
set(ACTIVE_PLATFORMS "")
set(PLATFORMS_EXPORTERS "")
set(PLATFORMS_APIS "")
set(PLATFORMS_LIST "")

file(GLOB __PLATFORM_DIRS 
	LIST_DIRECTORIES true 
	"${GODOT_SOURCE_DIR}/platform/*"
)

# for each available platform
foreach(__DIR IN LISTS __PLATFORM_DIRS)

	unset(__PLATFORM_ID) # just in case

	if(NOT IS_DIRECTORY "${__DIR}")
		continue()
	endif()

	if(NOT EXISTS "${__DIR}/detect.cmake")
		# for now we will comment this warning, because most of platforms are not supported.
		# message(WARNING "The platform \"${__DIR}\" is defined, but doesn't have detect.cmake in it, so it can't be processed..")
		continue()
	endif()

	include("${__DIR}/detect.cmake")
	
	# getting platform id
	get_top_directory("${__DIR}" __PLATFORM_ID)

	# just to be sure
	unset(${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)
	unset(${__PLATFORM_ID}_PLATFROM_NAME)
	unset(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

	# if export file exist 
	if(EXISTS "${__DIR}/export/export.cpp")
		list(APPEND PLATFORMS_EXPORTERS "${__PLATFORM_ID}")
	endif()

	# if api file exist
	if(EXISTS "${__DIR}/api/api.cpp")
		list(APPEND PLATFORMS_APIS "${__PLATFORM_ID}")
	endif()

	# if platform defined as active (must be defined in detect.cmake)
	cmake_language(CALL "${__PLATFORM_ID}_get_is_platform_active" ${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)
	if(${__PLATFORM_ID}_IS_PLATFORM_ACTIVE)

		cmake_language(CALL "${__PLATFORM_ID}_get_platform_name" "${__PLATFORM_ID}_PLATFROM_NAME")
		list(APPEND ACTIVE_PLATFORMS "${${__PLATFORM_ID}_PLATFROM_NAME}")
		list(APPEND ACTIVE_PLATFORM_PATHS "${__DIR}")

	endif()

	# if platform can be built (must be defined in detect.cmake)
	cmake_language(CALL "${__PLATFORM_ID}_get_can_platform_build" ${__PLATFORM_ID}_PLATFROM_CAN_BUILD)
	if(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

		list(APPEND PLATFORMS_LIST "${__PLATFORM_ID}")
		if(__PLATFORM_ID STREQUAL GODOT_PLATFORM)
			cmake_language(CALL "${__PLATFORM_ID}_create_custom_options")
		endif()

	endif()

endforeach()

execute_python_method(methods save_active_platforms
	PYTHON_ARGS 
		ARR_VAR "ACTIVE_PLATFORMS"
		ARR_VAR "ACTIVE_PLATFORM_PATHS"
)

############### Creating default parameters ###############

# Important note: even though all option variables here is cache varaibles, when we referensing them we only use simple variant, so some variables can be overriten.
# (for example, some platforms tend to override GODOT_BUILD_TOOLS option)

# Target build options
set_string_option	(GODOT_BIN_DIRECTORY			"bin/$<CONFIG>"		DESCRIPTION "Build directory. (can use generator expression)")
set_bool_option		(GODOT_BUILD_TOOLS 				TRUE 	DESCRIPTION	"Build the tools (a.k.a. the Godot editor). By itself, this option does nothing. By enableing this option build will add two additional configurations: ToolsDebug and ToolsRelWithDebInfo. Tools will be build only by choosing those configurations.")
set_bool_option		(GODOT_USE_LTO					FALSE	DESCRIPTION "Use link-time optimization.")
set_bool_option		(GODOT_USE_PRECISE_MATH_CHECKS 	FALSE 	DESCRIPTION "Math checks use very precise epsilon (debug option).")
# Instead of profile, cmake can just use toolchain files
# set_path_option		(GODOT_PROFILE 					"" 		DESCRIPTION "Path to the profile file." FILE)

# Components
set_bool_option		(GODOT_DEPRECATED 			TRUE 	DESCRIPTION "Enable deprecated features.")
set_bool_option		(GODOT_GDSCRIPT 			TRUE 	DESCRIPTION "Enable GDScript support.")
set_bool_option		(GODOT_MINIZIP 				TRUE 	DESCRIPTION "Enable ZIP archive support using minizip.")
set_bool_option		(GODOT_XAUDIO2 				FALSE 	DESCRIPTION "Enable the XAudio2 audio driver.")
set_string_option	(GODOT_CUSTOM_MODULES 		"" 		DESCRIPTION	"A list of comma-separated directory paths containing custom modules to build.")
# Technicaly you will not find this option in the SCons SConstruct. But actually this is an option which is used in gdnative module.
set_bool_option		(GODOT_GDNATIVE_WRAPPER		FALSE	DESCRIPTION	"")
set_bool_option		(GODOT_CUSTOM_MODULES_RECURSIVE TRUE DESCRIPTION "Detect custom modules recursively for each specified path.")

# Advanced options
# verbose 	# Enable verbose output for the compilation
# progress 	# Show a progress indicator during compilation
set_string_option	(GODOT_WARNINGS				"all" 	DESCRIPTION "Level of compilation warnings (\"extra\", \"all\", \"moderate\", \"no\")" ENUM "extra" "all" "moderate" "no")
set_bool_option		(GODOT_WERROR 				FALSE 	DESCRIPTION "Treat compiler warnings as errors.")
# Those options (GODOT_DEV/GODOT_PRODUCTION) works not the same as in scons, because in scons those options are not alises for other options. 
# In scons "dev" and "production" options set defaults for another options, and not options themself.
# To do so, we need to know if user setted other options directly via console or not, and we can't do this check in cmake.
# Because of that, those two options will be actual aliaces, and not just defaults setters. 
set_bool_option		(GODOT_PRODUCTION			FALSE 	DESCRIPTION "Set defaults to build Godot for use in production.")
set_bool_option		(GODOT_DEV 					FALSE 	DESCRIPTION "If yes, alias for verbose=yes warnings=extra werror=yes")
set_string_option	(GODOT_EXTRA_SUFFIX			"" 		DESCRIPTION "Custom extra suffix added to the base filename of all generated binary files.")
# vsproj 	# NO NEED
# macports_clang	# Build using Clang from MacPorts ("no", "5.0", "devel")
# TODO: not forget to actually implement forsing to True if mingw  
set_bool_option		(GODOT_SPLIT_LIBMODULES		FALSE	DESCRIPTION "Split intermediate libmodules.a in smaller chunks to prevent exceeding linker command line size (forced to True when using MinGW).")
set_bool_option		(GODOT_DISABLE_3D			FALSE	DESCRIPTION "Disable 3D nodes for a smaller executable.")
set_bool_option		(GODOT_DISABLE_ADVANCE_GUI 	FALSE	DESCRIPTION "Disable advanced GUI nodes and behaviors.")
set_bool_option		(GODOT_NO_EDITOR_SPLASH 	FALSE	DESCRIPTION "Don't use the custom splash screen for the editor.")
set_string_option	(GODOT_SYSTEM_CERTS_PATH 	""		DESCRIPTION "Use this path as SSL certificates default for editor (for package maintainers).")
set_string_option	(GODOT_LTO_JOBS_COUNT		"1"		DESCRIPTION "Number of jobs for lto (not sure what exactly this meen)")

# Thirdparty libraries
set_bool_option		(GODOT_BUILTIN_BULLET		TRUE 	DESCRIPTION "Use the built-in Bullet library.")
set_bool_option		(GODOT_BUILTIN_CERTS		TRUE 	DESCRIPTION "Use the built-in SSL certificates bundles.")
set_bool_option		(GODOT_BUILTIN_EMBREE		TRUE 	DESCRIPTION "Use the built-in Embree library.")
set_bool_option		(GODOT_BUILTIN_ENET			TRUE 	DESCRIPTION "Use the built-in ENet library.")
set_bool_option		(GODOT_BUILTIN_FREETYPE		TRUE 	DESCRIPTION "Use the built-in FreeType library.")
set_bool_option		(GODOT_BUILTIN_LIBOGG		TRUE 	DESCRIPTION "Use the built-in libogg library.")
set_bool_option		(GODOT_BUILTIN_LIBPNG		TRUE 	DESCRIPTION "Use the built-in libpng library.")
set_bool_option		(GODOT_BUILTIN_LIBTHEORA	TRUE 	DESCRIPTION "Use the built-in libtheora library.")
set_bool_option		(GODOT_BUILTIN_LIBVORBIS	TRUE 	DESCRIPTION "Use the built-in libvorbis library.")
set_bool_option		(GODOT_BUILTIN_LIBVPX		TRUE 	DESCRIPTION "Use the built-in libvpx library.")
set_bool_option		(GODOT_BUILTIN_LIBWEBP		TRUE 	DESCRIPTION "Use the built-in libwebp library.")
set_bool_option		(GODOT_BUILTIN_WSLAY		TRUE 	DESCRIPTION "Use the built-in wslay library.")
set_bool_option		(GODOT_BUILTIN_MBEDTLS		TRUE 	DESCRIPTION "Use the built-in mbedTLS library.")
set_bool_option		(GODOT_BUILTIN_MINIUPNPC	TRUE 	DESCRIPTION "Use the built-in miniupnpc library.")
set_bool_option		(GODOT_BUILTIN_OPUS			TRUE 	DESCRIPTION "Use the built-in Opus library.")
set_bool_option		(GODOT_BUILTIN_PCRE2		TRUE 	DESCRIPTION "Use the built-in PCRE2 library.")
set_bool_option		(GODOT_BUILTIN_PCRE2_WITH_JIT TRUE 	DESCRIPTION "Use JIT compiler for the built-in PCRE2 library.")
set_bool_option		(GODOT_BUILTIN_RECAST		TRUE 	DESCRIPTION "Use the built-in Recast library.")
set_bool_option		(GODOT_BUILTIN_SQUISH		TRUE 	DESCRIPTION "Use the built-in squish library.")
set_bool_option		(GODOT_BUILTIN_XATLAS		TRUE 	DESCRIPTION "Use the built-in xatlas library.")
set_bool_option		(GODOT_BUILTIN_ZLIB			TRUE 	DESCRIPTION "Use the built-in zlib library.")
set_bool_option		(GODOT_BUILTIN_ZSTD			TRUE 	DESCRIPTION "Use the built-in Zstd library.")

# Generator expressions for easier working with build types which can be used in the future.
set(IS_OPTIMIZED_GEN_EXPR      $<CONFIG:Release,MinSizeRel,RelWithDebInfo>)
set(IS_RELEASE_GEN_EXPR        $<CONFIG:Release,MinSizeRel>)
set(IS_DEBUG_INFO_GEN_EXPR     $<CONFIG:Debug,RelWithDebInfo>)
set(IS_DEBUG_GEN_EXPR          $<CONFIG:Debug>)
set(IS_OPT_DEBUG_GEN_EXPR      $<CONFIG:RelWithDebInfo>)

if(MINGW)
	set(GODOT_SPLIT_LIBMODULES TRUE CACHE BOOL "" FORCE)
endif()

# Normilizing godot bin directory and making it absolute.
if(NOT IS_ABSOLUTE "${GODOT_BIN_DIRECTORY}")
	join_paths(GODOT_BIN_DIRECTORY "${CMAKE_BINARY_DIR}" "${GODOT_BIN_DIRECTORY}")
else()
	normilize_path(GODOT_BIN_DIRECTORY "${GODOT_BIN_DIRECTORY}")
endif()

############### Creating the environment ###############
# This is basically the analog of the SCons Environment variable.
# This environment library can be configured later, from platform/module scripts (same as it done in scons)
# In the future this can be changed..
add_env(global-env)

# setting some "global" variables, which can be appended by modules
set_target_properties(global-env 
	PROPERTIES
		USE_PTRCALL false # do we need to define PTRCALL_ENABLED. This variable can be overriten on module configuration
		X86_LIBTHEORA_OPT_GCC false
		X86_LIBTHEORA_OPT_VC false
		EXTRA_SUFFIX ""
		MODULE_VERSION_STRING ""
)

target_include_directories(global-env INTERFACE
	"${GODOT_SOURCE_DIR}"
)

# some thirdparty libs does not have warnings in them, so we will create separate environment to handle all warnings levels
add_env(warnings-env)

############### Configuring platform ###############

if(NOT GODOT_PLATFORM IN_LIST PLATFORMS_LIST)
	message(FATAL_ERROR "Platform \"${GODOT_PLATFORM}\" can't be found in active platforms (${PLATFORMS_LIST}). Maybe current platform \"${CMAKE_SYSTEM_NAME}\" is not supported yet.")
elseif(NOT ${GODOT_PLATFORM}_PLATFROM_CAN_BUILD)
	message(FATAL_ERROR "Platform \"${GODOT_PLATFORM}\" exist, but can't be built.")
endif()

############### Processing modules ###############

#[=[
DOCUMENTATION FOR MODULES

All functions modules config.cmake file should implement
- function(<module_name>_configure_module) -> configures module if needed
- function(<module_name>_get_module_can_build <output>) -> returns true if module can be build and should be processed
- (optional) function(<module_name>_get_is_module_enabled <output>) -> to override default value of the <module_name>_IS_MODULE_ENABLED option
- (optional) function(<module_name>_get_doc_classes <output>) -> works with <module_name>_get_doc_relative_path. Used to define module classes for documentation
- (optional) function(<module_name>_get_doc_relative_path <output>) -> works with <module_name>_get_doc_classes. Used to define relative path of the module classes.
- (optional) function(<module_name>_get_relative_icon_path <output>) -> used to define icons path for module. If this function wasn't defined, default path is "icons"
- (optional) function(<module_name>_get_version_string <output>) -> used to add some specific info to the version of the current build (for now it is used only in the mono module)

Variables which will be defined for modules
- MODULES_IDS -> all modules names
- MODULES_PATHS -> all modules paths (in sync with MODULES_IDS)
- <module_name>_MODULE_PATH -> path for the specific module
- <module_name>_IS_MODULE_ENABLED -> this is option (a.k.a. CACHE value) which determines is module enabled (will be processed) or not. Usually it is set up through console line, or simply through cache
- <module_name>_MODULE_CAN_BUILD -> this variable is output from <module_name>_get_module_can_build function. Also defines if module can be built
- MODULES_CLASSES -> classses names from all modules
- <module_name>_MODULE_DOC_CLASSES -> list of classes for specific module
- <class_name>_CLASS_PATH -> path for the doc of the specific class
- <module_name>_MODULE_DOC_RELATIVE_PATH -> relative path of the modules doc folder
- <module_name>_ICONS_PATH -> icon path for specific module
- MODULES_ICONS_PATHS -> icon paths of all modules
]=]

# getting all modules
#[=[
important thing is, modules paths provided by the GODOT_CUSTOM_MODULES must lead to the folders which holds modules folders 
not the modules itself: 
path is "some/provided/path"
structure is:
some/provided/path/module1/
some/provided/path/module2/
some/provided/path/module3/
...
]=]

set(__MODULE_DIRS "") # just to be sure
# Built in directories we are detecting without recursion
get_modules_paths(__MODULES_DIRS "modules")

set(__ADDITIONAL_ARGS "")
if(GODOT_CUSTOM_MODULES_RECURSIVE)
	set(__ADDITIONAL_ARGS "RECURSIVE")
endif()
get_modules_paths(__TEMP_MODULES_DIRS ${__ADDITIONAL_ARGS} ${GODOT_CUSTOM_MODULES})
list(APPEND __MODULES_DIRS ${__TEMP_MODULES_DIRS})

# Provide default include path for both the custom module search `path`
# and the base directory containing custom modules, as it may be different
# from the built-in "modules" name (e.g. "custom_modules/summator/summator.h"),
# so it can be referenced simply as `#include "summator/summator.h"`
# independently of where a module is located on user's filesystem.

# Comment from cmake implementer:
# I'm not sure, if this is a good idea to prepend include directories 
# not only with user input, but also with parent directory of that input..
# This will definetly create a lot of garbage includes, so I would propose to only 
# include directories provided by the user.. This will work in most situations, 
# because user will provide a folder which containes modules, and not module folders directly,
# and so the desired result will be achieved by the build system.
# IMHO, the logic which tries to force scons is simply not intuitive.
# But here I will replicate scons logic as best as I can.
set(__ADDITIONAL_INCLUDES "")
foreach(__MODULE_SUBDIR IN LISTS GODOT_CUSTOM_MODULES)
	normilize_path(__MODULE_SUBDIR "${__MODULE_SUBDIR}" ABSOLUTE)
	list(APPEND __ADDITIONAL_INCLUDES "${__MODULE_SUBDIR}")

	# I would prefer to remove this logic, but this is basically what scons version is doing,
	# so, as I said above, I will do the same..
	if(TRUE)
		get_filename_component(__PARENT_DIR "${__MODULE_SUBDIR}" DIRECTORY)
		list(APPEND __ADDITIONAL_INCLUDES "${__PARENT_DIR}")
	endif()
endforeach()
list(REMOVE_DUPLICATES __ADDITIONAL_INCLUDES)
target_include_directories(global-env INTERFACE ${__ADDITIONAL_INCLUDES})

# those lists are sync with each other
set(MODULES_IDS "") # all modules ids (a.k.a. folder names)
set(MODULES_PATHS "") # all modules paths

# processing all modules
# local variables (not really needed, but just as overview of which variables counts as local)
unset(__MODULE_VALID)
unset(__MODULE_ID)

foreach(__DIR IN LISTS __MODULES_DIRS)
	# just in case..
	normilize_path(__DIR "${__DIR}")

	is_module("${__DIR}" __MODULE_VALID)
	if(NOT __MODULE_VALID)
		message(WARNING "Provided module by the path \"${__DIR}\" is not valid, and can't be processed..")
		continue()
	endif()

	get_top_directory("${__DIR}" __MODULE_ID)

	if(__MODULE_ID IN_LIST MODULES_IDS)
		# if module with same id was already defined..
		message(WARNING "Provided module \"${__MODULE_ID}\" is already defined. Old module path is \"${${__MODULE_ID}_MODULE_PATH}\", new module path is \"${__DIR}\". New module will not be processed!")
		continue()
	endif()

	# appending module id to the list
	list(APPEND MODULES_IDS "${__MODULE_ID}")
	# setting module path in two ways:
	# with variable:
	set(${__MODULE_ID}_MODULE_PATH "${__DIR}")
	# and by appending it to the list
	list(APPEND MODULES_PATHS "${__DIR}")

	if(EXISTS "${__DIR}/config.cmake")
		include("${__DIR}/config.cmake")
	endif()

	# if we are not already provided that property..
	if (NOT DEFINED ${__MODULE_ID}_IS_MODULE_ENABLED)
		set(__MODULE_ENABLED true) # default is true
		# if module can give us answer
		if(COMMAND ${__MODULE_ID}_get_is_module_enabled) 
			cmake_language(CALL ${__MODULE_ID}_get_is_module_enabled __MODULE_ENABLED)
		endif() # otherwise default is true

		set_bool_option(${__MODULE_ID}_IS_MODULE_ENABLED "${__MODULE_ENABLED}" DESCRIPTION "Is module \"${__MODULE_ID}\" enabled.")	
	endif()
endforeach()

# generating some files
execute_python_method(methods cmake_write_modules
	PYTHON_ARGS
		ARR_VAR "MODULES_IDS"
		ARR_VAR "MODULES_PATHS"
)

############### Processing new configurations ###############

if(GODOT_BUILD_TOOLS)
	# If we are using tools, we will not use Release and MinSizeRel
	set(__POSSIBLE_BUILD_TYPES 
		"Debug" 
		"RelWithDebInfo"
	)
else()
	set(__POSSIBLE_BUILD_TYPES 
		"Debug" 
		"RelWithDebInfo" 
		"Release" 
		"MinSizeRel"
	)
endif()

if(CMAKE_CONFIGURATION_TYPES)

	set(CMAKE_CONFIGURATION_TYPES "${__POSSIBLE_BUILD_TYPES}")
	message(STATUS "Possible configurations is: ${CMAKE_CONFIGURATION_TYPES}")

else()

	# if no build type defined, make defualt Debug.
	if("${CMAKE_BUILD_TYPE}" STREQUAL "")
		
		set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
		
	elseif(NOT CMAKE_BUILD_TYPE IN_LIST __POSSIBLE_BUILD_TYPES)
		
		message(FATAL_ERROR "Invalid build type ${CMAKE_BUILD_TYPE}. Possible build types are: ${__POSSIBLE_BUILD_TYPES}")
	
	endif()

	# also add property to the CMAKE_BUILD_TYPE, so it will be more easier to choose build type in cmake gui.
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${__POSSIBLE_BUILD_TYPES})

	message(STATUS "Current build type is \"$CACHE{CMAKE_BUILD_TYPE}\".")

endif()

# We will clean up all flags which were added by the cmake itself, 
# because all those flags will be specifically added by the platforms

foreach(__LANG "CXX" "C" "OBJCXX" "OBJC")

	set(CMAKE_${__LANG}_FLAGS "")

	foreach(__BUILD_TYPE IN LISTS __POSSIBLE_BUILD_TYPES)
		string(TOUPPER "${__BUILD_TYPE}" __BUILD_TYPE)
		set(CMAKE_${__LANG}_FLAGS_${__BUILD_TYPE} "")
	endforeach()
endforeach()

############### Processing some defines ###############
# Build type defines - more platform-specific ones can be in detect.py.

# DEBUG_ENABLED enables debugging *features* and debug-only code, which is intended
# to give *users* extra debugging information for their game development.
target_compile_definitions(global-env INTERFACE $<${IS_DEBUG_INFO_GEN_EXPR}:DEBUG_ENABLED>)

# DEV_ENABLED enables *engine developer* code which should only be compiled for those
# working on the engine itself.
target_compile_definitions(global-env INTERFACE $<${IS_DEBUG_GEN_EXPR}:DEV_ENABLED>)

if(GODOT_USE_PRECISE_MATH_CHECKS)
	target_compile_definitions(global-env INTERFACE "PRECISE_MATH_CHECKS")
endif()

if(GODOT_NO_EDITOR_SPLASH)
	target_compile_definitions(global-env INTERFACE "NO_EDITOR_SPLASH")
endif()

if(NOT GODOT_DEPRECATED)
	target_compile_definitions(global-env INTERFACE "DISABLE_DEPRECATED")
endif()

target_compile_definitions(global-env INTERFACE 
	$<${IS_DEBUG_GEN_EXPR}:DEBUG_MEMORY_ALLOC;DISABLE_FORCED_INLINE> # if we are in the full debug..
	$<${IS_RELEASE_GEN_EXPR}:NDEBUG> # if we are the full release..
)

# are we using MSVC..
set(__IS_MSVC_GEN_EXPR $<BOOL:${MSVC}>)

# are we using gcc..
set(__IS_GCC_GEN_EXPR
	$<OR:$<CXX_COMPILER_ID:GNU>,$<C_COMPILER_ID:GNU>,$<OBJCXX_COMPILER_ID:GNU>,$<OBJC_COMPILER_ID:GNU>>)

# are we using clang.......
set(__IS_CLANG_GEN_EXPR
	$<OR:$<CXX_COMPILER_ID:Clang>,$<C_COMPILER_ID:Clang>,$<OBJCXX_COMPILER_ID:Clang>,$<OBJC_COMPILER_ID:Clang>>)

# if compiler for c/cxx is gcc and its version is >= 7.0.0
set(__CXX_GCC_7VER_GEN_EXPR 		$<AND:$<CXX_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,7.0.0>>)
set(__C_GCC_7VER_GEN_EXPR 			$<AND:$<C_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<C_COMPILER_VERSION>,7.0.0>>)
set(__OBJCXX_GCC_7VER_GEN_EXPR 		$<AND:$<OBJCXX_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<OBJCXX_COMPILER_VERSION>,7.0.0>>)
set(__OBJC_GCC_7VER_GEN_EXPR 		$<AND:$<OBJC_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<OBJC_COMPILER_VERSION>,7.0.0>>)

set(__GCC_7VER_GEN_EXPR 
	$<OR:${__CXX_GCC_7VER_GEN_EXPR},${__C_GCC_7VER_GEN_EXPR},${__OBJCXX_GCC_7VER_GEN_EXPR},${__OBJC_GCC_7VER_GEN_EXPR}>)

# if compiler for c/cxx is gcc and its version is >= 9.0.0
set(__CXX_GCC_9VER_GEN_EXPR 		$<AND:$<CXX_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,9.0.0>>)
set(__C_GCC_9VER_GEN_EXPR 			$<AND:$<C_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<C_COMPILER_VERSION>,9.0.0>>)
set(__OBJCXX_GCC_9VER_GEN_EXPR 		$<AND:$<OBJCXX_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<OBJCXX_COMPILER_VERSION>,9.0.0>>)
set(__OBJC_GCC_9VER_GEN_EXPR 		$<AND:$<OBJC_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:$<OBJC_COMPILER_VERSION>,9.0.0>>)

set(__GCC_9VER_GEN_EXPR 
	$<OR:${__CXX_GCC_9VER_GEN_EXPR},${__C_GCC_9VER_GEN_EXPR},${__OBJCXX_GCC_9VER_GEN_EXPR},${__OBJC_GCC_9VER_GEN_EXPR}>)

target_compile_options(global-env INTERFACE $<${__IS_MSVC_GEN_EXPR}:/EHsc;/utf-8>)

if(GODOT_DEV)
	set(GODOT_WARNINGS "extra")
	set(GODOT_WERROR TRUE)
endif()

if(GODOT_PRODUCTION)
	set(GODOT_USE_STATIC_CPP TRUE)
	set(GODOT_USE_LTO TRUE)
	if(MSVC)
		message(FATAL_ERROR 
			"WARNING: For `production` Windows builds, you should use MinGW with GCC "
			"or Clang instead of Visual Studio, as they can better optimize the "
			"GDScript VM in a very significant way. MSVC LTO also doesn't work "
			"reliably for our use case."
			"If you want to use MSVC nevertheless for production builds, set "
			"`GODOT_USE_LTO=FALSE` and use 'Release' or 'MinSizeRel' targets instead of the `GODOT_PRODUCTION=TRUE` option.")
	endif()
endif()

cmake_language(CALL ${GODOT_PLATFORM}_configure_platform)

# applying warnings level

set(__MSVC_DISABLE_WARNINGS "/wd4267" "/wd4244" "/wd4305" "/wd4018" "/wd4800")
set(__GNU_COMMON_WARNINGS 
	# only for gcc
	$<${__IS_GCC_GEN_EXPR}:-Wno-misleading-indentation>
	# only for gcc greater then 7.0.0
	$<${__GCC_7VER_GEN_EXPR}:-Wshadow-local>
	# only for clang
	# TODO: here also must be emcc (aka Emscripten Compiler Frontend), but I'm not sure how to check it in cmake
	$<${__IS_CLANG_GEN_EXPR}:-Wno-ordered-compare-function-pointers>
)	

if (GODOT_WARNINGS STREQUAL "extra")

	target_compile_options(warnings-env INTERFACE
		# only for MSVC
		$<${__IS_MSVC_GEN_EXPR}:/Wall>
		# general parameters for not MSVC
		$<$<NOT:${__IS_MSVC_GEN_EXPR}>:-Wall;-Wextra;-Wwrite-strings;-Wno-unused-parameter;${__COMMON_WARNINGS}> 
		# not MSVC, only for c++
		$<$<AND:$<NOT:${__IS_MSVC_GEN_EXPR}>,$<COMPILE_LANGUAGE:CXX>>:-Wctor-dtor-privacy;-Wnon-virtual-dtor> 
		# only for gcc
		$<${__IS_GCC_GEN_EXPR}:-Walloc-zero;-Wduplicated-branches;-Wduplicated-cond;-Wstringop-overflow=4;-Wlogical-op>  
		# only for gcc c++
		$<$<COMPILE_LANG_AND_ID:CXX,GNU>-Wnoexcept;-Wplacement-new=1>  
		# only for gcc greater then 9.0.0
		$<${__GCC_9VER_GEN_EXPR}:-Wattribute-alias=2> 
	)

elseif(GODOT_WARNINGS STREQUAL "all")

	target_compile_options(warnings-env INTERFACE
		$<IF:${__IS_MSVC_GEN_EXPR},/W3;${__MSVC_DISABLE_WARNINGS},-Wall;${__GNU_COMMON_WARNINGS}>)

elseif(GODOT_WARNINGS STREQUAL "moderate")

	target_compile_options(warnings-env INTERFACE
		$<IF:${__IS_MSVC_GEN_EXPR},/W2;${__MSVC_DISABLE_WARNINGS},-Wall;-Wno-unused;${__GNU_COMMON_WARNINGS}>)

else()
	
	target_compile_options(warnings-env INTERFACE
		$<IF:${__IS_MSVC_GEN_EXPR},/w,-w>)

endif()

# applying errors if warnings

if(GODOT_WERROR)

	target_compile_options(warnings-env INTERFACE
		$<IF:${__IS_MSVC_GEN_EXPR},/WX,-Werror>)

else()

	target_compile_options(warnings-env INTERFACE 
		# only for non MSVC 			
		$<$<NOT:${__IS_MSVC_GEN_EXPR}>:-Werror=return-type>)

endif()


############### Configuring modules ###############

# just to keep track of all classes
set(MODULES_CLASSES "")
# just to keep track of all unique classes directories paths
set(CLASSES_DOC_PATHS "")
# to keep track of all icons paths
set(MODULES_ICONS_PATHS "")
# Actually enabled modules which can be built
set(MODULES_LIST "") 

foreach(__MODULE_ID IN LISTS MODULES_IDS)

	# just to be sure
	unset(${__MODULE_ID}_MODULE_DOC_CLASSES)
	unset(${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH)
	unset(${__MODULE_ID}_MODULE_CAN_BUILD)
	unset(${__MODULE_ID}_ICONS_PATH)
	
	if(NOT ${__MODULE_ID}_IS_MODULE_ENABLED)
		continue()
	endif()

	# all functions allready was included when we parsed modules, 
	# so there is not need for additional include
	cmake_language(CALL ${__MODULE_ID}_get_module_can_build ${__MODULE_ID}_MODULE_CAN_BUILD)

	if(${__MODULE_ID}_MODULE_CAN_BUILD)

		cmake_language(CALL ${__MODULE_ID}_configure_module)

		# configuring documentation
		if(COMMAND "${__MODULE_ID}_get_doc_classes" AND COMMAND "${__MODULE_ID}_get_doc_relative_path")
			cmake_language(CALL "${__MODULE_ID}_get_doc_classes" ${__MODULE_ID}_MODULE_DOC_CLASSES)
			cmake_language(CALL "${__MODULE_ID}_get_doc_relative_path" ${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH)

			join_paths(__DOC_ABS_PATH "${${__MODULE_ID}_MODULE_PATH}" "${${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH}")
			
			if (NOT __DOC_ABS_PATH IN_LIST CLASSES_DOC_PATHS) 
				list(APPEND CLASSES_DOC_PATHS "${__DOC_ABS_PATH}")
			endif()

			foreach(__MODULE_CLASS IN LISTS ${__MODULE_ID}_MODULE_DOC_CLASSES)
				if (DEFINED ${__MODULE_CLASS}_CLASS_PATH)
					# if class allready was defined.
					message(WARNING "Class with the name \"__MODULE_CLASS\" already was defined by another module. Old class path is \"${${__MODULE_CLASS}_CLASS_PATH}\". New class path is \"${__DOC_ABS_PATH}\". New class documentation will be discarded.")
					continue()
				endif()

				# setting path of the specific class
				set(${__MODULE_CLASS}_CLASS_PATH "${__DOC_ABS_PATH}")
				list(APPEND MODULES_CLASSES "${__MODULE_CLASS}")
			endforeach()
		endif()

		# configuring icons
		if(COMMAND "${__MODULE_ID}_get_relative_icon_path")
			cmake_language(CALL "${__MODULE_ID}_get_relative_icon_path" __ICON_DIR)
		else()
			set(__ICON_DIR "icons")
		endif()
		# just to keep track of it
		join_paths(${__MODULE_ID}_ICONS_PATH "${${__MODULE_ID}_MODULE_PATH}" "${__ICON_DIR}")
		list(APPEND MODULES_ICONS_PATHS "${${__MODULE_ID}_ICONS_PATH}")

		list(APPEND MODULES_LIST "${__MODULE_ID}")

	endif()

endforeach()

get_target_property(__MODULE_VERSION_STRING global-env MODULE_VERSION_STRING)
execute_python_method(methods update_version
	PYTHON_ARGS
		STR_VAR "__MODULE_VERSION_STRING"
)

# If I correct, order of suffixes should work like that:
# 1. Suffix specified by the platform (or the platform name itself)
# 2. ".opt" if build is optimized
# 3. Debug suffix (.debug or .tools if tools enabled)
# 4. Processor bits count (.64/.32)
# 5. Anything user specifies in GODOT_EXTRA_SUFFIX
# 6. Anything platform will add in <platform_id>_configure_platform method
# And only for godot main program:
# 7. Anything modules could have added into MODULE_VERSION_STRING (specifically mono)

# Processing suffix for the godot program and libraries
# This variable will be used by add_lib and add_exe functions,
# as a default suffix for libraries and executables.
set(__SUFFIX "")

if(COMMAND "${GODOT_PLATFORM}_get_program_suffix")
	cmake_language(CALL "${GODOT_PLATFORM}_get_program_suffix" __${GODOT_PLATFORM}_PROGRAM_SUFFIX)
else()
	set(__${GODOT_PLATFORM}_PROGRAM_SUFFIX ${GODOT_PLATFORM})
endif()

set(__SUFFIX "${__SUFFIX}.${__${GODOT_PLATFORM}_PROGRAM_SUFFIX}")

# extra suffix for all optimized versions
set(__SUFFIX "${__SUFFIX}$<${IS_OPTIMIZED_GEN_EXPR}:.opt>")

# extra suffix for all versions with debug info 
if(GODOT_BUILD_TOOLS)
	set(__SUFFIX "${__SUFFIX}$<${IS_DEBUG_INFO_GEN_EXPR}:.tools>")
else()
	set(__SUFFIX "${__SUFFIX}$<${IS_DEBUG_INFO_GEN_EXPR}:.debug>") 
endif()

set(__SUFFIX "${__SUFFIX}.${PROCESSOR_BITS}")

if(NOT GODOT_EXTRA_SUFFIX STREQUAL "")
	set(__SUFFIX "${__SUFFIX}.${GODOT_EXTRA_SUFFIX}")
endif()

# Prepend extra suffix
get_target_property(__EXTRA_SUFFIX global-env EXTRA_SUFFIX)
set_target_properties(global-env PROPERTIES EXTRA_SUFFIX "${__SUFFIX}${__EXTRA_SUFFIX}")

############### Processing some defines after modules were processed ###############

get_target_property(__USE_PTRCALL global-env USE_PTRCALL)

if(__USE_PTRCALL)
	target_compile_definitions(global-env INTERFACE "PTRCALL_ENABLED")
endif()

if(GODOT_BUILD_TOOLS)
	target_compile_definitions(global-env INTERFACE "TOOLS_ENABLED")
endif()

if (GODOT_DISABLE_3D)

	assert("Build option 'GODOT_DISABLE_3D=true' cannot be used with 'GODOT_BUILD_TOOLS=true' (editor), only with 'GODOT_BUILD_TOOLS=false' (export template)."
		NOT GODOT_BUILD_TOOLS
	)

	target_compile_definitions(global-env INTERFACE "_3D_DISABLED") 
endif()

if (GODOT_DISABLE_ADVANCE_GUI)
	
	assert("Build option 'GODOT_DISABLE_ADVANCE_GUI=true' cannot be used with 'GODOT_BUILD_TOOLS=true' (editor), only with 'GODOT_BUILD_TOOLS=false' (export template)."
		NOT GODOT_BUILD_TOOLS
	)
	
	target_compile_definitions(global-env INTERFACE "ADVANCED_GUI_DISABLED") 
endif()

if (GODOT_MINIZIP)
	target_compile_definitions(global-env INTERFACE "MINIZIP_ENABLED") 
endif()

# detecting some modules which requred for the tools
foreach(__MODULE_ID "freetype")
	if (NOT ${__MODULE_ID}_IS_MODULE_ENABLED)
		
		if(GODOT_BUILD_TOOLS)
			set(GODOT_BUILD_TOOLS false)
			message(WARNING "Because of build option '${__MODULE_ID}_IS_MODULE_ENABLED=false', and usage of multiconfigurational generator, the tools will be turened off.")
			break() # tools are already off, nothing to check
		endif()

	endif()	
endforeach()

# this is basically a library to hold all the other main libraries (like cor-lib, scene-lib, modules-lib etc.)
add_library(global-libs-list INTERFACE)

# Just for eazy access to the mechanism of globals libs registration. 
function(register_global_lib __NAME)
	target_link_libraries(global-libs-list INTERFACE "${__NAME}")
endfunction()

add_subdirectory(core)
add_subdirectory(servers)
add_subdirectory(scene)
add_subdirectory(editor)
add_subdirectory(drivers)
add_subdirectory(platform)
add_subdirectory(modules)
add_subdirectory(main)

add_subdirectory("platform/${GODOT_PLATFORM}")
