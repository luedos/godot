cmake_minimum_required (VERSION 3.20.0)
project (godot VERSION 4.3.0 LANGUAGES CXX C ASM)

# Seting defualt language standarts. 
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Just for all hardcoded folders out there.
set(ENGINE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

# package config is used by the project here and there
find_package(PkgConfig QUIET)
find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
message(STATUS "Found python: ${PYTHON_EXECUTABLE}")

# First of all, including all needed functions
include(methods.cmake)

############### Processing platforms ###############

# Platform of the godot is decided by the system,
# and if you want to change it, you must change CMAKE_SYSTEM_NAME.
# Because this will not only let the godot know which platform you are using,
# but also cmake itself, which then will instruct compiler as well.
# For that is suggested to write some toolchain files.
# That said, you also has the ability to override godot platform, in toolchain file or console for example,
# by specifying godot_platform variable. That is useful if you want something like "server" as a platform.
if ("${godot_platform}" STREQUAL "")
	string(TOLOWER "${CMAKE_SYSTEM_NAME}" __SYSTEM_NAME)
	if(__SYSTEM_NAME MATCHES "(windows|win32)")
		set(godot_platform "windows") # windows case
	elseif(__SYSTEM_NAME MATCHES "(linux)")
		set(godot_platform "linuxbsd")
	else()
		# For now we are not supporting any other platforms..
		message(FATAL_ERROR "Platform \"${CMAKE_SYSTEM_NAME}\" is not supported.")
	endif()
endif()

# Just in case we provided platform from some options
if (godot_platform STREQUAL "osx")
	message(WARNING "Platform \"osx\" has been renamed to \"macos\" in Godot 4. Building for platform \"macos\".")
	set(godot_platform "macos")
elseif (godot_platform STREQUAL "iphone")
	message(WARNING "Platform \"iphone\" has been renamed to \"ios\" in Godot 4. Building for platform \"ios\".")
	set(godot_platform "ios")
elseif(godot_platform MATCHES "(linux|dragonfly|freebsd|netbsd|openbsd|x11)")
	if (godot_platform STREQUAL "x11")
		message(WARNING "Platform \"x11\" has been renamed to \"linuxbsd\" in Godot 4.0. Building for platform \"linuxbsd\".")
	endif()
	set(godot_platform "linuxbsd")
elseif (godot_platform STREQUAL "javascript")
	message(WARNING "Platform \"javascript\" has been renamed to \"web\" in Godot 4. Building for platform \"web\".")
	set(godot_platform "web")
endif()

message(STATUS "Godot detected platform: '${godot_platform}'.")

############### Processing processor ###############

set(PROCESSOR_IS_X86_32 FALSE)
set(PROCESSOR_IS_X86_64 FALSE)
set(PROCESSOR_IS_ARM32 FALSE)
set(PROCESSOR_IS_ARM64 FALSE)
set(PROCESSOR_IS_PPC32 FALSE)
set(PROCESSOR_IS_PPC64 FALSE)
set(PROCESSOR_IS_WASM32 FALSE)
set(PROCESSOR_IS_RV64 FALSE)

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" __PROCESSOR_ARCHITECTURE)
if(godot_platform STREQUAL "android")
	string(TOLOWER "${CMAKE_ANDROID_ARCH}" __PROCESSOR_ARCHITECTURE)
endif()

set(PROCESSOR_ARCH_ALIAS "")

if (__PROCESSOR_ARCHITECTURE MATCHES "(^x86$)|(^x86_32$)|(^i.86$)")
	set(PROCESSOR_IS_X86_32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "x86_32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(^x86_64)|(x64)|(amd64)")
	set(PROCESSOR_IS_X86_64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "x86_64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(armv7|arm32)")
	set(PROCESSOR_IS_ARM32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "arm32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(armv8|arm64v8|aarch64|arm64)")
	set(PROCESSOR_IS_ARM64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "arm64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(ppcle)|(^ppc$)|(ppc32)")
	set(PROCESSOR_IS_PPC32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "ppc32")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(ppc64le|ppc64)")
	set(PROCESSOR_IS_PPC64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "ppc64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "(rv|riscv|riscv64)")
	set(PROCESSOR_IS_RV64 TRUE)
	set(PROCESSOR_ARCH_ALIAS "rv64")
elseif (__PROCESSOR_ARCHITECTURE MATCHES "wasm32")
	set(PROCESSOR_IS_WASM32 TRUE)
	set(PROCESSOR_ARCH_ALIAS "wasm32")
else()
	# This is mostly mean that our script will go blind folded into build process, 
	# but that doesn't necessarily mean that build will failed.
	set(PROCESSOR_ARCH_ALIAS "${__PROCESSOR_ARCHITECTURE}")
	message(WARNING "The target architecture \"${__PROCESSOR_ARCHITECTURE}\" wasn't processed, this can lead to some problems in build time")
endif()

set(PROCESSOR_BITS 64)
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(PROCESSOR_BITS 32)
endif()

############### Creating default parameters ###############

# Important note: even though all option variables here is cache variables, when we referencing them we only use simple variant, so some variables can be overridden.
# Another important note: even though every variable in cmake is upper case, options use strictly lower case. This is done to have at least some comparability with scons options which is important for build profile.
# Options are not fully comparable with their scons counterparts, but the main difference is just a 'godot_' suffix in front of them.

# Target build options
set_string_option   (godot_bin_directory            "bin/$<CONFIG>"     DESCRIPTION "Build directory. (can use generator expression). If not absolute, will be relative to CMAKE_BINARY_DIR (aka directory where you configured your cmake).")
set_string_option   (godot_target                   "editor"            DESCRIPTION "Compilation target." ENUM "editor" "template_release" "template_debug")
set_bool_option     (godot_dev_build                FALSE               DESCRIPTION "Developer build with dev-only debugging code (DEV_ENABLED).")
set_bool_option     (godot_debug_symbols            FALSE               DESCRIPTION "Build with debugging symbols.")
set_bool_option     (godot_separate_debug_symbols   FALSE               DESCRIPTION "Build with debugging symbols.")
set_string_option   (godot_lto                      "none"              DESCRIPTION "Link-time optimization (production builds)." ENUM "none" "auto" "thin" "full")
set_string_option   (godot_lto_jobs_count	        "4"              	DESCRIPTION "Link-time optimization number of jobs (production builds). This additional configuration used here because cmake configures number of compilation jobs at build time, so we can't know it at configuration time, and we need it to setup lto properly.")
set_bool_option     (godot_production               FALSE               DESCRIPTION "Set defaults to build Godot for use in production.")
set_bool_option     (godot_threads                  TRUE                DESCRIPTION "Enable threading support.")

# Components
set_bool_option     (godot_deprecated               TRUE                DESCRIPTION "Enable deprecated features.")
set_string_option   (godot_precision                "single"            DESCRIPTION "Set the floating-point precision level." ENUM "single" "double")
set_bool_option     (godot_minizip                  TRUE                DESCRIPTION "Enable ZIP archive support using minizip.")
set_bool_option     (godot_brotli                   TRUE                DESCRIPTION "Enable Brotli for decompresson and WOFF2 fonts support.")
set_bool_option     (godot_xaudio2                  FALSE               DESCRIPTION "Enable the XAudio2 audio driver.")
set_bool_option     (godot_vulkan                   TRUE                DESCRIPTION "Enable the vulkan rendering driver.")
set_bool_option     (godot_opengl3                  TRUE                DESCRIPTION "Enable the OpenGL/GLES3 rendering driver.")
set_bool_option     (godot_d3d12                    FALSE               DESCRIPTION "Enable the Direct3D 12 rendering driver.")
set_bool_option     (godot_openxr                   TRUE                DESCRIPTION "Enable the OpenXR driver.")
set_bool_option     (godot_use_volk                 TRUE                DESCRIPTION "Use the volk library to load the Vulkan loader dynamically.")
set_bool_option     (godot_disable_exceptions       TRUE                DESCRIPTION "Force disabling exception handling code.")
set_string_option   (godot_custom_modules           ""                  DESCRIPTION "A list of semicolum-separated directory paths containing custom modules to build.")
set_bool_option     (godot_custom_modules_recursive TRUE                DESCRIPTION "Detect custom modules recursively for each specified path.")

# Advanced options
set_bool_option     (godot_dev_mode                 FALSE               DESCRIPTION "Alias for dev options: verbose=yes warnings=extra werror=yes tests=yes.")
set_bool_option     (godot_tests                    FALSE               DESCRIPTION "Build the unit tests.")

set_string_option   (godot_warnings                 "all"               DESCRIPTION "Level of compilation warnings." ENUM "extra" "all" "moderate" "no")
set_bool_option     (godot_werror                   FALSE               DESCRIPTION "Treat compiler warnings as errors.")

set_string_option   (godot_extra_suffix             ""                  DESCRIPTION "Custom extra suffix added to the base filename of all generated binary files.")
set_bool_option     (godot_disable_3d               FALSE               DESCRIPTION "Disable 3D nodes for a smaller executable.")
set_bool_option     (godot_disable_advance_gui      FALSE               DESCRIPTION "Disable advanced GUI nodes and behaviors.")
set_string_option   (godot_build_profile            ""                  DESCRIPTION "Path to a file containing a feature build profile (currently the only thing we are reading from a profile is disabled_classes).")
set_bool_option     (godot_modules_enabled_by_default TRUE              DESCRIPTION "If no, disable all modules except ones explicitly enabled.")
set_bool_option     (godot_no_editor_splash         TRUE                DESCRIPTION "Don't use the custom splash screen for the editor.")
set_string_option   (godot_system_certs_path        ""                  DESCRIPTION "Use this path as SSL certificates default for editor (for package maintainers).")
set_bool_option     (godot_use_precise_math_checks  FALSE               DESCRIPTION "Math checks use very precise epsilon (debug option).")
set_bool_option     (godot_engine_update_check      TRUE                DESCRIPTION "Enable engine update checks in the Project Manager.")
set_bool_option     (godot_steamapi                 FALSE               DESCRIPTION "Enable minimal SteamAPI integration for usage time tracking (editor only).")

# Thirdparty libraries
set_bool_option     (godot_builtin_brotli           TRUE    DESCRIPTION "Use the built-in Brotli library.")
set_bool_option     (godot_builtin_certs            TRUE    DESCRIPTION "Use the built-in SSL certificates bundles.")
set_bool_option     (godot_builtin_clipper2         TRUE    DESCRIPTION "Use the built-in Clipper2 library.")
set_bool_option     (godot_builtin_embree           TRUE    DESCRIPTION "Use the built-in Embree library.")
set_bool_option     (godot_builtin_enet             TRUE    DESCRIPTION "Use the built-in ENet library.")
set_bool_option     (godot_builtin_freetype         TRUE    DESCRIPTION "Use the built-in FreeType library.")
set_bool_option     (godot_builtin_msdfgen          TRUE    DESCRIPTION "Use the built-in MSDFgen library.")
set_bool_option     (godot_builtin_glslang          TRUE    DESCRIPTION "Use the built-in glslang library.")
set_bool_option     (godot_builtin_graphite         TRUE    DESCRIPTION "Use the built-in Graphite library.")
set_bool_option     (godot_builtin_harfbuzz         TRUE    DESCRIPTION "Use the built-in HarfBuzz library.")
set_bool_option     (godot_builtin_icu4c            TRUE    DESCRIPTION "Use the built-in ICU library.")
set_bool_option     (godot_builtin_libogg           TRUE    DESCRIPTION "Use the built-in libogg library.")
set_bool_option     (godot_builtin_libpng           TRUE    DESCRIPTION "Use the built-in libpng library.")
set_bool_option     (godot_builtin_libtheora        TRUE    DESCRIPTION "Use the built-in libtheora library.")
set_bool_option     (godot_builtin_libvorbis        TRUE    DESCRIPTION "Use the built-in libvorbis library.")
set_bool_option     (godot_builtin_libwebp          TRUE    DESCRIPTION "Use the built-in libwebp library.")
set_bool_option     (godot_builtin_wslay            TRUE    DESCRIPTION "Use the built-in wslay library.")
set_bool_option     (godot_builtin_mbedtls          TRUE    DESCRIPTION "Use the built-in mbedTLS library.")
set_bool_option     (godot_builtin_miniupnpc        TRUE    DESCRIPTION "Use the built-in miniupnpc library.")
set_bool_option     (godot_builtin_openxr           TRUE    DESCRIPTION "Use the built-in OpenXR library.")
set_bool_option     (godot_builtin_pcre2            TRUE    DESCRIPTION "Use the built-in PCRE2 library.")
set_bool_option     (godot_builtin_pcre2_with_jit   TRUE    DESCRIPTION "Use JIT compiler for the built-in PCRE2 library.")
set_bool_option     (godot_builtin_recastnavigation TRUE    DESCRIPTION "Use the built-in Recast navigation library.")
set_bool_option     (godot_builtin_rvo2_2d          TRUE    DESCRIPTION "Use the built-in RVO2 2D library.")
set_bool_option     (godot_builtin_rvo2_3d          TRUE    DESCRIPTION "Use the built-in RVO2 3D library.")
set_bool_option     (godot_builtin_squish           TRUE    DESCRIPTION "Use the built-in squish library.")
set_bool_option     (godot_builtin_xatlas           TRUE    DESCRIPTION "Use the built-in xatlas library.")
set_bool_option     (godot_builtin_zlib             TRUE    DESCRIPTION "Use the built-in zlib library.")
set_bool_option     (godot_builtin_zstd             TRUE    DESCRIPTION "Use the built-in Zstd library.")

inline_if(EDITOR_BUILD godot_target STREQUAL "editor")
inline_if(DEBUG_FEATURES godot_target MATCHES "(editor|template_debug)")

############### Finding platforms ###############

#[=[
DOCUMENTATION FOR PLATFORMS

All functions platform detect.cmake file should implement
- function(<platform_id>_get_platform_name __OUTPUT) -> returns platform name (will be stored in "<platfom_id>_PLATFROM_NAME")
- function(<platform_id>_get_is_platform_active __OUTPUT) -> returns true is platform active (will be stored in "<platfom_id>_IS_PLATFORM_ACTIVE")
- function(<platform_id>_get_can_platform_build __OUTPUT) -> returns true is platform can be built (will be stored in "<platfom_id>_PLATFROM_CAN_BUILD")
- function(<platform_id>_create_custom_options) -> will add some custom options with set_<type>_option function
- function(<platform_id>_configure_platform) -> doing all kind of stuff, like adding specific flags for compiler/linker, modifying some option etc.
- (optional) function(<platform_id>_get_program_suffix <output_variable>) -> returns some platform dependent suffix for program file

Variables which will be defined for platforms
- PLATFORMS_LIST -> buildable platforms raw names (folder names)
- PLATFORMS_EXPORTERS -> list of platform ids (raw names) which has export.cpp file
- PLATFORMS_APIS -> list of platform ids (raw names) which has api.cpp file
]=]

set(PLATFORMS_EXPORTERS "")
set(PLATFORMS_APIS "")
set(PLATFORMS_LIST "")
set(PLATFORMS_DOC_CLASSES "")
set(PLATFORMS_DOC_CLASS_PATHS "")

file_glob_dirs(__PLATFORM_DIRS "${ENGINE_SOURCE_DIR}/platform/*")

# for each available platform
foreach(__DIR IN LISTS __PLATFORM_DIRS)

	unset(__PLATFORM_ID) # just in case

	if(NOT IS_DIRECTORY "${__DIR}" OR NOT EXISTS "${__DIR}/detect.cmake")
		continue()
	endif()

	include("${__DIR}/detect.cmake")
	
	# getting platform id
	get_top_directory("${__DIR}" __PLATFORM_ID)

	if(COMMAND "${__PLATFORM_ID}_get_platform_doc_classes" AND COMMAND "${__PLATFORM_ID}_get_platform_doc_relative_path")
		cmake_language(CALL "${__PLATFORM_ID}_get_platform_doc_classes" ${__PLATFORM_ID}_PLATFORM_DOC_CLASSES)
		cmake_language(CALL "${__PLATFORM_ID}_get_platform_doc_relative_path" ${__PLATFORM_ID}_PLATFORM_DOC_RELATIVE_PATH)

		join_paths(__DOC_ABS_PATH "${__DIR}" "${${__PLATFORM_ID}_PLATFORM_DOC_RELATIVE_PATH}")
		
		if (NOT __DOC_ABS_PATH IN_LIST PLATFORMS_DOC_CLASS_PATHS) 
			list(APPEND PLATFORMS_DOC_CLASS_PATHS "${__DOC_ABS_PATH}")
		endif()

		foreach(__PLATFORM_CLASS IN LISTS ${__PLATFORM_ID}_PLATFORM_DOC_CLASSES)
			if (DEFINED ${__PLATFORM_CLASS}_CLASS_PATH)
				# if class allready was defined.
				message(WARNING "Class with the name \"${__PLATFORM_CLASS}\" already was defined by another platform. Old class path is \"${${__PLATFORM_CLASS}_CLASS_PATH}\". New class path is \"${__DOC_ABS_PATH}\". New class documentation will be discarded.")
				continue()
			endif()

			# setting path of the specific class
			set(${__PLATFORM_CLASS}_CLASS_PATH "${__DOC_ABS_PATH}")
			list(APPEND PLATFORMS_DOC_CLASSES "${__PLATFORM_CLASS}")
		endforeach()
	endif()

	# just to be sure
	unset(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

	# if export file exist 
	if(EXISTS "${__DIR}/export/export.cpp")
		list(APPEND PLATFORMS_EXPORTERS "${__PLATFORM_ID}")
	endif()

	# if api file exist
	if(EXISTS "${__DIR}/api/api.cpp")
		list(APPEND PLATFORMS_APIS "${__PLATFORM_ID}")
	endif()

	# if platform can be built (must be defined in detect.cmake)
	cmake_language(CALL "${__PLATFORM_ID}_get_can_platform_build" ${__PLATFORM_ID}_PLATFROM_CAN_BUILD)
	if(${__PLATFORM_ID}_PLATFROM_CAN_BUILD)

		list(APPEND PLATFORMS_LIST "${__PLATFORM_ID}")
		if(__PLATFORM_ID STREQUAL godot_platform)
			cmake_language(CALL "${__PLATFORM_ID}_create_custom_options")
		endif()

		set(${__PLATFORM_ID}_SUPPORTED_LIST "")
		if (COMMAND "${__PLATFORM_ID}_get_platform_supported")
			cmake_language(CALL "${__PLATFORM_ID}_get_platform_supported" ${__PLATFORM_ID}_SUPPORTED_LIST)
		endif()
	endif()
endforeach()

set_string_option(godot_platform "${godot_platform}" DESCRIPTION "Target platform." ENUM ${PLATFORMS_LIST})

if(NOT godot_platform IN_LIST PLATFORMS_LIST)
	message(FATAL_ERROR "Platform \"${godot_platform}\" can't be found in active platforms (${PLATFORMS_LIST}). Maybe current platform \"${CMAKE_SYSTEM_NAME}\" is not supported yet.")
elseif(NOT ${godot_platform}_PLATFROM_CAN_BUILD)
	message(FATAL_ERROR "Platform \"${godot_platform}\" exist, but can't be built.")
endif()


############### Utility setup ###############

# Generator expressions for easier working with build types which can be used in the future.
set(IS_OPT_GEN_EXPR $<CONFIG:Release,RelWithDebInfo,MinSizeRel>)
set(IS_OPT_NONE_GEN_EXPR $<CONFIG:Debug>)
set(IS_OPT_SIZE_GEN_EXPR $<CONFIG:MinSizeRel>)
set(IS_OPT_SPEED_GEN_EXPR $<CONFIG:Release,RelWithDebInfo>)
set(IS_OPT_DEBUG_GEN_EXPR $<CONFIG:RelWithDebInfo>)
set(IS_DEB_INFO_GEN_EXPR $<CONFIG:Debug,RelWithDebInfo>)

# Normilizing godot bin directory and making it absolute.
if(NOT IS_ABSOLUTE "${godot_bin_directory}")
	join_paths(godot_bin_directory "${CMAKE_BINARY_DIR}" "${godot_bin_directory}")
else()
	normilize_path(godot_bin_directory "${godot_bin_directory}")
endif()

############### Creating the environment ###############

# This is basically the analog of the SCons Environment variable.
# This environment library can be configured later, from platform/module scripts (same as it done in scons)
# In the future this can be changed..
add_env(global-env)

# setting some "global" variables, which can be appended by modules
set_target_properties(global-env 
	PROPERTIES
		USE_PTRCALL FALSE # do we need to define PTRCALL_ENABLED. This variable can be overriten on module configuration
		X86_LIBTHEORA_OPT_GCC FALSE
		X86_LIBTHEORA_OPT_VC FALSE
		EXTRA_SUFFIX ""
)

# some thirdparty libs does not have warnings in them, so we will create separate environment to handle all warnings levels
add_env(global-warnings-env)
add_env(thirdparty-warnings-env)

############### Processing modules ###############

#[=[
DOCUMENTATION FOR MODULES

All functions modules config.cmake file should implement
- function(<module_name>_configure_module) -> configures module if needed
- function(<module_name>_get_module_can_build <output>) -> returns true if module can be build and should be processed
- (optional) function(<module_name>_get_is_module_enabled <output>) -> to override default value of the <module_name>_IS_MODULE_ENABLED option
- (optional) function(<module_name>_get_module_dependencies <dependencies_list_output> <optional_dependencies_list_output>) -> Returns dependencies for the module
- (optional) function(<module_name>_create_custom_options) -> will add some custom options with set_<type>_option function
- (optional) function(<module_name>_get_doc_classes <output>) -> works with <module_name>_get_doc_relative_path. Used to define module classes for documentation
- (optional) function(<module_name>_get_doc_relative_path <output>) -> works with <module_name>_get_doc_classes. Used to define relative path of the module classes.
- (optional) function(<module_name>_get_relative_icon_path <output>) -> used to define icons path for module. If this function wasn't defined, default path is "icons"
- (optional) function(<module_name>_get_version_string <output>) -> used to add some specific info to the version of the current build (for now it is used only in the mono module)

Variables which will be defined for modules
- MODULES_IDS -> all modules names
- MODULES_PATHS -> all modules paths (in sync with MODULES_IDS)
- <module_name>_MODULE_PATH -> path for the specific module
- godot_module_<module_name>_enabled -> this is option (a.k.a. CACHE value) which determines is module enabled (will be processed) or not. Usually it is set up through console line, or simply through cache
- <module_name>_REQUIRED_DEPENDENCIES -> Required modules for the one <module_name> to be build
- <module_name>_OPTIONAL_DEPENDENCIES -> Optional modules which only affect module sorting
- <module_name>_MODULE_CAN_BUILD -> this variable is output from <module_name>_get_module_can_build function. Also defines if module can be built
- MODULES_CLASSES -> classses names from all modules
- <module_name>_MODULE_DOC_CLASSES -> list of classes for specific module
- <class_name>_CLASS_PATH -> path for the doc of the specific class
- <module_name>_MODULE_DOC_RELATIVE_PATH -> relative path of the modules doc folder
- <module_name>_ICONS_PATH -> icon path for specific module
- MODULES_ICONS_PATHS -> icon paths of all modules
- <module_name>_VERSION_STRING -> version string returned from '<module_name>_get_version_string' of specific module
- MODULES_VERSION_STRING -> total combined version string of all modules
- MODULES_LIST -> all modules which is enabled and will be built
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

set(__MODULES_DIRS "") # just to be sure
# Built in directories we are detecting without recursion
get_modules_paths(__BUILTIN_MODULES_DIRS "modules")

set(__ADDITIONAL_ARGS "")
if(godot_custom_modules_recursive)
	set(__ADDITIONAL_ARGS "RECURSIVE")
endif()
get_modules_paths(__CUSTOM_MODULES_DIRS ${__ADDITIONAL_ARGS} ${godot_custom_modules})

# those lists are sync with each other
set(__ALL_MODULES_IDS "") # all modules ids (a.k.a. folder names)

# processing all modules
macro(detect_modules __MODULES_DIRS_VAR __MODULES_IDS_VAR)
	foreach(__DIR IN LISTS ${__MODULES_DIRS_VAR})
		# just in case..
		normilize_path(__DIR "${__DIR}" ABSOLUTE)

		is_module("${__DIR}" __MODULE_VALID)
		if(NOT __MODULE_VALID)
			message(WARNING "Provided module by the path '${__DIR}'' is not valid, and can't be processed..")
			continue()
		endif()

		get_top_directory("${__DIR}" __MODULE_ID)

		if(__MODULE_ID IN_LIST __ALL_MODULES_IDS)
			# if module with same id was already defined..
			message(WARNING "Provided module '${__MODULE_ID}' is already defined. Old module path is '${${__MODULE_ID}_MODULE_PATH}', new module path is '${__DIR}'. New module will override old one.")
			list(REMOVE_ITEM __ALL_MODULES_IDS "${__MODULE_ID}")
		endif()

		if (__MODULE_ID IN_LIST ${__MODULES_IDS_VAR})
			list(REMOVE_ITEM ${__MODULES_IDS_VAR} "${__MODULE_ID}")
		endif()

		# appending module id to the list
		list(APPEND __ALL_MODULES_IDS "${__MODULE_ID}")
		list(APPEND ${__MODULES_IDS_VAR} "${__MODULE_ID}")
		set(${__MODULE_ID}_MODULE_PATH "${__DIR}")

	endforeach()
endmacro()


set(__BUILTIN_MODULES_IDS "")
set(__CUSTOM_MODULES_IDS "")
detect_modules(__BUILTIN_MODULES_DIRS __BUILTIN_MODULES_IDS)
detect_modules(__CUSTOM_MODULES_DIRS __CUSTOM_MODULES_IDS)

list(REMOVE_ITEM __BUILTIN_MODULES_IDS ${__CUSTOM_MODULES_IDS})

set(MODULES_IDS ${__BUILTIN_MODULES_IDS} ${__CUSTOM_MODULES_IDS})
set(MODULES_PATHS "") # all modules paths
# Then processing selected modules without duplicates.
foreach (__MODULE_ID IN LISTS MODULES_IDS)

	# Resetting some variables just in case
	set(${__MODULE_ID}_REQUIRED_DEPENDENCIES "")
	set(${__MODULE_ID}_OPTIONAL_DEPENDENCIES "")

	set(__MODULE_DIR "${${__MODULE_ID}_MODULE_PATH}")

	list(APPEND MODULES_PATHS "${__MODULE_DIR}")

	include("${__MODULE_DIR}/config.cmake")

	set(__MODULE_ENABLED FALSE)
	# if we are not already provided that property..
	if (NOT DEFINED godot_module_${__MODULE_ID}_enabled)
		if (godot_modules_enabled_by_default)
			set(__MODULE_ENABLED TRUE)
		endif()

		# if module can give us answer
		if(COMMAND ${__MODULE_ID}_get_is_module_enabled) 
			cmake_language(CALL ${__MODULE_ID}_get_is_module_enabled __MODULE_ENABLED)
		elseif (__MODULE_ENABLED)
			# Just so we will not get annoying warnings later, we will disable module by default if we can't built it
			cmake_language(CALL ${__MODULE_ID}_get_module_can_build __MODULE_ENABLED)
		endif()

	endif()

	set_bool_option(godot_module_${__MODULE_ID}_enabled "${__MODULE_ENABLED}" DESCRIPTION "Enable module '${__MODULE_ID}'.")	

	if (COMMAND ${__MODULE_ID}_create_custom_options)
		cmake_language(CALL ${__MODULE_ID}_create_custom_options)
	endif()
endforeach()

# Provide default include path for both the custom module search `path`
# and the base directory containing custom modules, as it may be different
# from the built-in "modules" name (e.g. "custom_modules/summator/summator.h"),
# so it can be referenced simply as `#include "summator/summator.h"`
# independently of where a module is located on user's filesystem.

set(__ADDITIONAL_INCLUDES "")
foreach(__MODULE_ID IN LISTS __CUSTOM_MODULES_IDS)
	set(__MODULE_DIR "${__MODULE_ID}_MODULE_PATH")
	get_filename_component(__MODULE_PARENT_DIR "${__MODULE_DIR}" DIRECTORY)
	get_filename_component(__MODULES_BASE_DIR "${__MODULE_PARENT_DIR}" DIRECTORY)

	list(APPEND __ADDITIONAL_INCLUDES "${__MODULE_PARENT_DIR}" "${__MODULES_BASE_DIR}")
endforeach()

list(REMOVE_DUPLICATES __ADDITIONAL_INCLUDES)
target_include_directories(global-env INTERFACE ${__ADDITIONAL_INCLUDES})

############### Processing build profile ###############

set(__DISABLED_CLASSES_RAW_ARRAY "[]")
if (NOT "${godot_build_profile}" STREQUAL "")
	normilize_path(__PROFILE_NORMILIZED_PATH "${godot_build_profile}" ABSOLUTE)

	message(STATUS "Using feature build profile: ${__PROFILE_NORMILIZED_PATH}")
	file(READ "${__PROFILE_NORMILIZED_PATH}" __PROFILE_JSON_CONTENT)

	################# reading disabled_classes #################
	string(JSON
		__DISABLED_CLASSES_RAW_ARRAY
		ERROR_VARIABLE __TEMP_ERROR_VAR
		GET "${__PROFILE_JSON_CONTENT}" "disabled_classes"
	)

	if (NOT "${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND")
		message(FATAL_ERROR "Failed to read 'disabled_classes' from build profile.")
	endif()
	string(REGEX REPLACE "(\n)" "" __DISABLED_CLASSES_RAW_ARRAY "${__DISABLED_CLASSES_RAW_ARRAY}")

	################# reading disabled_build_options #################

	string(JSON
		__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY
		ERROR_VARIABLE __TEMP_ERROR_VAR
		GET "${__PROFILE_JSON_CONTENT}" "disabled_build_options"
	)

	if (NOT "${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND")
		message(FATAL_ERROR "Failed to read 'disabled_build_options' from build profile.")
	endif()
	string(REGEX REPLACE "(\n)" "" __DISABLED_BUILD_OPTIONS_RAW_DICTIONARY "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}")

	set(__DISABLED_BUILD_OPTIONS_COUNT 0)
	string(JSON
		__DISABLED_BUILD_OPTIONS_COUNT
		ERROR_VARIABLE __TEMP_ERROR_VAR
		LENGTH "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}"
	)

	if ("${__TEMP_ERROR_VAR}" STREQUAL "NOTFOUND" AND NOT __DISABLED_BUILD_OPTIONS_COUNT EQUAL 0)
		math(EXPR __DISABLED_BUILD_OPTIONS_COUNT "${__DISABLED_BUILD_OPTIONS_COUNT} - 1")
		foreach (__OPTION_INDEX RANGE ${__DISABLED_BUILD_OPTIONS_COUNT})
			string(JSON
				__OPTION_NAME
				MEMBER "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}" ${__OPTION_INDEX}
			)
			string(JSON
				__OPTION_VALUE
				GET "${__DISABLED_BUILD_OPTIONS_RAW_DICTIONARY}" "${__OPTION_NAME}"
			)

			message(STATUS "Overriding build option 'godot_${__OPTION_NAME}' with value '${__OPTION_VALUE}'.")
			set("godot_${__OPTION_NAME}" "${__OPTION_VALUE}")
		endforeach()
	endif()
endif()

execute_python_method(cmake_methods write_disabled_classes
	PYTHON_ARGS
		RAW_VAR "__DISABLED_CLASSES_RAW_ARRAY"
	ACTION_CACHE_NAME "write_disabled_classes"
	DEPENDENT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/core/disabled_classes.gen.h"
)

############### Global defines setup ###############

target_include_directories(global-env INTERFACE "${ENGINE_SOURCE_DIR}")

if (EDITOR_BUILD)
	target_compile_definitions(global-env INTERFACE "TOOLS_ENABLED")
endif()

# DEBUG_ENABLED enables debugging *features* and debug-only code, which is intended
# to give *users* extra debugging information for their game development.
if (godot_target MATCHES "(editor|template_debug)")
	target_compile_definitions(global-env INTERFACE "DEBUG_ENABLED")
endif()

if (godot_dev_build)
	# DEV_ENABLED enables *engine developer* code which should only be compiled for those
	# working on the engine itself.
	target_compile_definitions(global-env INTERFACE "DEV_ENABLED")
else()
	target_compile_definitions(global-env INTERFACE "NDEBUG")
endif()

if (godot_use_precise_math_checks)
	target_compile_definitions(global-env INTERFACE "PRECISE_MATH_CHECKS")
endif()

if (EDITOR_BUILD)
	if (godot_engine_update_check)
		target_compile_definitions(global-env INTERFACE "ENGINE_UPDATE_CHECK_ENABLED")
	endif()

	if (NOT EXISTS "${ENGINE_SOURCE_DIR}/main/splash_editor.png")
		# Force disabling editor splash if missing.
		set(godot_no_editor_splash TRUE)
	endif()

	if (godot_no_editor_splash)
		target_compile_definitions(global-env INTERFACE "NO_EDITOR_SPLASH")
	endif()
endif()

if (NOT godot_deprecated)
	target_compile_definitions(global-env INTERFACE "DISABLE_DEPRECATED")
endif()

if (godot_precision STREQUAL "double")
	target_compile_definitions(global-env INTERFACE "REAL_T_IS_DOUBLE")
endif()

if (godot_dev_mode)
	set(godot_warnings "extra")
	set(godot_werror TRUE)
	set(godot_tests TRUE)
endif()

if (godot_production)
	set(godot_use_static_cpp TRUE)
	set(godot_debug_symbols FALSE)
	set(godot_lto "auto")
endif()

cmake_language(CALL ${godot_platform}_configure_platform)

if (godot_dev_build)
	message(STATUS "NOTE: Developer build, with debug optimization level and debug symbols (unless overridden).")
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	if ("${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "")
		message(WARNING 
			"Couldn't detect compiler version, skipping version checks. "
			"Build may fail if the compiler doesn't support C++17 fully.")
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "9")
		message(FATAL_ERROR
			"Detected GCC version older than 9, which does not fully support "
			"C++17. Supported versions are GCC 9 and later. Use a newer GCC "
			"version, or Clang 6 or later."
		)
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8.4")
		message(FATAL_ERROR
			"Detected GCC 8 version < 8.4, which is not supported due to a "
			"regression in its C++17 guaranteed copy elision support. Use a "
			"newer GCC version, or Clang 6 or later."
		)
	elseif (FALSE)
		# checking for mingw win32?
	endif()
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
	if ("${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "")
		message(WARNING 
			"Couldn't detect compiler version, skipping version checks. "
			"Build may fail if the compiler doesn't support C++17 fully."
		)
	# Apple LLVM versions differ from upstream LLVM version \o/, compare
	# in https://en.wikipedia.org/wiki/Xcode#Toolchain_versions
	elseif (godot_platform MATCHES "(macos|ios)")
		if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0")
			message(FATAL_ERROR
				"Detected Clang version older than 6, which does not fully support "
				"C++17. Supported versions are Clang 6 and later."
			)
		elseif (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0")
			message(FATAL_ERROR
				"Detected Apple Clang version older than 12, which does not fully "
				"support C++17. Supported versions are Apple Clang 10 and later."
			)
		endif()
	elseif (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0")
		message(FATAL_ERROR
			"Detected Clang version older than 6, which does not fully support "
			"C++17. Supported versions are Clang 6 and later."
		)
	endif()
endif()

if (MSVC)
	if (godot_debug_symbols)
		target_compile_options(global-env INTERFACE "/Zi" "/FS")
		target_link_options(global-env INTERFACE "/DEBUG:FULL")
	else()
		target_link_options(global-env INTERFACE "/DEBUG:NONE")
	endif()

	target_compile_options(global-env INTERFACE
		$<${IS_OPT_SPEED_GEN_EXPR}:/O2>
		$<${IS_OPT_SIZE_GEN_EXPR}:/O1>
		$<${IS_OPT_NONE_GEN_EXPR}:/Od>
	)
	target_link_options(global-env INTERFACE
		$<${IS_OPT_GEN_EXPR}:/OPT:REF>
		$<${IS_OPT_DEBUG_GEN_EXPR}:/OPT:NOICF>
	)
else()
	if (godot_debug_symbols)
		# Adding dwarf-4 explicitly makes stacktraces work with clang builds,
		# otherwise addr2line doesn't understand them
		target_compile_options(global-env INTERFACE "-gdwarf-4")
		if (CMAKE_CXX_COMPILER MATCHES "/em\\+\\+(-[a-zA-Z0-9.])?$")
			# Emscripten only produces dwarf symbols when using "-g3".
			target_compile_options(global-env INTERFACE "-g3")
			# Emscripten linker needs debug symbols options too.
			target_link_options(global-env INTERFACE "-gdwarf-4" "-g3")
		elseif (godot_dev_build)
			target_compile_options(global-env INTERFACE "-g3")
		else()
			target_compile_options(global-env INTERFACE "-g2")
		endif()
	else()
		if (CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
			target_link_options(global-env INTERFACE "-Wl,-S" "-Wl,-x" "-Wl,-dead_strip")
		else()
			target_link_options(global-env INTERFACE "-s")
		endif()
	endif()

	target_compile_options(global-env INTERFACE
		$<${IS_OPT_SPEED_GEN_EXPR}:-O3>
		$<${IS_OPT_SIZE_GEN_EXPR}:-Os>
		$<${IS_OPT_DEBUG_GEN_EXPR}:-Og>
		$<${IS_OPT_NONE_GEN_EXPR}:-O0>
	)
	target_link_options(global-env INTERFACE
		$<${IS_OPT_SPEED_GEN_EXPR}:-O3>
		$<${IS_OPT_SIZE_GEN_EXPR}:-Os>
		$<${IS_OPT_DEBUG_GEN_EXPR}:-Og>
		$<${IS_OPT_NONE_GEN_EXPR}:-O0>
	)
endif()

if (NOT godot_lto STREQUAL "none")
	message(STATUS "Using LTO: ${godot_lto}")
endif()

if (godot_disable_exceptions)
	if (MSVC)
		target_compile_definitions(global-env INTERFACE "_HAS_EXCEPTIONS=0")
	else()
		target_compile_options(global-env INTERFACE "-fno-exceptions")
	endif()
elseif (MSVS)
	target_compile_options(global-env INTERFACE "/EHsc")
endif()

# Configure compiler warnings
if (MSVC)
	target_compile_options(thirdparty-warnings-env INTERFACE "/w")

	if (godot_warnings STREQUAL "no")
		target_compile_options(global-warnings-env INTERFACE "/w")
	else()
		if (godot_warnings STREQUAL "extra")
			target_compile_options(global-warnings-env INTERFACE "/W4")
		elseif (godot_warnings STREQUAL "all")
			# C4458 is like -Wshadow. Part of /W4 but let's apply it for the default /W3 too.
			target_compile_options(global-warnings-env INTERFACE "/W3" "/w34458")
		elseif (godot_warnings STREQUAL "moderate")
			target_compile_options(global-warnings-env INTERFACE "/W2")
		endif()

		# Disable warnings which we don't plan to fix.
		target_compile_options(global-warnings-env INTERFACE 
			"/wd4100" # C4100 (unreferenced formal parameter): Doesn't play nice with polymorphism.
			"/wd4127" # C4127 (conditional expression is constant)
			"/wd4201" # C4201 (non-standard nameless struct/union): Only relevant for C89.
			"/wd4244" # C4244 C4245 C4267 (narrowing conversions): Unavoidable at this scale.
			"/wd4245"
			"/wd4267"
			"/wd4305" # C4305 (truncation): double to float or real_t, too hard to avoid.
			"/wd4514" # C4514 (unreferenced inline function has been removed)
			"/wd4714" # C4714 (function marked as __forceinline not inlined)
			"/wd4820" # C4820 (padding added after construct)
		)
	endif()

	# Set exception handling model to avoid warnings caused by Windows system headers.
	target_compile_options(global-warnings-env INTERFACE "/EHsc")

	if (godot_werror)
		target_compile_options(global-warnings-env INTERFACE "/WX")
		target_link_options(global-warnings-env INTERFACE "/WX")
	endif()
else() # GCC, Clang
	target_compile_options(thirdparty-warnings-env INTERFACE "-w")

	set(__COMMON_WARNINGS "")
	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		list(APPEND __COMMON_WARNINGS "-Wshadow" "-Wno-misleading-indentation")
		if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "7" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8")
			list(APPEND __COMMON_WARNINGS "-Wno-strict-overflow")
		endif()

		if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "11")
			# Regression in GCC 9/10, spams so much in our variadic templates
			# that we need to outright disable it.
			list(APPEND __COMMON_WARNINGS "-Wno-type-limits")
		endif()

		if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12")
			# False positives in our error macros, see GH-58747.
			list(APPEND __COMMON_WARNINGS "-Wno-return-type")
		endif()
	elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		# We often implement `operator<` for structs of pointers as a requirement
		# for putting them in `Set` or `Map`. We don't mind about unreliable ordering.
		list(APPEND __COMMON_WARNINGS
			"-Wno-ordered-compare-function-pointers"
			"-Wshadow-field-in-constructor"
			"-Wshadow-uncaptured-local"
		)
	endif()

	if (godot_warnings STREQUAL "extra")
		target_compile_options(global-warnings-env INTERFACE
			"-Wall"
			"-Wextra"
			"-Wwrite-strings"
			"-Wno-unused-parameter"
			${__COMMON_WARNINGS}
		)
		target_compile_options(global-warnings-env INTERFACE
			$<$<COMPILE_LANGUAGE:CXX>:-Wctor-dtor-privacy;-Wnon-virtual-dtor>
		)

		if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
			target_compile_options(global-warnings-env INTERFACE
				"-Walloc-zero"
				"-Wduplicated-branches"
				"-Wduplicated-cond"
				"-Wstringop-overflow=4"
			)
			target_compile_options(global-warnings-env INTERFACE
				$<$<COMPILE_LANGUAGE:CXX>:-Wplacement-new=1>
			)

			# Need to fix a warning with AudioServer lambdas before enabling.
			# if cc_version_major != 9:  # GCC 9 had a regression (GH-36325).
			#    env.Append(CXXFLAGS=["-Wnoexcept"])

			if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "9")
				target_compile_options(global-warnings-env INTERFACE "-Wattribute-alias=2")
			endif()

			if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "11")
				# Broke on MethodBind templates before GCC 11.
				target_compile_options(global-warnings-env INTERFACE "-Wlogical-op")
			endif()
		elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			target_compile_options(global-warnings-env INTERFACE "-Wimplicit-fallthrough")
		endif()
	elseif (godot_warnings STREQUAL "all")
		target_compile_options(global-warnings-env INTERFACE "-Wall" ${__COMMON_WARNINGS})
	elseif (godot_warnings STREQUAL "moderate")
		target_compile_options(global-warnings-env INTERFACE "-Wall" "-Wno-unused" ${__COMMON_WARNINGS})
	else()
		target_compile_options(global-warnings-env INTERFACE "-w")
	endif()
endif()

############### Configuring modules ###############

# just to keep track of all classes
set(MODULES_DOC_CLASSES "")
# just to keep track of all unique classes directories paths
set(MODULES_DOC_CLASS_PATHS "")
# to keep track of all icons paths
set(MODULES_ICONS_PATHS "")
# Actually enabled modules which can be built
set(MODULES_LIST "")
# Version string for the module
set(MODULES_VERSION_STRING "")

foreach (__MODULE_ID IN LISTS MODULES_IDS)
	if (NOT "${godot_module_${__MODULE_ID}_enabled}")
		continue()
	endif()

	cmake_language(CALL ${__MODULE_ID}_get_module_can_build "${__MODULE_ID}_MODULE_CAN_BUILD")

	if(NOT ${__MODULE_ID}_MODULE_CAN_BUILD)
		message(WARNING "Module '${__MODULE_ID}' was enabled, but can't be built. Skipping this module.")
		continue()
	endif()

	if (COMMAND ${__MODULE_ID}_get_module_dependencies)
		cmake_language(CALL ${__MODULE_ID}_get_module_dependencies "${__MODULE_ID}_REQUIRED_DEPENDENCIES" "${__MODULE_ID}_OPTIONAL_DEPENDENCIES")
	endif()

	check_module_dependencies(__DEPENDENCIES_MET "${__MODULE_ID}")

	if (NOT __DEPENDENCIES_MET)
		continue()
	endif()

	cmake_language(CALL ${__MODULE_ID}_configure_module)

	if (COMMAND "${__MODULE_ID}_get_version_string")
		cmake_language(CALL "${__MODULE_ID}_get_version_string" ${__MODULE_ID}_VERSION_STRING)
		if (NOT "${${__MODULE_ID}_VERSION_STRING}" STREQUAL "")
			set(MODULES_VERSION_STRING "${MODULES_VERSION_STRING}.${${__MODULE_ID}_VERSION_STRING}")
		endif()
	endif()

	# Get doc classes paths (if present)
	if(COMMAND "${__MODULE_ID}_get_doc_classes" AND COMMAND "${__MODULE_ID}_get_doc_relative_path")
		cmake_language(CALL "${__MODULE_ID}_get_doc_classes" ${__MODULE_ID}_MODULE_DOC_CLASSES)
		cmake_language(CALL "${__MODULE_ID}_get_doc_relative_path" ${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH)

		join_paths(__DOC_ABS_PATH "${${__MODULE_ID}_MODULE_PATH}" "${${__MODULE_ID}_MODULE_DOC_RELATIVE_PATH}")
		
		if (NOT __DOC_ABS_PATH IN_LIST MODULES_DOC_CLASS_PATHS) 
			list(APPEND MODULES_DOC_CLASS_PATHS "${__DOC_ABS_PATH}")
		endif()

		foreach(__MODULE_CLASS IN LISTS ${__MODULE_ID}_MODULE_DOC_CLASSES)
			if (DEFINED ${__MODULE_CLASS}_CLASS_PATH)
				# if class allready was defined.
				message(WARNING "Class with the name \"${__MODULE_CLASS}\" already was defined by another module. Old class path is \"${${__MODULE_CLASS}_CLASS_PATH}\". New class path is \"${__DOC_ABS_PATH}\". New class documentation will be discarded.")
				continue()
			endif()

			# setting path of the specific class
			set(${__MODULE_CLASS}_CLASS_PATH "${__DOC_ABS_PATH}")
			list(APPEND MODULES_DOC_CLASSES "${__MODULE_CLASS}")
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
endforeach()

# This will not be quite.. Composing modules dependencies map for python
parse_to_python_var(__PYTHON_MODULES_LIST ARR_VAR MODULES_LIST)
set(__PYTHON_DEPENDENCIES_MAP "{")
set(__FIRST TRUE)

foreach (__MODULE_ID IN LISTS MODULES_LIST)
	if (__FIRST)
		set(__FIRST FALSE)
	else()
		set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP},")
	endif()

	parse_to_python_var(__PYTHON_REQURIED_DEPENDENCIES ARR_VAR "${__MODULE_ID}_REQUIRED_DEPENDENCIES")
	parse_to_python_var(__PYTHON_OPTIONAL_DEPENDENCIES ARR_VAR "${__MODULE_ID}_OPTIONAL_DEPENDENCIES")

	set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP}'${__MODULE_ID}':[${__PYTHON_REQURIED_DEPENDENCIES},${__PYTHON_OPTIONAL_DEPENDENCIES}]")
endforeach()
set(__PYTHON_DEPENDENCIES_MAP "${__PYTHON_DEPENDENCIES_MAP}}")

execute_python_method(cmake_methods sort_module_list
	PYTHON_ARGS
		"RAW_VAR" "module_list=__PYTHON_MODULES_LIST"
		"RAW_VAR" "module_dependencies=__PYTHON_DEPENDENCIES_MAP"
	OUTPUT_VARIABLE MODULES_LIST
)

############### Processing program suffix ###############

# If I correct, order of suffixes should work like that:
# 1. Suffix specified by the platform (or the platform name itself)
# 2. Target (in our case .editor/.release/.debug)
# 3. ".dev" if godot_dev_build
# 4. ".double" if godot_precision == "double"
# 5. Architecture
# 6. Anything user specifies in godot_extra_suffix
# 7. Anything platform will add in <platform_id>_configure_platform method
# And only for godot main program:
# 8. Anything modules could have returned from _get_version_string method (specifically mono)

# Processing suffix for the godot program and libraries
# This variable will be used by add_lib and add_exe functions,
# as a default suffix for libraries and executables.
set(__SUFFIX "")

if(COMMAND "${godot_platform}_get_program_suffix")
	cmake_language(CALL "${godot_platform}_get_program_suffix" "__${godot_platform}_PROGRAM_SUFFIX")
else()
	set("__${godot_platform}_PROGRAM_SUFFIX" "${godot_platform}")
endif()

set(__SUFFIX "${__SUFFIX}.${__${godot_platform}_PROGRAM_SUFFIX}.${godot_target}")

if (godot_dev_build)
	set(__SUFFIX "${__SUFFIX}.dev")
endif()

if (godot_precision STREQUAL "double")
	set(__SUFFIX "${__SUFFIX}.double")
endif()

set(__SUFFIX "${__SUFFIX}.${PROCESSOR_ARCH_ALIAS}")

if (NOT godot_threads)
	set(__SUFFIX "${__SUFFIX}.nothreads")
endif()

if(NOT godot_extra_suffix STREQUAL "")
	set(__SUFFIX "${__SUFFIX}.${godot_extra_suffix}")
endif()

# Prepend extra suffix
target_property(PREPEND_STR global-env EXTRA_SUFFIX "${__SUFFIX}")

execute_python_method(cmake_methods get_version_info
	PYTHON_ARGS
		STR_VAR "module_version_string=MODULES_VERSION_STRING"
	OUTPUT_VARIABLE PYTHON_VERSION_INFO
)

if (godot_disable_3d)
	if (EDITOR_BUILD)
		message(FATAL_ERROR 
			"Build option 'disable_3d=yes' cannot be used for editor builds, "
			"but only for export templates.")
	endif()

	target_compile_definitions(global-env INTERFACE "_3D_DISABLED")
endif()

if (godot_disable_advance_gui)
	if (EDITOR_BUILD)
		message(FATAL_ERROR 
			"Build option 'disable_advanced_gui=yes' cannot be used for editor builds, "
			"but only for export templates."
		)
	endif()

	target_compile_definitions(global-env INTERFACE "ADVANCED_GUI_DISABLED")
endif()

if (godot_minizip)
	target_compile_definitions(global-env INTERFACE "MINIZIP_ENABLED")
endif()

if (godot_brotli)
	target_compile_definitions(global-env INTERFACE "BROTLI_ENABLED")
endif()

if (godot_threads)
	target_compile_definitions(global-env INTERFACE "THREADS_ENABLED")
endif()

add_env(global-libs-list)

add_subdirectory(core)
add_subdirectory(servers)
add_subdirectory(scene)
if (EDITOR_BUILD)
	add_subdirectory(editor)
endif()
add_subdirectory(drivers)
add_subdirectory(platform)
add_subdirectory(modules)
if (godot_tests)
	add_subdirectory(tests)
endif()
add_subdirectory(main)
add_subdirectory("platform/${godot_platform}")